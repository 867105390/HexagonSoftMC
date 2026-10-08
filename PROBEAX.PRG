'------------------------------------------------------------------------------
' File:        <MyTask>.prg
' Purpose:     Just an example of a module header
' Version:     1.00
' Author:      <MyFullName>
' Description:
' History:     YYYY-MM-DD  <MyShortCut>  V1.00
'              Created
'------------------------------------------------------------------------------

' module global "constants"

common shared TPro_DATA as double
common shared TPSignalCounter as long
common shared TPStatus as long
common shared TPStopTime as long

common shared TPStartTest as long = 1
common shared TPStart_Point as location of xyz = #{0,0,0}
common shared TPEnd_Point as location of xyz = #{100,100,0}

common shared TP_SEND as string

common shared probeEnable as long = 0
common shared lDummy as long

common shared TX as double
common shared TY as double
common shared TZ as double


common shared locStart as double
common shared newDest as double
common shared round_newDest as long

common shared x_revDir as long      'postive:1,negative:-1
common shared y_revDir as long      'postive:1,negative:-1
common shared z_revDir as long      'postive:1,negative:-1

' module global variables

dim shared x_back as double
dim shared y_back as double
dim shared z_back as double
dim shared bErrorInOnError as long

dim shared lPError as long


program 


OnError

catch 3042
  print "3042 in AX_Probe.prg"

  
'catch else
'  sleep 10 ' to eliminate tight loop
''  bErrorInOnError = 1
 'continuetask AX_PROBE.PRG
 print errornumber ,"   in AX_PROBE.prg"
end onError

  
  
    try
    Open "stoptime.DAT" Mode="w" as #1
  catch 5043
    Print "The Stream is already open, Closing and Reopening"
    close #1
    Open "stoptime.DAT" Mode="w" as #1
  end try

                  
      OnEvent TPSIGNAL sys.din.1010 = 1
           probeEnable = 1
           
           Stop x StopType=Immediate
                      
                                  
            TX = Tprobe_getPosition(x)/x.PFac
'           TY = Tprobe_getPosition(y)
'           TZ = Tprobe_getPosition(z)

            
'           TP_SEND = "*:"+"TX:"+STR$(TX)+";TY:"+STR$(TY)+";TZ:"+STR$(TZ)
'            
            Print "TP_SEND:" TX
            
            probeEnable = 0
            
           try  
                Proceed x ProceedType = CLEARMOTION                      
               catch else
                print "try to clear x error "
           end try                         
            
            
            if x.AttachedTo = "" then
              attach x
              sleep 10
            else
              try 
                detachfrom$ x File = x.AttachedTo
                sleep 10
                catch else
                print "detach x error"
              end try                
            end if 
            
            if SYS_OP_MODE = 1 then  
              call disableJog(tem_port,123)
              sleep 200
'              while not (JOG_X.PRG.state = 10 and JOG_Y.PRG.state = 10 and JOG_Z.PRG.state = 10)
'                sleep 1
'              end while
            end if 
 
'   
            try
               attach x
            catch 3173
                Stop x
                Proceed x ProceedType=CLEARMOTION
                Attach x
            catch else
                lPError = errornumber
           end try
            
                    
            move x x_revDir*20 abs=0 vcruise = 10
           
            
            detach x
            
            call enableJog(tem_port,124)
            sleep 200
'            while not (JOG_X.PRG.state=1 and JOG_Y.PRG.state=1 and JOG_Z.PRG.state=1)
'              sleep 1
'            end while  
'            

'            'Print #tpSocketDesc,TP_SEND 
'                        
'            call BackDistanceCalc
            
'            lPError = BackMove(x_back,y_back,z_back,Move_velocity)
            
'            if 0 = lError Then
'                while gxy.IsSettled <> 1
'                  sleep 1
'                end while
'               try 
'                  detach gxy
'               catch else
'                  Print "detach error"
'               end try
'               
'               if bErrorInOnError then 
'                  call  sendDeferredResponce(axRespFileDesc,axSeq,errornumber)
'               else
'                  call  sendDeferredResponce(axRespFileDesc,axSeq,0)
'               end if 'error in on error        
'            end if ' error
'            
'            if TPStartTest <> 0 then
'              Proceed gxyz ProceedType = NEXTMOTION
'            end if
            
'            EventOff TPSIGNAL           
      End OnEvent


    EventOn TPSIGNAL
    
      call TProbe_setInmode(x)
'      call TProbe_setInmode(y.Dadd)
'      call TProbe_setInmode(z.Dadd)
'      
      call TProbe_resetTriggerSetup(x)
'      call TProbe_resetTriggerSetup(y)
'      call TProbe_resetTriggerSetup(z)
     
      call TProbe_setTriggerSetup(x)
      
      

    
    while 1
'      call dir_Dection
      sleep 10
    end while
    
 
   
end program ' <MyTask>.prg


sub timeCalc(gr as generic group)
    TPStopTime = sys.Clock
    while gr.ismoving <> 3
        Sleep 1
    end while
    TPStopTime = sys.Clock - TPStopTime
    Print "Stop Time is:   ",TPStopTime
end sub

'sub BackDistanceCalc       'x:y:z = 1:1:1
'  
'  x_back = Back_Distance/sqrt(3)*x_dir
'  y_back = Back_Distance/sqrt(3)*y_dir
'  z_back = Back_Distance/sqrt(3)*z_dir
'
'end sub

function BackMove(byval xback as double,byval yback as double, byval zback as double,byval dValVelocity as double) as long
  
  move gxyz {x_back,y_back,z_back} abs = 0 Vcruise = dValVelocity
  waitformotion gxyz
  
end function


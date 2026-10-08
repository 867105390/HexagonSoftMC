'------------------------------------------------------------------------------
' File:        <MyTask>.prg
' Purpose:     探针测试程序
' Version:     1.00
' Author:      <MyFullName>
' Description:
' History:     YYYY-MM-DD  <MyShortCut>  V1.00
'              Created
'------------------------------------------------------------------------------

' module global "constants"


' module global variables

'起始点
common shared startPoint as location of xyz =#{-218.8934,-196.3677,-153.0766}

'接近点             
common shared approachPoint as location of xyz =#{-219.6934,-196.3677,-153.0766}
 
'触碰预设点 
common shared approachOffset as location of xyz  = #{-10,0,0}

'回退距离    
common shared backDis as double = 0.2

'触碰及回退速度                             
common shared touchVel as double = 5

'移动速度                              
common shared moveVel as double = 100

'触碰次数                             
common shared tpCounter as long = 100
                              
common shared actCounter as long = 0                                                               
common shared x_ports[1] as long
common shared y_ports[2] as long
common shared z_ports[3] as long

common shared TP_SEND as string
dim shared handleEnable as long = 0
common shared mc_timecnt as double =0.0

 

common shared TPTestEnable as long=1
dim shared lPError as long
 
program

  
   OnEvent TPSIGNALTest (sys.din.1010 = 0 and sys.din.2010 = 0 and sys.din.3010 = 0)                    
           BProbe = gxyz.setpoint                                                       
           Stop gxyz StopType=Immediate
           Proceed gxyz ProceedType = CLEARMOTION                      
'          print "StopPos: " gxyz.PFb                                                 
           TX = TprobeGetPosition(x)/x.PFac
           TY = TprobeGetPosition(y)/y.PFac
           TZ = TprobeGetPosition(z)/z.PFac           
           actCounter = actCounter+1           
        
           dirDecEnable = 1
           probeTrigger = 1
           handleEnable = 1
    End OnEvent 
    
       EventOn TPSIGNALTest
          
'        x_ports[1] = 6
'        y_ports[2] = 7
'        z_ports[3] = 8

'        try
'          Open "TP_X.DAT" Mode="w" as #x_ports[1]
'        catch 5043
'          Print "The Stream is already open, Closing and Reopening"
'          close #x_ports[1]
'          Open "TP_X.DAT" Mode="w" as #x_ports[1]
'        end try
'        
'        try
'          Open "TP_Y.DAT" Mode="w" as #y_ports[2]
'        catch 5043
'          Print "The Stream is already open, Closing and Reopening"
'          close #y_ports[2]
'          Open "TP_Y.DAT" Mode="w" as #y_ports[2]
'        end try
'        
'        try
'          Open "TP_Z.DAT" Mode="w" as #z_ports[3]
'        catch 5043
'          Print "The Stream is already open, Closing and Reopening"
'          close #z_ports[3]
'          Open "TP_Z.DAT" Mode="w" as #z_ports[3]
'        end try
        if SYS_OP_MODE = 1 then 
          call disablemcjog
          sleep 200
        end if
        

     attach gxyz
        mc_timecnt = sys.Clock
    
    while 1
    
      if handleEnable=0 and TPTestEnable= 1 then      
         try  
            Proceed gxyz ProceedType = CLEARMOTION                      
         catch else
            print "try to clear gxyz error "
         end try  
         call MoveSource
      end if   
      
      if  handleEnable  then   
 
'           TP_SEND = "TX:"+STR$(TX)+";TY:"+STR$(TY)+";TZ:"+STR$(TZ)
'                     
'           Print "TP_SEND:" TP_SEND
'           Print "***************************************"
'           Print #x_ports[1],STR$(TX)
'           Print #y_ports[2],STR$(TY)
'           Print #z_ports[3],STR$(TZ)
          
  
                     
           try  
                Proceed gxyz ProceedType = CLEARMOTION                      
           catch else
                print "try to clear gxyz error "
           end try  
           
           
           gxyz.BlendingFactor = 100          
           
           try
                         
              lPError = backGroupMove(backDis,touchVel)
                    
           catch else
              lPError = errornumber
           end try           
            
           if 0 = lPError then
            
               while gxyz.IsMoving<>0
                 sleep 1
               end while 
               Print "back movement done in test"              
               
           end if 
                
             
        
                          
                 
         if actCounter<tpCounter then       
           call MoveSource
         else
'           Print  #x_ports[1],"Finished"
'           Print  #y_ports[2],"Finished"
'           Print  #z_ports[3],"Finished"
'           Sleep 10
'           close #x_ports[1]
'           close #y_ports[2]
'           close #z_ports[3]
'           
       
          
           mc_timecnt = sys.Clock-mc_timecnt
           print "MC finished ";tpCounter " times is ";mc_timecnt/1000"s"          
           Print "TouchProbe test finished"
           
           try 
              detach gxyz
                
           catch else
                 Print "detach error"
           end try
            TPTestEnable=0
         end if
         
          handleEnable = 0  

      end if  
      sleep 1
  end while                       

end program ' <MyTask>.prg




function backGroupMove(byval dBackDistance as double,byval dBackVelocity as double) as long
  backGroupMove = 0
  try
      
      move gxyz dBackDistance*newDestUnitTest abs = 0 Vcruise = dBackVelocity
      waitformotion gxyz
'    end if
  catch else
      backGroupMove = user USR_GET_RECENT_ERROR(1,2,3)
    end try 
end function


sub MoveSource
 gxyz.BlendingFactor = 80
 move gxyz startPoint  abs =1 Vcruise = moveVel cp=0
     
 move gxyz approachPoint abs=1 vcruise = moveVel

 move gxyz approachOffset abs = 0 vcruise = touchVel
 waitformotion gxyz

end sub

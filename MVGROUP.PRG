'------------------------------------------------------------------------------
' File:        mvgroup.prg
' Purpose:     Move group server
' Version:     1.00
' Author:      <MyFullName>
' Description:
' History:     YYYY-MM-DD  <MyShortCut>  V1.00
'              Created
'------------------------------------------------------------------------------

' module global "constants"

'import comm.lib
' module global variables
common shared singal1 as long
common shared singal2 as long
common shared singal3 as long
common shared ERROR1 as long
common shared grNewTarget1 as long
common shared touchEnable1 as long
common shared pcmdRec as long
common shared tenable as long
common shared TPInSetBack as long = 0
common shared str_send_tp as string
common shared dirDecEnable as long
common shared  trigtime as long

common shared dTimeStap1 as double
common shared dTimeStap2 as double

common shared bSettleFlag as long = 0

'common shared drates as double

dim shared bErrorInOnError as long =0


program continue
dim lError as long
dim gG as generic group
dim timeCnt as double = 0.0
dim act_pe as double = 0.0
dim movementcounter as long = 0


OnError
  catch 19004
    print "19004"
    singal1 = 1
     print errornumber ,"   in mvgroup.prg"
  catch 65
    print "65"
    singal2 = 1
     print errornumber ,"   in mvgroup.prg"
  catch 3115
    print "3115"
    singal3 = 1
     print errornumber ,"   in mvgroup.prg"
catch else
  sleep 10 ' to eliminate tight loop
  bErrorInOnError = 1
 '' continuetask mvgroup.prg
 print errornumber ,"   in mvgroup.prg"
end onError


OnEvent TPINSET (SYS_OP_MODE = 2 and sys.din.1010 = 0 and sys.din.2010 = 0 and sys.din.3010 = 0 and probeEnable=1)    
     while trigtime<10 
        trigtime=trigtime+1
        sleep 1
     end while 
     if  sys.din.1010 = 0 and sys.din.2010 = 0 and sys.din.3010 = 0  then                                           
       Stop gxyz StopType=IMMEDIATE
       Proceed gxyz ProceedType = CLEARMOTION                    
       TX = TprobeGetPosition(x)/x.PFac
       TY = TprobeGetPosition(y)/y.PFac
       TZ = TprobeGetPosition(z)/z.PFac                                         
        
       dirDecEnable = 1
       probeTrigger = 1  'send touch postion to host           
       TPInSetBack = 1  'start back movement in Setpoint mode  
'     grNewTarget=0
'     touchEnable=0    
     end if                                          
End OnEvent    


OnEvent GROUPSTOP (grStop = 1)

    Stop gxyz StopType=IMMEDIATE
    print("software stop happens")
    bErrorInOnError = clearMotionAfterStop
    if bErrorInOnError <> 0 then
      bErrorInOnError = 1
    end if
	grNewTarget=0
End OnEvent

OnEvent CDetected sys.din.1009=1
  Stop gxyz StopType=IMMEDIATE
  bCollisionDetect = 1
  mvStandby = 1           
  
End OnEvent


       
EventOn TPINSET
EventOn GROUPSTOP
EventOn CDetected

' 
semaphoreGive(semMove)

while 1
'************************* Linear interpolation ************************* 
    if grNewTarget and not mvStandby Then    
    ' aquire motion semaphore
      while semaphoreTake(semMove,10) = 0 
        sleep 1
      end while
  ' move to new target
'      sleep 10
      bErrorInOnError = 0
      'start execute group motion
    '  Print "start gorup moving.................."
      timeCnt = sys.Clock
      movementcounter = movementcounter+1
      'send back to pc that already recieved cmmand. start to execute!      
            
      if IsDebug then
        print "Reference:";axSeq;"New target:";grTarget[1],grTarget[2],grTarget[3]
      end if  
      gG = systemgroup(axRef)
      try
          if gG.attachedto<>"MVGROUP.PRG" then
            try
              detachfrom x file = JOG_X.PRG
              detachfrom y file = JOG_Y.PRG
              detachfrom z file = JOG_Z.PRG
            catch else
            end try
            try
              attach gG
            catch 3173
              Stop gG
              Proceed gG ProceedType=CLEARMOTION
              Attach gG
            catch else
              lError = errornumber
            end try
          end if 
                  
          cmdFlag=0 
           
          lError = mvGroup(axSeq, gG, grTarget, grVel, grAbs)    
          ERROR1 = lError
      catch else
        lError = errornumber
      end try 
       
      if IsDebug then
        print "Reference:";axSeq;"New target ack/nak:";grTarget[1],grTarget[2],grTarget[3];" Error:";lError
      end if
      
'      print "#Before send grMoveAbsolute sendResponce#",axSeq,"time is :",sys.clock
        call sendResponce(axRespFileDesc,axSeq,lError)
'      print "#After send grMoveAbsolute sendResponce#",axSeq,"time is :",sys.clock
           
      if 0 = lError Then
          while gG.Ismoving <> 0
            sleep 1
          end while
          
         dTimeStap1 = sys.clock       
         while not gG.isSettled
            sleep 1
          end while  

'          gSTART:
'          while not abs(x.pe) <= x.pesettle and abs(y.pe) <= y.pesettle and abs(z.pe) <= z.pesettle 
'              sleep 1
''            print("waiting for gxyz to enter pesettle")
'          end while
'          
'          sleep 15
'          
'            if abs(x.pe) <= x.pesettle and abs(y.pe) <= y.pesettle and abs(z.pe) <= z.pesettle then
'              print("gxyz is stable inside pesettle, continue...")
'              bSettleFlag = 1
'            else
'              print("waiting for gxyz to enter pesettle")
'            goto gSTART
'          end if 
          
          
          dTimeStap2 = sys.clock - dTimeStap1
          print "The settling time is ";dTimeStap2
    '     try 
    '        detach gG
    '     catch else
    '        Print "detach error"
    '     end try
         
         if IsDebug then
            print "Reference:";axSeq;"target executed:";grTarget[1],grTarget[2],grTarget[3];" Error:";errornumber
         end if 
         
         if Not TPInSetBack and Not bCollisionDetect then 
         
             if bErrorInOnError then           
                call  sendDeferredResponce(axRespFileDesc,axSeq,errornumber)
'                print "#sendDeferredResponce error#",axSeq
             else 
'                sleep 100 
'                Print "#Before send grMoveAbsolute sendDeferredResponce 0#",axSeq,"time is :",sys.clock       
                call  sendDeferredResponce(axRespFileDesc,axSeq,0)
'                Print "#After send grMoveAbsolute sendDeferredResponce 0#",axSeq,"time is :",sys.clock
                tenable=1    'enable timer in MODECH.PRG
                sendflag=1
                        
             end if 'error in on error
          end if   
      else
        print "Error";lError     
        sleep 10       
      end if ' error
      
      grNewTarget = 0
      
      timeCnt = sys.Clock-timeCnt
      act_pe = grTarget[1] - gxyz.PFb{1}
      Print "act_pe",act_pe,"timeCnt",timeCnt
   '   Print "group movement exectuted  time is: ",timeCnt,"ms"
      
      semaphoreGive(semMove)
'    else      
'      sleep 1' no new target - wait a bit  
    end if
'********************************************************************

''************************* Circle interpolation ********************

if moveCircleEnable and not mvStandby then
    while semaphoreTake(semMove,10) = 0 
      sleep 1
    end while
    if IsDebug then
        print "Reference:";axSeq;"Circle target:";\
        grCircleMid[1],grCircleMid[2],grCircleMid[3],grCircleEnd[1],grCircleEnd[2],grCircleEnd[3]
    end if  
      gG = systemgroup(axRef)
      try
          if gG.attachedto<>"MVGROUP.PRG" then
            try
              detachfrom x file = JOG_X.PRG
              detachfrom y file = JOG_Y.PRG
              detachfrom z file = JOG_Z.PRG
            catch else
            end try
            try
              attach gG
            catch 3173
              Stop gG
              Proceed gG ProceedType=CLEARMOTION
              Attach gG
            catch else
              lError = errornumber
            end try
          end if 
                  
          cmdFlag=0 
           
          lError = mvGroupCircle(axSeq, gG, grCircleMid,grCircleEnd, grVel)    
          ERROR1 = lError
      catch else
        lError = errornumber
      end try 
       
      if IsDebug then
        print "Reference:";axSeq;"New Circle target ack/nak:";\
        grCircleMid[1],grCircleMid[2],grCircleMid[3],grCircleEnd[1],grCircleEnd[2],grCircleEnd[3];" Error:";lError
      end if
      
'      print "#Before send grMoveCircle sendResponce#",axSeq,"time is :",sys.clock
        call sendResponce(axRespFileDesc,axSeq,lError)
'      print "#After send grMoveCircle sendResponce#",axSeq,"time is :",sys.clock
           
      if 0 = lError Then
          while gG.Ismoving <> 0
            sleep 1
          end while
                   
    '     try 
    '        detach gG
    '     catch else
    '        Print "detach error"
    '     end try
         
         if IsDebug then
            print "Reference:";axSeq;"target executed:";\
            grCircleMid[1],grCircleMid[2],grCircleMid[3],grCircleEnd[1],grCircleEnd[2],grCircleEnd[3];" Error:";errornumber
         end if 
         
         if Not TPInSetBack then 
         
             if bErrorInOnError then           
                call  sendDeferredResponce(axRespFileDesc,axSeq,errornumber)
                print "#sendDeferredResponce error#",axSeq
             else 
'                sleep 100 
                Print "#Before send grMoveCircle sendDeferredResponce 0#",axSeq,"time is :",sys.clock       
                call  sendDeferredResponce(axRespFileDesc,axSeq,0)
                Print "#After send grMoveCircle sendDeferredResponce 0#",axSeq,"time is :",sys.clock

                        
             end if 'error in on error
          end if   
      else
        print "Error";lError     
        sleep 10       
      end if ' error
    
    moveCircleEnable=0
    semaphoreGive(semMove)
end if
''*******************************************************************

'**********************touch probe mode movement*********************
  if touchEnable then
'       sleep 10 
        while semaphoreTake(semMove,10) = 0 
          sleep 1
        end while
       sendflag=0 
       
       if IsDebug then
          print "Reference:";axSeq;"New touch target:";touchPreTarget[1],touchPreTarget[2],touchPreTarget[3],touchTarget[1],touchTarget[2],touchTarget[3]
       end if  
       gG = systemgroup(axRef)      
       try
        if gG.attachedto<>"MVGROUP.PRG" then
          try
            detachfrom x file = JOG_X.PRG
            detachfrom y file = JOG_Y.PRG
            detachfrom z file = JOG_Z.PRG
          catch else
          end try
          try
            attach gG
          catch 3173
            Stop gG
            Proceed gG ProceedType=CLEARMOTION
            Attach gG
          catch else
            lError = errornumber
          end try
        end if        
        
        gG.BlendingFactor = 80
    
        lError = mvGroupTouch(axSeq, gG, touchPreTarget,touchTarget,touchPreVel,touchVel)

    catch else
      lError = errornumber
    end try
      
    if IsDebug then
      print "Reference:";axSeq;"New target touch ack/nak:";touchPreTarget[1],touchPreTarget[2],touchPreTarget[3];" Error:";lError
    end if 
     
'    print "#Before send moveTouch sendResponce#",axSeq,"time is :",sys.clock    
    call sendResponce(axRespFileDesc,axSeq,lError)
'    print "#After send moveTouch sendResponce#",axSeq,"time is :",sys.clock
    
    if 0 = lError Then
        while gG.Ismoving <> 0
          sleep 1
        end while 
        
        if Not TPInSetBack then                      
          if bErrorInOnError then 
'             print "#sendDeferredResponce error#",axSeq
              call  sendDeferredResponce(axRespFileDesc,axSeq,errornumber)
           else 
'              sleep 100
'              print "#Before send moveTouch sendDeferredResponce 0 #",axSeq,"time is :",sys.clock             
              call  sendDeferredResponce(axRespFileDesc,axSeq,0)
'              print "#After send moveTouch sendDeferredResponce 0 #",axSeq,"time is :",sys.clock 
              sendflag=1               
          end if 'error in on error
        end if
          
     else
        print "Error";lError     
        sleep 10       
     end if
     
     touchEnable=0
     gG.BlendingFactor = 100
     semaphoreGive(semMove)    
'  else
'    sleep 1
  end if
  
'*****************Send Touch Position(IPP mode)*************************

  if probeTrigger then
      str_send_tp = "TX:"+STR$(TX)+";TY:"+STR$(TY)+";TZ:"+STR$(TZ)+";i;"+ \
                  STR$(newDestUnit{1})+";j;"+STR$(newDestUnit{2})+";k;"+STR$(newDestUnit{3})
      Call sendResponceString(tem_port,999,str_send_tp)
      probeTrigger=0
      Print "send TP_Pos time is :",axSeq,sys.clock
  end if
   
'***********************************************************************
  
'*****************Touch Back Move **************************************
   if TPInSetBack then
         
      while semaphoreTake(semMove,10) = 0 
        sleep 1
      end while 
        
       lError = TPBackGroupMove(backDistance,backMoveVelocity) 
       
       if 0 = lError then       
        
           while gG.Ismoving <> 0
                sleep 1
           end while 
           motStart=0       
           if bErrorInOnError then                
                call  sendDeferredResponce(axRespFileDesc,axSeq,errornumber)
'                print "#sendDeferredResponce error#",axSeq
           else
'                sleep 100
'               print "#Before send moveTouch sendDeferredResponce 0 #",axSeq,"time is :",sys.clock  
                call  sendDeferredResponce(axRespFileDesc,axSeq,0)
'               print "#After send moveTouch sendDeferredResponce 0 #",axSeq,"time is :",sys.clock  
                sendflag=1               
           end if 'error in on error

        else 
           Print "Touch Back Move Error: ",lError
        end if
        TPInSetBack = 0
        semaphoreGive(semMove) 
   end if    
'********************************************************************* 
' emegency stop and return back function 
  if bCollisionDetect=1 then
'    call sendResponceString(axRespFileDesc,axSeq,"collision!")

    while semaphoreTake(semMove,10) = 0 or gxyz.Ismoving <> 0
      sleep 1
    end while

    while gxyz.ismoving<>0
      sleep 1
    end while

    Proceed gxyz ProceedType = CLEARMOTION

    lError = collisionBackMove
    if 0 = lError then       
      while gG.Ismoving <> 0
          sleep 1
      end while
      bCollisionDetect = 2
'      
      if bErrorInOnError then                
        call sendDeferredResponce(axRespFileDesc,axSeq,errornumber)
      else
        call sendDeferredResponce(axRespFileDesc,axSeq,0)      
      end if 'error in on error
    else
      Print "Collision Back Move Error: ",lError
    end if
    semaphoreGive(semMove)
  end if

'   locStart = gxyz.setpoint
   sleep 1 
 ' semaphoreGive(semMove)
end while  
  
end program ' <MyTask>.prg

function mvGroup(byval seqNum as long, gG as generic group, dPos[*] as double, byval dValVelocity as double, byval absl as long) as long
  dim dValhandle as long
  dim drates as double
  
    mvGroup = 0
    try   
    motStart=1
    call calcRate(gG, drates, dPos[1], dPos[2])
    print "drates is :",drates 
    
    Move gG  {dPos[1],dPos[2],dPos[3]} VelocityCruise=dValVelocity Jrate=drates abs = absl  starttype=3 'PlcMotionStatus=dValhan    Move gG  {dPos[1],dPos[2],dPos[3]} VelocityCruise=dVadle
    
    motStart=0
    catch else
      mvGroup = user USR_GET_RECENT_ERROR(1,2,3)
    end try

end function


function TPBackGroupMove(byval dBackDistance as double,byval dBackVelocity as double) as long
  TPBackGroupMove = 0 
  try 
       move gxyz #{touchPreTarget[1],touchPreTarget[2],touchPreTarget[3]} abs = 1 Vcruise = dBackVelocity
'      move gxyz dBackDistance*newDestUnit abs = 0 Vcruise = dBackVelocity 'starttype=immediate
  catch else
      TPBackGroupMove = user USR_GET_RECENT_ERROR(1,2,3)
  end try 
end function


function mvGroupTouch(byval seqNum as long,gG as generic group,dtouchPreTarget[*] as double,dtouchTarget[*] as double,byval dPreVelocity as double,byval dVelocity as double) as long
  
  mvGroupTouch=0
  motStart=1
  try
    move gG {touchPreTarget[1],touchPreTarget[2],touchPreTarget[3]} abs=1 Vcruise = dPreVelocity CP=0
     
    move gG {touchTarget[1],touchTarget[2],touchTarget[3]} abs=1 Vcruise=dVelocity jerk=5000
  catch else
    mvGroupTouch = user USR_GET_RECENT_ERROR(1,2,3)
  end try
end function


function mvGroupCircle(byval seqNum as long,gG as generic group,dMidCircle[*] as double,dEndCircle[*] as double,byval dVelocity as double) as long
  mvGroupCircle=0
  try
  Circle gG CirclePoint={dMidCircle[1],dMidCircle[2],dMidCircle[3]} TargetPoint={dEndCircle[1],dEndCircle[2],dEndCircle[3]} Vcruise=dVelocity
  catch else
    mvGroupCircle = user USR_GET_RECENT_ERROR(1,2,3)
  end try
end function


function clearMotionAfterStop as long
  clearMotionAfterStop = 0

  try
    while gxyz.Ismoving <> 0
      sleep 1
    end while
    Proceed gxyz ProceedType = CLEARMOTION
    grstop = 0

  catch else
    clearMotionAfterStop = user USR_GET_RECENT_ERROR(1,2,3)
  end try
end function


function collisionBackMove as long 

  try 
    move gxyz {-vx*10,-vy*10,-vz*10} abs=0 vcruise=20
  catch else
    collisionBackMove = user USR_GET_RECENT_ERROR(1,2,3)
  end try
end function

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

'import comm.lib
' module global variables


dim shared bErrorInOnError as long =0
program continue
dim lError as long
dim gA as generic axis

OnError
catch else
  sleep 10 ' to eliminate tight loop
  bErrorInOnError = 1
  continuetask mvaxes.prg
end onError
' 
semaphoreGive(semMove)
while 1
' aquire motion semaphore
'  while semaphoreTake(semMove, 100) = 0 
 '   sleep 1
' end while
' move to new target  
  if axNewTarget Then
    bErrorInOnError = 0
    if IsDebug then
      print "Reference:";axSeq;"New target:";axTarget
    end if  
    gA = systemaxis(axRef)
    try
      attach gA
    
    catch 3173
      Stop gA
      Proceed gA ProceedType=CLEARMOTION
      Attach gA
    catch else
      lError = errornumber
    end try  

      lError = mvAxis(axSeq, gA, axTarget, axVel, axAbs)
            
    if IsDebug then
      print "Reference:";axSeq;"New target ack/nak:";axTarget;" Error:";lError
    end if  
    call sendResponce(axRespFileDesc,axSeq,lError)
    if 0 = lError Then
      while ga.ismoving
        sleep bus[0].cycletime
      end while
    detach gA
    if IsDebug then
      print "Reference:";axSeq;"target executed:";axTarget;" Error:";errornumber
    end if  
      if bErrorInOnError then 
        call sendDeferredResponce(axRespFileDesc,axSeq,errornumber)
      else
      call  sendDeferredResponce(axRespFileDesc,axSeq,0)
      end if 'error in on error        
    end if ' error
    axNewTarget = 0
  '  semaphoreGive(semMove)
  else
    sleep 2' no new target - wait a bit  
    
  end if
 ' semaphoreGive(semMove)
end while  
  
end program ' <MyTask>.prg

function mvAxis(byval seqNum as long, gA as generic axis, byval dValPosition as double, byval dValVelocity as double, byval absl as long) as long
dim dValhandle as long
'dValhandle = PlcMotionStatusCreate
    mvAxis = 0
    try
      Move gA  dValPosition    VelocityCruise=dValVelocity abs = absl 'PlcMotionStatus=dValhandle
    catch else
      mvAxis = user USR_GET_RECENT_ERROR(1,2,3)
    end try
'    PlcMotionStatusDestroy(dValhandle)
end function


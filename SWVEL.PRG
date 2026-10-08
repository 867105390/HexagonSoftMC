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


' module global variables

common shared signal_real as long =0


 
program  continue
while sys_simulated = 1
  sleep 100
end while

onevent getevent_up sys.din.2003 = 1
 print "getevent_up is triggerd"
 signal_real=1

end onevent


onevent getevent_down sys.DIn.2003 = 0
   print "getevent_down is triggerd"
   signal_real=0

end onevent



eventon getevent_up
eventon getevent_down

  while 1  

    call JOG_SWITCH_SPEED
    sleep 1 
  end while

end program ' <MyTask>.prg



sub JOG_SWITCH_SPEED

    if signal_real then
      while signal_real
        sleep 1 
      end while
        if NOT JOG_SPEED_SWITCH_PRESSED then
           JOG_SWITCH_SPEED_SIGNAL = 1
           JOG_SPEED_SWITCH_PRESSED = 1
           JOG_SPEED = JOG_FAST_SPEED
          
         else
            JOG_SWITCH_SPEED_SIGNAL = 0
            JOG_SPEED_SWITCH_PRESSED = 0
            JOG_SPEED = JOG_SLOW_SPEED        
          
        end if
      
    end if



end sub

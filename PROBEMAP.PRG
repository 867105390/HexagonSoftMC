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
common shared probeHwEnable as long

program continue

  call TProbeSetInmode(x,11)
  call TProbeSetInmode(y,11)
  call TProbeSetInmode(z,11)
        
  call TProbeResetTriggerSetup(x)
  call TProbeResetTriggerSetup(y)
  call TProbeResetTriggerSetup(z)
       
  call TProbeSetTriggerSetup(x)
  call TProbeSetTriggerSetup(y)
  call TProbeSetTriggerSetup(z)

end program ' <MyTask>.prg

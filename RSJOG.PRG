'------------------------------------------------------------------------------
' File:        <MyTask>.prg
' Purpose:     This program is enable serial jog
' Version:     1.00
' Author:      <MyFullName>
' Description:
' History:     YYYY-MM-DD  <MyShortCut>  V1.00
'              Created
'------------------------------------------------------------------------------

' module global "constants"


' module global variables


program continue
while sys_simulated = 1
  sleep 100
end while

while 1 
 
  if JOG_TYPE=2 then 
   try    
     load ReceHex.PRG
     load SendHex.PRG
     load BtonMap.PRG 
     print "SR JOG Box disabled"
     print "RS JOG Box enabled"
     
   catch else
   end try
  end if
  
  if JOG_TYPE=1 then
    try
     killtask ReceHex.PRG
     unload ReceHex.PRG
     killtask SendHex.PRG
     unload SendHex.PRG
     killtask BtonMap.PRG 
     unload BtonMap.PRG
     print "RS JOG Box disabled"
     print "SR JOG Box enabled"
   catch else
   end try
  end if
 sleep 10
end while

end program ' <MyTask>.prg

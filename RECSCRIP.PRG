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


program

Record Motion.rec 10000 Gap = 1 RecData = x.pcmd, x.pfb,sys.din.1000,sys.din.1001,ec_pdo_read(1,0x6040,0),ec_pdo_read(1,0x6041,0),x.CCmd,x.cfb,ec_pdo_read(1,0x60fd,0),x.FMode

while NOT x.pfb>0
 sleep 1
end while
RecordOn
sleep 20000
recordOff



end program ' <MyTask>.prg

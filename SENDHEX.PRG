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


common shared sendCount as long = 0


Program continue
  
  
  
'  try 
'    close #2
'  catch else
'
'  end try
'
'  Open COM2 BaudRate=115200 Parity=0 DataBits=8 StopBit=1 XOnOff=1 As #2
  
  while true
  
    if LED_H <= 255 then
      if LED_H <= 255 then 
        Txd[1] = 0xFF   'head frame
        Txd[2] = 0x01 
        Txd[3] = 0x00
        Txd[4] = LED_H 
        Txd[5] = LED_L
        Txd[6] = DigtTubeDisplay[1] 
        Txd[7] = DigtTubeDisplay[2]
        Txd[8] = DigtTubeDisplay[3]
        Txd[9] = DigtTubeDisplay[4]
        Txd[10] = sendCheckSum
        Txd[11] = 0xA5  'tail frame 
      end if  
     end if  
   
      PRINT #4,CHR$(Txd[1]);CHR$(Txd[2]);CHR$(Txd[3]);CHR$(Txd[4]);CHR$(Txd[5]);CHR$(Txd[6]);\
               CHR$(Txd[7]);CHR$(Txd[8]); CHR$(Txd[9]); CHR$(Txd[10]); CHR$(Txd[11]);  
      
      sleep 25
           

      
   end while

End Program
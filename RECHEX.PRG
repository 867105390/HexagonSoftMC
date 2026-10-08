'------------------------------------------------------------------------------
' File:        <MyTask>.prg
' Purpose:     Just an example of a module header
' Version:     1.00
' Author:      <MyFullName>
' Description: softMC received Hex data from serial jog box
' History:     YYYY-MM-DD  <MyShortCut>  V1.00
'              Created
'------------------------------------------------------------------------------

common shared str1 as string
common shared iteration_counter as long = 0
common shared time_counter as long = 0
common shared ldummy as long
common shared TEMP[14] as long
common shared count as long

Program

dim IDX as long

  try 
    close #2
  catch else

  end try

  Open COM2 BaudRate=115200 Parity=0 DataBits=8 StopBit=1 XOnOff=1 As #2
  
   
 
  while 1
'
'  while (loc(2) < 3) and (time_counter < 120) ' allow 120 seconds for system start up to complete
'    sleep 1000
'    time_counter = time_counter +1
'  end while
  

'while 1
  
    ldummy = loc(2)
  
    if ldummy>=14 then
      ldummy=14
    end if  
  
    FOR IDX = 1 TO ldummy
      TEMP[IDX] = ASC(INPUT$(1,#2))
    NEXT IDX
     
    sleep 20
    
  end while

  
'  ldummy=0

  print "done" 
  sleep 100

'  close #2

End Program



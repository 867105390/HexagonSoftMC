'------------------------------------------------------------------------------
' File:        <MyTask>.prg
' Purpose:     Just an example of a module header
' Version:     1.00
' Author:      <MyFullName>
' Description: Send Touch position in JOG mode
' History:     YYYY-MM-DD  <MyShortCut>  V1.00
'              Created
'------------------------------------------------------------------------------

' module global "constants"


' module global variables
common shared TP_SEND as string
dim shared is_connected as long =0


program continue

 

  
while 1
  
    str_send_tp = "TX:"+STR$(TX)+";TY:"+STR$(TY)+";TZ:"+STR$(TZ)+";i;"+ \
                  STR$(newDestUnit{1})+";j;"+STR$(newDestUnit{2})+";k;"+STR$(newDestUnit{3})
                    
    
  if SYS_OP_MODE=1 and probeTrigger= 1 then
     Call sendResponceString(tem_port,999,str_send_tp)
     TP_SEND = "*:"+"TX:"+STR$(TX)+";TY:"+STR$(TY)+";TZ:"+STR$(TZ)+ \
     ";i:"+ STR$(newDestUnit{1})+";j;"+STR$(newDestUnit{2})+";k;"+STR$(newDestUnit{3})  
              
'     Print "TP_SEND:" TP_SEND
     Print "send TP_Pos time is :",axSeq,sys.clock
     Print "***********************************************"
     probeTrigger = 0
  end if
  
 sleep 1
 end while
 

end program



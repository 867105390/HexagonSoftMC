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
''--------------- LED_H Falgs ------------------------------
'common shared Key_H_Buf as long
'common shared LED_H_TEMP[8] as long
'common shared Led_H_Status[8] as long
'common shared newKey_H_Staus[8] as long
'common shared oldKey_H_Staus[8] as long
'common shared Key_H_Status[8] as string
'common shared Bin_H_Count as long
'common shared Bin_H_Temp as string
''--------------- LED_L Falgs ------------------------------
'common shared Key_L_Buf as long
'common shared LED_L_TEMP[8] as long
'common shared Led_L_Status[8] as long
'common shared newKey_L_Staus[8] as long
'common shared oldKey_L_Staus[8] as long
'common shared Key_L_Status[8] as string
'common shared Bin_L_Count as long
'common shared Bin_L_Temp as string


program continue
      
   dim index as long
     
   while 1    
      
      Call GetHighBit
      Call GetLowBit
      Call DigtTubeDisplayVel
      
      for index=1 to 8      
        newKey_H_Staus[index]=VAL(Key_H_Status[index]) 
        newKey_L_Staus[index]=VAL(Key_L_Status[index])                      
      next index
    
    '-------------------------Low Speed ------------------------            
      if (newKey_L_Staus[1]=0 and oldKey_L_Staus[1]=1) then               
        Led_L_Status[1]=NOT Led_L_Status[1]     
      end if
      oldKey_L_Staus[1]=newKey_L_Staus[1]
      if Led_L_Status[1] then
        LED_L_TEMP[1]=1
        JOG_SPEED_FACTOR=0.2
        Led_L_Status[2]=0
        Led_L_Status[3]=0
      else
        LED_L_TEMP[1]=0
      end if         
 
    '-----------------------------------------------------------
    
    '-------------------------Middle Speed ---------------------           
      if (newKey_L_Staus[2]=0 and oldKey_L_Staus[2]=1) then               
        Led_L_Status[2]=NOT Led_L_Status[2]     
      end if
      oldKey_L_Staus[2]=newKey_L_Staus[2]
      if Led_L_Status[2] then
        LED_L_TEMP[2]=2
        JOG_SPEED_FACTOR=0.5
        Led_L_Status[1]=0
        Led_L_Status[3]=0
      else
        LED_L_TEMP[2]=0
      end if         
 
    '-----------------------------------------------------------
    
    '-------------------------High Speed -----------------------           
      if (newKey_L_Staus[3]=0 and oldKey_L_Staus[3]=1) then               
        Led_L_Status[3]=NOT Led_L_Status[3]     
      end if
      oldKey_L_Staus[3]=newKey_L_Staus[3]
      if Led_L_Status[3] then
        LED_L_TEMP[3]=4
        JOG_SPEED_FACTOR=1
        Led_L_Status[1]=0
        Led_L_Status[2]=0
      else
        LED_L_TEMP[3]=0
      end if         
 
    '-----------------------------------------------------------
    
    '-------------------------Z Down ---------------------------               
      if newKey_L_Staus[4] and NOT Led_H_Status[2] then   'Z is not locked 
        LED_L_TEMP[4]=8
      else
        LED_L_TEMP[4]=0
      end if
    '-----------------------------------------------------------
    
    '-------------------------Z Up ------------------------------
      if newKey_L_Staus[5] and NOT Led_H_Status[2] then 
        LED_L_TEMP[5]=16
      else
        LED_L_TEMP[5]=0
      end if
    '-----------------------------------------------------------
    
    '-------------------------X Left ---------------------------
      if newKey_L_Staus[6] and NOT Led_L_Status[8] then 
        LED_L_TEMP[6]=32
      else
        LED_L_TEMP[6]=0
      end if
    '-----------------------------------------------------------
    
    '-------------------------X Right -------------------------
      if newKey_L_Staus[7] and NOT Led_L_Status[8] then 
        LED_L_TEMP[7]=64
        JOG_MOVE_X_SIGNAL=1
      else
        LED_L_TEMP[7]=0
      end if
    '-----------------------------------------------------------
    
     '-------------------------X Lock ---------------------           
      if (newKey_L_Staus[8]=0 and oldKey_L_Staus[8]=1) then               
        Led_L_Status[8]=NOT Led_L_Status[8]     
      end if
      oldKey_L_Staus[8]=newKey_L_Staus[8]
      if Led_L_Status[8] then
        LED_L_TEMP[8]=128
        JOG_X_LOCK=0
      else
        LED_L_TEMP[8]=0
        JOG_X_LOCK=1
      end if         
 
    '-----------------------------------------------------------
    
    
    
    '-------------------------Y Lock ----------------------------             
      if (newKey_H_Staus[1]=0 and oldKey_H_Staus[1]=1) then               
        Led_H_Status[1]=NOT Led_H_Status[1]     
      end if
      oldKey_H_Staus[1]=newKey_H_Staus[1]
      if Led_H_Status[1] then
        LED_H_TEMP[1]=1
        JOG_Y_LOCK=0
      else
        LED_H_TEMP[1]=0
        JOG_Y_LOCK=1
      end if         
 
    '--------------------------------------------------------------
    
    '------------------------Z Lock -------------------------------  
      if (newKey_H_Staus[2]=0 and oldKey_H_Staus[2]=1) then               
        Led_H_Status[2]=NOT Led_H_Status[2]      
      end if
      oldKey_H_Staus[2]=newKey_H_Staus[2]
      if Led_H_Status[2] then
        LED_H_TEMP[2] =2
        JOG_Z_LOCK=0
      else
        LED_H_TEMP[2] =0
        JOG_Z_LOCK=1
      end if       
  
    '-------------------------Y Forward---------------------------------- 
      if newKey_H_Staus[3] and NOT Led_H_Status[1] then 
        LED_H_TEMP[3]=4
      else
        LED_H_TEMP[3]=0
      end if
   '----------------------------------------------------------------
   
   '-------------------------F1 ------------------------------------ 'JOG mode enable   
     if SYS_OP_MODE = 1 then 
'        if (newKey_H_Staus[4]=0 and oldKey_H_Staus[4]=1) then              
'          Led_H_Status[4]=NOT Led_H_Status[4]      
'        end if
'        oldKey_H_Staus[4]=newKey_H_Staus[4]
'        if Led_H_Status[4] then
'          LED_H_TEMP[4] =8
'        else
'          LED_H_TEMP[4] =0
'        end if 
         
      end if
      
      if gxyz.En=1 then
         LED_H_TEMP[4] =8
         
      end if
      if gxyz.En=0 then
         LED_H_TEMP[4] =0
      end if   
  '------------------------------------------------------------------
  
  '-------------------------F2 --------------------------------------  
      if (newKey_H_Staus[5]=0 and oldKey_H_Staus[5]=1) then               
        Led_H_Status[5]=NOT Led_H_Status[5]      
      end if
      oldKey_H_Staus[5]=newKey_H_Staus[5]
      if Led_H_Status[5] then
        LED_H_TEMP[5] =16
      else
        LED_H_TEMP[5] =0
      end if       
  '------------------------------------------------------------------
  
  '-------------------------F3 --------------------------------------   
      if (newKey_H_Staus[6]=0 and oldKey_H_Staus[6]=1) then               
        Led_H_Status[6]=NOT Led_H_Status[6]      
      end if
      oldKey_H_Staus[6]=newKey_H_Staus[6]
      if Led_H_Status[6] then
        LED_H_TEMP[6] =32
      else
        LED_H_TEMP[6] =0
      end if       
  '------------------------------------------------------------------
  
  '-------------------------Y Back ----------------------------------   
       if newKey_H_Staus[7] and NOT Led_H_Status[1] then 
        LED_H_TEMP[7]=64
      else
        LED_H_TEMP[7]=0
      end if
  '------------------------------------------------------------------
  
  '-------------------------MANUAL LED-------------------------------   
      if (newKey_H_Staus[8]=0 and oldKey_H_Staus[8]=1) then               
        Led_H_Status[8]=NOT Led_H_Status[8]      
      end if
      oldKey_H_Staus[8]=newKey_H_Staus[8]
      if Led_H_Status[8] then
        LED_H_TEMP[8] =0
      else
        LED_H_TEMP[8] =0
      end if  
      
      if SYS_OP_MODE=1 then
        LED_H_TEMP[8] =128
      end if 
      if SYS_OP_MODE=2 then
        LED_H_TEMP[8] =0
      end if   
  '------------------------------------------------------------------
     
     if LEN(HEX$(TEMP[4]))>=2 then
      XPos=VAL("0x"+HEX$(TEMP[3])+HEX$(TEMP[4]))
     else
      XPos=VAL("0x"+HEX$(TEMP[3])+"0"+HEX$(TEMP[4]))
     end if   
     
     XJogFactor=(XPos-2048)/1792
     
     if LEN(HEX$(TEMP[6]))>=2 then
      YPos=VAL("0x"+HEX$(TEMP[5])+HEX$(TEMP[6]))
     else
      YPos=VAL("0x"+HEX$(TEMP[5])+"0"+HEX$(TEMP[6]))
     end if
     
     YJogFactor=(2048-YPos)/1792
     
     if LEN(HEX$(TEMP[8]))>=2 then
      ZPos=VAL("0x"+HEX$(TEMP[7])+HEX$(TEMP[8]))
     else
      ZPos=VAL("0x"+HEX$(TEMP[7])+"0"+HEX$(TEMP[8]))
     end if
     
     ZJogFactor=(ZPos-2048)/1792
     
     if LEN(HEX$(TEMP[12]))>=2 then
      Enc=VAL("0x"+HEX$(TEMP[11])+HEX$(TEMP[12]))
     else
      Enc=VAL("0x"+HEX$(TEMP[11])+"0"+HEX$(TEMP[12]))
     end if
     
     JogVelSetFactor=Enc/4095
     
     JOG_SPEED_ACTUAL=JOG_SPEED_MAX*JogVelSetFactor
    
  
      LED_H=LED_H_TEMP[1]+LED_H_TEMP[2]+LED_H_TEMP[3]+LED_H_TEMP[4]+LED_H_TEMP[5]+\
            LED_H_TEMP[6]+LED_H_TEMP[7]+LED_H_TEMP[8]
      
      LED_L=LED_L_TEMP[1]+LED_L_TEMP[2]+LED_L_TEMP[3]+LED_L_TEMP[4]+LED_L_TEMP[5]+\
            LED_L_TEMP[6]+LED_L_TEMP[7]+LED_L_TEMP[8]
      
      sleep 25
       
    end while


end program ' <MyTask>.prg


sub GetHighBit
  
  dim index1 as long 
  dim index2 as long
  
  Key_H_Buf=TEMP[9]  
  Bin_H_Temp=BIN$(Key_H_Buf)
  Bin_H_Count=LEN(Bin_H_Temp)
'  print Bin_H_Count
  
  for index1=1 to Bin_H_Count
    Key_H_Status[index1]=RIGHT$(Bin_H_Temp,1)
    Bin_H_Temp =LEFT$(Bin_H_Temp,Bin_H_Count-index1) 
'    print index1 ,Key_H_Status[index1] 
  next index1
  
  if Bin_H_Count<8 then
  for index2=Bin_H_Count+1 to 8
    Key_H_Status[index2]="0"
'    print index2 ,Key_H_Status[index2] 
  next index2
end if 
   
end sub


sub GetLowBit
  
  dim index1 as long 
  dim index2 as long
  
  Key_L_Buf=TEMP[10]  
  Bin_L_Temp=BIN$(Key_L_Buf)
  Bin_L_Count=LEN(Bin_L_Temp)
'  print Bin_L_Count
  
  for index1=1 to Bin_L_Count
    Key_L_Status[index1]=RIGHT$(Bin_L_Temp,1)
    Bin_L_Temp =LEFT$(Bin_L_Temp,Bin_L_Count-index1) 
'    print index1 ,Key_H_Status[index1] 
  next index1
  
  if Bin_L_Count<8 then
  for index2=Bin_L_Count+1 to 8
    Key_L_Status[index2]="0"
'    print index2 ,Key_L_Status[index2] 
  next index2
  end if 
   
end sub
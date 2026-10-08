
'------------------------------------------------------------------------------
' File:        jogbox.prg
' Purpose:     jog x axis program
' Version:     1.00
' Author:      chi/lukes
' Description:
' History:     20170608  V1.00
'              Created
'              2019/08/29  1.add serial jog box control
'                          2.fix jog move  exceed soft limit
'------------------------------------------------------------------------------

' module global "constants"


' module global variables


program ''continue
onerror
  catch 65
    Sleep 10
    ContinueTask jog_x.prg 
end onerror


onevent ev_x JOG_VEL_X = 0

    Stop X StopType=IMMEDIATE
    proceed X ProceedType = CLEARMOTION
    detach X
    JOG_STATE_X = JOG_STATE_INIT  
end onevent



  JOG_STATE_X = JOG_STATE_INIT
  call jog_init_x
  
  eventon ev_x
  
  while TRUE

  
      if SYS_OP_MODE = SYS_OP_JOG_MODE then
          
          select case JOG_STATE_X
          
            case JOG_STATE_INIT
                call jog_init_x
                JOG_STATE_X = JOG_STATE_IDLE
                
            case JOG_STATE_STOP
                call jog_stop_x
                JOG_STATE_X = JOG_STATE_IDLE
                
            case JOG_STATE_MOVE
             
                JOG_STATE_X = JOG_STATE_IDLE
                call jog_move_x
               
                 
            case JOG_STATE_IDLE
                call jog_idle_x
           
               sleep 1
                 
            case JOG_STATE_ERR
                  JOG_STATE_X = JOG_STATE_IDLE
                  call jog_error_x
                  
          end select          
                    
      else
        JOG_Error_CODE = 8001               'not in jog mode
       ' print lError,": system Not in Jog mode"
      end if
      
      sleep 1
    '' semaphoreGive(semMove)
  end while
 ''  semaphoreGive(semMove)
  eventoff ev_x
  
end program 


'******************************************
'function: jog_init
'description: init jog parameters
'
'
'
'****************************************** 
sub jog_init_x
    JOG_Error_CODE = 0
    call attach_x
   ' Attach x
   
  try 
  if x.AttachedTo <> "" then
    detachfrom$ x File = x.AttachedTo
  end if
   Attach x
  catch 3006
   
  catch 3173
     Proceed x ProceedType = CLEARMOTION
     Attach x
  end try  
    with x
      BlendingMethod=1

    end with

end sub






'******************************************
'function: jog_stop
'description: stop jog 
'****************************************** 
sub jog_stop_x 
  
   Stop X StopType=IMMEDIATE
   if x.AttachedTo = "JOG_X.PRG" then
      try
        Detach x
      catch else
        Proceed x ProceedType=CLEARMOTION
        Detach x
      end try
   end if
 
end sub




'******************************************
'function: jog_error
'description: jog error handler
'             
'****************************************** 
sub jog_error_x
    
end sub


'******************************************
'function: jog_move
'description: jog move aixs 
'             
'****************************************** 
sub jog_move_x
  if x.En then
    if JOG_VEL_X = 0 then
        JOG_Error_CODE = 8004         'velocity = 0 
    else 
        call attach_x
        try 
          Attach x
          catch 3173
            Proceed x ProceedType = CLEARMOTION
            Attach x
        end try  
        with x
      
            if JOG_TYPE =1 then 
                if JOG_SPEED = JOG_FAST_SPEED then
                    try                 
                      Jog -1*JOG_VEL_X StartType=IMMEDIATE Acceleration=x.Acc Deceleration=x.Dec
                      'Move XJOGTarget cp=0 abs=1 vcruise=JOG_VEL_X StartType=IMMEDIATE Acceleration=x.Acc Deceleration=x.Dec
                    catch 3155
                      Stop StopType=IMMED
                      JOG_STATE_X = JOG_STATE_STOP
                      JOG_Error_CODE = 8006
                    catch 3154
                     Stop StopType=IMMED
                     JOG_STATE_X = JOG_STATE_STOP
                     JOG_Error_CODE = 8007
                     
                    catch else
      
                    end try
                  
                end if
                 
                
                if JOG_SPEED = JOG_SLOW_SPEED then 
                    try                       
                      Jog -1*JOG_VEL_X StartType=IMMEDIATE Acceleration=x.Acc Deceleration=x.Dec
                      'Move XJOGTarget cp=0 abs=1  vcruise=JOG_VEL_X  StartType=IMMEDIATE Acceleration=x.Acc Deceleration=x.Dec
                    catch 3155
                      Stop StopType=IMMED
                      JOG_STATE_X = JOG_STATE_STOP
                      JOG_Error_CODE = 8006
                    catch 3154
                     Stop StopType=IMMED
                     JOG_STATE_X = JOG_STATE_STOP
                     JOG_Error_CODE = 8007
                     
                    catch else
                    
                    end try          
              
                end if
              else 
                  try 
                     Jog -1*JOG_VEL_X StartType=IMMEDIATE Acceleration=x.Acc Deceleration=x.Dec
                     'Move XJOGTarget cp=0 abs=1 vcruise=JOG_VEL_X StartType=IMMEDIATE Acceleration=x.Acc Deceleration=x.Dec   
                  catch 3155
                      Stop StopType=IMMED
                      JOG_STATE_X = JOG_STATE_STOP
                      JOG_Error_CODE = 8006
                  catch 3154
                     Stop StopType=IMMED
                     JOG_STATE_X = JOG_STATE_STOP
                     JOG_Error_CODE = 8007
                  catch else
                    
                  end try
              end if
                
             end with
          
          end if
  else
    JOG_Error_CODE = 8003         'x axis not enabled
  end if            
end sub



'************************************************************************
'    FUNCTION:    Attach x axis
'            
'************************************************************************
sub attach_x

 dim sTaskName as string  = "jog_x.prg"


  if x.AttachedTo <> sTaskName then
      try 
        Proceed x ProceedType = CLEARMOTION
      catch 3042
      
      catch 3177
      
      end try
  end if

end sub






'************************************************************************
'    FUNCTION:    detach x axis
'            
'************************************************************************

sub detach_x
    
  dim sTaskName as string  = "jog_x.prg"
  
  if x.AttachedTo = sTaskName then
        Proceed x ProceedType = CLEARMOTION
  end if
  
  Detach x
  
end sub




'******************************************
'function: jog_idle_x
'description: stay in idle state
'             monitor jog state
'
'    return:  
'           0         : Succed
'           8002      : jog velocity exceeded                  
'******************************************

sub jog_idle_x

 if JOG_MOVE_X_SIGNAL = 0 then    
   JOG_VEL_X = 0    
 end if
 
  'X move positive
 if JOG_MOVE_X_SIGNAL<0 or newKey_L_Staus[7] then            
   
   XJOGTarget=X.Pmax-XLimitDiff
  
   if JOG_TYPE=2 and (not newKey_L_Staus[7]) then
      JOG_VEL_X = JOG_SPEED_ACTUAL*(JOG_MOVE_X_SIGNAL)*JOG_SPEED_FACTOR*JOG_X_LOCK*xSecLimit
   else
      JOG_VEL_X = JOG_SPEED*JOG_MOVE_X_SIGNAL*JOG_SPEED_FACTOR_X
   end if
   
   if JOG_TYPE=2 and newKey_L_Staus[7] then
      JOG_VEL_X =-1*JOG_SPEED_ACTUAL*JOG_SPEED_FACTOR*JOG_X_LOCK*xSecLimit
   end if 
   
   JOG_STATE_X = JOG_STATE_MOVE  
  
 end if  
 'X move negative   
 if JOG_MOVE_X_SIGNAL>0 or newKey_L_Staus[6] then              
           
   XJOGTarget=X.Pmin+XLimitDiff
    
   if JOG_TYPE=2 and (not newKey_L_Staus[6]) then
      JOG_VEL_X = JOG_SPEED_ACTUAL*(JOG_MOVE_X_SIGNAL)*JOG_SPEED_FACTOR*JOG_X_LOCK*xSecLimit
   else
      JOG_VEL_X = JOG_SPEED*JOG_MOVE_X_SIGNAL*JOG_SPEED_FACTOR_X
   end if
   
   if JOG_TYPE=2 and newKey_L_Staus[6] then
      JOG_VEL_X =JOG_SPEED_ACTUAL*JOG_SPEED_FACTOR*JOG_X_LOCK*xSecLimit
   end if
   JOG_STATE_X = JOG_STATE_MOVE 
    
 end if  

end sub
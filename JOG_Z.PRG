'------------------------------------------------------------------------------
' File:        jog_z.prg
' Purpose:     jog z axis program
' Version:     1.00
' Author:      chi
' Description:
' History:     20170608  V1.00
'              Created
'              2019/08/29  1.add serial jog box control
'                          2.fix jog move exceed soft limit
'------------------------------------------------------------------------------

' module global "constants"


' module global variables


program ''continue
onerror
  catch 65
    Sleep 10
    ContinueTask jog_z.prg 
end onerror


onevent ev_z JOG_VEL_Z = 0
  if z.IsMoving then
    Stop z StopType=IMMEDIATE
    proceed z ProceedType = ClearMotion
    detach z
  end if
  detach z
  JOG_STATE_Z = JOG_STATE_INIT
  sleep 1
  
end onevent

  JOG_STATE_Z = JOG_STATE_INIT
  call jog_init_z
  eventon ev_z
  'semaphoreGive(semMove)
  while TRUE
      ' aquire motion semaphore
    '  while semaphoreTake(semMove, 100) = 0 
    '    sleep 1
     ' end while  
      if SYS_OP_MODE = SYS_OP_JOG_MODE then
      
      
        '  call jog_idle_x     
          
          select case JOG_STATE_Z
          
            case JOG_STATE_INIT
                call jog_init_z
                JOG_STATE_Z = JOG_STATE_IDLE
                
            case JOG_STATE_STOP
               '' call jog_stop_x
                JOG_STATE_Z = JOG_STATE_IDLE
                
            case JOG_STATE_MOVE
             
                JOG_STATE_Z = JOG_STATE_IDLE
                call jog_move_z
               
                 
            case JOG_STATE_IDLE
               call jog_idle_Z
               '' sleep bus[0].cycletime/1000
               sleep 1
                 
            case JOG_STATE_ERR
                  JOG_STATE_Z = JOG_STATE_IDLE
                  call jog_error_Z
                  
          end select          
                    
      else
        JOG_Error_CODE = 8001               'not in jog mode
       ' print lError,": system Not in Jog mode"
      end if
      
      sleep 1
  '  semaphoreGive(semMove)
  end while
 ' semaphoreGive(semMove)
  eventoff ev_z
  
end program 


'******************************************
'function: jog_init
'description: init jog parameters
'
'
'
'****************************************** 
sub jog_init_z
    JOG_Error_CODE = 0
    call attach_z
   ' Attach z
   
  try 
   Attach z
  catch 3006
  
  catch 3173
     Proceed z ProceedType = CLEARMOTION
     Attach z
  end try  
    with z
      BlendingMethod=1
'      En=1
     '' PeMax=0.2
    ''  PmaxEn=1
     '' PminEn=1
    end with
 ''   call detach_x
   
end sub






'******************************************
'function: jog_stop
'description: stop jog 
'****************************************** 
sub jog_stop_z 
    Stop z StopType=IMMED
end sub




'******************************************
'function: jog_error
'description: jog error handler
'             
'****************************************** 
sub jog_error_z
    
end sub


'******************************************
'function: jog_move
'description: jog move aixs 
'             
'****************************************** 
sub jog_move_z
  if z.En then
    if JOG_VEL_Z = 0 then
        JOG_Error_CODE = 8004         'velocity = 0 
    else   
        call attach_z
    ''    Attach z
        try 
          Attach z
        catch 3173
          Proceed z ProceedType = CLEARMOTION
          Attach z
        end try  

        with z
          if JOG_TYPE=1 then
             if JOG_SPEED = JOG_FAST_SPEED then
              
                 try 
                     ' Proceed ProceedType=ClearMotion
                    JOG -1*JOG_VEL_Z StartType=IMMEDIATE Acceleration=Z.Acc Deceleration=Z.Dec 
                    'Move ZJOGTarget cp=0 abs=1 vcruise=JOG_VEL_Z StartType=IMMEDIATE Acceleration=4*Z.Acc Deceleration=4*Z.Dec 
      
                  catch 3155
                    Stop StopType=IMMED
                    JOG_STATE_Z = JOG_STATE_STOP
                    JOG_Error_CODE = 8006
                  catch 3154
                   Stop StopType=IMMED
                   JOG_STATE_Z = JOG_STATE_STOP
                   JOG_Error_CODE = 8007
                   
                  catch else
                  
                  '  Proceed ProceedType=ClearMotion
                  end try
              end if
                            
               if JOG_SPEED = JOG_SLOW_SPEED then 
               
                 try
                     ' Proceed ProceedType=ClearMotion
                    JOG -1*JOG_VEL_Z StartType=IMMEDIATE Acceleration=Z.Acc Deceleration=Z.Dec 
                    'Move ZJOGTarget cp=0 abs=1 vcruise=JOG_VEL_Z StartType=IMMEDIATE Acceleration=4*Z.Acc Deceleration=4*Z.Dec
                    
      
                  catch 3155
                    Stop StopType=IMMED
                    JOG_STATE_Z = JOG_STATE_STOP
                    JOG_Error_CODE = 8006
                  catch 3154
                   Stop StopType=IMMED
                   JOG_STATE_Z = JOG_STATE_STOP
                   JOG_Error_CODE = 8007    
                  catch else                 
                  '  Proceed ProceedType=ClearMotion
                  end try               
               end if
            else
                try 
                ' Proceed ProceedType=ClearMotion
                  JOG -1*JOG_VEL_Z StartType=IMMEDIATE Acceleration=Z.Acc Deceleration=Z.Dec
                ' Move ZJOGTarget cp=0 abs=1 vcruise=JOG_VEL_Z StartType=IMMEDIATE Acceleration=6*Z.Acc Deceleration=6*Z.Dec
               
                catch 3155
                  Stop StopType=IMMED
                  JOG_STATE_Z = JOG_STATE_STOP
                  JOG_Error_CODE = 8006
                catch 3154
                  Stop StopType=IMMED
                  JOG_STATE_Z = JOG_STATE_STOP
                  JOG_Error_CODE = 8007
                catch else
                    
                end try
            end if
            
          end with
'       call detach_z
    end if
  else
    JOG_Error_CODE = 8003         'z axis not enabled
  end if            
end sub



'************************************************************************
'    FUNCTION:    Attach z axis
'            
'************************************************************************
sub attach_z

 dim sTaskName as string  = "jog_z.prg"

 ' Detach z

  if z.AttachedTo <> sTaskName then
      try 
        Proceed z ProceedType = CLEARMOTION
      catch 3042
      end try
  end if
  
 '' Sleep 10
end sub




'************************************************************************
'    FUNCTION:    detach z axis
'            
'************************************************************************

sub detach_z
    
  dim sTaskName as string  = "jog_z.prg"
  
  if z.AttachedTo = sTaskName then
        Proceed z ProceedType = CLEARMOTION
  end if
  
  Detach z
  
end sub




'******************************************
'function: jog_idle_Z
'description: stay in idle state
'             monitor jog state
'
'    return:  
'           0         : Succed
'           8002      : jog velocity exceeded                  
'****************************************** 
sub jog_idle_z

 if JOG_MOVE_Z_SIGNAL = 0 then    
   JOG_VEL_Z = 0    
 end if
 
  'Z move positive
 if JOG_MOVE_Z_SIGNAL<0 or newKey_L_Staus[5] then            
   JOG_STATE_Z = JOG_STATE_MOVE
   ZJOGTarget=Z.Pmax-ZLimitDiff
   
   if JOG_TYPE=2 and (not newKey_L_Staus[5]) then
      JOG_VEL_Z = JOG_SPEED_ACTUAL*(JOG_MOVE_Z_SIGNAL)*JOG_SPEED_FACTOR*JOG_Z_LOCK*zSecLimit
   else
      JOG_VEL_Z = JOG_SPEED*(JOG_MOVE_Z_SIGNAL)*JOG_SPEED_FACTOR_Z*1.5
   end if
   
   if JOG_TYPE=2 and newKey_L_Staus[5] then
      JOG_VEL_Z =-1*JOG_SPEED_ACTUAL*JOG_SPEED_FACTOR*JOG_Z_LOCK*zSecLimit
   end if 
 end if  
 'Z move negative   
 if JOG_MOVE_Z_SIGNAL>0 or newKey_L_Staus[4] then              
   JOG_STATE_Z = JOG_STATE_MOVE          
   ZJOGTarget=Z.Pmin+ZLimitDiff
   
   if JOG_TYPE=2 and (not newKey_L_Staus[4]) then
      JOG_VEL_Z = JOG_SPEED_ACTUAL*(JOG_MOVE_Z_SIGNAL)*JOG_SPEED_FACTOR*JOG_Z_LOCK*zSecLimit
   else
      JOG_VEL_Z = JOG_SPEED*(JOG_MOVE_Z_SIGNAL)*JOG_SPEED_FACTOR_Z*1.5
   end if
   
   if JOG_TYPE=2 and newKey_L_Staus[4] then
      JOG_VEL_Z =JOG_SPEED_ACTUAL*JOG_SPEED_FACTOR*JOG_Z_LOCK*zSecLimit
   end if 
 end if  

end sub

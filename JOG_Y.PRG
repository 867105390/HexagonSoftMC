'------------------------------------------------------------------------------
' File:        jog_y.prg
' Purpose:     jog y axis program
' Version:     1.00
' Author:      chi/lukes
' Description:
' History:     20170612  V1.00
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
    ContinueTask jog_y.prg 
end onerror



onevent ev_y JOG_VEL_Y = 0

    Stop Y StopType=DecStopOnPath 'this use to make sure to reduce the virbation
    proceed Y ProceedType = ClearMotion
    detach Y
    JOG_STATE_Y = JOG_STATE_INIT
end onevent




  JOG_STATE_Y = JOG_STATE_INIT
  call jog_init_y
  eventon ev_y  

  while TRUE
        
      if SYS_OP_MODE = SYS_OP_JOG_MODE then
                
          select case JOG_STATE_Y
          
            case JOG_STATE_INIT
                call jog_init_y
                JOG_STATE_Y = JOG_STATE_IDLE
                
            case JOG_STATE_STOP

                JOG_STATE_Y = JOG_STATE_IDLE
                
            case JOG_STATE_MOVE
             
                JOG_STATE_Y = JOG_STATE_IDLE
                call jog_move_y
                   
            case JOG_STATE_IDLE
                call jog_idle_Y

               sleep 1
                 
            case JOG_STATE_ERR
                  JOG_STATE_Y = JOG_STATE_IDLE
                  call jog_error_y
                  
          end select          
                    
      else
        JOG_Error_CODE = 8001               'not in jog mode
       ' print lError,": system Not in Jog mode"
      end if
      
      sleep 1

  end while

  eventoff ev_y
  
end program 


'******************************************
'function: jog_init
'description: init jog parameters
'
'
'
'****************************************** 
sub jog_init_y
    JOG_Error_CODE = 0
    call attach_y
   ' Attach x
   
  try 
   Attach y
  catch 3006
    
  catch 3173
     Proceed y ProceedType = CLEARMOTION
     Attach y
  end try  
    with y
      BlendingMethod=1
    end with
end sub






'******************************************
'function: jog_stop
'description: stop jog 
'****************************************** 
sub jog_stop_y
    Stop y StopType=IMMED
end sub




'******************************************
'function: jog_error
'description: jog error handler
'             
'****************************************** 
sub jog_error_y
    
end sub


'******************************************
'function: jog_move
'description: jog move aixs 
'             
'****************************************** 
sub jog_move_y
  dim yJerkLimit as double
  dim yJerkNormal as double
  yJerkLimit=100
  yJerkNormal=12600
  if y.En then
    if JOG_VEL_Y = 0 then
        JOG_Error_CODE = 8004         'velocity = 0 
    else    
        call attach_y
        try 
          Attach y
        catch 3173
          Proceed y ProceedType = CLEARMOTION
          Attach y
        end try  

        with y
         if JOG_TYPE=1 then 
            if JOG_SPEED = JOG_FAST_SPEED then
              try               
                ' JOG -1*JOG_VEL_Y StartType=IMMEDIATE Acceleration=Y.Acc Deceleration=Y.Dec Jrate=10

                
                
                'JOG -1*JOG_VEL_Y StartType=IMMEDIATE arate=50 drate=50  Jrate=10 jerkmax=5000
                JOG -1*JOG_VEL_Y StartType=IMMEDIATE Acceleration=Y.Acc Deceleration=Y.Dec
                'Move YJOGTarget cp=0 abs=1 vcruise=JOG_VEL_Y  StartType=IMMEDIATE Acceleration=y.Acc Deceleration=y.Dec
              catch 3155
                Stop StopType=IMMED
                JOG_STATE_Y = JOG_STATE_STOP
                JOG_Error_CODE = 8006
              catch 3154
               Stop StopType=IMMED
               JOG_STATE_Y = JOG_STATE_STOP
               JOG_Error_CODE = 8007               
              catch else              
           
              end try              
           end if
         
           if JOG_SPEED = JOG_SLOW_SPEED then 
              try 
                JOG -1*JOG_VEL_Y StartType=IMMEDIATE Acceleration=Y.Acc Deceleration=Y.Dec               
                'Move YJOGTarget cp=0 abs=1 vcruise=JOG_VEL_Y StartType=IMMEDIATE Acceleration=y.Acc Deceleration=y.Dec 
              catch 3155
                Stop StopType=IMMED
                JOG_STATE_Y = JOG_STATE_STOP
                JOG_Error_CODE = 8006
              catch 3154
               Stop StopType=IMMED
               JOG_STATE_Y = JOG_STATE_STOP
               JOG_Error_CODE = 8007             
              catch else           
        
              end try                             
           end if
       else
          try 
            JOG -1*JOG_VEL_Y StartType=IMMEDIATE Acceleration=Y.Acc Deceleration=Y.Dec jrate=10
            'Move YJOGTarget cp=0 abs=1 vcruise=JOG_VEL_Y StartType=IMMEDIATE Acceleration=Y.Acc Deceleration=Y.Dec
          catch 3155
            Stop StopType=IMMED
            JOG_STATE_Y = JOG_STATE_STOP
            JOG_Error_CODE = 8006
          catch 3154
            Stop StopType=IMMED
            JOG_STATE_Y = JOG_STATE_STOP
            JOG_Error_CODE = 8007
          catch else
                    
          end try
       end if            
     end with

    end if
  else
    JOG_Error_CODE = 8003         'y axis not enabled
  end if            
end sub



'************************************************************************
'    FUNCTION:    Attach y axis
'            
'************************************************************************
sub attach_y

 dim sTaskName as string  = "jog_y.prg"

 ' Detach x

  if y.AttachedTo <> sTaskName then
      try 
        Proceed y ProceedType = CLEARMOTION
      catch 3042
      end try
  end if
  
 '' Sleep 10
end sub


'************************************************************************
'    FUNCTION:    detach y axis
'            
'************************************************************************

sub detach_y
    
  dim sTaskName as string  = "jog_y.prg"
  
  if y.AttachedTo = sTaskName then
        Proceed y ProceedType = CLEARMOTION
  end if
  
  Detach y
  
end sub



'******************************************
'function: jog_idle_y
'description: stay in idle state
'             monitor jog state
'
'    return:  
'           0         : Succed
'           8002      : jog velocity exceeded                  
'****************************************** 
sub jog_idle_y

 if JOG_MOVE_Y_SIGNAL = 0 then    
   JOG_VEL_Y = 0    
 end if
 
  'Y move positive
 if JOG_MOVE_Y_SIGNAL<0 or newKey_H_Staus[3] then            
   JOG_STATE_Y = JOG_STATE_MOVE
   YJOGTarget=Y.Pmax-YLimitDiff
   

   
   if JOG_TYPE=2 and (not newKey_H_Staus[3]) then
      JOG_VEL_Y = JOG_SPEED_ACTUAL*(JOG_MOVE_Y_SIGNAL)*JOG_SPEED_FACTOR*JOG_Y_LOCK*ySecLimit
   else
      JOG_VEL_Y = JOG_SPEED*JOG_MOVE_Y_SIGNAL*JOG_SPEED_FACTOR_Y 'SR jogbox velocity
   end if
   
   if JOG_TYPE=2 and newKey_H_Staus[3] then
      JOG_VEL_Y =-1*JOG_SPEED_ACTUAL*JOG_SPEED_FACTOR*JOG_Y_LOCK*ySecLimit
   end if 
 end if  
 'Y move negative   
 if JOG_MOVE_Y_SIGNAL>0 or newKey_H_Staus[7] then              
   JOG_STATE_Y = JOG_STATE_MOVE          
   YJOGTarget=Y.Pmin+YLimitDiff
   

    
   if JOG_TYPE=2 and (not newKey_H_Staus[7]) then
      JOG_VEL_Y = JOG_SPEED_ACTUAL*(JOG_MOVE_Y_SIGNAL)*JOG_SPEED_FACTOR*JOG_Y_LOCK*ySecLimit
   else
      JOG_VEL_Y = JOG_SPEED*JOG_MOVE_Y_SIGNAL*JOG_SPEED_FACTOR_Y 'SR jogbox velocity
   end if
   
   if JOG_TYPE=2 and newKey_H_Staus[7] then
      JOG_VEL_Y =JOG_SPEED_ACTUAL*JOG_SPEED_FACTOR*JOG_Y_LOCK*ySecLimit
   end if 
 end if  

end sub
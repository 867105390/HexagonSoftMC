'------------------------------------------------------------------------------
' File:        jmap.prg
' Purpose:     jog signal mapping program
' Version:     1.00
' Author:      chi
' Description:
' History:      2017/06/08 V1.00
'              Created
'------------------------------------------------------------------------------

' module global "constants"

'common shared JOG_MOVE_X_SIGNAL as long = 0                       'analog input signal of x axis
'common shared JOG_MOVE_Y_SIGNAL as long = 0                       'analog input signal of y axis
'common shared JOG_MOVE_Z_SIGNAL as long = 0                       'analog input signal of z axis
'common shared JOG_FAST_SPEED as double = 30                       'fast jog speed  : Vcruise
'common shared JOG_SLOW_SPEED as double = 5                        'slow jog speed  : Vcruise
'common shared JOG_EMERGENCY_SIGNAL as long = 0 
'common shared JOG_START_SIGNAL as long = 0 
'common shared JOG_SWITCH_SPEED_SIGNAL as long = 0                 '1: fast speed, 0: slow speed
'common shared JOG_SPEED_SWITCH_PRESSED as long = 0
'common shared JOG_SPEED as long = JOG_SLOW_SPEED                  ' by default, jog speed is 5, slow speed.


' module global variables
common shared vx as double
common shared vy as double
common shared vz as double
common shared sv as double
common shared JogLock as long


program continue
    while sys_simulated = 1
      sleep 100
    end while
  

    OnEvent DirVector sys.din.1009=1
      vx = 0
      vy = 0
      vz = 0
      sv = sqrt(x.VFB*x.VFB + y.VFB*y.VFB + z.VFB*z.VFB)
      if gxyz.ismoving then
        vx = x.VFB/sv
        vy = y.VFB/sv
        vz = z.VFB/sv
      end if
      JogLock = 1
      
      print vx, vy, vz
      
    End OnEvent
    
    
    OnEvent JogReset abs(EC_CDHD_GET_ANIN1(x))+abs(EC_CDHD_GET_ANIN1(y))+abs(EC_CDHD_GET_ANIN1(z))+abs(JOG_MOVE_X_SIGNAL_SOFTWARE)+abs(JOG_MOVE_Y_SIGNAL_SOFTWARE)+abs(JOG_MOVE_Z_SIGNAL_SOFTWARE) = 0
      JogLock = 0
    End OnEvent
    
    eventon DirVector
    eventon JogReset



    while 1
    
    if JOG_TYPE =1 then
      if sys.din.1009 = 0 and JogLock = 0 then
          if abs(EC_CDHD_GET_ANIN1(x)/1000) < 0.01 then
            JOG_MOVE_X_SIGNAL = JOG_MOVE_X_SIGNAL_SOFTWARE
          else
            JOG_MOVE_X_SIGNAL = EC_CDHD_GET_ANIN1(x)/1000
          end if      
  
          if abs(EC_CDHD_GET_ANIN1(y)/1000) < 0.01 then
            JOG_MOVE_Y_SIGNAL = JOG_MOVE_Y_SIGNAL_SOFTWARE
          else
            JOG_MOVE_Y_SIGNAL = EC_CDHD_GET_ANIN1(y)/1000
          end if
  
          if abs(EC_CDHD_GET_ANIN1(z)/1000) < 0.01 then
            JOG_MOVE_Z_SIGNAL = JOG_MOVE_Z_SIGNAL_SOFTWARE
          else
            JOG_MOVE_Z_SIGNAL = EC_CDHD_GET_ANIN1(z)/1000
          end if
      end if
      
      if sys.din.1009 = 1 then
        JOG_MOVE_X_SIGNAL = vx
        JOG_MOVE_Y_SIGNAL = vy
        JOG_MOVE_Z_SIGNAL = vz
      end if
      
      if sys.din.1009 = 0 and JogLock = 1 then
        JOG_MOVE_X_SIGNAL = 0
        JOG_MOVE_Y_SIGNAL = 0
        JOG_MOVE_Z_SIGNAL = 0
        
      end if 
                  
     
    else
        JOG_MOVE_X_SIGNAL = XJogFactor
        JOG_MOVE_Y_SIGNAL = YJogFactor
        JOG_MOVE_Z_SIGNAL = ZJogFactor
    end if
    
    
    
    ZOOM_IN_SIG = sys.din.1003
    ZOOM_OUT_SIG = sys.din.1004
    if JOG_TYPE =1 then
      START_SIG_EN = sys.din.2005
    else
      START_SIG_EN = newKey_H_Staus[4]
    end if
' 如果急停信号焊好之后，将以下注释代码，取消注释。 停止所有程序，重新拉入控制器，重启系统。
'**********************************************************************************************'
    if sys.din.1002 OR sys.din.2002 OR sys.din.3002 then
        EMERGENCY_STOP_SIG = 1
       else
        EMERGENCY_STOP_SIG = 0
        
        if START_SIG_EN then
            try 
                call DuoEnableGroup(1)
            catch else
            
            end try
       end if        
    end if    
'**********************************************************************************************'     

      sleep 3
      
    end while


end program




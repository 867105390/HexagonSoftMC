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

program continue

  dim sysInf as string

  sysInf = ver

  if Instr(sysInf, "0.4.21") > 0 then
    FWVERSION = 4.21
  end if

  if Instr(sysInf, "0.4.18") > 0 then
    FWVERSION = 4.18
  end if

  if FWVERSION = 0.0 then
    sys_simulated = 1
    print "UNKONW FW, system enter into simulated mode to safe"
  end if


  Load$ "ECCONFIG.PRG"
  Stas$ "ECCONFIG.PRG"
  while ECCONFIG.PRG.state <> 10
    sleep 500
  end while

if sys_simulated = 0  then
  Load$ "EC_SETUP.PRG"
  Stas$ "EC_SETUP.PRG"

  while EC_SETUP.PRG.state <> 10
    sleep 500
  end while
  
  if 4.21 = FWVERSION then
    Load$ "AxisEC.PRG"
    Stas$ "AxisEC.PRG"
    while AxisEC.PRG.state <> 10
      sleep 500
    end while
  else
    Load$ "AxisECO.PRG"
    Stas$ "AxisECO.PRG"
    while AxisECO.PRG.state <> 10
      sleep 500
    end while
  end if
  

  Load$ "AX_SETUP.PRG"
  Stas$ "AX_SETUP.PRG"

  while AX_SETUP.PRG.state <> 10
    sleep 500
  end while
  
  Load$ "ROBOT.PRG"
  Stas$ "ROBOT.PRG"

  while ROBOT.PRG.state <> 10
    sleep 500
  end while

end if

if sys_simulated = 1 then
  Load$ "SIMSETUP.PRG"
  ' PROGRAM CONTINUE starts SIMSETUP when loaded.
  while SIMSETUP.PRG.state <> 10
    sleep 500
  end while
  ' AX_SETUP skips physical master setup in simulation, but configures A4/A5.
  Load$ "AX_SETUP.PRG"
  Stas$ "AX_SETUP.PRG"
  while AX_SETUP.PRG.state <> 10
    sleep 500
  end while
end if

  Load$ "PARA.PRG"
  Stas$ "PARA.PRG"
  while PARA.PRG.state <> 10
    sleep 500
  end while

  Load$ "DUOSET.PRG"
  Stas$ "DUOSET.PRG"
  while DUOSET.PRG.state <> 10
    sleep 500
  end while

  Load$ "RSJOG.PRG"
  Load$ "mhgr.prg"
  Load$ "SWVEL.PRG"
  Load$ "jmap.prg"


   Load$ "mvaxes.prg"
   Load$ "mvgroup.prg"
   Load$ "server.prg"
   Load$ "jog_x.prg"
   Load$ "jog_y.prg"
   Load$ "jog_z.prg"
   Load$ "tman.prg"
   Load$ "tcpcom.prg"
   
   Load$ "erract.prg"
   Stas$ "erract.prg" 
   
   Load$ "vellim.prg"
   Stas$ "vellim.prg" 
   
   Load$ "msocket.prg"
   Stas$ "msocket.prg" 
   
   load Latch.prg
   

     
  sys.ErrorHandlerMode=0
  
  Print "Hexagon setup successed!"

end program ' <MyTask>.prg

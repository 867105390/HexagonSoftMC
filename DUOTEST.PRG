' Manual SIMULATION ONLY regression test. Never called by AUTOEXEC.
common shared duoTestPassed as long = 0
common shared duoTestError as long = 0
common shared ERR_DUO_TEST as error "Duo simulation assertion failed" 20809
program
  dim oldNoMotion as long
  dim oldSocketFlag as long
  dim expectedError as long
  duoTestPassed = 0
  duoTestError = 0
  oldNoMotion = sys.NoMotion
  oldSocketFlag = bSocketIsOpen1
  try
    if sys_simulated <> 1 then
      throw ERR_DUO_TEST
    end if
    if x.Simulated <> 1 or y.Simulated <> 1 or z.Simulated <> 1 then
      throw ERR_DUO_TEST
    end if
    if X_F.Simulated <> 1 or Z_F.Simulated <> 1 then
      throw ERR_DUO_TEST
    end if
    sys.NoMotion = 0
    bSocketIsOpen1 = 1
    call DuoAssert(X_F.Slave = GEAR and Z_F.Slave = GEAR)
    call DuoAssert(X_F.GearRatio = 1 and Z_F.GearRatio = 1)
    call grEn(0,9002,1,1)
    call DuoAssert(x.En = 1 and y.En = 1 and z.En = 1 and X_F.En = 1 and Z_F.En = 1)
    attach x
    Move x -5 VelocityCruise=10
    while x.IsMoving
      sleep 10
    end while
    detach x
    sleep 100
    call DuoAssert(abs(x.PCMD-X_F.PCMD) < 0.000001)
    attach z
    Move z -2 VelocityCruise=5
    while z.IsMoving
      sleep 10
    end while
    detach z
    sleep 100
    call DuoAssert(abs(z.PCMD-Z_F.PCMD) < 0.000001)

    attach gXYZ
    Move gXYZ {-4,-5,-3} VelocityCruise=10
    while gXYZ.IsMoving
      sleep 10
    end while
    sleep 100
    call DuoAssert(abs(x.PCMD-X_F.PCMD) < 0.000001 and abs(z.PCMD-Z_F.PCMD) < 0.000001)
    ' Leave gXYZ attached: MHGR must release a previous group owner.
    axRespFileDesc = 0
    axSeq = 9001
    if TaskState("MHGR.PRG") <> 1 then
      KillTask MHGR.PRG
      StartTask MHGR.PRG
    end if
    grNewHome = 1
    call DuoWaitHome
    call DuoAssert(homingIsDone = 1 and DuoPositionsMatch)
    call DuoAssert(X_F.Slave = GEAR and Z_F.Slave = GEAR)

    call grEn(0,9003,1,0)
    call DuoAssert(x.En = 0 and y.En = 0 and z.En = 0 and X_F.En = 0 and Z_F.En = 0)
    call DuoAssert(X_F.Slave = GEAR and Z_F.Slave = GEAR)
    call DuoEnableGroup(1)
    call DuoAssert(x.En = 1 and z.En = 1 and X_F.En = 1 and Z_F.En = 1)
    call DuoEnableGroup(0)
    expectedError = 0
    try
      call DuoEnableGroup(2)
    catch ERR_DUO_ENABLE.num
      expectedError = 1
    end try
    call DuoAssert(expectedError = 1 and X_F.En = 0 and Z_F.En = 0)
    expectedError = 0
    try
      call DuoEnableAxis(1,2)
    catch ERR_DUO_ENABLE.num
      expectedError = 1
    end try
    call DuoAssert(expectedError = 1 and x.En = 0 and X_F.En = 0)
    call DuoUnbind
    attach X_F
    X_F.Displacement = 0
    X_F.Displacement = X_F.PFB-1
    detach X_F
    ' Deliberately bypass DuoBind ONLY in this simulation fixture to create
    ' an already-geared pair with a position offset while both drives are off.
    attach X_F
    attach Z_F
    X_F.MasterSource = x.PCMD
    Z_F.MasterSource = z.PCMD
    X_F.Slave = GEAR
    Z_F.Slave = GEAR
    detach X_F
    detach Z_F
    expectedError = 0
    try
      call DuoEnableGroup(1)
    catch ERR_DUO_POSITION.num
      expectedError = 1
    end try
    call DuoAssert(expectedError = 1 and x.En = 0 and X_F.En = 0)
    call DuoUnbind
    expectedError = 0
    try
      call DuoBind
    catch ERR_DUO_POSITION.num
      expectedError = 1
    end try
    call DuoAssert(expectedError = 1 and X_F.Slave = OFF and Z_F.Slave = OFF)
    grNewHome = 1
    call DuoWaitHome
    call DuoAssert(homingIsDone = 1 and DuoPositionsMatch and X_F.Slave = GEAR and Z_F.Slave = GEAR)
    duoHomeCancel = 1
    grNewHome = 1
    call DuoWaitHome
    call DuoAssert(homingIsDone = 0 and x.En = 0 and y.En = 0 and z.En = 0 and X_F.En = 0 and Z_F.En = 0 and X_F.Slave = OFF and Z_F.Slave = OFF)
    duoHomeCancel = 0
    grNewHome = 1
    call DuoWaitHome
    call DuoAssert(homingIsDone = 1 and DuoPositionsMatch and X_F.Slave = GEAR and Z_F.Slave = GEAR)
  catch else
    duoTestError = errornumber
  end try
  duoHomeCancel = 0
  call DuoEnableGroup(0)
  sys.NoMotion = oldNoMotion
  bSocketIsOpen1 = oldSocketFlag
  print "DUOTEST passed=";duoTestPassed;" error=";duoTestError
end program

sub DuoAssert(byval condition as long)
  if condition = 0 then
    throw ERR_DUO_TEST
  end if
  duoTestPassed = duoTestPassed + 1
end sub

sub DuoWaitHome
  dim startedAt as double
  startedAt = sys.Clock
  while grNewHome and ((sys.Clock-startedAt) < 5000)
    sleep 10
  end while
  if grNewHome then
    throw ERR_DUO_TEST
  end if
end sub

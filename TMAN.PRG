'------------------------------------------------------------------------------
' File:        <MyTask>.prg
' Purpose:     Just an example of a module header
' Version:     1.01
' Author:      <MyFullName>
' Description: Added logging and debug flag for task management
' History:     YYYY-MM-DD  <MyShortCut>  V1.01
'              Added debug logging for KillTask and StartTask with if-end if
'------------------------------------------------------------------------------

' Module global variables
common shared TM as long = 0
dim shared bErrorInOnError as long = 0
dim shared timecnt as double
dim shared counts as long

program continue
dim isNotMoving as long
OnError
catch 8025
  TM = 1
  if isDebug then
    print "TMAN.PRG report error..."
  end if
catch else
  sleep 10
  bErrorInOnError = 1
  if isDebug then
    print errornumber, "   in tman.prg"
  end if
  ContinueTask TMAN.prg 
end onError

while sys_simulated = 1
  SYS_OP_MODE_CHANGE = 0
  sleep 100
end while

while 1
  
  if SYS_OP_MODE_CHANGE = 1 and (not sys.din.1002) then
    isNotMoving=0
    counts=0
    print "opmode has been changed, currently it is "; SYS_OP_MODE
    while not isNotMoving
      ' A geared follower reports IsMoving while gearing is active, even at rest.
      ' grNewHome covers independent five-drive homing until cleanup completes.
      if grNewHome = 0 and not gxyz.IsMoving and not x.IsMoving and not Y.IsMoving and not Z.IsMoving then
        counts=counts+1
      else
        counts=0
      end if
      sleep 10
      if counts>10 then
         isNotMoving=1
      end if
    end while
    ' ----------------------------- JOG MODE -----------------------------
    if SYS_OP_MODE = SYS_OP_JOG_MODE then
      timecnt = sys.Clock
      
    
    
       while (NOT gxyz.AttachedTo = "" and counts < 100)
        try
          detachfrom gxyz file = MVGroup.PRG
        catch else
        end try
        sleep 1
        counts = counts + 1
      end while    
      while MVGROUP.prg.state = 1
        try
         KillTask MVGROUP.prg
         catch  else
         sleep 1
        end try
        if isDebug then
          print "Killed MVGROUP.prg"
        end if
        sleep 1
      end while

      ' Keep MHGR alive: killing a drive-internal home skips its cleanup.

      while latch.prg.state = 1
        try
        KillTask latch.prg
        catch else
        print "Killed latch.prg failed"
        end try
        
        if isDebug then
          print "Killed latch.prg"
        end if
      end while

      while jog_x.prg.state <> 1
        try
          StartTask jog_x.prg
          if isDebug then
            print "Started jog_x.prg"
          end if
          sleep 1
        catch else
          KillTask jog_x.prg
          if isDebug then
            print "Killed jog_x.prg in catch"
          end if
          sleep 1
          StartTask jog_x.prg
          if isDebug then
            print "Restarted jog_x.prg in catch"
          end if
          sleep 1
        end try
      end while

      while jog_y.prg.state <> 1
        try
          StartTask jog_y.prg
          if isDebug then
            print "Started jog_y.prg"
          end if
          sleep 1
        catch else
          KillTask jog_y.prg
          if isDebug then
            print "Killed jog_y.prg in catch"
          end if
          sleep 1
          StartTask jog_y.prg
          if isDebug then
            print "Restarted jog_y.prg in catch"
          end if
          sleep 1
        end try
      end while

      while jog_z.prg.state <> 1
        try
          StartTask jog_z.prg
          if isDebug then
            print "Started jog_z.prg"
          end if
          sleep 1
        catch else
          KillTask jog_z.prg
          if isDebug then
            print "Killed jog_z.prg in catch"
          end if
          sleep 1
          StartTask jog_z.prg
          if isDebug then
            print "Restarted jog_z.prg in catch"
          end if
          sleep 1
        end try
      end while

      timecnt = sys.Clock - timecnt
      if isDebug then
        print "Switch to JOG mode time is: "; timecnt
      end if
    end if

    ' ------------------------- IPP MODE --------------------------
    if SYS_OP_MODE = SYS_OP_IPP_MODE and (not sys.din.1002) then
      timecnt = sys.Clock
      try
        while jog_x.prg.state = 1
          KillTask jog_x.prg
          if isDebug then
            print "Killed jog_x.prg"
          end if
          sleep 1
        end while

        while jog_y.prg.state = 1
          KillTask jog_y.prg
          if isDebug then
            print "Killed jog_y.prg"
          end if
          sleep 1
        end while

        while jog_z.prg.state = 1
          KillTask jog_z.prg
          if isDebug then
            print "Killed jog_z.prg"
          end if
          sleep 1
        end while

        while MVGROUP.prg.state = 10 OR MVGROUP.prg.state = 7 OR MVGROUP.prg.state = 4
          StartTask MVGROUP.prg
          if isDebug then
            print "Started MVGROUP.prg"
          end if
          sleep 1
        end while

        while MHGR.prg.state = 10 OR MHGR.prg.state = 7 OR MHGR.prg.state = 4
          StartTask MHGR.prg
          if isDebug then
            print "Started MHGR.prg"
          end if
          sleep 1
        end while

        while Latch.prg.state = 10 OR Latch.prg.state = 7 OR Latch.prg.state = 4
          StartTask Latch.prg
          if isDebug then
            print "Started Latch.prg"
          end if
          sleep 1
        end while

      catch else
        if isDebug then
          print "error in change to IPP mode in TMAN.PRG"
        end if
      end try

      try
        Proceed X ProceedType = CLEARMOTION
        Proceed Y ProceedType = CLEARMOTION
        Proceed Z ProceedType = CLEARMOTION
      catch else
        if isDebug then
          print "try to clear motion of x, y, z ..."
        end if
      end try

      timecnt = sys.Clock - timecnt
      if isDebug then
        print "Switch to Set-Point mode time is: "; timecnt
      end if
    end if

    SYS_OP_MODE_CHANGE = 0
  end if

  sleep 1
end while

end program ' <MyTask>.prg

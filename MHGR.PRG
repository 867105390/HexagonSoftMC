' Master_Duo: unbind, home five drives, then bind equal-position pairs.
program continue
dim axesArr[5] as generic axis
dim ax as generic axis
dim i as long
dim lError as long
dim responseSent as long
dim ownerTask as string

axesArr[1] = x
axesArr[2] = y
axesArr[3] = z
axesArr[4] = X_F
axesArr[5] = Z_F
semaphoreGive(semMove)

while 1
  if grNewHome then
    lError = 0
    responseSent = 0
    homingIsDone = 0
    IS_HOMING_PARAMETER_DEFINED = 0
    try
      call DuoCheckHomeCancel
      call DuoEnableGroup(0)
      ' Group motion keeps its attachment after a move; release it before homing.
      ownerTask = gXYZ.AttachedTo
      if ownerTask <> "" then
        Detachfrom$ gXYZ File=ownerTask
      end if
      for i = 1 to homing_num_of_axes
        ax = axesArr[i]
        ownerTask = ax.AttachedTo
        if ownerTask <> "" then
          Detachfrom$ ax File=ownerTask
        end if
      next i
      call DuoUnbind
      for i = 1 to homing_num_of_axes
        ax = axesArr[i]
        Proceed ax ProceedType=CLEARMOTION
        Attach ax
      next i

      if sys_simulated = 0 then
        call DuoSetHomeParameters(x, HOME_FAST_SPEED_GR, HOME_SLOW_SPEED_GR, HOME_ACC_GR)
        call DuoSetHomeParameters(y, HOME_FAST_SPEED_GR, HOME_SLOW_SPEED_GR, HOME_ACC_GR)
        call DuoSetHomeParameters(z, HOME_FAST_SPEED_AX, HOME_SLOW_SPEED_AX, HOME_ACC_AX)
        call DuoSetHomeParameters(X_F, HOME_FAST_SPEED_GR, HOME_SLOW_SPEED_GR, HOME_ACC_GR)
        call DuoSetHomeParameters(Z_F, HOME_FAST_SPEED_AX, HOME_SLOW_SPEED_AX, HOME_ACC_AX)
        call EC_SLAVE_SET_HOMING_PARAMETERS(X_F, HOMING_METHOD, EC_SLAVE_GET_HOMING_PARAMETERS(x, HOMING_METHOD))
        call EC_SLAVE_SET_HOMING_PARAMETERS(X_F, HOMING_OFFSET, EC_SLAVE_GET_HOMING_PARAMETERS(x, HOMING_OFFSET))
        call EC_SLAVE_SET_HOMING_PARAMETERS(Z_F, HOMING_METHOD, EC_SLAVE_GET_HOMING_PARAMETERS(z, HOMING_METHOD))
        call EC_SLAVE_SET_HOMING_PARAMETERS(Z_F, HOMING_OFFSET, EC_SLAVE_GET_HOMING_PARAMETERS(z, HOMING_OFFSET))
      end if

      call DuoCheckHomeCancel
      call sendResponce(axRespFileDesc, axSeq, 0)
      responseSent = 1
      if sys_simulated = 0 then
        print "Homing Z/Z_F, X/X_F, then Y"
        call ec_grHome_XY(400000)
      else
        for i = 1 to homing_num_of_axes
          ax = axesArr[i]
          ax.Displacement = 0
          ax.Displacement = ax.PFB
        next i
      end if

      call DuoCheckHomeCancel
      for i = 1 to homing_num_of_axes
        ax = axesArr[i]
        Detach ax
      next i
      call DuoBind
      call DuoCheckHomeCancel
      call DuoEnableGroup(1)
      IS_HOMING_PARAMETER_DEFINED = 1
      homingIsDone = 1
      print "Five-axis homing done; X_F/Z_F geared 1:1"
    catch else
      lError = errornumber
      homingIsDone = 0
      ' A failed parameter write or homing stage must not enable/rebind axes.
      for i = 1 to homing_num_of_axes
        try
          axesArr[i].En = 0
        catch else
          sleep 1
        end try
        try
          ax = axesArr[i]
          if ax.AttachedTo = "MHGR.PRG" then
            Detach ax
          end if
        catch else
          sleep 1
        end try
      next i
      try
        call DuoUnbind
      catch else
        sleep 1
      end try
      for i = 1 to homing_num_of_axes
        try
          ax = axesArr[i]
          if ax.AttachedTo = "MHGR.PRG" then
            Detach ax
          end if
        catch else
          sleep 1
        end try
      next i
    end try

    if responseSent then
      call sendDeferredResponce(axRespFileDesc, axSeq, lError)
    else
      call sendResponce(axRespFileDesc, axSeq, lError)
    end if
    grNewHome = 0
  else
    sleep 2
  end if
end while
end program

sub DuoSetHomeParameters(ax as generic axis, byval requestedFast as double, byval requestedSlow as double, byval requestedAcc as double)
  dim fastCounts as long
  dim slowCounts as long
  dim accCounts as long
  fastCounts = ax.VFac * 1000 * requestedFast
  slowCounts = ax.VFac * 1000 * requestedSlow
  accCounts = ax.AFac * 1000 * 1000 * requestedAcc
  call EC_SLAVE_SET_HOMING_PARAMETERS(ax, FAST_HOMING_SPEED, fastCounts)
  sleep 100
  call EC_SLAVE_SET_HOMING_PARAMETERS(ax, SLOW_HOMING_SPEED, slowCounts)
  sleep 100
  call EC_SLAVE_SET_HOMING_PARAMETERS(ax, HOMING_ACCELERATION, accCounts)
  sleep 100
end sub

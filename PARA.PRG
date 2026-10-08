'------------------------------------------------------------------------------
' File:        PARA.PRG
' Purpose:     Hexagon centralized application parameters
' Version:     3.00
' Description: XY_SU.PRG is retired. All final application parameters follow
'              this machine's original PARA.PRG values and direct-setting style.
'------------------------------------------------------------------------------

common shared HexSN as string="55126008"
common shared ParaVer as string="V3.0_NEW-FW-20260622"
dim shared xAttachPrg as string
dim shared yAttachPrg as string
dim shared zAttachPrg as string
dim shared xfAttachPrg as string
dim shared zfAttachPrg as string
dim shared groupAttachPrg as string

program

  try
    xAttachPrg=x.AttachedTo
    if xAttachPrg <> "" then
      Detachfrom$ x File=xAttachPrg
    end if
    yAttachPrg=y.AttachedTo
    if yAttachPrg <> "" then
      Detachfrom$ y File=yAttachPrg
    end if
    zAttachPrg=z.AttachedTo
    if zAttachPrg <> "" then
      Detachfrom$ z File=zAttachPrg
    end if
    xfAttachPrg=X_F.AttachedTo
    if xfAttachPrg <> "" then
      Detachfrom$ X_F File=xfAttachPrg
    end if
    zfAttachPrg=Z_F.AttachedTo
    if zfAttachPrg <> "" then
      Detachfrom$ Z_F File=zfAttachPrg
    end if
    groupAttachPrg=gXYZ.AttachedTo
    if groupAttachPrg <> "" then
      Detachfrom$ gXYZ File=groupAttachPrg
    end if
  catch else
  end try

  call SetXAxisParameters
  call SetYAxisParameters
  call SetZAxisParameters
  call SetXFParameters
  call SetZFParameters
  call SetGroupParameters

  try
    if xAttachPrg <> "" then
      AttachTo$ x File=xAttachPrg
    end if
    if yAttachPrg <> "" then
      AttachTo$ y File=yAttachPrg
    end if
    if zAttachPrg <> "" then
      AttachTo$ z File=zAttachPrg
    end if
    if xfAttachPrg <> "" then
      AttachTo$ X_F File=xfAttachPrg
    end if
    if zfAttachPrg <> "" then
      AttachTo$ Z_F File=zfAttachPrg
    end if
    if groupAttachPrg <> "" then
      AttachTo$ gXYZ File=groupAttachPrg
    end if
  catch else
  end try

  '摇杆和限位参数
  JOG_TYPE=1
  XLimitDiff=2
  YLimitDiff=2
  ZLimitDiff=1
  xDecPos=40
  yDecPos=55
  zDecPos=30

  'SR摇杆参数
  JOG_FAST_SPEED=100
  JOG_SLOW_SPEED=0.2
  xSecVlim=0.2
  ySecVlim=0.2
  zSecVlim=0.1

  'RS摇杆参数
  JOG_SPEED_MAX=100

  '测头参数
  backMoveVelocity=30
  backDistance=10

  '回零参数
  HOME_FAST_SPEED_AX=30
  HOME_SLOW_SPEED_AX=10
  HOME_ACC_AX=500
  HOME_ACC_GR=500
  HOME_FAST_SPEED_GR=20
  HOME_SLOW_SPEED_GR=10

  Print "Hexagon parameters setup is done"

end program


'==============================================================================
' X轴参数：对应最早 PARA.PRG 中的 Attach x 参数块。
'==============================================================================
sub SetXAxisParameters

  Attach x
    x.PMax=3
    x.PMin=-306
    x.VCruise=350
    x.VMax=750
    x.Acc=2000
    x.Dec=x.Acc
    x.PESettle=0.0028
    x.PFac=1000000
    x.PEMax=50
    x.VelocityOverSpeed=1.2*x.VMax
  Detach x

end sub


'==============================================================================
' Y轴参数：对应最早 PARA.PRG 中的 Attach y 参数块。
'==============================================================================
sub SetYAxisParameters

  Attach y
    y.PMax=4
    y.PMin=-402
    y.VCruise=350
    y.VMax=750
    y.Acc=2000
    y.Dec=y.Acc
    y.PESettle=0.0028
    y.PFac=1000000
    y.PEMax=50
    y.VelocityOverSpeed=1.2*y.VMax
  Detach y

end sub


'==============================================================================
' Z轴参数：对应最早 PARA.PRG 中的 Attach z 参数块。
' 原文件没有设置 z.VMax，因此这里不新增该参数。
'==============================================================================
sub SetZAxisParameters

  Attach z
    z.PMax=9
    z.PMin=-313
    z.VCruise=100
    z.VMax=120
    z.Acc=500
    z.Dec=z.Acc
    z.PESettle=0.0028
    z.PFac=1000000
    z.PEMax=20
    z.VelocityOverSpeed=1.2*z.VMax
  Detach z

end sub


' Copy only PARA overrides; base axis settings belong to AX_SETUP.PRG.
sub SetXFParameters
  Attach X_F
    X_F.PMax=x.PMax
    X_F.PMin=x.PMin
    X_F.VCruise=x.VCruise
    X_F.VMax=x.VMax
    X_F.Acc=x.Acc
    X_F.Dec=x.Dec
    X_F.PESettle=x.PESettle
    X_F.PFac=x.PFac
    X_F.PEMax=x.PEMax
    X_F.VelocityOverSpeed=x.VelocityOverSpeed
  Detach X_F
end sub

sub SetZFParameters
  Attach Z_F
    Z_F.PMax=z.PMax
    Z_F.PMin=z.PMin
    Z_F.VCruise=z.VCruise
    Z_F.VMax=z.VMax
    Z_F.Acc=z.Acc
    Z_F.Dec=z.Dec
    Z_F.PESettle=z.PESettle
    Z_F.PFac=z.PFac
    Z_F.PEMax=z.PEMax
    Z_F.VelocityOverSpeed=z.VelocityOverSpeed
  Detach Z_F
end sub

'==============================================================================
' XYZ轴组参数：数值来自本目录原 PARA.PRG。
'==============================================================================
sub SetGroupParameters

  Attach gXYZ
    gXYZ.PeMax=Sqrt(x.PeMax^2+y.PeMax^2+z.PeMax^2)

    gXYZ.J1.PMax=x.PMax
    gXYZ.J1.PMin=x.PMin
    gXYZ.J2.PMax=y.PMax
    gXYZ.J2.PMin=y.PMin
    gXYZ.J3.PMax=z.PMax
    gXYZ.J3.PMin=z.PMin

    gXYZ.XMax=x.PMax
    gXYZ.XMin=x.PMin
    gXYZ.YMax=y.PMax
    gXYZ.YMin=y.PMin
    gXYZ.ZMax=z.PMax
    gXYZ.ZMin=z.PMin

    gXYZ.VMax=900
    gXYZ.AMax=5400
    gXYZ.DMax=gXYZ.AMax
    gXYZ.JMax=15000
    gXYZ.Acc=3600
    gXYZ.Dec=gXYZ.Acc
    gXYZ.Jerk=gXYZ.JMax
    gXYZ.DecStop=gXYZ.DMax*1.5
  Detach gXYZ

end sub

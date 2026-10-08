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
simsetup(x)
simsetup(y)
simsetup(z)
simsetup(X_F)
simsetup(Z_F)
SetGroup(gXYZ)

end program ' <MyTask>.prg
sub simsetup( ax as generic axis)
with ax
  busnumber = 0
  dadd = 0
  attach
  simulated = 1
  pemax = 1e10
  pfac = 1000000
  vfac = pfac / 1000
  afac = vfac / 1000
  jfac = afac / 1000
  vcruise = 50
  vmax = 500
  amax = 5000
  jmax = 50000
  VELOCITYOVERSPEED = 1e10
  detach
end with
end sub

sub SetGroup(gr as generic group)
  dim i as long
  dim omega as double = 15
  dim profile as long = -1 'sine acc
  with gr
    attach
      en = 0
      sleep 10
      vfac = 1/1000
      afac = vfac/1000
      jfac = afac/1000
      positionerrorsettle = 2
      pemax  = 1
      abs = 1

      x.axistype = 0
      y.axistype = 0
      z.axistype = 0

      configgroup

      vmax = 500 '  mm/sec
      amax = 1500 '  1500 mm/sec^2
      dmax = 1500 '  1500 mm/sec^2
      jmax = omega*amax  
      vcruise = vmax
      acc = amax
      dec = dmax
      jerk = jmax

      vmtran = vmax
      amtran = amax
      jmtran = jmax
      vtran = vmtran
      atran = amtran
      dtran = amtran
      jtran = jmtran

      vmrot = vmax
      amrot = amax
      jmrot = jmax
      vrot = vmrot
      arot = amrot
      drot = amrot
      jrot = jmrot

      xmax = 300
      xmin = 0

      ymax = 300
      ymin = 0

      zmax =  300
      zmin =  0

      rmin = 0
      rmax = 4000

      smooth = -1
      prftype = profile

      j1.pmin = 0
      x.pmin = 0
      
      j2.pmin = 0
      y.pmin = 0
      
      j3.pmin = 0
      z.pmin = 0
      
      j1.pmax = 300
      x.pmax = 300
      
      j2.pmax = 300
      y.pmax = 300
      
      j3.pmax = 300
      z.pmax = 300
      
      Print "group ";elementname;" set."
      detach
  end with
end sub

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

sys.naxes = 5
common shared gXYZ as group axisname=a1 axisname=a2 axisname=a3 model=1 of xyz
common shared Axes[64] as generic axis
' 1: no EtherCAT slaves (simulation); 0: five physical drives.
common shared sys_simulated as long = 1
common shared FWVERSION as double = 0.0

program continue
  Load UTILS.LIB
  
  Axes[1] = A1
  Axes[2] = A2
  Axes[3] = A3
  Axes[4] = A4
  Axes[5] = A5

  a1.axisname=x
  a2.axisname=y
  a3.AxisName =z
  a4.AxisName =X_F
  a5.AxisName =Z_F
  

  sys.DoubleFormat=1
  
  sys.Name="ServoTronix"

  sys.NoMotion = 1
  
  Print "Hex. Configure Done"
 

terminate program ' <MyTask>.prg



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

common shared vel_xy as double
common shared repetbility as double
common shared start_xy_test as long = 1
common shared counterTime as long = 0
common shared counterTime_y as long =0
common shared counterTime_x as long =0

common shared y_flag as long = 1
common shared x_flag as long = 1
common shared channel_ports[2] as long

' module global variables


program
    vel_xy = 100
    channel_ports[1] = 5
    channel_ports[2] = 6
    call initPar
  
   '调用的子程序名，根据实际情况更改
    call t_x
end program ' <MyTask>.prg


'运动参数初始化，根据需要调整加速度预加加速度的倍率关系
sub initPar
     
'      ?vesexecute("sys.Motion = 1")
'      sys.Motion = 1
      Attach gXYZ
              gXYZ.VCruise=500
              gXYZ.VMax=1.5*gXYZ.VCruise
              gXYZ.Acc=gXYZ.VCruise*6
              gXYZ.Jerk=5*gXYZ.Acc
              gXYZ.AMax=1.5*gXYZ.Acc
              gXYZ.JMax=1.5*gXYZ.Jerk
              gXYZ.DMax=gXYZ.AMax
              gXYZ.Dec=gXYZ.Acc
              
              x.VCruise=300
              x.Acc = 6 * x.VCruise
              x.Dec = x.Acc
              x.Vmax=1.5*x.Vcruise
              x.AMax = 1.5*x.Acc
              x.DMax=y.AMax
              x.Jerk=7*x.acc            
              x.VelocityOverSpeed = 1.2* x.Vmax
              x.JMax=1.2*x.Jerk
              
              
              y.VCruise=300
              y.Acc = 6 * y.VCruise
              y.Dec = y.Acc
              y.Vmax=1.5*y.Vcruise
              y.AMax = 1.5*y.Acc
              y.DMax=y.AMax
              y.Jerk=  7*y.acc
              y.VelocityOverSpeed = 1.2* y.Vmax
              y.JMax=1.2*y.Jerk
              
              
'               gxyz.Jerk=10000
'               gxyz.PEMax = 150'50
               gxyz.pemax=50
               
               x.PEMax=50'15
               y.PEMax=50'15
               z.PEMax=15
               
               z.AMAX = 8*z.Vmax
               Z.Acc = 0.6*Z.AMax
               
               Z.DMax=Z.AMax
               Z.Dec = 0.8*Z.DMax
               
               Z.JMAX = 10* Z.AMAX
               Z.Jerk = 0.8*Z.JMax
               
               
'              Jerk = 30000
              
      
  Detach gXYZ
end sub



'测试轴组的定位时间
sub t_xy
  
  dim rpTimes as long =0

 try
    Open "Data_xy.DAT" Mode="w" as #channel_ports[1]
  catch 5043
    Print "The Stream is already open, Closing and Reopening"
    close #channel_ports[1]
    Open "Data_xy.DAT" Mode="w" as #channel_ports[1]
  end try
  
  
   try
    Open "SetT_xy.DAT" Mode="w" as #channel_ports[2]
  catch 5043
    Print "The Stream is already open, Closing and Reopening"
    close #channel_ports[2]
    Open "SetT_xy.DAT" Mode="w" as #channel_ports[2]
  end try
  
  
  with gXYZ
'      while 1
      Attach
        en=1
        Sleep 100
        Print  "XY PE :"
        Print "************************************************:"
'        Print #channel_ports[1],"start test :"
'        Print #channel_ports[1],"************************************************:"
'        Print #channel_ports[2],"start test  XY SETTIME:"
'        Print #channel_ports[2],"************************************************:"
        
     for rpTimes = 1 to 100 step 1
'       while start_xy_test

'        move {-0.025,-0.025} abs=1 Vcruise=vel_xy
        move {-10,-10,0} abs=1 Vcruise=vel_xy
        call waitisfinished_xy
        'sleep 300
        sleep 100
'        move {0.025,0.025} abs=1 Vcruise=vel_xy
        move {-290,-390,-300} abs=1 Vcruise=vel_xy
        call waitisfinished_xy
'        sleep 100
         call  rcRepgr(gXYZ,-290,-390,-300)  '传递的目标位置与上一条运动指令保持一致
          Print #channel_ports[2],counterTime
        Print  counterTime
        repetbility = gXYZ.pe
        Print repetbility
        Print #channel_ports[1],repetbility
        delay 1000
'      end while
      next


      Detach  
  end with

      Print "Finished"
      Print #channel_ports[1],"Finished"
'      sleep 100
      gXYZ.en=0
      Sleep 10
      close #channel_ports[1]
      close #channel_ports[2]
      sleep 100
  
end sub

'z轴整定时间测量
sub t_z

  dim times_rp as long = 0
  
    try
    Open "Data_z.PRG" Mode="w" as #channel_ports[1]
  catch 5043
    Print "The Stream is already open, Closing and Reopening"
    close #channel_ports[1]
    Open "Data_z.PRG" Mode="w" as #channel_ports[1]
  end try
  
  
    
   try
    Open "SetT_z.DAT" Mode="w" as #channel_ports[2]
  catch 5043
    Print "The Stream is already open, Closing and Reopening"
    close #channel_ports[2]
    Open "SetT_z.DAT" Mode="w" as #channel_ports[2]
  end try
 
  with z
      Attach
        en=1
        Sleep 100
        Print  "start test z: z :"
        Print "************************************************:"
'        Print #channel_ports[1],"start test :"
'        Print #channel_ports[1],"************************************************:"
'        
'        Print #channel_ports[2],"start test :"
'        Print #channel_ports[2],"************************************************:"
        
      for times_rp = 1 to 100 step 1
        move -10 abs=1 Vcruise=vel_xy
        delay 1000
        call waitisfinished_z
        'delay 1000
        move -290 abs=1 Vcruise=vel_xy
        call waitisfinished_z
        call rcRep(z,-290)
        Print counterTime
         Print #channel_ports[2],counterTime
         
        'repetbility = y.pcmd - y.PFb
        repetbility = z.pe
        Print repetbility
        Print #channel_ports[1],repetbility
        delay 1000
      next
      
      Print "Finished"
      Print #channel_ports[1],"Finished"
        Print #channel_ports[2],"Finished"
      
      Sleep 10
      close #channel_ports[1] 
      close #channel_ports[2] 
      
      Detach  
  end with
end sub



'y轴整定时间测试
sub t_y

  dim times_rp as long = 0
  
    try
    Open "Data_y.PRG" Mode="w" as #channel_ports[1]
  catch 5043
    Print "The Stream is already open, Closing and Reopening"
    close #channel_ports[1]
    Open "Data_y.PRG" Mode="w" as #channel_ports[1]
  end try
   
    
   try
    Open "Set_Y.DAT" Mode="w" as #channel_ports[2]
  catch 5043
    Print "The Stream is already open, Closing and Reopening"
    close #channel_ports[2]
    Open "Set_Y.DAT" Mode="w" as #channel_ports[2]
  end try
 
  with y
      Attach
        en=1
        Sleep 100
        Print  "start test y: y :"
        Print "************************************************:"
'        Print #channel_ports[1],"start test :"
'        Print #channel_ports[1],"************************************************:"
'       
'        Print #channel_ports[2],"start test :"
'        Print #channel_ports[2],"************************************************:"
      for times_rp = 1 to 100 step 1
        move -10 abs=1 Vcruise=vel_xy
        call waitisfinished_y
        'delay 1000
        move -390 abs=1 Vcruise=vel_xy
        call waitisfinished_y
        
        call rcRep(Y,-390)
        
        Print counterTime
        Print #channel_ports[2],counterTime
        'repetbility = y.pcmd - y.PFb
        repetbility = y.pe
        Print repetbility
        Print #channel_ports[1],repetbility
        delay 1000
      next
      
      Print "Finished"
      Print #channel_ports[1],"Finished"
       Print #channel_ports[2],"Finished"
      
      Sleep 10
      close #channel_ports[1] 
      close #channel_ports[2]
      Detach  
  end with
end sub

'单轴整定时间计算函数
sub rcRep(ax as generic axis,byval targetPos as double)
   
   
      while ax.ismoving <> 0 'ax.pcmd <> targetPos
          sleep 1
      end while 
        counterTime = sys.Clock
        while ax.IsSettled <> 1 
             sleep 1 
'             if abs(ax.pe) >= ax.PositionErrorSettle then
''                Print "over shoot :PE:   ",ax.pe
'             end if
        end while
         counterTime = sys.Clock - counterTime
         Print "single ax Settle time is:   ", counterTime
         
end sub

'轴组整定时间计算函数
 sub rcRepgr(gr as generic group,byval xcmd as double,byval ycmd as double,byval zcmd as double)

      while gr.pcmd{1} <> xcmd AND  gr.pcmd{2} <> ycmd AND gr.pcmd{3} <> zcmd
          sleep 1
      end while 
        counterTime = sys.Clock
        while gr.IsSettled <> 1 

             if y.IsSettled = 1 AND y_flag then
                counterTime_y = sys.Clock - counterTime
                Print "y is settled at time:" , counterTime_y
                y_flag=0
             end if
             
             if x.IsSettled =1 AND x_flag then 
                counterTime_x = sys.Clock - counterTime
                Print "x is settled at time: ",counterTime_x
                x_flag = 0
             end if
'             
'             if abs(gr.pe) > gr.pesettle then 
'                Print "over shoot group :PE:   ",gr.pe
'             end if
'             
'             if abs(x.PE) > x.PESettle then
'                  Print "OverShoot X axis: ",x.PE
'             end if
'             
'             if abs(y.PE) > y.PESettle then
'                  Print "OverShoot Y axis:",y.PE
'             end if
             
             sleep 1 
        end while
         counterTime = sys.Clock - counterTime
         Print "group Settle time is:   ", counterTime
         
end sub



'x轴整定时间测试程序
sub t_x

  dim times_rp as long = 0
  
    try
    Open "Data_x.PRG" Mode="w" as #channel_ports[1]
  catch 5043
    Print "The Stream is already open, Closing and Reopening"
    close #channel_ports[1]
    Open "Data_x.PRG" Mode="w" as #channel_ports[1]
  end try
  
  
  try
    Open "Set_x.DAT" Mode="w" as #channel_ports[2]
  catch 5043
    Print "The Stream is already open, Closing and Reopening"
    close #channel_ports[2]
    Open "Set_x.DAT" Mode="w" as #channel_ports[2]
  end try
 
  with x
      Attach
        en=1
        Sleep 100
        Print  "start test x: x..."
        Print "************************************************:"
'        Print #channel_ports[1],"start test x: x...:"
'        Print #channel_ports[1],"************************************************:"
'        
'        Print #channel_ports[2],"start test :"
'        Print #channel_ports[2],"************************************************:"
    
      for times_rp = 1 to 100 step 1
     
'      while start_xy_test
      
        move 0 abs=1 Vcruise=vel_xy
        call waitisfinished_x
        sleep 100
        move -300 abs=1 Vcruise=vel_xy
        call waitisfinished_x  
        call rcRep(x,-300)
        
        Print counterTime
        Print #channel_ports[2],counterTime
     
        repetbility = x.pe
        Print repetbility
        Print #channel_ports[1], repetbility
        
          delay 1000 
'      end while
      next     
      Print "Finished"
      Print #channel_ports[1],"Finished"
      Print #channel_ports[2],"Finished"
      
      Sleep 10
      close #channel_ports[1]
      close #channel_ports[2]
      sleep 100
      Stop
      call waitisfinished_x
      En=0
      Detach  
  end with
end sub



sub waitisfinished_x
          while x.IsMoving <> 0
            Sleep 1
          end while
end sub


sub waitisfinished_y
          while y.IsMoving <> 0
            Sleep 1
          end while
end sub

sub waitisfinished_z
          while z.IsMoving <> 0
            Sleep 1
          end while
end sub

sub waitisfinished_xy
          while gXYZ.IsMoving <> 0
            Sleep 1
          end while
end sub
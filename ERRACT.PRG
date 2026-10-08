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
common shared tcounter as long = 0
common shared estop_flag as long
common shared estop_flag4 as long 
common shared estop_flag1 as long = 0 
dim shared a1 as long =0

program

OnError
  catch 5041
      killtask erract.prg
      sleep 100
      continuetask erract.prg
  catch else
      sleep 10 ' to eliminate tight loop
    '  bErrorInOnError = 1
    Continuetask ERRACT.PRG
end onError

while sys_simulated = 1
  sleep 100
end while

while 1
'      if TM then
'          killtask tman.prg
'          tcounter=0
'          while tman.prg.state <> 10 and tcounter <50
'            sleep 10
'            tcounter = tcounter + 1
'           end while
'           continuetask tman.prg
'           TM=0    
'      end if
      while (not homingIsDone)
          sleep 100
      end while
      if  (not sys.din.1002) then
          estop_flag=0
          estop_flag4=0
          sleep 10
      end if
      
    if (SYS_OP_MODE = SYS_OP_JOG_MODE) and (sys.din.1002) and (not estop_flag4)  then
        grNewTarget=0
        if (jog_x.prg.state=4) then
          tcounter=0           
          killtask jog_x.prg          
          while jog_x.prg.state <> 10 and tcounter <100
            sleep 10
            tcounter = tcounter + 1
          end while
        end if

        if (jog_y.prg.state=4) then
          tcounter=0           
          killtask jog_y.prg          
          while jog_y.prg.state <> 10 and tcounter <100
            sleep 10
            tcounter = tcounter + 1
          end while
        end if

        if (jog_z.prg.state=4) then
          tcounter=0           
          killtask jog_z.prg          
          while jog_z.prg.state <> 10 and tcounter <100
            sleep 10
            tcounter = tcounter + 1
          end while
        end if

          tcounter=0
          if (tman.prg.state <> 1) then            
            killtask tman.prg
  '          tcounter=0
            while tman.prg.state <> 10 and tcounter <100
              sleep 10
              tcounter = tcounter + 1
            end while
            tcounter=0
            if tman.prg.state = 10 then
              StartTask tman.prg
              while tman.prg.state <> 1 and tcounter <100
                sleep 10
                tcounter = tcounter + 1
              end while 
            end if                        
           end if

        if (mvgroup.prg.state=4) then
        tcounter=0           
        killtask mvgroup.prg          
        while mvgroup.prg.state <> 10 and tcounter <100
        sleep 10
        tcounter = tcounter + 1
         end while
          end if
          estop_flag4=1        
    end if
    
      if (SYS_OP_MODE = SYS_OP_IPP_MODE) and (sys.din.1002) and (not estop_flag)  then
          grNewTarget=0
          tcounter=0           
          killtask jog_x.prg          
          while jog_x.prg.state <> 10 and tcounter <100
            sleep 10
            tcounter = tcounter + 1
           end while
           
          tcounter=0 
          killtask jog_y.prg          
          while jog_y.prg.state <> 10 and tcounter <100
            sleep 10
            tcounter = tcounter + 1
           end while
           
          tcounter=0 
          killtask jog_z.prg
          while jog_z.prg.state <> 10 and tcounter <500
            sleep 10
            tcounter = tcounter + 1
           end while 
           
           sleep 500
           
           
          tcounter=0
          if tman.prg.state <> 1 then            
            killtask tman.prg
  '          tcounter=0
            while tman.prg.state <> 10 and tcounter <100
              sleep 10
              tcounter = tcounter + 1
            end while
            tcounter=0
            if tman.prg.state = 10 then
              StartTask tman.prg
              while tman.prg.state <> 1 and tcounter <100
                sleep 10
                tcounter = tcounter + 1
              end while 
            end if                        
           end if 
                      
            tcounter=0         
            killtask mvgroup.prg           
            while mvgroup.prg.state <> 10 and tcounter <1000
              sleep 10
              tcounter = tcounter + 1
            end while
            if mvgroup.prg.state <> 10 then
               print "mvgroup.prg is not been killed..."
            end if
            
            singal1=0
            singal2=0
            singal3=0
          sleep 10
          estop_flag=1
          estop_flag1=1
'          grNewTarget=0
'          sleep 10
'          call sendDeferredResponce(axRespFileDesc,axSeq,0)            
      end if
      if (SYS_OP_MODE = SYS_OP_IPP_MODE) and (not sys.din.1002) and (estop_flag1)  then
'          continuetask tman.prg
          sleep 1000
          estop_flag1=0
          grNewTarget=0
          sleep 10
          call sendDeferredResponce(axRespFileDesc,axSeq,0)       
      end if 
      sleep 10
end while 
      
end program ' <MyTask>.prg

'------------------------------------------------------------------------------
' File:        <MyTask>.prg
' Purpose:     Just an example of a module header
' Version:     1.00
' Author:      <MyFullName>
' Description:
' History:     YYYY-MM-DD  <MyShortCut>  V1.00
'              Created
'              MC switch SYS_OP_MODE
'              2019/09/30  add semaphore for kill and restar jog tasks
'------------------------------------------------------------------------------

' module global "constants"


' module global variables


COMMON SHARED semKill AS SEMAPHORE


common shared actionEnable as long = 0
dim shared lPError as long


program continue

      OnError
        catch 65
          detach gxyz
        print "Error 65 in ProbeJOG.prg" 
        
'        catch else
'         continuetask PROBEJOG.PRG
      
      End OnError


      OnEvent TPJOG (SYS_OP_MODE = 1 and sys.din.1010 = 0 and sys.din.2010 = 0 and sys.din.3010 = 0 and probeEnable=1)                                                                        

           Stop gxyz StopType=IMMEDIATE                  
           probeStop = gxyz.setpoint
'           Proceed gxyz ProceedType = CLEARMOTION  
'           print "locStart: ", locStart          
'           print "BProbe: ", BProbe

           dirDecEnable=1
                                                                              
           TX = TprobeGetPosition(x)/x.PFac
           TY = TprobeGetPosition(y)/y.PFac
           TZ = TprobeGetPosition(z)/z.PFac
           probeTrigger=1  'send touch postion to host                         
                            
           actionEnable=1  'start back movement in JOG mode    
           print "PROBEJOG is triggerd"       
       End OnEvent    
       
      EventOn TPJOG
            
  
       while 1 
                 
         if actionEnable then       
                        
             Call modeHandle                                                                  
                          
             try  
                Proceed gxyz ProceedType = CLEARMOTION                      
             catch else                  
                print "Proceed gxyz error "               
             end try                          
             
             
             Call attachTask 
                         
             try                           
                lPError = backGroupMove(backDistance,backMoveVelocity)                      
             catch else
                lPError = errornumber
             end try           
              
             if 0 = lPError then             
                 while gxyz.IsMoving<>0
                   sleep 10
                 end while
                 
                 try 
                    detach gxyz
                 catch else
                    Print "detach error in PROBEGR.PRG"
                 end try                
                              
              
                 
               call  sendDeferredResponce(axRespFileDesc,axSeq,0)
               print "back movement done in TPJOG!" 
               cmdFlag=0
               sendflag=1
               motStart=0
                             
             else
               call  sendDeferredResponce(axRespFileDesc,axSeq,errornumber)
               print "back movement error in TPJOG ";errornumber                                       
             end if 
             
             call enableMcJog
             sleep 100
             
             actionEnable = 0 
             
         end if

        if x.IsMoving =0 and y.IsMoving = 0 and z.IsMoving = 0 then
          locStart = gxyz.setpoint    
        end if
        
        sleep 1
      
     end while
        
 
end program ' <MyTask>.prg



sub modeHandle
     while semaphoreTake(semKill,100) = 0 
        sleep 1
     end while     
     KillTask jog_x.prg
     sleep 10 
     while jog_x.prg.state = 1 
        KillTask jog_x.prg
        sleep 10
     end while
     
     KillTask jog_y.prg
     sleep 10         
     while jog_y.prg.state = 1 
        KillTask jog_y.prg
        sleep 10
     end while
      
     KillTask jog_z.prg
     sleep 10        
     while jog_z.prg.state = 1 
         KillTask jog_z.prg
         sleep 10
     end while 
     semaphoreGive(semKill)
end sub


sub attachTask
   while semaphoreTake(semKill,100) = 0 
      sleep 1
   end while           
   try
      KillTask jog_x.prg
      KillTask jog_y.prg
      KillTask jog_z.prg
      detachfrom x File = jog_x.prg
      detachfrom y File = jog_y.prg
      detachfrom z File = jog_z.prg 
      attach gxyz
                      
    catch 3025
      detachfrom x File = jog_x.prg
      detachfrom y File = jog_y.prg
      detachfrom z File = jog_z.prg
      attach gxyz 
      print "attach gxyz error in ProbeJOG.PRG"
  end try  
  semaphoreGive(semKill)
end sub


function backGroupMove(byval dBackDistance as double,byval dBackVelocity as double) as long
  backGroupMove = 0
  try

      move gxyz dBackDistance*newDestUnit abs = 0 Vcruise = dBackVelocity jerk=10000'starttype=immediate
 
  catch else
      backGroupMove = user USR_GET_RECENT_ERROR(1,2,3)
  end try 
end function





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


common shared newDest as location of xyz
common shared PreTarget as location of xyz
common shared Target as location of xyz


program continue

  
  while 1
     call dir_Dection     
   sleep 1 
  end while
  
end program ' <MyTask>.prg


sub dir_Dection

   while not dirDecEnable
    sleep 1
   end while
   

  if SYS_OP_MODE =2 then
      PreTarget = #{touchPreTarget[1],touchPreTarget[2],touchPreTarget[3]}
      Target = #{touchTarget[1],touchTarget[2],touchTarget[3]}
      newDest = PreTarget - Target
      try 
         newDestUnit = newDest/Distl(newDest,#{0,0,0})
      catch else
         newDestUnit = #{0,0,0}
      end try
             
      dirDecEnable = 0   
      print "newDest:" newDest
      print "newDestUnit:" newDestUnit 
               
  else
       Print locStart,probeStop
       newDest = locStart - probeStop
       try 
         newDestUnit = newDest/Distl(newDest, #{0,0,0})
       catch else
         newDestUnit = #{0,0,0}
       end try
             
       dirDecEnable = 0
        
       print "newDest:" newDest
       print "newDestUnit:" newDestUnit
  
       
   end if    
    
end sub



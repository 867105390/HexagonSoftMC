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

dim shared bErrorInOnError as long =0
dim shared Homing_Is_Done as long =1

program  

OnError

  catch else
    sleep 10 ' to eliminate tight loop
    bErrorInOnError = 1
    continuetask VELLIM.PRG
end onError'

while Homing_Is_Done
  while not homingIsDone
    sleep 10
  end while
  
  if JOG_TYPE=1 then
    if (abs(x.PMax - x.PFb))<xDecPos or (abs(x.PFb - x.PMin))<xDecPos then     
      JOG_SPEED_FACTOR_X = xSecVlim
    else
      JOG_SPEED_FACTOR_X = 0.4
    end if
    
    if abs(x.PFb-XJOGTARGET)<4 then
      JOG_SPEED_FACTOR_X = 0
    end if 
    
'    
    if abs(y.PMax - y.PFb) < yDecPos or abs(y.PFb - y.PMin) < yDecPos then     
       JOG_SPEED_FACTOR_Y = ySecVlim   '
    else
       JOG_SPEED_FACTOR_Y = 0.4
    end if
    
    if abs(y.PFb-YJOGTARGET)<4 then
      JOG_SPEED_FACTOR_Y = 0
    end if
    
    if abs(z.PMax - z.PFb) < zDecPos or abs(z.PFb - z.PMin) < zDecPos then
      JOG_SPEED_FACTOR_Z = zSecVlim
    else 
      JOG_SPEED_FACTOR_Z = 0.4      
    end if
    
    if abs(z.PFb-ZJOGTARGET)<3 then
      JOG_SPEED_FACTOR_Z = 0
    end if
    
 end if
 
 if JOG_TYPE=2 then
   if abs(x.PMax - x.PFb) < xDecPos or abs(x.PFb - x.PMin) < xDecPos then     
      xSecLimit = xSecVlim  
    else
      xSecLimit = 1   
    end if
    
    if abs(x.PFb-XJOGTARGET)<1 then
      xSecLimit = 0
    end if 
    
    if abs(y.PMax - y.PFb) < yDecPos or abs(y.PFb - y.PMin) < yDecPos then     
      ySecLimit = ySecVlim   '
    else
      ySecLimit = 1
    end if
    
    if abs(y.PFb-YJOGTARGET)<2 then
      ySecLimit = 0
    end if
    
    if abs(z.PMax - z.PFb) < zDecPos or abs(z.PFb - z.PMin) < zDecPos then
      zSecLimit = zSecVlim
    else 
      zSecLimit = 1     
    end if 
    
    if abs(z.PFb-ZJOGTARGET)<1 then
      zSecLimit = 0
    end if
 
 end if
  
 sleep 1

end while

end program ' <MyTask>.prg

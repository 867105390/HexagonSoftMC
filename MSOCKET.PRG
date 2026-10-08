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
common shared socket_flag as long = 0

' module global variables


program

OnError
  catch else
      sleep 10 ' to eliminate tight loop
    '  bErrorInOnError = 1
    Continuetask MSOCKET.PRG
end onError

while 1

		while not homingIsDone 	
			sleep 10
		end while
		
		if homingIsDone and (not bSocketIsOpen1) and (not socket_flag) then  		
	 		KillTask JOG_X.PRG
	 		sleep 10
	 		KillTask JOG_Y.PRG
	 		sleep 10
	 		KillTask JOG_Z.PRG
	 		sleep 10
	 		KillTask MVAXES.PRG
	 		sleep 10
	 		KillTask MVGROUP.PRG
	 		sleep 10
   		if socket_flag=0 then   
   				attach gxyz
   					try
							call DuoEnableGroup(0)
							sleep 10
		  				if gxyz.En <>0 then
		    				print "gxyz.En fail..."
		  				end if
		  				catch else
		  				  sleep 10
		  			end try
		     				
	 					detach gxyz
	 	  				socket_flag=1
	 		end if
		end if
		 
		if homingIsDone and bSocketIsOpen1 then
   		socket_flag=0
		end if
 sleep 100

end while  
   
end program ' <MyTask>.prg

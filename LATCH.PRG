program continue
	if sys_simulated = 0 then
		preLatchPos = LatchGetPosition(3)
	end if
	while 1
		if sys_simulated = 0 and latchFlag = 1 then
			if preLatchPos <> LatchGetPosition(3) then
				zLatch[1] = zLatch[1] + 1
				zLatch[Int(zLatch[1]+1)] = LatchGetPosition(3)
				preLatchPos = LatchGetPosition(3)
				sleep 1
			else
				sleep 1
			end if
		end if
		sleep 1
	end while

end program

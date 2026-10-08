common shared xxx as long = sys.dout.3006
program
    OnEvent PCOMx xxx = 1
		print "test"
    End OnEvent


	EventOn PCOMX

	while 1 
		sleep 100
	end while

	EVENTOFF pcomx
end program
'------------------------------------------------------------------------------
' File:        TCPCOM.prg
' Purpose:     Just an example of a module header
' Version:     1.00
' Author:      <MyFullName>
' Description:
' History:     YYYY-MM-DD  <MyShortCut>  V1.00
'              Created
'------------------------------------------------------------------------------

' module global "constants"
common shared str_last_error as string
common shared str_error as string
common shared str_error_num as long
common shared str_send_cyc as string
common shared loop_run_cyc as long = 1
dim shared is_connected as long =0
' module global variables

program continue
 
  call func_openSocet
  
 while loop_run_cyc 
    if JOG_MOVE_X_SIGNAL<>0 OR JOG_MOVE_y_SIGNAL<>0 OR JOG_MOVE_z_SIGNAL<>0  then
      JOG_DEFLECTION_SIG = 1
    else
      JOG_DEFLECTION_SIG = 0
    end if

  try 
    str_send_cyc = "x:"+STR$(x.PFb)+";y:"+STR$(y.PFb)+";z:"+STR$(Z.PFb)+";"+ "state_x:"+STR$(X.IsMoving)+";"+ \
                    "state_y:"+STR$(Y.IsMoving)+";state_z:"+STR$(Z.IsMoving)+";js_state:"+STR$(JOG_DEFLECTION_SIG)+";trigger_sig:"+STR$(TRIGGER_SIG)
        'str_send_cyc = x.PFb,y.PFb,z.PFb,x.IsMoving,y.IsMoving,z.IsMoving,JOG_DEFLECTION_SIG,TRIGGER_SIG'STR$(x.PFb)+" "+STR$(y.PFb)+" "+STR$(Z.PFb)+" "+STR$(X.IsMoving)+" "+STR$(Y.IsMoving)+" "+STR$(Z.IsMoving)+" "+STR$(JOG_DEFLECTION_SIG)+" "+STR$(TRIGGER_SIG)                
                   
     str_send_cyc= str_send_cyc + ";zoom_in_sig:"+STR$(ZOOM_IN_SIG)+";zoom_out_sig:"+STR$(ZOOM_OUT_SIG)+";start_sig:"+STR$(START_SIG_EN)+";emergency_sig:"\
                    +STR$(EMERGENCY_STOP_SIG)+";group_en:"+STR$(gxyz.En)+";settle_flag:"+STR$(gxyz.IsSettled)+";collision_flag:"+STR$(bCollisionDetect)
  if str_send_cyc <> "" then
     print #2,str_send_cyc
  end if
  catch 5041
    call func_openSocet
  catch else
    call func_openSocet
  end try
 '' ErrorHistoryClear
  sleep 3
  
 end while
 
  close #2
  Print "Server #2 Closed Sockets."
 
end program


sub func_openSocet
  Try
    is_connected = 0
    OpenSocket Options=1 as #2
  catch 5043 'socket is already open
    print "socket 1 is already open. closing an reopening"
    close #2
    is_connected = 0
    OpenSocket Options=1 as #2
  End Try
   
   Accept(#2, 6002)
   is_connected = 1
end sub
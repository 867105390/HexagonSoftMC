' Master_Duo: bind only, after AX_SETUP and PARA in both startup modes.
program
  if DuoPositionsMatch then
    call DuoBind
    print "X_F -> X, Z_F -> Z: electronic gear 1:1 bound"
  else
    print "Duo positions differ: waiting for host five-axis homing command"
  end if
end program

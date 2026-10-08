' Five CDHD EtherCAT drives: X, Y, Z, X_F and Z_F.
' Drive 4 uses drive 1 settings; drive 5 uses drive 3 settings.
' Standard EC_SETUP entry, extended for Master_Duo.

common shared EC_SETUP_PRG_error_code as long = 0
common shared EC_SETUP_PRG_error_str as string = ""
common shared numOfSlaves as long = 0
common shared num_Of_Motion_Drives as long = 0
common shared ERR_EC_SETUP as error "ERROR SETTING UP ETHERCAT. CHECK EC_SETUP_PRG_error_code/EC_SETUP_PRG_error_str" 20764

program
  dim drive_addr as long
  dim retVal as long
  dim ec_setup_iterations as long = 1
  dim OPMODE_Error as long

  OnError
    Catch ERR_EC_SETUP.num
      print "EC_SETUP.PRG stopped; check EC_SETUP_PRG_error_code"
    Catch Else
      EC_SETUP_PRG_error_code = errornumber
      EC_SETUP_PRG_error_str = "EC_SETUP.PRG failed; check EC_SETUP_PRG_error_code"
      throw ERR_EC_SETUP
  End OnError

START_EC_SETUP:
  OPMODE_Error = 0
  numOfSlaves = EC_ETHERCAT_INIT
  num_Of_Motion_Drives = 5

  if numOfSlaves < num_Of_Motion_Drives then
    EC_SETUP_PRG_error_code = 1001
    EC_SETUP_PRG_error_str = "Master_Duo requires five EtherCAT drives"
    throw ERR_EC_SETUP
  end if

  for drive_addr = 1 to num_Of_Motion_Drives
    if EC_SLAVES_INFO[drive_addr]->vendor_id <> 0x2E1 or EC_SLAVES_INFO[drive_addr]->product_code <> 0x2EC then
      EC_SETUP_PRG_error_code = drive_addr
      EC_SETUP_PRG_error_str = "MISMATCH IN VENDOR ID or PRODUCT CODE"
      throw ERR_EC_SETUP
    end if
    call DuoMapPDOs(drive_addr)
  next

  retVal = EC_RESCAN_SLAVES
  sleep 500
  retVal = CHECK_TOPOLOGY
  EC_ADDRESS_BY_ALIAS = 0
  call EC_CREATE_MASTER
  call EC_SET_BUS_CYCLETIME(2000)
  retVal = EC_SET_NEW_STATIC_DISTANCE(300)

  for drive_addr = 1 to num_Of_Motion_Drives
    call DuoInstallDrive(drive_addr)
  next

  Try
    call EC_STARTMASTER
  Catch EC_MASTER_NOT_ALL_SLAVES_OPMODE.num
    OPMODE_Error = 1
  End Try

  if OPMODE_Error = 1 then
    call EC_STOPMASTER
    if ec_setup_iterations < 6 then
      ec_setup_iterations = ec_setup_iterations + 1
      print "Restarting EC_SETUP.PRG attempt #: ";ec_setup_iterations
      sleep 3000
      goto START_EC_SETUP
    end if
    throw EC_MASTER_NOT_ALL_SLAVES_OPMODE
  end if

  for drive_addr = 1 to numOfSlaves
    if ETSLAVES[drive_addr]->et_slavetype = ECAT_MOTIONSLAVE then
      Try
        call EC_CLEAR_FAULTS(drive_addr)
      Catch Else
        if EC_SDO_READ(drive_addr, 0x603F, 0) = 0x7386 then
          sleep 5000
          call EC_CLEAR_FAULTS(drive_addr)
        end if
      End Try
    end if
  next

  for drive_addr = 1 to num_Of_Motion_Drives
    call EC_SDO_WRITE(drive_addr, 0x60FE, 2, 32, 0x3F0000)
    if EC_IS_PDO(drive_addr, 0x6060, 0) then
      call EC_PDO_WRITE(drive_addr, 0x6060, 0, 8)
    else
      call EC_SDO_WRITE(drive_addr, 0x6060, 0, 8, 8)
    end if
  next
  print "Five-drive EtherCAT setup finished successfully"
end program

sub DuoMapPDOs(byval drive_addr as long)
  call EC_SDO_WRITE(drive_addr, 0x1C12, 0, 8, 0)
  call EC_SDO_WRITE(drive_addr, 0x1C12, 1, 16, 0x1600)
  call EC_SDO_WRITE(drive_addr, 0x1C12, 2, 16, 0x1601)
  call EC_SDO_WRITE(drive_addr, 0x1C12, 3, 16, 0x1603)
  call EC_SDO_WRITE(drive_addr, 0x1C12, 0, 8, 3)

  call EC_SDO_WRITE(drive_addr, 0x1600, 0, 8, 0)
  call EC_SDO_WRITE(drive_addr, 0x1600, 1, 32, 0x60400010)
  call EC_SDO_WRITE(drive_addr, 0x1600, 2, 32, 0x60600008)
  call EC_SDO_WRITE(drive_addr, 0x1600, 0, 8, 2)
  call EC_SDO_WRITE(drive_addr, 0x1601, 0, 8, 0)
  call EC_SDO_WRITE(drive_addr, 0x1601, 1, 32, 0x607A0020)
  call EC_SDO_WRITE(drive_addr, 0x1601, 2, 32, 0x60810020)
  call EC_SDO_WRITE(drive_addr, 0x1601, 0, 8, 2)
  call EC_SDO_WRITE(drive_addr, 0x1603, 0, 8, 0)
  call EC_SDO_WRITE(drive_addr, 0x1603, 1, 32, 0x60FE0120)
  call EC_SDO_WRITE(drive_addr, 0x1603, 2, 32, 0x60B20010)
  call EC_SDO_WRITE(drive_addr, 0x1603, 3, 32, 0x60B80010)
  call EC_SDO_WRITE(drive_addr, 0x1603, 0, 8, 3)

  call EC_SDO_WRITE(drive_addr, 0x1C13, 0, 8, 0)
  call EC_SDO_WRITE(drive_addr, 0x1C13, 1, 16, 0x1A00)
  call EC_SDO_WRITE(drive_addr, 0x1C13, 2, 16, 0x1A01)
  call EC_SDO_WRITE(drive_addr, 0x1C13, 3, 16, 0x1A02)
  call EC_SDO_WRITE(drive_addr, 0x1C13, 4, 16, 0x1A03)
  call EC_SDO_WRITE(drive_addr, 0x1C13, 0, 8, 4)

  call EC_SDO_WRITE(drive_addr, 0x1A00, 0, 8, 0)
  call EC_SDO_WRITE(drive_addr, 0x1A00, 1, 32, 0x60410010)
  call EC_SDO_WRITE(drive_addr, 0x1A00, 2, 32, 0x60610008)
  call EC_SDO_WRITE(drive_addr, 0x1A00, 0, 8, 2)
  call EC_SDO_WRITE(drive_addr, 0x1A01, 0, 8, 0)
  call EC_SDO_WRITE(drive_addr, 0x1A01, 1, 32, 0x60640020)
  call EC_SDO_WRITE(drive_addr, 0x1A01, 2, 32, 0x60780010)
  if drive_addr = 3 or drive_addr = 5 then
    ' Keep the original Z mapping, including its inactive third entry.
    call EC_SDO_WRITE(drive_addr, 0x1A01, 3, 32, 0x60770010)
  end if
  call EC_SDO_WRITE(drive_addr, 0x1A01, 0, 8, 2)
  call EC_SDO_WRITE(drive_addr, 0x1A02, 0, 8, 0)
  call EC_SDO_WRITE(drive_addr, 0x1A02, 1, 32, 0x20F20010)
  call EC_SDO_WRITE(drive_addr, 0x1A02, 2, 32, 0x20F90010)
  call EC_SDO_WRITE(drive_addr, 0x1A02, 3, 32, 0x60BA0020)
  call EC_SDO_WRITE(drive_addr, 0x1A02, 0, 8, 3)
  call EC_SDO_WRITE(drive_addr, 0x1A03, 0, 8, 0)
  call EC_SDO_WRITE(drive_addr, 0x1A03, 1, 32, 0x60FD0020)
  call EC_SDO_WRITE(drive_addr, 0x1A03, 2, 32, 0x20B60020)
  call EC_SDO_WRITE(drive_addr, 0x1A03, 3, 32, 0x60F40020)
  call EC_SDO_WRITE(drive_addr, 0x1A03, 0, 8, 3)
  ETSLAVES[drive_addr]->et_opmode = 8
end sub

sub DuoInstallDrive(byval drive_addr as long)
  dim io_base as long
  dim pcom_base as long

  call EC_SET_CTRL_OBJECT(EC_BUSID, drive_addr, EC_CTRL_INDEX_6040h, EC_CTRL_SUBINDEX_00h)
  call EC_SET_STATUS_OBJECT(EC_BUSID, drive_addr, EC_STATUS_INDEX_6041h, EC_STATUS_SUBINDEX_00h)
  call EC_SET_PCMD_OBJECT(EC_BUSID, drive_addr, EC_PCMD_INDEX_607Ah, EC_PCMD_SUBINDEX_00h)
  call EC_SET_PFB_OBJECT(EC_BUSID, drive_addr, EC_PFB_INDEX_6064h, EC_PFB_SUBINDEX_00h)
  call EC_SET_VCMD_OBJECT(EC_BUSID, drive_addr, EC_VCMD_INDEX_6081h, EC_VCMD_SUBINDEX_00h)
  call EC_SET_VADDCMD_OBJECT(EC_BUSID, drive_addr, EC_VADDCMD_INDEX_60B1h, EC_VADDCMD_SUBINDEX_00h)
  call EC_SET_TRQCMD_OBJECT(EC_BUSID, drive_addr, EC_TRQCMD_INDEX_6071h, EC_TRQCMD_SUBINDEX_00h)
  call EC_SET_TRQFBK_OBJECT(EC_BUSID, drive_addr, EC_TRQFBK_INDEX_6078h, EC_TRQFBK_SUBINDEX_00h)
  call EC_SET_TRQDMND_OBJECT(EC_BUSID, drive_addr, EC_TRQDMND_INDEX_6074h, EC_TRQDMND_SUBINDEX_00h)
  call EC_SET_TRQADDCMD_OBJECT(EC_BUSID, drive_addr, EC_TRQADDCMD_INDEX_60B2h, EC_TRQADDCMD_SUBINDEX_00h)
  call EC_SET_PEXT_OBJECT(EC_BUSID, drive_addr, EC_PEXT_INDEX_20B6h, EC_PEXT_SUBINDEX_00h)

  call EC_SDO_WRITE(drive_addr, 0x60C0, 0, 16, 2)
  call EC_SDO_WRITE(drive_addr, 0x6092, 1, 32, 1000000)
  call EC_SDO_WRITE(drive_addr, 0x6092, 2, 32, 1)
  call EC_SDO_WRITE(drive_addr, 0x6091, 1, 32, 1)
  call EC_SDO_WRITE(drive_addr, 0x6091, 2, 32, 1)
  call EC_SDO_WRITE_DOUBLE(drive_addr, 0x2108, 0, 32, 32)
  call EC_SDO_WRITE(drive_addr, 0x2109, 0, 16, 2)
  call EC_SDO_WRITE(drive_addr, 0x6098, 0, 8, 2)

  call EC_USE_SLAVE(drive_addr, 0x2E1, 0x2EC, "ECAT_AXIS_SLAVE", TRUE)
  io_base = drive_addr * 1000
  call EC_ASSOCIATE_PDO_TO_SYS_DIO(drive_addr, 0x60FD, 0, io_base, 11, 16)
  call EC_ASSOCIATE_PDO_TO_SYS_DIO(drive_addr, 0x60FE, 1, io_base, 6, 16)

  ' Preserve the original drives' HWA mapping; give new drives their own range.
  pcom_base = 1000
  if drive_addr > 3 then
    pcom_base = io_base
  end if
  call EC_ASSOCIATE_PDO_TO_SYS_DIO_HWA(drive_addr, 0x2191, 0, pcom_base + 6, 1, 0, 2)
  call EC_ASSOCIATE_PDO_TO_SYS_DIO_HWA(drive_addr, 0x2192, 0, pcom_base + 7, 1, 0, 2)
end sub




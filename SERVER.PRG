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

common shared bSocketIsOpen1 as long
dim shared instance as long = 10


program continue
  dim servers as string = "SrvrN"
' open server socket  
  Try
    OpenSocket Options=1 as #3
  catch 5043 'socket is already open
    print "socket 1 is already open. closing an reopening"
    close #3
    OpenSocket Options=1 as #3
  End Try
 
  while 1
 
    Try
      OpenSocket Options=1 as #instance
    catch 5043 'socket is already open
      print "socket: "instance "  is already open. closing an reopening"
      close #instance
      OpenSocket Options=1 as #instance
    End Try
 
 
    Accept(#3, #instance, 6001)
    load$ servers+".prg" as servers+"_"+str$(instance)+".prg"
   
 
    instance = instance + 1
    if instance > 99 then
      instance  = 10
    end if  
 
  end while
 
  close #3
  Print "Server Closed Sockets. Server Exits"
 
end program

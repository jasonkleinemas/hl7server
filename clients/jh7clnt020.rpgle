**FREE
//***************************************************************
ctl-opt DFTACTGRP(*NO) ACTGRP('QILE') BNDDIR('QC2LE') DEBUG(*YES);
//***************************************************************
dcl-f JH7CLNT020 workstn;
dcl-f JH7LOG     keyed;
//***************************************************************

dcl-pi *n;
  is_portNumber  char(5); // Port Number
end-pi;

dcl-ds cd qualified; // This will auto convert the data.
  asc char(32000) pos(1) ccsid(819);
  ebc char(32000) pos(1);
end-ds;

dcl-s gs_socketData        char(32000);     // Socket data
dcl-s gi_sockDataLength    int(10:0) inz (%size(gs_socketData));// Socket data  length
dcl-s gi_serverPortNumber  int(10:0);       // Port number
dcl-s gi_socketDescriptor  int(10:0);       // Socket description number for the client
dcl-s gi_socketReturnCode  int(10:0);       // Return code for sockets

//   Server name parameter (like 'machine.company.com' or 'LOCALHOST')
dcl-s ServerName            char(255) inz('LOCALHOST');
dcl-s GET_STR_LEN          zoned(5:0) inz(0);
dcl-s OLD_STR_LEN          zoned(5:0) inz(0);
dcl-s OLD_STR               char(32000);
dcl-s DONE                 zoned(1:0);
dcl-c HEX0B                     X'0B';
dcl-c HEX0D                     X'0D';
dcl-c HEX1C                     X'1C';
dcl-c HEX5F                     X'5F';
dcl-s END                  zoned(1:0) inz(0);
dcl-s gp_SocketData        pointer inz(%addr(gs_socketData));
dcl-s WorkDateTime         timeStamp;

//COPY QMISCCOPY,CPPSDS
/copy cb/jhxsckcpy.rpgle

//   Obtain a socket descriptor
gi_socketDescriptor = socket(AF_INET:SOCK_STREAM:0);
//   If socket failed - End the client program with dump
if gi_socketDescriptor < 0;
  return;
endif;
//   Fill in necessary fields in the IP address structure
SocketAddr = *allx'00';
SinFamily = AF_INET;
SinPort = gi_serverPortNumber;
//   Prepare the host name for the GetHostByName function
ServerName = %trim(ServerName) + X'00';
Server@ = %addr(ServerName);

//   Get the host address if given the server name
Host@ = GetHostByName(Server@);

//   If host name cannot be resolved - End the client program with dump
if Host@ = *null;
  return;
endif;
//   Set the pointer to the host entry data structure
HostEntData@ = HName@;

//   Copy the IP address from the host entry structure into
//   the server IP address structure
SinAddr = HAddrArr(1);

//   Connect to the server
gi_socketReturnCode = Connect(gi_socketDescriptor:%addr(SocketAddr):%size(SocketAddr));
//   If connect unsuccessful - End the client program with dump
if gi_socketReturnCode < 0;
  return;
endif;
dsply 'CONNECTED';

dow (not *INKC);
  exfmt REC1;

  if *INKC;
    iter;
  endif;
  OUTSNT0 = *blank;
  OUTSNT1 = *blank;
  OUTSNT2 = *blank;
  OUTSNT3 = *blank;
  OUTSNT4 = *blank;
  OUTSNT5 = *blank;
  OUTSNT6 = *blank;
  OUTSNT7 = *blank;
  OUTSNT8 = *blank;
  *IN19 = %error();
  if *In19 = *off;
    WorkDateTime = %timeStamp(INDATETIME);
    chain WorkDateTime LOGFILER;
    if %found(JH7LOG);
      exsr SendMessage;
    else;
      OUTSNT0 = 'Not Found';
    endif;
  else;
    OUTSNT0 = 'Bad Date';
  endif;
enddo;
//   End the program
callp close(gi_socketDescriptor);

*INLR = *On;
//***************************************************************
begsr SendMessage;

  OUTSNT0 = %subst(LOGDATA:1  :70); // This goes to the Screen
  OUTSNT1 = %subst(LOGDATA:71 :70);
  OUTSNT2 = %subst(LOGDATA:141:70);
  OUTSNT3 = %subst(LOGDATA:211:70);
  OUTSNT4 = %subst(LOGDATA:281:70);
  OUTSNT5 = %subst(LOGDATA:351:70);
  OUTSNT6 = %subst(LOGDATA:421:70);
  OUTSNT7 = %subst(LOGDATA:491:70);
  OUTSNT8 = %subst(LOGDATA:561:70);

  cd.ebc = LOGDATA;
  gs_socketData = cd.asc;

  gi_sockDataLength = %scan(HEX1C:gs_socketData) + 1;
  gi_socketReturnCode = write(gi_socketDescriptor:%addr(gs_socketData):gi_sockDataLength);
  gs_socketData = ' ';
  DONE = 0;
  dow DONE = 0;
    exsr readSocketData;
  enddo;

  OUTSNT9 = gs_socketData;
  gs_socketData = *blank;
  gi_sockDataLength = *zero;
endsr;
//************************************************************************
begsr readSocketData;

  gi_socketReturnCode = read(gi_socketDescriptor:gp_SocketData:gi_sockDataLength);

  if gi_socketReturnCode <= 0;
    DONE = 1;
  else;
    if gi_sockDataLength > 0;
      cd.asc = gs_socketData;
      gs_socketData = cd.ebc;
    endif;
    if %scan(HEX1C:gs_socketData) <> *zero;
      DONE = 1;
    endif;

  endif;
endsr;
//***************************************************************
// Initialization Subroutine
//***************************************************************
begsr *INZSR;
  gi_serverPortNumber = %int(is_portNumber);
endsr;


**free
//***************************************************************
ctl-opt DFTACTGRP(*NO) ACTGRP('QILE') BNDDIR('QC2LE') DEBUG(*YES);
//
//

//
//  30     Subfile Display Indicator
//  33     Subfile Clear Indicator
//  34     Subfile End Indicator
//  35     Subfile Display Control Indicator
//***************************************************************
// >>>>> File not found - conversion could be impaired.
dcl-f JH7CLNT010     WORKSTN INFDS(DSSUBF)
                             SFILE(SFL01:RRN);
dcl-f JH7LOG                 Keyed;
//***************************************************************
// Program Status Data Structure

dcl-pi *n;
  is_portNumber  char(5); // Port Number
end-pi;

dcl-ds dc qualified;
  asc char(32000) pos(1) ccsid(819);
  ebc char(32000) pos(1);
end-ds;

dcl-ds *n psds;
  W$PGM           char(10) pos(1);
  W$JOB           char(10) pos(244);
end-ds;
//
// Subfile File Level Data Structure
dcl-ds DSSUBF;
  SFLRR#          binDec(4:0) pos(376); // RRN of Current Page
  SFLPG#          binDec(4:0) pos(378); // Current Page Number
  SFLREC          binDec(4:0) pos(380); // Not Sure Just Yet
end-ds;
//
dcl-c #RECDS                    15;   // # Recds in Page
//
dcl-s RRN                 packed(4:0) inz;  // Rel. Rec. Num.
dcl-s @COUNT              packed(4:0) inz;  // Counter

//dcl-s PORT                 zoned(5:0);
dcl-s SocketData            char(32000);  //   Socket data
dcl-s SockDtaLen             int(10:0) inz (%size(SocketData)); //   Socket data  length
dcl-s serverPortNumber             uns(5:0); //   Port number
dcl-s SD                     int(10:0); //   Socket description number for the client
dcl-s RC                     int(10:0); //   Return code for sockets

//   Server name parameter (like 'machine.company.com' or 'LOCALHOST')
dcl-s ServerName            char(255) Inz('LOCALHOST');
dcl-s GET_STR_LEN          zoned(5:0) INZ(0);
dcl-s OLD_STR_LEN          zoned(5:0) INZ(0);
dcl-s OLD_STR               char(32000);
dcl-s DONE                 zoned(1:0);
dcl-c HEX0B                     X'0B';
dcl-c HEX0D                     X'0D';
dcl-c HEX1C                     X'1C';
dcl-c HEX5F                     X'5F';
dcl-s END                  zoned(1:0) INZ(0);
dcl-s SocketData@        pointer Inz(%Addr(SocketData));

/copy cb/jhxsckcpy.rpgle
//==========================================================================================
// Start of moved field definitions.
//==========================================================================================
//dcl-s ASCIITable            char(10);
//dcl-s CHAR                packed(5:0);
//dcl-s ConvLibr              char(10);
//dcl-s EBCDICTable           char(10);
//==========================================================================================
// End of moved field definitions.
//==========================================================================================


//ASCIITable  = 'QASCII    ';
//EBCDICTable = 'QEBCDIC   ';
//ConvLibr    = 'QSYS      ';
//***************************************************************
//   Obtain a socket descriptor
SD = Socket( AF_INET : SOCK_STREAM : 0);
//   If socket failed - End the client program
if SD < 0;
  return;
endif;
//   Fill in necessary fields in the IP address structure
SocketAddr = *allx'00';
SinFamily = AF_INET;
SinPort = serverPortNumber;
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
RC = Connect(SD:%addr(SocketAddr):%size(SocketAddr));
//   If connect unsuccessful - End the client program with dump
if RC < 0;
  return;
endif;
dsply 'CONNECTED';

exsr $LOAD;
dow (not *INKC);
  exsr $Display;
  if (*INKC);
    iter;
  endif;
  if (RRN > 0);
    exsr $Process;
  endif;
  if (*IN25);
    if (not *IN34);
      exsr $Load;
    endif;
    iter;
  endif;
enddo;
//   End the program
callp close(SD);

*inlr = *on;
//***************************************************************
// Initialize the Subfile
//***************************************************************
begsr $Init;

  RRN = 0;
  *IN33 = *On;
  *IN35 = *On;
  write CTL01;
  *IN30 = *Off;
  *IN33 = *Off;
  *IN34 = *Off;

endsr;
//***************************************************************
// Position in the Subfile
//***************************************************************
//    $Position     BEGSR

//    WKxxxx        SETLL     xxxxxxPF

//                  ENDSR
//***************************************************************
// Load the Subfile
//***************************************************************
begsr $Load;

  @COUNT = 0;

  dow (not *IN34) and (@COUNT < #RECDS);
    read JH7LOG;
    *IN34 = %eof();

    if (*IN34);
      iter;
    endif;
    OUTACK     = LOGDATA;
    HL7MESSAGE = LOGDATA;


    RRN = RRN + 1;
    @COUNT = @COUNT + 1;
    write SFL01;
  enddo;

  if (RRN > 0);
    *IN30 = *On;
  endif;

  RECNBR = RRN;

endsr;
//***************************************************************
// Display the Subfile
//***************************************************************
begsr $Display;

  write OVR01;
  exfmt CTL01;
  RECNBR = SFLPG#;

endsr;
//***************************************************************
// Process the Subfile
//***************************************************************
begsr $Process;

  *IN95 = *Off;

  dow (not *IN95);
    readc SFL01;
    *IN95 = %eof();

    if (*IN95);
      iter;
    endif;

    if (INOPT = '1');
      exsr $Opt1;
    endif;

    INOPT = ' ';
    update SFL01;
    write CTL01;
  enddo;

endsr;
//***************************************************************
// Option 1
//***************************************************************
begsr $Opt1;
  SocketData = hl7MESSAGE;
  
  dc.ebc = SocketData;
  SocketData = dc.asc;
  SockDtaLen = %scan(HEX1C:SocketData) + 1;
  RC = write(SD:%addr(SocketData):SockDtaLen);
  SocketData = '';

  dow DONE = 0;
    exsr readDataSocket;
  enddo;
  outack = old_str;
  OLD_STR = *BLANK;
endsr;
//*******************************************************************
begsr readDataSocket;
//   Read data from the client's socket to SocketData variable
  RC = Read (SD: SocketData@: SockDtaLen);

//   If read failed - End the server
  DONE = 0;
  if RC <= 0;
    DONE = 1;
  else;
  dc.asc = SocketData;
  SocketData = dc.ebc;

    if %SCAN(HEX1C:SocketData) <> *ZERO;
      END = 1;
      DONE = 1;
    endif;
    if RC + OLD_STR_LEN <= 31999;
      OLD_STR = %SUBST(OLD_STR:1:OLD_STR_LEN) +
      %SUBST(SocketData:1:RC);
      OLD_STR_LEN = OLD_STR_LEN + RC;
    else;
      GET_STR_LEN = (31999 - OLD_STR_LEN) + 1;
      OLD_STR = %SUBST(OLD_STR:1:OLD_STR_LEN) +
      %SUBST(SocketData:1:GET_STR_LEN);
      LOGDATA = OLD_STR;
      OLD_STR = %SUBST(SocketData:GET_STR_LEN  :
      RC - GET_STR_LEN);
      OLD_STR_LEN= RC - GET_STR_LEN + 1;
    endif;

    if %SCAN(HEX1C:SocketData) <> *ZERO OR END = 1;
      OLD_STR_LEN = *ZERO;
    endif;
  endif;
endsr;
//***************************************************************
// Initialization Subroutine
//***************************************************************
begsr *INZSR;

  serverPortNumber = %int(is_portNumber);
  exsr $Init;

endsr;


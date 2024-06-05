**free

/copy ../cb_rpgle/genericHeaders/controlOptions.rpgle
//
//================================================================
//   File descriptions
//================================================================

dcl-f JH7TMPIN               usage(*update:*delete:*output) usrOpn;
dcl-f JH7LOG                 usage(*update:*delete:*output);
dcl-f JH7ENV10               keyed;

/copy ../cb_rpgle/print/qprint_dclf.rpgle

// Procedure Interface
dcl-pi *n;
   is_portNumber             char(5);
   is_logToFile              char(1);
   is_logToPrinter           char(1);
end-pi;
//================================================================
//   Declares
//================================================================
/copy ../cb_rpgle/constants/trueFalse.rpgle
/copy ../cb_rpgle/genericHeaders/programStatusDataStructure.rpgle

/copy cb/general_dcl.rpgle
/copy cb/generalIp_dcl.rpgle

/copy cb/ipSocket_dcl.rpgle
/copy cb/environment_ds.rpgle

/copy cb/getField_dcl.rpgle
/copy cb/svr_parseMshSegment_dcl.rpgle
//================================================================
//   Data definitions
//================================================================
dcl-ds enviornment        likeds(enviornmentTemplate);
dcl-s oldSocketdata         char(32000) inz;
dcl-s oldSocketdataLen     zoned(5:0) inz(0);
dcl-s getSocketdataLen     zoned(5:0) inz(0);
dcl-s COUNTER              zoned(5:0) inz(0);

dcl-s WritePos             zoned(5:0) inz;
dcl-s endOfMessageFound      ind      inz(*off);
dcl-s endProgram             ind      inz(*off);

dcl-s posStartBlock        zoned(5:0) inz;
dcl-s posSegmentTerminator zoned(5:0) inz;
dcl-s ERR                   char(  7) inz;

dcl-s CallPgmCtr           zoned(1:0) inz;

dcl-s environmentFoundForMessage char(  1) inz(*blank);

//dcl-s PortNumber             int(10:0) Inz(0);                        // Port number
//dcl-s SD                     int(10:0);                               // Socket# for the serv
//dcl-s SD2                    int(10:0);                               // Socket# for the clie
//dcl-s RC                     int(10:0);                               // Return code for sock
//dcl-s RecevedLength          int(10:0);                               // Return code for sock
//dcl-s OptVal                 Uns(10:0) Inz(1);                        // Option name for

//dcl-s OLD_STR_LEN          zoned(5:0) INZ(0);
//dcl-s COUNTER              zoned(5:0) INZ(0);
//dcl-s PORT                  char(5);
//dcl-s OLD_STR               char(32000);
//dcl-s GET_STR_LEN          zoned(5:0) INZ(0);
//dcl-s END                  zoned(1:0) INZ(0);
//dcl-s DONE                 zoned(1:0) INZ(0);
//dcl-s LOGGING               char(1);
//dcl-s OB                   zoned(5:0);
//dcl-s OD                   zoned(5:0);
//dcl-s ERR                   char(7);
//dcl-s RESTART               char(1);
//================================================================
//   M A I N   P R O G R A M
//================================================================
  enviornment.logToPrinter = %upper(is_logToPrinter);
  enviornment.logToFile    = %upper(is_logToFile   );
  if enviornment.logToPrinter = 'Y';
    open qPrint;
  endif;
  open JH7TMPIN;
  IN7DATIM = %timeStamp();

  if ipStartListen() = true;
    qPrintLog('*** Start of Receve.');
    dow endProgram = false;                  // Enter read/write loop
      exsr processSocketdata;
    enddo;
  endif;

  //   End program
  qPrintLog('*** Closing Sockets.');
  ipClose(socketDescripton2);
  ipClose(socketDescripton);
  qPrintLog('*** All Done!');
  qPrintLog('*** Ending Server.');
  close JH7TMPIN;
  if enviornment.logToPrinter = 'Y';
    close qPrint;
  endif;
  *inlr = *on;
  return;
//#----------------------------------------------------------------------------
/copy cb/getField.rpgle
/copy cb/svr_parseMshSegment.rpgle
//****************************************************************
begsr processSocketdata;

  socketReturnCode = ipRead(socketDescripton2:SocketData@:socketDataLength);  // Read data from the client's socket to SocketData variable
  qPrintLog('*** Data length: ' + %char(socketReturnCode) + '.');
  if socketReturnCode <= 0;
    qPrintLog('*** Connection closed by client.');
    endProgram = true;
  else;
    dc.asc = SocketData;
    SocketData = dc.ebc;
    if %scan(hl7EndOfBlock:SocketData) <> *zero;
      endOfMessageFound = *on;
    endif;
    
    select;
      when (socketReturnCode + oldSocketdataLen) < 32000;
        oldSocketdata = %subst(oldSocketdata:1:oldSocketdataLen) + %subst(SocketData:1:socketReturnCode);
        oldSocketdataLen = oldSocketdataLen + socketReturnCode;
      when (socketReturnCode + oldSocketdataLen) = 32000;
        oldSocketdata = %subst(oldSocketdata:1:oldSocketdataLen) + %subst(SocketData:1:socketReturnCode);
        LOGDATA = oldSocketdata;
        exsr WRITESR;
        oldSocketdata = *blank;
        oldSocketdataLen = *Zero;
      when (socketReturnCode + oldSocketdataLen) > 32000;
        getSocketdataLen = (32000 - oldSocketdataLen);
        oldSocketdata = %subst(oldSocketdata:1:oldSocketdataLen) + %subst(SocketData:1:getSocketdataLen);
        LOGDATA = oldSocketdata;
        exsr WRITESR;
        oldSocketdata = %subst(SocketData:getSocketdataLen + 1: %abs(socketReturnCode - getSocketdataLen));
        oldSocketdataLen = %abs(socketReturnCode - getSocketdataLen);
      other;
    endsl;
    
    if %scan(hl7EndOfBlock:SocketData) <> *zero OR endOfMessageFound = *on;
      LOGDATA = oldSocketdata;
      exsr WRITESR;
      endOfMessageFound = *off;
      oldSocketdata = *blank;
      oldSocketdataLen = *zero;
      if sendAck() = false;
        endProgram = true;
      endif;
      COUNTER = 0;
      IN7DATIM = %timeStamp();
    endif;
  endif;
endsr;
//*************************************************************************
begsr WRITESR;
  COUNTER    = COUNTER + 1;
  IN7COUNTER = COUNTER;
  LOGCOUNTER = COUNTER;
  LOGDATIM   = IN7DATIM;
  LOGJOB#    = %char(pgmPsds.jobNumber);
  if enviornment.logToFile = 'Y';
    write LOGFILER;
  endif;
  IN7DATA = LOGDATA;
  write HL7TMPINR;
  exsr parseMshSegment;
endsr;
//*************************************************************************
dcl-proc sendAck;
dcl-pi *n ind;
end-pi;
  SocketData = hl7StartOfBlock + 'MSH¦' + HEX5F +
  '~\&¦HNA¦' + %trim(mshSegment.sndApplication ) +
  '¦'        +  %trim(mshSegment.sndFacility   ) +
  '¦'        +  %trim(mshSegment.rcvApplication) +
  '¦'        +  %trim(mshSegment.rcvFacility   ) + '¦' + HEX5F + '""' + HEX5F +
  '""¦ACK¦ADTIF0097¦P¦2.2¦¦'                     + hl7SegmentTerm +
  'MSA¦AA¦ADTIF0097¦Message Stored¦¦'            + hl7SegmentTerm + hl7EndOfBlock + hl7SegmentTerm;

  socketDataLength = %len(%trim(SocketData));
  dc.ebc = SocketData;
  SocketData = dc.asc;
  socketReturnCode = ipWrite(socketDescripton2: SocketData@: socketDataLength);
  SocketData = *BLANK;
//   If write failed - End the server
  if socketReturnCode <= 0;
    qPrintLog('<<< Send ACK to client faild.');
    return false;
  endif;
  COUNTER = 0;
  IN7DATIM = %timeStamp();
  return true;
//   If write failed - End the server
//  if socketReturnCode <= 0;
//    endProgram = *on;
//  endif;
end-proc;
//#----------------------------------------------------------------------------
/copy cb/ipTestPort.rpgle
/copy cb/svr_ipStartListen.rpgle

/copy ../cb_rpgle/print/qprint_print.rpgle
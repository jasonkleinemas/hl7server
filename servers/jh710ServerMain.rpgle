**free

/copy ../cb_rpgle/genericHeaders/controlOptions.rpgle

//================================================================
//   File descriptions
//================================================================

dcl-f JH7TMPIN               usage(*update:*delete:*output) usropn;
dcl-f JH7LOG                 usage(*update:*delete:*output) keyed;
dcl-f JH7ENV10               keyed;
dcl-f JH7ENV20L1             keyed;
dcl-f JH7CFG30L1             keyed;

/copy ../cb_rpgle/print/qprint_dclf.rpgle

//================================================================
//   Declares
//================================================================

// Procedure interface
dcl-pi *n;
   is_portNumber             char(5);
   is_logToFile              char(1);
   is_logToPrinter           char(1);
end-pi;
//
// Dynamic program calling.
//
dcl-s  PENVPGMAAA            char( 10);
dcl-pr PENVPGMAAA_  extPgm(PENVPGMAAA);
  *n               likeds(enviornment);
end-pr;

/copy cb/general_dcl.rpgle


/copy ../cb_rpgle/constants/trueFalse.rpgle
/copy ../cb_rpgle/genericHeaders/programStatusDataStructure.rpgle
/copy cb/ipSocket.rpgle
/copy cb/environment_ds.rpgle

/copy cb/getField_dcl.rpgle
/copy cb/parseMshSegment_dcl.rpgle

dcl-s oldSocketdata       char(32000) inz;
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

dcl-s environmentFoundForMessage            char(  1) inz(*blank);

//================================================================
//   M A I N   P R O G R A M
//================================================================
  enviornment.logToPrinter = %upper(is_logToPrinter);
  enviornment.logToFile    = %upper(is_logToFile   );
  if enviornment.logToPrinter = 'Y';
    open qPrint;
  endif;
  
  socketPortNumber = %int(is_portNumber);

  if ipPortGood(socketPortNumber) = true;
    qPrintLog('*** Call JH7000PUR to cleanout log file.');
    purgeOldDataFromLog();
    IN7DATIM = %timeStamp();
    open JH7TMPIN;
  else;
    *inlr = *on;
  endif;
 
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

/copy cb/getField.rpgle
/copy cb/parseMshSegment.rpgle

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
        exsr writeToHl7inAndLog;
        oldSocketdata = *blank;
        oldSocketdataLen = *Zero;
      when (socketReturnCode + oldSocketdataLen) > 32000;
        getSocketdataLen = (32000 - oldSocketdataLen);
        oldSocketdata = %subst(oldSocketdata:1:oldSocketdataLen) + %subst(SocketData:1:getSocketdataLen);
        LOGDATA = oldSocketdata;
        exsr writeToHl7inAndLog;
        oldSocketdata = %subst(SocketData:getSocketdataLen + 1: %abs(socketReturnCode - getSocketdataLen));
        oldSocketdataLen = %abs(socketReturnCode - getSocketdataLen);
      other;
    endsl;

    if %scan(hl7EndOfBlock:SocketData) <> *zero OR endOfMessageFound = *on;
      qPrintLog('*** Working with HL7 Data.');
      LOGDATA = oldSocketdata;
      exsr writeToHl7inAndLog;
      close JH7TMPIN;
      exsr callProgramsForMessage;
      qPrintLog('*** CLEAR TEMP FILE: QTEMP/JH7TMPIN.');
      ERR = executeCommand('CLRPFM FILE(QTEMP/JH7TMPIN)');
      open JH7TMPIN;
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
begsr writeToHl7inAndLog;
  if %scan(hl7EndOfBlock:LOGDATA) <> 0;
    WritePos = %scan(hl7EndOfBlock:LOGDATA);
    if %subst(LOGDATA:WritePos - 1:1) = hl7SegmentTerm;
    else;
      LOGDATA = %subst(LOGDATA:1:WritePos-1) + hl7SegmentTerm + hl7EndOfBlock + hl7SegmentTerm;
    endif;
  endif;
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
begsr callProgramsForMessage;

  if environmentFoundForMessage = 'Y';
    qPrintLog('<*> Processed By Environment ID: ' + %trim(enviornment.id) + '.');
    clearTempFiles();
    
    CallPgmCtr = 0;
    dou CallPgmCtr = 9;
      CallPgmCtr = CallPgmCtr + 1;
      if enviornment.programCallArray(CallPgmCtr) <> *blank;
        qPrintLog('*** Call PGM' + %char(CallPgmCtr) + ': ' + enviornment.programCallArray(CallPgmCtr));
        PENVPGMAAA = %upper(enviornment.programCallArray(CallPgmCtr));
        qPrintLog('*** Call ' + PENVPGMAAA + ' Dynamic name.');
      endif;
    enddo;
    
    if enviornment.logToFile = 'Y';
      chain (LOGDATIM:LOGCOUNTER:LOGJOB#) LOGFILER;
      LOGED    = 'Y';                                                    // Message was processed.
      LOGRESON = 'PROCESSED BY ENVIRONMENT ID: ' + enviornment.id + '.'; // 
      update LOGFILER;
    endif;
  else;
    qPrintLog('<<< Not Found in JH7ENV10 Table. On Chain.');
    if enviornment.logToFile = 'Y';
      chain (LOGDATIM:LOGCOUNTER:LOGJOB#) LOGFILER;
      LOGED    = 'N';                                                    // Message was NOT processed.
      LOGRESON = 'NOT FOUND IN JH7ENV10 TABLE.';
      update LOGFILER;
    endif;
    ws_msh = *blank;
    mshSegment  = *blank;
  endif;
  LOGED     = *blank;
  LOGRESON  = *blank;
endsr;
//#----------------------------------------------------------------------------
dcl-proc purgeOldDataFromLog;
//  dcl-pr JH7000PUR   extPgm('JH7000PUR');
//  end-pr;

//  dcl-ds PURGE;
//    PURDATESTAMP        timeStamp;
//    PURDATENOW               char( 10) overlay(PURDATESTAMP:1);
//    PURMSGSTAMP         timeStamp;
//    PURLASTMSGDAT            char( 10) overlay(PURMSGSTAMP:1);
//  end-ds;
    
//  PURDATESTAMP = %timeStamp();
end-proc;
//#----------------------------------------------------------------------------
dcl-proc clearTempFiles;
  dcl-pi *n;
  end-pi;
  
  qPrintLog('*** CLEAR TEMP FILE: QTEMP/JH7TMPD.');
  ERR= executeCommand('CLRPFM FILE(QTEMP/JH7TMPD)');

  qPrintLog('*** CLEAR TEMP FILE: QTEMP/JH7TMPK.');
  ERR= executeCommand('CLRPFM FILE(QTEMP/JH7TMPK)');

  qPrintLog('*** CLEAR TEMP FILE: QTEMP/JH7TMPR.');
  ERR= executeCommand('CLRPFM FILE(QTEMP/JH7TMPR)');

end-proc;
//#----------------------------------------------------------------------------
/copy ../cb_rpgle/generalSystemOs/executeCommand.rpgle
/copy ../cb_rpgle/print/qprint_print.rpgle

/copy cb/ipStartListen.rpgle
/copy cb/ipTestPort.rpgle

/copy cb/sendAck.rpgle
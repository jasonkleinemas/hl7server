**free

/copy ../cb_rpgle/genericHeaders/controlOptions.rpgle

//================================================================
//   File descriptions
//================================================================

dcl-f JH7RECORDP             usage(*output);
dcl-f JH7ENV20L1             keyed;

//================================================================
//   Data definitions
//================================================================

// Procedure Interface
dcl-pi *n;
   is_portNumber             char(5);
end-pi;

dcl-ds enviornment             likeds(enviornmentTemplate);
/copy cb/environment_ds.rpgle

/copy cb/general_dcl.rpgle
/copy cb/generalIp_dcl.rpgle
/copy cb/ipSocket_dcl.rpgle

/copy ../cb_rpgle/constants/trueFalse.rpgle
/copy ../cb_rpgle/genericHeaders/programStatusDataStructure.rpgle

/copy cb/getField_dcl.rpgle
/copy cb/svr_parseMshSegment_dcl.rpgle


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
dcl-s IN7DATA             char(32000);

dcl-s environmentFoundForMessage char(  1) inz(*blank);

//================================================================
//   M A I N   P R O G R A M
//================================================================

  socketPortNumber = %int(is_portNumber);

  if ipPortGood(socketPortNumber) = true;
    LOGDATIM = %timeStamp();
//    open JH7RECORDP;
    if ipStartListen() = true;
      dow endProgram = false;                  // Enter read/write loop
        exsr processSocketdata;
      enddo;
    endif;
    ipClose(socketDescripton2);
    ipClose(socketDescripton);
  endif;
//  if %open(JH7RECORDP);
//    close JH7RECORDP;
//  endif;
  *inlr = *on;
  return;
//#----------------------------------------------------------------------------
/copy cb/getField.rpgle
/copy cb/svr_srSetEnvSperators.rpgle
/copy cb/svr_parseMshSegment.rpgle
//#----------------------------------------------------------------------------
begsr processSocketdata;

  socketReturnCode = ipRead(socketDescripton2:SocketData@:socketDataLength);  // Read data from the client's socket to SocketData variable
  
  if socketReturnCode <= 0;
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
        exsr writeToHl7Log;
        oldSocketdata = *blank;
        oldSocketdataLen = *Zero;
      when (socketReturnCode + oldSocketdataLen) > 32000;
        getSocketdataLen = (32000 - oldSocketdataLen);
        oldSocketdata = %subst(oldSocketdata:1:oldSocketdataLen) + %subst(SocketData:1:getSocketdataLen);
        LOGDATA = oldSocketdata;
        exsr writeToHl7Log;
        oldSocketdata = %subst(SocketData:getSocketdataLen + 1: %abs(socketReturnCode - getSocketdataLen));
        oldSocketdataLen = %abs(socketReturnCode - getSocketdataLen);
      other;
    endsl;

    if %scan(hl7EndOfBlock:SocketData) <> *zero OR endOfMessageFound = *on;
      qPrintLog('*** Working with HL7 Data.');
      LOGDATA = oldSocketdata;
      IN7DATA = LOGDATA;
      exsr writeToHl7Log;
      exsr parseMshSegment;
      enviornment.sendingApp      = mshSegment.sndApplication;
      enviornment.sendingFacility = mshSegment.sndFacility;
      enviornment.recevingApp     = mshSegment.rcvApplication;
      enviornment.RecevingFaciity = mshSegment.rcvFacility;
      enviornment.messageType     = mshSegment.type;
      enviornment.messageEvent    = mshSegment.event;
      endOfMessageFound = *off;
      oldSocketdata = *blank;
      oldSocketdataLen = *zero;
      if sendAck() = false;
        endProgram = true;
      endif;
      COUNTER = 0;
      LOGDATIM = %timeStamp();
    endif;
  endif;
endsr;
//#----------------------------------------------------------------------------
begsr writeToHl7Log;
  LOGDATIM = %timeStamp();
  COUNTER    = COUNTER + 1;
  LOGCOUNTER = COUNTER;
  LOGJOB#    = %char(pgmPsds.jobNumber);
  write LOGFILER;
endsr;
//#----------------------------------------------------------------------------
/copy cb/ipTestPort.rpgle
/copy cb/svr_ipStartListen.rpgle
/copy cb/svr_sendAck.rpgle
//#----------------------------------------------------------------------------
dcl-proc qPrintLog;
  dcl-pi *n;
    is_line char(100) const;
  end-pi;
end-proc;
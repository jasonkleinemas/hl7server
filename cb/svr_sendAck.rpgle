**free
/if not defined(sendAck)
/define sendAck
dcl-proc sendAck;
  dcl-pi *n ind;
  end-pi;
  
  dcl-ds *n;
    TimeNow             timeStamp     pos(1);
    TimeNowS                 char(26) pos(1);
  end-ds;
  
  if environmentFoundForMessage = 'Y';
    chain enviornment.id HL7ENV2R;
    if %found(JH7ENV20L1) = *off;
      ENID = 'DDDDDDDDDD';
      chain ENID HL7ENV2R;
    endif;
  else;
    ENID   = 'DDDDDDDDDD';
    chain ENID HL7ENV2R;
  endif;
  TimeNow = %timeStamp();

  SocketData = hl7StartOfBlock + 'MSH' + enviornment.fieldChar   +
  enviornment.subFieldChar + enviornment.FieldRepChar + enviornment.escapeChar + enviornment.subSubFieldChar + enviornment.fieldChar +
  %trim(ENSNDANAME)          + enviornment.subFieldChar +
  %trim(ENSNDAUID)           + enviornment.subFieldChar +
  %trim(ENSNDAUTID)          + enviornment.fieldChar    +
  
  %trim(ENSNDFNAME)          + enviornment.subFieldChar +
  %trim(ENSNDFUID)           + enviornment.subFieldChar +
  %trim(ENSNDFUTID)          + enviornment.fieldChar    +
  
  %trim(ENRCVANAME)          + enviornment.subFieldChar +
  %trim(ENRCVAUID)           + enviornment.subFieldChar +
  %trim(ENRCVAUTID)          + enviornment.fieldChar    +
  
  %trim(ENRCVFNAME)          + enviornment.subFieldChar +
  %trim(ENRCVFUID)           + enviornment.subFieldChar +
  %trim(ENRCVFUTID)          + enviornment.fieldChar    +
  %subst(TimeNowS:1:4)       +
  %subst(TimeNowS:6:2)       +
  %subst(TimeNowS:9:2)       +
  %subst(TimeNowS:12:2)      +
  %subst(TimeNowS:15:2)      +
  %subst(TimeNowS:18:2)      + enviornment.fieldChar   +
  'charOT' + enviornment.subFieldChar + '""' + enviornment.subFieldChar + '""' + enviornment.fieldChar +
  'ACK'                      + enviornment.fieldChar   +
  'ADTIF0097'                + enviornment.fieldChar   +
  'P'                        + enviornment.fieldChar   +
  '2.2'                      + enviornment.fieldChar   +
                               enviornment.fieldChar   + hl7SegmentTerm +
  'MSA'                      + enviornment.fieldChar   +
  'AA'                       + enviornment.fieldChar   +
  'ADTIF0097'                + enviornment.fieldChar   +
  %trim(ENTEXTMSG)           + enviornment.fieldChar   + enviornment.fieldChar +
  hl7SegmentTerm + hl7EndOfBlock + hl7SegmentTerm;

  socketDataLength = %len(%trim(SocketData));

  dc.ebc = SocketData;
  SocketData = dc.asc;

//   Write response to the client (the item record or question marks)
  qPrintLog('*** Send ACK to Client.');
  socketDataLength = %scan(hl7EndOfBlock:SocketData) + 1;
  socketReturnCode = ipWrite(socketDescripton2:SocketData@:socketDataLength);
  SocketData = *blank;

//   If write failed - End the server
  if socketReturnCode <= 0;
    qPrintLog('<<< Send ACK to client faild.');
    return false;
  endif;

  return true;
end-proc;
/endif
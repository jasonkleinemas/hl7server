**free

begsr callProgramsForMessage;

  if environmentFoundForMessage = 'Y';
    qPrintLog('<*> Processed By Environment ID: ' + %trim(enviornment.id) + '.');
//    clearTempFiles();
    
    CallPgmCtr = 0;
    dou CallPgmCtr = 9;
      CallPgmCtr = CallPgmCtr + 1;
      if enviornment.programCallArray(CallPgmCtr) <> *blank;
        qPrintLog('*** Call PGM' + %char(CallPgmCtr) + ': ' + enviornment.programCallArray(CallPgmCtr));
        PENVPGMAAA = %upper(enviornment.programCallArray(CallPgmCtr));
        qPrintLog('*** Call ' + PENVPGMAAA + ' Dynamic name.');
        PENVPGMAAA_(enviornment);
      endif;
    enddo;
    
    if enviornment.logToFile = 'Y';
      chain (LOGDATIM:LOGCOUNTER:LOGJOB#) LOGFILER;
      LOGED    = 'Y';                                                    // Message was processed.
      LOGRESON = 'PROCESSED BY ENVIRONMENT ID: ' + enviornment.id + '.'; // 
      update LOGFILER;
    endif;
  else;
    if enviornment.logToFile = 'Y';
      chain (LOGDATIM:LOGCOUNTER:LOGJOB#) LOGFILER;
      LOGED    = 'N';                                                    // Message was NOT processed.
      update LOGFILER;
    endif;
    ws_msh = *blank;
    mshSegment  = *blank;
  endif;
  LOGED     = *blank;
  LOGRESON  = *blank;
endsr;
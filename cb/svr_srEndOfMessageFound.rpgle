**free
/if not defined(srEndOfMessageFound)
/define srEndOfMessageFound

begsr srEndOfMessageFound;
  qPrintLog('*** Working with HL7 Data.');
  LOGDATA = oldSocketdata;
  exsr writeToHl7inAndLog;
  close JH7TMPIN;
  exsr parseMshSegment;
  exsr srSetEnvProgramsToCall;
  exsr callProgramsForMessage;
  qPrintLog('*** CLEAR TEMP FILE: QTEMP/JH7TMPIN.');
  err = executeCommand('CLRPFM FILE(QTEMP/JH7TMPIN)');
  open JH7TMPIN;
  endOfMessageFound = *off;
  oldSocketdata     = *blank;
  oldSocketdataLen  = *zero;
  if sendAck() = false;
    endProgram = true;
  endif;
  COUNTER  = 0;
  IN7DATIM = %timeStamp();
endsr;

/endif

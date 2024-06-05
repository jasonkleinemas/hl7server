**free

/if not defined(srSetEnvProgramsToCall)
/define srSetEnvProgramsToCall

begsr srSetEnvProgramsToCall;
  chain (mshSegment.sndApplication:mshSegment.sndFacility:mshSegment.rcvApplication:mshSegment.rcvFacility:mshSegment.type:mshSegment.event) HL7ENVR;
  if %found(JH7ENV10);
    environmentFoundForMessage  = 'Y';
    enviornment.sendingApp      = ENVSNDAPP;
    enviornment.sendingFacility = ENVSNDFAC;
    enviornment.recevingApp     = ENVRCVAPP;
    enviornment.RecevingFaciity = ENVRCVFAC;
    enviornment.messageType     = ENVMSGTYPE;
    enviornment.messageEvent    = ENVMSGEVNT;
    enviornment.id              = ENVID;
    chain enviornment.id HL7CFG30R;
    if %found(JH7CFG30L1);
      enviornment.programCallArray(1) = CFG3PGM1;
      enviornment.programCallArray(2) = CFG3PGM2;
      enviornment.programCallArray(3) = CFG3PGM3;
      enviornment.programCallArray(4) = CFG3PGM4;
      enviornment.programCallArray(5) = CFG3PGM5;
      enviornment.programCallArray(6) = CFG3PGM6;
      enviornment.programCallArray(7) = CFG3PGM7;
      enviornment.programCallArray(8) = CFG3PGM8;
      enviornment.programCallArray(9) = CFG3PGM9;
    else;
      environmentFoundForMessage    = 'N';
      qPrintLog('<<< No JH7CFG30 Record found for environment. SUBR:parseMshSegment');
      LOGRESON = 'No JH7CFG30 Record found for environment ' + enviornment.id;
    endif;
  else;
    qPrintLog('<<< Entry not found in JH7ENV10. SUBR:parseMshSegment');
    LOGRESON = 'No JH7ENV10 Record found.';
    environmentFoundForMessage = 'N';
  endif;
endsr;

/endif
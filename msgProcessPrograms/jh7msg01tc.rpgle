**free

/copy ../cb_rpgle/genericHeaders/controlOptions.rpgle
//#----------------------------------------------------------------------------
//
//  Call message programs to test.
//
//#----------------------------------------------------------------------------


// Procedure Interface
dcl-pi *n;
  is_envId   char(10);
  is_pgmName char(10);
end-pi;

dcl-s  PENVPGMAAA            char( 10);
dcl-pr PENVPGMAAA_  extPgm(PENVPGMAAA);
  *n               likeds(enviornment);
end-pr;

/copy cb/general_dcl.rpgle
/copy cb/environment_ds.rpgle
/copy ../cb_rpgle/constants/trueFalse.rpgle

dcl-ds  enviornment  likeds(enviornmentTemplate);

//#----------------------------------------------------------------------------

enviornment.id            = is_envId;
enviornment.logToFile     = is_pgmName;
enviornment.logToPrinter  = 'Y';
enviornment.testingFlag   = 'Y';

PENVPGMAAA = %upper(is_pgmName);

PENVPGMAAA_(enviornment);

*inlr = *on;
return;

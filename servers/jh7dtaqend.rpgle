**free

/copy ../cb_rpgle/genericHeaders/controlOptions.rpgle
//#----------------------------------------------------------------------------
//
//      This will End the hl7 dataq server
//
//#----------------------------------------------------------------------------

// Procedure Interface
dcl-pi *n;
   is_dqName             char(10);
   is_dqLib              char(10);
end-pi;

// Prototypes
dcl-pr sendDataQueue   extPgm('QSNDDTAQ');
   *n                    char( 10); // Data Queue Name
   *n                    char( 10); // Data Queue Library
   *n                  packed(5:0); // Data Queue Length
   *n                    char( 10); // Data Queue Data
end-pr;

/copy cb/general_dcl.rpgle
/copy cb/environment_ds.rpgle
/copy ../cb_rpgle/constants/trueFalse.rpgle

dcl-s dqData             char( 10) inz('END');
dcl-s dqLen            packed(5:0) inz(10);

is_dqName = %upper(is_dqName);
is_dqLib  = %upper(is_dqLib);

if %parms() = 1;
  is_dqLib = '*LIBL';
else;
  is_dqLib = is_dqLib;
endif;

sendDataQueue(is_dqName:is_dqLib:dqLen:dqData);

*inlr = *on;


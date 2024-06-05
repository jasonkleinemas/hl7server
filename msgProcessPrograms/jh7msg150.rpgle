**free

/copy ../cb_rpgle/genericHeaders/controlOptions.rpgle
//#----------------------------------------------------------------------------
//
//  Get constans, Doc Meta Data, Convert keys.
//
//#----------------------------------------------------------------------------

/copy cb/dclf_JH7CON10L1_constantsTable.rpgle
/copy cb/dclf_JH7DOC10_pageFormat.rpgle
/copy cb/dclf_JH7GEN10L1_genericConvertTable.rpgle
/copy cb/dclf_JH7TMPD_tempPageFormat.rpgle
/copy cb/dclf_JH7TMPK_tempKeys.rpgle

/copy ../cb_rpgle/print/qprint_dclf.rpgle

// Procedure Interface
dcl-pi *n;
  enviornment             likeds(enviornmentTemplate);
end-pi;

/copy cb/general_dcl.rpgle
/copy cb/environment_ds.rpgle
/copy ../cb_rpgle/constants/trueFalse.rpgle

//#----------------------------------------------------------------------------
exsr openFiles;

writeConstValuesToTempKeys();

writeDocMetaDataToTemp();

genericConvertKeyValue();

exsr closeFiles;

if enviornment.testingFlag = 'Y';
  *inlr = *on;
endif;
return;
//#----------------------------------------------------------------------------
begsr openFiles;
  openJH7CON10L1();
  openJH7DOC10();
  openJH7GEN10L1();
  openJH7TMPD();
  openJH7TMPK();
  if enviornment.logToPrinter = 'Y';
    qPrintOpen();
  endif;
endsr;

begsr closeFiles;
  qPrintClose();
  closeJH7TMPK();
  closeJH7TMPD();
endsr;
//#----------------------------------------------------------------------------
dcl-proc writeConstValuesToTempKeys;
  chain(en) (enviornment.id) HL7CONR;
  if %found(JH7CON10L1);
    dou %eof(JH7CON10L1);
      TMPKEY = CONNAM;
      TMPVAL = CONVAL;
      write HL7TMPKR;
      reade(en) (enviornment.id) HL7CONR;
    enddo;
  endif;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc genericConvertKeyValue;
  
  dcl-s ws_value char(50);
  
  setll *start JH7TMPK;
  read(en) JH7TMPK;
    dou %eof(JH7TMPK);
      ws_value = genericConvertGetKeyValue(TMPKEY:TMPVAL);
      if ws_value <> null;
        tempKeyWrite(TMPKEY:TMPVAL);
      endif;
      read(en) JH7TMPK;
    enddo;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc genericConvertGetKeyValue;
  dcl-pi *n                  char(50);
    is_tableName             char(10) value;
    is_keyName               char(10) value;
  end-pi;

  chain (enviornment.id:is_tableName:is_keyName) JH7GEN10L1;
  if %found(JH7GEN10L1);
    return GENVAL;
  else;
    return null;
  endif;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc writeDocMetaDataToTemp;

  dcl-s ws_tmpKeyVal char (10) inz('DOC TYPE');

  chain (ws_tmpKeyVal) HL7TMPKR;
  if %found(JH7TMPK);
    ws_tmpKeyVal = genericConvertGetKeyValue(TMPKEY:TMPVAL);
    if ws_tmpKeyVal = null;
    else;
      TMPVAL = ws_tmpKeyVal;
      update HL7TMPKR;
    endif;
  endif;

  ws_tmpKeyVal = TMPVAL;
  chain (ws_tmpKeyVal) HL7DOC1R;
  if %found(JH7DOC10);
    ws_tmpKeyVal = 'ZZZZZZZZZZ';
    chain (ws_tmpKeyVal) HL7DOC1R;
    if not %found(JH7DOC10);
      PAGLEN    = 0;
      PAGWIDTH  = 0;
      TOPMARG   = 0;
      LEFTMARG  = 0;
      LINSPACE  = 0;
      FONTTYPE  = 0;
      FONTWIDTH = 0;
      CHARLINE  = 0;
      LINEPAGE  = 0;
      OVERLAYNM = *blank;
    endif;
  endif;

  if PAGLEN <> *zero;
    D3PAGLEN = %char(PAGLEN);
  else;
    D3PAGLEN = '11.00';
    PAGLEN   =  11.00;
  endif;

  if PAGWIDTH  <> *zero;
    D3PAGWTH = %char(PAGWIDTH);
  else;
    D3PAGWTH = '8.50';
    PAGWIDTH =  8.50;
  endif;

  if TOPMARG   <> *zero;
    D3TOPMAR = %char(TOPMARG);
  else;
    D3TOPMAR = '0.45';
    TOPMARG  =  0.45;
  endif;

  if LEFTMARG  <> *zero;
    D3LFTMAR = %char(LEFTMARG);
  else;
    D3LFTMAR = '0.35';
    LEFTMARG =  0.35;
  endif;

  if LINSPACE  <> *zero;
    D3LINSPC = %char(LINSPACE);
  else;
    D3LINSPC = '.15';
    LINSPACE =  .15;
  endif;

  if FONTTYPE  <> *zero;
    D3FNTTYP = %char(FONTTYPE);
  else;
    D3FNTTYP = '420';
    FONTTYPE =  420;
  endif;

  if FONTWIDTH <> *zero;
    D3FNTWTH = %char(%int(1440 / FONTWIDTH));
  else;
    D3FNTWTH = '10';
    FONTWIDTH=  10;
  endif;

  if CHARLINE  <> *zero;
    D3RECLNG = %char(CHARLINE);
  else;
    D3RECLNG = '80';
    CHARLINE =  80;
  endif;

  if LINEPAGE  <> *zero;
    D3LINPAG = %char(LINEPAGE);
  else;
    D3LINPAG = '60';
    LINEPAGE =  60;
  endif;

  if OVERLAYNM <> *blank;
    D3OVERLAY = OVERLAYNM;
  else;
    D3OVERLAY = *blank;
    OVERLAYNM = *blank;
  endif;

  write HL7TMPDR;
end-proc;
//#----------------------------------------------------------------------------
/copy ../cb_rpgle/print/qprint_print.rpgle
/copy cb/tempKeys.rpgle
//#----------------------------------------------------------------------------
/copy cb/proc_JH7CON10L1_constantsTable.rpgle
/copy cb/proc_JH7DOC10_pageFormat.rpgle
/copy cb/proc_JH7GEN10L1_genericConvertTable.rpgle
/copy cb/proc_JH7TMPD_tempPageFormat.rpgle
/copy cb/proc_JH7TMPK_tempKeys.rpgle
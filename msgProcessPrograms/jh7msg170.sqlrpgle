**free

/copy ../cb_rpgle/genericHeaders/controlOptions.rpgle
//#----------------------------------------------------------------------------
//
//  Report
//
//#----------------------------------------------------------------------------
dcl-f JH7DOC20               Keyed USROPN;
dcl-f JH7DOC30L1             Keyed USROPN;
dcl-f JH7TMPD                Keyed USROPN;
dcl-f JH7TMPR                Usage(*UPDATE:*DELETE:*OUTPUT) USROPN;
Dcl-F JH7TMPR2               Usage(*UPDATE:*DELETE:*OUTPUT)
                             RENAME(HL7TMPRR:HL7TMPRR2) PREFIX(T)
                             USROPN;
/copy cb/dclf_JH7TMPK_tempKeys.rpgle
/copy ../cb_rpgle/print/qprint_dclf.rpgle

// Procedure Interface
dcl-pi *n;
  enviornment             likeds(enviornmentTemplate);
end-pi;

/copy cb/general_dcl.rpgle
/copy cb/environment_ds.rpgle
/copy ../cb_rpgle/constants/trueFalse.rpgle

dcl-s PageLineCtr         Packed(2:0) Inz;
dcl-s TempVarVal         VarChar(50);
dcl-s Page#Ctr             Zoned(9:0) Inz;
dcl-s KDocType              Char(10) Inz;
dcl-s LineCtr             Packed(9:0) Inz;
dcl-s HEADCtr             Packed(1:0) Inz;
dcl-s FOOTCtr             Packed(1:0) Inz;
dcl-s Header                Char(500) Inz Dim(9);
dcl-s Footer                Char(500) Inz Dim(9);
dcl-s Err                   Char(7) Inz;

//==========================================================================================
// Start of moved field definitions.
//==========================================================================================
dcl-s char10                Char(10);
dcl-s wwType                Char(1);
dcl-s wwVarType             Char(1);
//==========================================================================================
// End of moved field definitions.
//==========================================================================================
exsr InzVars;
exsr OpenFiles;

Exec SQL
  Set option commit = *none;

//char10 = 'DOC TYPE';
//chain (CHAR10) HL7TMPKR;
//if %found(JH7TMPK);
//  KDOCTYPE = TMPVAL;
//else;
//  KDOCTYPE = *blank;
//endif;
KDOCTYPE = tempKeyGetValue('DOC TYPE');


exsr Main;
exsr CloseFiles;

if %found(JH7DOC20);
  Err = executeCommand('CPYF'  +
  ' FROMFILE(QTEMP/JH7TMPR2)'  +
  ' TOFILE(QTEMP/JH7TMPR)'     +
  ' MBROPT(*REPLACE)'          +
  ' FMTOPT(*MAP *DROP)' );
endif;

if enviornment.testingFlag = 'Y';
  *inlr = *on;
endif;
return;
//#----------------------------------------------------------------------------
begsr OpenFiles;
  open JH7DOC20;
  open JH7DOC30L1;
  open JH7TMPD;
  open JH7TMPR;
  open JH7TMPR2;
  if enviornment.logToPrinter = 'Y';
    open qPrint;
  endif;
  openJH7TMPK();
endsr;
//#----------------------------------------------------------------------------
begsr CloseFiles;
  close JH7DOC20;
  close JH7DOC30L1;
  close JH7TMPD;
  close JH7TMPR;
  close JH7TMPR2;
  qPrintClose();
  closeJH7TMPK();
endsr;
//#----------------------------------------------------------------------------
begsr Main;
  chain (enviornment.id:KDOCTYPE) HL7DOC20R;
  if %found(JH7DOC20);

    wwVarType = '1';
    chain (D2HFID:WWVARTYPE) HL7DOC30R;
    if %found(JH7DOC30L1);
      dow NOT %eof(JH7DOC30L1);
        Err = FillErs;
        reade (D2HFID:WWVARTYPE) HL7DOC30R;
      enddo;
    endif;
    exsr DeleteRpt2;
    read HL7TMPDR;
    Err = PrintReport;
  endif;
endsr;
//#----------------------------------------------------------------------------
begsr DeleteRpt2;

  Exec SQL
    DELETE FROM JH7TMPR2;
endsr;
//#----------------------------------------------------------------------------
begsr InzVars;

  HEADER(1) = *Blank;
  FOOTER(1) = *Blank;
  HEADER(2) = *Blank;
  FOOTER(2) = *Blank;
  HEADER(3) = *Blank;
  FOOTER(3) = *Blank;
  HEADER(4) = *Blank;
  FOOTER(4) = *Blank;
  HEADER(5) = *Blank;
  FOOTER(5) = *Blank;
  HEADER(6) = *Blank;
  FOOTER(6) = *Blank;
  HEADER(7) = *Blank;
  FOOTER(7) = *Blank;
  HEADER(8) = *Blank;
  FOOTER(8) = *Blank;
  HEADER(9) = *Blank;
  FOOTER(9) = *Blank;
  TempVarVal = ' ';

endsr;
//#----------------------------------------------------------------------------
dcl-proc PrintReport;
  dcl-pi PrintReport          Char(7);
  end-pi;

  wwVarType = '2';
  LineCtr = 0;
  read HL7TMPRR;
  Page#Ctr = 0;
  dow NOT %eof(JH7TMPR);
    HEADCtr = 0;
    FOOTCtr = 0;
    PageLineCtr = 1;
    Page#Ctr = Page#Ctr + 1;
    if Page#Ctr > 1  OR D2NFSTPAGH = ' ';                            // Print Header
      wwType = 'H';
      chain (D2HFID:WWVARTYPE:WWTYPE) HL7DOC30R;
      if %found(JH7DOC30L1);
        Err = FillErs;
      endif;
      reade (D2HFID:WWVARTYPE:WWTYPE) HL7DOC30R;
      dow NOT %eof(JH7DOC30L1);
        Err = FillErs;
        reade (D2HFID:WWVARTYPE:WWTYPE) HL7DOC30R;
      enddo;
      dow HEADCtr < D2HEADLINE;
        HEADCtr = HEADCtr + 1;
        Err = PrintReportLine(HEADER(PageLineCtr));
      enddo;
    endif;
// Print Report add also page break code for last page
    dow (PageLineCtr + D2FOOTLINE) < %int(D3LINPAG)
    and %EOF(JH7TMPR) = *Off;
      Err = PrintReportLine(TMPRPT);
      read HL7TMPRR;
    enddo;
// Print Extra Blank Lines for last page to get footer to print at bottom of last page.
    dow (PageLineCtr + D2FOOTLINE) < %int(D3LINPAG);
      Err = PrintReportLine(*Blank);
    enddo;
    if Page#Ctr > 1  OR D2NFSTPAGF = ' ';                            // Print Footer
      wwType = 'F';
      chain (D2HFID:WWVARTYPE:WWTYPE) HL7DOC30R;
      if %found(JH7DOC30L1);
        Err = FillErs;
      endif;
      reade (D2HFID:WWVARTYPE:WWTYPE) HL7DOC30R;
      dow NOT %eof(JH7DOC30L1);
        Err = FillErs;
        reade (D2HFID:WWVARTYPE:WWTYPE) HL7DOC30R;
      enddo;
      dow FootCtr < D2FOOTLINE;
        FootCtr = FootCtr + 1;
        Err = PrintReportLine(FOOTER(FootCtr));
      enddo;
    endif;
  enddo;

  return *Blank;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc FillErs;
  dcl-pi FillErs              Char(7);
  end-pi;
  if D3VARTYPE = '1' or D3VARTYPE = '2';
    if D3LINE > 0 and D3LINE < 10;
      if D3COLLUM > 0 and D3COLLUM < 450;
        if D3VARNAME <> *Blank;
          if D3VARTYPE = '1';
            TempVarVal = tempKeyGetValue(D3VARNAME);
          else;
            TempVarVal = GetInternalVal(D3VARNAME);
          endif;
          if D3TRIMTYPE = 'B';
            TempVarVal = %trim(TempVarVal);
          endif;
          if D3TRIMTYPE = 'R' or D3TRIMTYPE = ' ';
            TempVarVal = %trimr(TempVarVal);
          endif;
          if D3TRIMTYPE = 'L';
            TempVarVal = %triml(TempVarVal);
          endif;
          if D3Type = 'H' or D3Type = 'F';
            Err = SetupHeadFoot(TempVarVal);
          endif;
        endif;
      endif;
    endif;
  endif;
  return *Blank;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc SetupHeadFoot;
  dcl-pi SetupHeadFoot        Char(7);
    TempVarVal            VarChar(50);
  end-pi;

  if D3Type = 'H' or D3Type = 'h';
    %subst(HEADER(D3LINE):D3COLLUM) = TempVarVal;
  endif;

  if D3Type = 'F' or D3Type = 'f';
    %subst(FOOTER(D3LINE):D3COLLUM) = TempVarVal;
  endif;

  return *Blank;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc PrintReportLine;
  dcl-pi *n      Char(7);
    LineString            VarChar(500) const;
  end-pi;

  TTMPRPT = LineString;
  PageLineCtr = PageLineCtr + 1;
  LineCtr = LineCtr + 1;
  TTMPRPTLIN = LineCtr;
  write HL7TMPRR2;

  return *Blank;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc zGetKeyValue;
  dcl-pi *n       VarChar(1000);
    InString         Char(  10) value;
  end-pi;

//  if InString <> *blank;
//    chain InString HL7TMPKR;
//    if %Found(JH7TMPKL2) = *Off;
//      TMPVAL = *Blank;
//    endif;
//  else;
//    TMPVAL = *Blank;
//  endif;

  return %trim(TMPVAL);
end-proc;
//#----------------------------------------------------------------------------
dcl-proc GetInternalVal;
  dcl-pi *n                varChar(100);
    InString                  char( 10) value;
  end-pi;

  dcl-s OutString          VarChar(100);
  dcl-s DATE_MDY              Date(*MDY);
  dcl-s DATE_DMY              Date(*DMY);
  dcl-s DATE_YMD              Date(*YMD);
  dcl-s DATE_JUL              Date(*JUL);
  dcl-s DATE_ISO              Date(*ISO);
  dcl-s DATE_USA              Date(*USA);
  dcl-s DATE_EUR              Date(*EUR);
  dcl-s DATE_JIS              Date(*JIS);

  dcl-s TIME_HMS              Time(*HMS);
  dcl-s TIME_ISO              Time(*ISO);
  dcl-s TIME_USA              Time(*USA);
  dcl-s TIME_EUR              Time(*EUR);
  dcl-s TIME_JIS              Time(*JIS);

  if InString <> *blank;
    select;
      when InString = 'PAGE';
        OutString = 'Page: ' + %char(%int(%char(Page#Ctr)));
      when InString = 'PAGE#';
        OutString = %char(%int(%char(Page#Ctr)));
//#-------------------------------------------------------- Date
      when InString = 'DATE*MDY';
        DATE_MDY = %date();
        OutString = %char(DATE_MDY);
      when InString = 'DATE*DMY';
        DATE_DMY = %date();
        OutString = %char(DATE_DMY);
      when InString = 'DATE*YMD';
        DATE_YMD = %date();
        OutString = %char(DATE_YMD);
      when InString = 'DATE*JUL';
        DATE_JUL = %date();
        OutString = %char(DATE_JUL);
      when InString = 'DATE*ISO';
        DATE_ISO = %date();
        OutString = %char(DATE_ISO);
      when InString = 'DATE*USA';
        DATE_USA = %date();
        OutString = %char(DATE_USA);
      when InString = 'DATE*EUR';
        DATE_EUR = %date();
        OutString = %char(DATE_EUR);
      when InString = 'DATE*JIS';
        DATE_JIS = %date();
        OutString = %char(DATE_JIS);
//#-------------------------------------------------------- Time
      when InString = 'TIME*HMS';
        TIME_HMS = %time();
        OutString = %char(TIME_HMS);
      when InString = 'TIME*ISO';
        TIME_ISO = %time();
        OutString = %char(TIME_ISO);
      when InString = 'TIME*USA';
        TIME_USA = %time();
        OutString = %char(TIME_USA);
      when InString = 'TIME*EUR';
        TIME_EUR = %time();
        OutString = %char(TIME_EUR);
      when InString = 'TIME*JIS';
        TIME_JIS = %time();
        OutString = %char(TIME_JIS);
//#-------------------------------------------------------- 
      other;
        OutString = *Blank;
    endsl;
  endif;

  return OutString;
end-proc;
//#----------------------------------------------------------------------------
/copy ../cb_rpgle/print/qprint_print.rpgle
/copy ../cb_rpgle/generalSystemOs/executeCommand.rpgle
/copy cb/proc_JH7TMPK_tempKeys.rpgle
/copy cb/tempKeys.rpgle
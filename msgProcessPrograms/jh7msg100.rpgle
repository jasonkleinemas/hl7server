**free

/copy ../cb_rpgle/genericHeaders/controlOptions.rpgle
//#----------------------------------------------------------------------------
//
//  Parse the HL7
//
//#----------------------------------------------------------------------------
dcl-f JH7TMPIN               usrOpn;                // Hold message to be worked
dcl-f JH7CFG10L1             keyed usrOpn;          // Field info
dcl-f JH7CFG20L1             keyed usrOpn;          //
dcl-f JH7TMPR                usage(*outPut) usrOpn; // Put report
/copy cb/dclf_JH7TMPK_tempKeys.rpgle
/copy ../cb_rpgle/print/qprint_dclf.rpgle

// Procedure Interface
dcl-pi *n;
  enviornment             likeds(enviornmentTemplate);
end-pi;

dcl-s testingFlag            ind      inz(*on); // Set to *off in running env

/copy cb/general_dcl.rpgle
/copy ../cb_rpgle/constants/trueFalse.rpgle
/copy cb/environment_ds.rpgle

dcl-s endOfMessageFound      ind      inz(*off);
dcl-s WorkString            char(32767);
dcl-s WorkString_ln       packed(5:0);

dcl-s SEG_ST              packed(5:0) inz(1);
dcl-s SEG_ED              packed(5:0);
dcl-s SEG_LN              packed(5:0);
dcl-s SEG_CTR             packed(5:0);
dcl-s SEG_HED               char(3);
dcl-s SEG                varchar(32001);

dcl-s Err                   char(7);
dcl-s LINECTR              zoned(9:0) inz(0);
dcl-s TempLine           varchar(32000);
dcl-s SegCtrVal             char(4) inz('0');

//==========================================================================================
// Start of moved field definitions.
//==========================================================================================
dcl-s CCREPORTCTR         packed(3:0);
dcl-s SCIN                  char(32000);
dcl-s SCOUT                 char(32000);
dcl-s SCSTART             packed(3:0);
dcl-s SCTR                packed(3:0);
dcl-s SCWK                  char(1);
dcl-s SEG_ED2             packed(5:0);
dcl-s SEG_FD              packed(5:0);
dcl-s SEG_0D              packed(5:0);
dcl-s SPFIN               packed(5:0);
dcl-s SPFLAG              packed(1:0);
dcl-s SPINFIELD           packed(5:0);
dcl-s SPINSEPERATOR         char(1);
dcl-s SPINSTRING            char(32000);
dcl-s SPLENG              packed(5:0);
dcl-s SPNOTFOUND          packed(1:0);
dcl-s SPOUTBACK             char(32000);
dcl-s SPSEPCNT            packed(5:0);
dcl-s SPSTART             packed(5:0);
dcl-s ZZ_doCount          packed(9:0);
//==========================================================================================
// End of moved field definitions.
//==========================================================================================

endOfMessageFound  = *off;
WorkString         = *blank;
WorkString_ln      = 0;
Err                = *blank;
LINECTR            = 0;
TempLine           = ' ';
SegCtrVal          = '0';
SEG_ST             = 1;
SEG_ED             = 0;
SEG_LN             = 0;
SEG_CTR            = 0;
SEG_HED            = ' ';
SEG                = ' ';
TempLine           = ' ';
SegCtrVal          = '0';

//#----------------------------------------------------------------------------

exsr OpenFiles;


Err = GetString(WorkString:WorkString_ln:WorkString:WorkString_ln:'Y');
exsr GETSEG;
exsr CloseFiles;

if enviornment.testingFlag = 'Y';
  *inlr = *on;
endif;
return;
//#----------------------------------------------------------------------------
begsr OpenFiles;
  open JH7TMPIN;
  if not %open(JH7CFG10L1);
    open JH7CFG10L1;
  endif;
  if not %open(JH7CFG20L1);
    open JH7CFG20L1;
  endif;
  open JH7TMPK;
  open JH7TMPR;
  if enviornment.logToPrinter = 'Y';
    open qPrint;
  endif;
endsr;
//#----------------------------------------------------------------------------
begsr CloseFiles;
  close JH7TMPIN;
//***               Close     JH7CFG10L1
//***               Close     JH7CFG20L1
  close JH7TMPK;
  close JH7TMPR;
  if %open(qPrint);
    close qPrint;
  endif;
endsr;
//********************************************************* SPLIT UP THE SEGMENTS
begsr GETSEG;
  Err = GetString(WorkString:0:WorkString:WorkString_ln:'n');
  SEG_ST  = %scan(hl7StartOfBlock:WorkString:SEG_ST) + 1;                       // get stat of messag
  dou hl7EndOfBlock = %subst(WorkString:1:1);
    if SEG_ST > *ZERO;
      for ZZ_doCount = 1 To 3;
        if hl7SegmentTerm = %subst(WorkString:SEG_ST:1);
          SEG_ST = SEG_ST + 1;
        else;
          leave;
        endif;
      endfor;
      SEG_HED = %subst(WorkString:SEG_ST:3);
      exsr GETSEGV;
    else;
      endOfMessageFound = *on;
    endif;
    if endOfMessageFound = *on;
      leave;
    endif;
    if WorkString_ln < 16000;
      Err = GetString(WorkString:WorkString_ln:WorkString:WorkString_ln:'n');
    endif;
    SEG = *blankS;
    SEG_ED = %scan(hl7SegmentTerm:WorkString);
    SEG_ST = 1;
    if (SEG_ST + 1) = %scan(hl7EndOfBlock:WorkString);
      leave;
    endif;
  enddo;
endsr;
//************************** GET INFO ACCORDING TO DATA FILE. ONLY CALL FROM GETSEG!!!
begsr GETSEGV;
//**                dump
  ERR = CheckReportSeg(SEG_HED);
  if (CFG20REPOR = 'Y' or CFG20REPOR = 'y') and SEG_HED = Err;
    exsr OBXSR;
  else;
    SEG_ED = %scan(hl7SegmentTerm:WorkString:SEG_ST + 1);
    if SEG_ED = 0;
      WorkString_ln = 0;
      WorkString = *blank;
    else;
      SEG_LN = (SEG_ED + 1) - (SEG_ST + 1);
      if SEG_LN > *ZERO;
        SEG = %subst(WorkString:SEG_ST:SEG_LN);
      else;
        SEG_HED = *blankS;
      endif;
      if %len(%trim(SEG)) > 7;                                        // This is to stop emty segments.
        if SEG_HED = CheckReportSeg(SEG_HED);
          exsr SPLITOBX2;
        endif;
        if %trim(SegCtrVal) = '0';
          chain (enviornment.id:SEG_HED) HL7CFG10R;
          *IN51 = not %found();
        else;
          chain (enviornment.id:SEG_HED:SEGCTRVAL) HL7CFG10R;
          *IN51 = not %found();
        endif;
        dow *IN51 = *off;
          exsr SEGMENTSR;
          if %trim(SegCtrVal) = '0';
            reade (enviornment.id:SEG_HED) HL7CFG10R;
            *IN51 = %eof();
          else;
            reade (enviornment.id:SEG_HED:SEGCTRVAL) HL7CFG10R;
            *IN51 = %eof();
          endif;
        enddo;
      endif;
      WorkString_ln = WorkString_ln - SEG_ED;
      WorkString = %subst(WorkString:SEG_ED + 1 :
      WorkString_ln);
    endif;
  endif;
  SegCtrVal = '0';
endsr;
//*************************************************************************
begsr OBXSR;

  SEG = %subst(WorkString:SEG_ST);
  CCREPORTCTR = 1;
  dou CFG20FLD#  = CCREPORTCTR;
    SEG_ST = %scan(enviornment.fieldChar:WorkString:SEG_ST + 1);
    CCREPORTCTR = CCREPORTCTR + 1;
  enddo;
  SEG_ST = %scan(enviornment.fieldChar:WorkString:SEG_ST + 1) + 1;
  if CFG20SFLD# > 1;
    CCREPORTCTR = 1;
    dou CFG20SFLD# = CCREPORTCTR;
      SEG_ST = %scan(enviornment.subFieldChar:WorkString:SEG_ST + 1);
      CCREPORTCTR = CCREPORTCTR + 1;
    enddo;
    SEG_ST = SEG_ST + 1;
  endif;
  WorkString    = %subst(WorkString: SEG_ST:
  WorkString_ln - SEG_ST + 1 );
  WorkString_ln = WorkString_ln - SEG_ST + 1;
  exsr SPLITOBX;
endsr;
//******************************** SLIP UP OBX REPORT IF REPORT IN ONE OBX
begsr SPLITOBX;
  SPFLAG = 2;
  SEG_0D = 0;
  SEG_FD = 0;
  SEG_ED2 = 0;
  SEG_ST = 1;

  dou SPFLAG = 9;
    if WorkString_ln < 16000;
      Err = GetString(WorkString:WorkString_ln:WorkString:WorkString_ln:'n');
    endif;
    SEG_ED = %scan(%trim(CFG20SEPL)
    :WorkString:SEG_ST);
    if SEG_ED = 0;
      SEG_0D = %scan(hl7SegmentTerm:WorkString:SEG_ST);
      if SEG_0D = 0;
        SEG_ED = %scan(hl7EndOfBlock:WorkString:SEG_ST);
        if SEG_ED = 0;
          SPFLAG = 9;
        else;
          SPFLAG = 9;
          endOfMessageFound = *on;
        endif;
      else;
        if SEG_0D <> 0;                                               //  This is used if is not last field
          SEG_ED = SEG_0D;
          SEG_FD = %scan(enviornment.fieldChar:WorkString:SEG_ST);
          if SEG_FD < SEG_0D and SEG_FD > 0;
            SEG_ED2 = SEG_FD;
          else;
            SEG_ED2 = SEG_0D;
          endif;
        endif;
        SPFLAG = 9;
        SEG_LN = SEG_ED2 - SEG_ST;
        if SEG_LN > 0;
          TMPRPT = %subst(WorkString:SEG_ST:SEG_LN);
        else;
          TMPRPT = *blankS;
        endif;
        TMPRPT = ClearHL7Encdng(TMPRPT);
        LINECTR = LINECTR + 1;
        TMPRPTLIN = LINECTR;
        write HL7TMPRR;
        WorkString_ln = WorkString_ln - SEG_LN;
        WorkString = %subst(WorkString:SEG_LN + 1:
        WorkString_ln);
        leave;
      endif;
    endif;
    SEG_LN = SEG_ED - SEG_ST;
    if SEG_LN > 0;
      TMPRPT = %subst(WorkString:SEG_ST:SEG_LN);
    else;
      TMPRPT = *blankS;
    endif;
    TMPRPT = ClearHL7Encdng(TMPRPT);
    LINECTR = LINECTR + 1;
    TMPRPTLIN = LINECTR;
    write HL7TMPRR;
    WorkString = %subst(WorkString:SEG_LN + 1 + %len(%trim(CFG20SEPL)):WorkString_ln - SEG_LN + 1 );
    WorkString_ln = WorkString_ln - ( SEG_LN + %len(%trim(CFG20SEPL)) );
    SEG_ST = 1;
  enddo;
  if hl7SegmentTerm = %subst(WorkString:1:1);
    WorkString = %subst(WorkString:2:
    WorkString_ln - 1);
    WorkString_ln = WorkString_ln - 1;
  endif;

  chain (enviornment.id:SEG_HED) HL7CFG10R;
  *IN59 = not %found();
  dow *IN59 = *off;
    exsr SEGMENTSR;
    reade (enviornment.id:SEG_HED) HL7CFG10R;
    *IN59 = %eof();
  enddo;
  SEG_HED = *blankS;

endsr;
//*************************************************************************
begsr SPLITOBX2;
  if CFG20CTRF <> 0;
    SPINFIELD = CFG20CTRF + 1;
    SPINSEPERATOR = enviornment.fieldChar;
    SPINSTRING = SEG;
    exsr SPLIT;
    SegCtrVal = SPOUTBACK;
  else;
    SegCtrVal = '0';
  endif;
  SPINFIELD = CFG20FLD#  + 1;
  SPINSEPERATOR = enviornment.fieldChar;
  SPINSTRING = SEG;
  exsr SPLIT;
  TMPRPT = ClearHL7Encdng(SPOUTBACK);
  LINECTR = LINECTR + 1;
  TMPRPTLIN = LINECTR;
  write HL7TMPRR;
endsr;
//*************************************************************************
begsr SEGMENTSR;
  SPINFIELD     = CFG10FLD# + 1;
  SPINSEPERATOR = enviornment.fieldChar;
  SPINSTRING    = SEG;
  exsr SPLIT;

  if CFG10ARRAY <> *ZERO;
    SPINFIELD     = CFG10ARRAY;
    SPINSEPERATOR = enviornment.fieldRepChar;
    SPINSTRING    = SPOUTBACK;
    exsr SPLIT;
  endif;
  if CFG10SFLD# <> *ZERO;
    SPINFIELD     = CFG10SFLD#;
    SPINSEPERATOR = enviornment.subFieldChar;
    SPINSTRING    = SPOUTBACK;
    exsr SPLIT;
    if CFG10SSFLD <> *ZERO;
      SPINFIELD     = CFG10SSFLD;
      SPINSEPERATOR = enviornment.subSubFieldChar;
      SPINSTRING    = SPOUTBACK;
      exsr SPLIT;
    endif;
  endif;
//  SPOUTBACK = SCANSEP(enviornment.subFieldChar:SPOUTBACK);
  SPOUTBACK = %xlate(enviornment.subFieldChar:' ':SPOUTBACK);
//  ERR = WRITE_KEYS(CFG10KEYDS:SPOUTBACK:CFG10BLANK);
  ERR = tempKeyWrite(CFG10KEYDS:SPOUTBACK:CFG10BLANK);
endsr;
//**************************************************

// REMOVES THE FIELD SPEATOR

begsr SCANSR;
  SCOUT = *blankS;
  SCSTART = 1;
  SCTR = 1;
  SCWK = *blank;
  if SCIN <> *blank;
    SCWK = %subst(SCIN:SCTR:1);
    dow SCTR < 199;
      if SCWK = enviornment.subFieldChar;
        %subst(SCIN:SCTR:1) = ' ';
      endif;
      SCTR = SCTR + 1;
      SCWK = %subst(SCIN:SCTR:1);
    enddo;
  endif;
  SCOUT = SCIN;
  SCIN = *blankS;
endsr;
//*********************************************************

//   CUT UP STRING BY DELIMITER
//   INPUTS : SPINFIELD     - THE FIELD YOU WANT  5.0
//            SPINSEPERATOR - THE DELIMITER       1
//            SPINSTRING    - THE STRING TO SPLIT 32000
//   OUTPUTS: SPOUTBACK     - THE RESULT          32000
begsr SPLIT;

  SPOUTBACK = *blank;
  SPNOTFOUND = *ZERO;
  SPSTART = 1;
  SPFIN = *ZERO;
  SPSEPCNT = *ZERO;
  SPLENG = *ZERO;
  if %len(%trim(SPINSTRING)) > *ZERO;
    if SPINFIELD > 1;
      dou (SPINFIELD - 1) = SPSEPCNT;
        SPSTART = %scan(SPINSEPERATOR
        :SPINSTRING:SPSTART);
        if SPSTART > %len(%trimR(SPINSTRING));
          leave;
        endif;
        if SPSTART < 1;
          SPNOTFOUND = 1;
          leave;
        endif;
        SPSEPCNT = SPSEPCNT + 1;
        SPSTART  = SPSTART  + 1;
      enddo;
    else;
      SPSTART = 1;
    endif;
    if SPNOTFOUND = 1;
      SPOUTBACK = *blank;
    else;
      if SPINSTRING <> *blank;
        SPFIN = %scan(%trim(SPINSEPERATOR):SPINSTRING:SPSTART);
        SPFIN = SPFIN - 1;
        if SPFIN < 1;
          SPFIN = %len(%trimR(SPINSTRING));
        endif;
        SPLENG =  SPFIN - SPSTART;
        if SPLENG > -1;
          SPOUTBACK=%subst(SPINSTRING:SPSTART:SPLENG+1);
          if SPINSEPERATOR = %subst(SPOUTBACK:1:1);
            SPOUTBACK=%subst(SPINSTRING:SPSTART+1:SPLENG);
          endif;
        endif;
        if SPSTART = 1;
          SPOUTBACK=%subst(SPINSTRING:SPSTART:SPLENG+1);
        endif;
      else;
        SPOUTBACK = SPINSTRING;
      endif;
      if SPSTART = 0;
        SPOUTBACK = *blank;
      endif;
      if SPOUTBACK = SPINSEPERATOR;
        SPOUTBACK = *blank;
      endif;
    endif;
  endif;
  SPINFIELD = *ZERO;
  SPINSEPERATOR = *blank;
  SPINSTRING = *blank;
endsr;
//**************************************************************
dcl-proc GetString;                                                   // Get from JH7TMPIN if needed
  dcl-pi *n                  char(    7);
    String_in                char(32767) ;
    String_in_ln           packed(  5:0) value;
    String_out               char(32767) ;
    String_out_ln          packed(  5:0);
    is_Reset                 char(     1) value;
  end-pi;

  dcl-s ReadRecord            char(1) Static inz('Y');
  dcl-s NoMoreRecords         char(1) Static inz('N');
  dcl-s ReturnCode            char(7) inz;
  dcl-s String             varchar(32767);
  dcl-s Number              packed(5:0) inz;

  if is_Reset = 'Y';
    ReadRecord    = 'Y';
    NoMoreRecords = 'N';
  else;
    if NoMoreRecords = 'N';
      if ReadRecord = 'Y';
        read(E) JH7TMPIN;
        *IN50 = %error();
        *IN50 = %eof();
        ReadRecord = 'N';
      else;
        ReadRecord = 'Y';
      endif;
      if *In50 = *on;
        NoMoreRecords = 'Y';
        String_out    = String_in;
        String_out_ln = String_in_ln;
      else;
        if ReadRecord = 'N';
          String = %subst(IN7DATA:1:16000);
        else;
          String = %subst(IN7DATA:16001:16000);
        endif;
        Number = GetStringLn(String);
        if 16000 = Number;
          String_out_ln = String_in_ln + 16000;
        else;
          String_out_ln = String_in_ln + Number;
        endif;
        %subst(String_out:String_in_ln + 1:16000) = String;
      endif;
    else;
      String_out    = String_in;
      String_out_ln = String_in_ln;
    endif;
  endif;
  if 0 < %scan(hl7EndOfBlock:String_out);
    NoMoreRecords = 'Y';
  endif;
  select;
    when NoMoreRecords = 'Y';
      ReturnCode = '1';                                               //  No more records
    other;
      ReturnCode = '0';                                               //  every thing good
  endsl;
  return ReturnCode;
end-proc GetString;
//#----------------------------------------------------------------------------
dcl-proc GetStringLn;

  dcl-pi GetStringLn        packed(5:0);
    InString              varchar(32767);
  end-pi;

  dcl-s Number              packed(5:0) inz;
  InString = %trimr(InString);
  Number = %scan(hl7EndOfBlock:InString);
  if Number < 1;
    Number = 16000;
  endif;
  return Number;
end-proc;
//********************************************** REPLACE CHAR WITH BLANK.
dcl-proc SCANSEP;

  dcl-pi SCANSEP           varchar(32000);
    SCANSEPERATOR            char(1) value;
    SCANSTRING            varchar(32000);
  end-pi;

  if SCANSTRING <> *blank;
    SCANSTRING = %trimr(SCANSTRING);
    dow 0 <> %scan(SCANSEPERATOR:%trim(SCANSTRING):1);
      if SCANSTRING = *blank;
        leave;
      endif;
      %subst(SCANSTRING:
      %scan(SCANSEPERATOR:SCANSTRING:1):1) = ' ';
      if SCANSTRING = *blank;
        leave;
      endif;
    enddo;
  endif;
  return SCANSTRING;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc ClearHL7Encdng;
  dcl-pi *n               varchar(32767);
    SCANSTRING            varchar(32767) value options(*convert); // was varchar.
  end-pi;

  dcl-s COUNTER              zoned(5:0) inz;
  dcl-s Pos                  zoned(5:0) inz(1);

  if SCANSTRING <> *blank;
    SCANSTRING = %trimr(SCANSTRING);
    Pos = %scan(enviornment.escapeChar:SCANSTRING:POS);
    dow Pos <> 0;
      select;
        when 'F' = %subst(SCANSTRING:Pos + 1:1);
          SCANSTRING = %replace(enviornment.fieldChar:SCANSTRING:Pos:3);
        when 'S' = %subst(SCANSTRING:Pos + 1:1);
          SCANSTRING = %replace(enviornment.subFieldChar:SCANSTRING:Pos:3);
        when 'T' = %subst(SCANSTRING:Pos + 1:1);
          SCANSTRING = %replace(enviornment.subSubFieldChar:SCANSTRING:Pos:3);
        when 'R' = %subst(SCANSTRING:Pos + 1:1);
          SCANSTRING = %replace(enviornment.fieldRepChar:SCANSTRING:Pos:3);
        when 'E' = %subst(SCANSTRING:Pos + 1:1);
          SCANSTRING = %replace(enviornment.escapeChar:SCANSTRING:Pos:3);
        other;
      endsl;
      if (POS + 1) >= %len(%trimr(SCANSTRING));
        leave;
      endif;
      Pos = %scan(enviornment.escapeChar:SCANSTRING:POS + 1);
    enddo;
  endif;
  return SCANSTRING;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc WRITE_KEYS;
  dcl-pi WRITE_KEYS           char(7);
    KEYNAME                  char(50) value;
    KEYvalue              varchar(5000) value options(*convert);
    ALLOW_BLANK              char(1) value;
  end-pi;

  if KEYvalue <> *blank or ALLOW_BLANK = 'Y' or ALLOW_BLANK = 'y';
    TMPKEY    = KEYNAME;
    TMPVAL    = KEYvalue;
    write HL7TMPKR;
  endif;

  return 'writeky';
end-proc;
//#----------------------------------------------------------------------------
dcl-proc CheckReportSeg;
  dcl-pi *n                  char(3);
    InSeg                    char(3) value;
  end-pi;
  dcl-s RetCode              char(3) inz;
  chain (enviornment.id:INSEG) HL7CFG20R;
  if %found(JH7CFG20L1) = *on;
    RetCode = InSeg;
  else;
    RetCode = 'not';
  endif;
  return RetCode;
end-proc;
//#----------------------------------------------------------------------------
/copy ../cb_rpgle/print/qprint_print.rpgle
/copy cb/tempKeys.rpgle

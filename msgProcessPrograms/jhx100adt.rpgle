**FREE

/COPY QMISCCOPY,HSPEC_H
//***************************************************************
//
//   JHX100adt - BREAK OUT THE DATA BETWEEN SEPARATORS.
//
//**************************k*********k**************************
dcl-f JHXIN                  // H UsrOpn;                             // HOLD JHX MESSAGE
Dcl-F JHXCFG10L1             Keyed                                   // HOLD FIELD INFO
                             UsrOpn;
Dcl-F JHXCFG20L1             Keyed                                   // HOLD report
                             UsrOpn;
Dcl-F JHXTMPK                Usage(*OUTPUT)                          // HOLD KEYS
                             UsrOpn;
Dcl-F JHXTMPR                Usage(*OUTPUT)                          // HOLD REPORT
                             UsrOpn;

/COPY QMISCCOPY,CPPRINTLOF

// Procedure Interface
Dcl-PI JHX100ADT;
   ENVORMENT                 Like(ENVORMENT);
End-PI;

/COPY QMISCCOPY,CPPRINTLOD
/COPY QMISCCOPY,CPQCMDD
/COPY QMISCCOPY,CPATOI
dcl-pr GetString            Char(7);
  String_in             VarChar(32767);
  String_in_ln           Packed(5:0) Value;
  String_out               Char(32767);
  String_out_ln          Packed(5:0);
  Reset                    Char(1) Value;
end-pr;

dcl-pr SCANSEP           VarChar(6000);
  SCANSEPERATOR            Char(1) VALUE;
  SCANSTRING            VarChar(6000);
end-pr;


//SPLITSTRING      PR         32000A   Varying
// SPINFIELD                      5S 0 VALUE
// SPINSEPERATOR                  1A   VALUE
// SPINSTRING                 32000A   VALUE Varying

dcl-pr WRITE_KEYS           Char(7);
  KEYNAME                  Char(50) VALUE;
  KEYVALUE              VarChar(500);
  KEYGROUP                 Char(1) VALUE;
  KEYTYPE                  Char(1) VALUE;
  KEYTYPEX                 Char(1) VALUE;
  KEYSEARCH                Char(1) VALUE;
  KEYOBJECT                Char(1) VALUE;
  ALLOW_BLANK              Char(1) VALUE;
end-pr;

dcl-pr ClearHL7Encdng    VarChar(32767);
  SCANSTRING            VarChar(32767);
end-pr;

dcl-pr GetStringLn        Packed(5:0);
  InString              VarChar(32767);
end-pr;

dcl-pr CheckReportSeg       Char(3);
  InSeg                    Char(3) Value;
end-pr;

dcl-c HEX0B                     X'0B';
dcl-c HEX0D                     X'0D';
dcl-c HEX1C                     X'1C';
dcl-c NULL                      X'00';

dcl-s FOUND1C               Char(1) Inz('N');
dcl-s WorkString            Char(32767);
dcl-s WorkString_ln       Packed(5:0);

dcl-s SEG_ST              Packed(5:0) Inz(1);
dcl-s SEG_ED              Packed(5:0);
dcl-s SEG_LN              Packed(5:0);
dcl-s SEG_CTR             Packed(5:0);
dcl-s SEG_HED               Char(3);
dcl-s SEG                VarChar(2001);

dcl-s Err                   Char(7);
dcl-s LINECTR              Zoned(9:0) INZ(0);
//OBXSEG          S          32000A   Varying
//SINGLEOBX       S              1A
dcl-s TempLine           VarChar(6000);
dcl-s SegCtrVal             Char(4) Inz('0');

/COPY QMISCCOPY,CPYENVPASS
//==========================================================================================
// Start of moved field definitions.
//==========================================================================================
dcl-s CCREPORTCTR         Packed(3:0);
dcl-s SCIN                  Char(6000);
dcl-s SCOUT                 Char(6000);
dcl-s SCSTART             Packed(3:0);
dcl-s SCTR                Packed(3:0);
dcl-s SCWK                  Char(1);
dcl-s SEG_ED2             Packed(5:0);
dcl-s SEG_FD              Packed(5:0);
dcl-s SEG_0D              Packed(5:0);
dcl-s SPFIN               Packed(5:0);
dcl-s SPFLAG              Packed(1:0);
dcl-s SPINFIELD           Packed(5:0);
dcl-s SPINSEPERATOR         Char(1);
dcl-s SPINSTRING            Char(6000);
dcl-s SPLENG              Packed(5:0);
dcl-s SPNOTFOUND          Packed(1:0);
dcl-s SPOUTBACK             Char(6000);
dcl-s SPSEPCNT            Packed(5:0);
dcl-s SPSTART             Packed(5:0);
dcl-s ZZ_doCount          Packed(9:0);
//==========================================================================================
// End of moved field definitions.
//==========================================================================================

FOUND1C       = 'N';
WorkString    = *Blank;
WorkString_ln = 0;
Err           = *Blank;
LINECTR       = 0;
TempLine      = ' ';
SegCtrVal     = '0';
SEG_ST        = 1;
SEG_ED        = 0;
SEG_LN        = 0;
SEG_CTR       = 0;
SEG_HED       = ' ';
SEG           = ' ';
TempLine      = ' ';
SegCtrVal     = '0';
//                  Eval



exsr OpenFiles;

// >>>>> Automatically removed by conversion
//C     *ENTRY        PLIST
//C                   PARM                    ENVORMENT
// >>>>> Automatically removed by conversion
//C     SEGKEY        KLIST
//C                   KFLD                    ENVID
//C                   KFLD                    SEG_HED
// >>>>> Automatically removed by conversion
//C     SEGKEY2       KLIST
//C                   KFLD                    ENVID
//C                   KFLD                    SEG_HED
//C                   KFLD                    SegCtrVal

Err = GetString(WorkString:WorkString_ln:
WorkString:WorkString_ln:'Y');
exsr GETSEG;
exsr CloseFiles;

return;
if 'x' = 'y';
  *InLR = *On;
endif;
begsr OpenFiles;
  open JHXIN;
  if Not %Open(JHXCFG10L1);
    open JHXCFG10L1;
  endif;
  if Not %Open(JHXCFG20L1);
    open JHXCFG20L1;
  endif;
  open JHXTMPK;
  open JHXTMPR;
  open Qsysprt;
endsr;
begsr CloseFiles;
  close JHXIN;
//***               Close     JHXCFG10L1
//***               Close     JHXCFG20L1
  close JHXTMPK;
  close JHXTMPR;
  close Qsysprt;
endsr;
//********************************************************* SPLIT UP THE SEGMENTS
begsr GETSEG;
  Err = GetString(WorkString:0:WorkString:WorkString_ln:'n');
  SEG_ST  = %SCAN(HEX0B:WorkString:SEG_ST) + 1;                       // get stat of messag
  dou HEX1C = %subst(WorkString:1:1);
    if SEG_ST > *ZERO;
      for ZZ_doCount = 1 To 3;
        if Hex0d = %SUBST(WorkString:SEG_ST:1);
          SEG_ST = SEG_ST + 1;
        else;
          leave;
        endif;
      endfor;
      SEG_HED = %SUBST(WorkString:SEG_ST:3);
      exsr GETSEGV;
    else;
      FOUND1C = 'Y';
    endif;
    if FOUND1C = 'Y';
      leave;
    endif;
    if WorkString_ln < 3000;
      Err = GetString(WorkString:WorkString_ln:
      WorkString:WorkString_ln:'n');
    endif;
    SEG = *BLANKS;
    SEG_ED = %SCAN(HEX0D:WorkString);
    SEG_ST = 1;
    if (SEG_ST + 1) = %Scan(HEX1C:WorkString);
      leave;
    endif;
  enddo;
endsr;
//************************** GET INFO ACCORDING TO DATA FILE. ONLY CALL FROM GETSEG!!!
begsr GETSEGV;
  ERR = CheckReportSeg(SEG_HED);
  if (CFG20REPOR = 'Y' or CFG20REPOR = 'y') and                       // ENVREPORT
  SEG_HED = Err;                                                      // ENVRPTSEG
    exsr OBXSR;
  else;
    SEG_ED = %SCAN(HEX0D:WorkString:SEG_ST + 1);
    if SEG_ED = 0;
      WorkString_ln = 0;
      WorkString = *blank;
    else;
      SEG_LN = (SEG_ED + 1) - (SEG_ST + 1);
      if SEG_LN > *ZERO;
        SEG = %SUBST(WorkString:SEG_ST:SEG_LN);
      else;
        SEG_HED = *BLANKS;
      endif;
      if %LEN(%TRIM(SEG)) > 7;                                        // This is to
        if SEG_HED = CheckReportSeg(SEG_HED);                         // stop emty
          exsr SPLITOBX2;                                             // segments.
        endif;                                                        //   ENVRPTSEG
        if %trim(SegCtrVal) = '0';
          chain (ENVID:SEG_HED) HL7CFG10R;
          *IN51 = not %found();
        else;
          chain (ENVID:SEG_HED:SEGCTRVAL) HL7CFG10R;
          *IN51 = not %found();
        endif;
        dow *IN51 = *OFF;
          exsr SEGMENTSR;
          if %trim(SegCtrVal) = '0';
            reade (ENVID:SEG_HED) HL7CFG10R;
            *IN51 = %eof();
          else;
            reade (ENVID:SEG_HED:SEGCTRVAL) HL7CFG10R;
            *IN51 = %eof();
          endif;
        enddo;
      endif;
      WorkString_ln = WorkString_ln - SEG_ED;
      WorkString = %SUBST(WorkString:SEG_ED + 1 :
      WorkString_ln);
    endif;
  endif;
  SegCtrVal = '0';
endsr;
//*************************************************************************
begsr OBXSR;

  SEG = %subst(WorkString:SEG_ST);
  CCREPORTCTR = 1;
  dou CFG20FLD#  = CCREPORTCTR;                                       //   ENVRPTFELD
    SEG_ST = %SCAN(ENVFIELDSEP:WorkString:SEG_ST + 1);
    CCREPORTCTR = CCREPORTCTR + 1;
  enddo;
  SEG_ST = %SCAN(ENVFIELDSEP:WorkString:SEG_ST + 1) + 1;
  if CFG20SFLD# > 1;
    CCREPORTCTR = 1;
    dou CFG20SFLD# = CCREPORTCTR;
      SEG_ST = %SCAN(ENVSUBFIELDSEP:WorkString:SEG_ST + 1);
      CCREPORTCTR = CCREPORTCTR + 1;
    enddo;
//*                 EVAL      SEG_ST = %SCAN(ENVSUBFIELDSEP:WorkString:
//*                                                         SEG_ST + 1) + 1
    SEG_ST = SEG_ST + 1;
  endif;
  WorkString    = %subst(WorkString: SEG_ST: WorkString_ln - SEG_ST + 1 );
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
    if WorkString_ln < 3000;
      Err = GetString(WorkString:WorkString_ln: WorkString:WorkString_ln:'n');
    endif;
    SEG_ED = %SCAN(%TRIM(CFG20SEPL)                                   //         ENVSEPL
    :WorkString:SEG_ST);
    if SEG_ED = 0;
      SEG_0D = %SCAN(HEX0D:WorkString:SEG_ST);
      if SEG_0D = 0;
        SEG_ED = %SCAN(HEX1C:WorkString:SEG_ST);
        if SEG_ED = 0;
          SPFLAG = 9;
        else;
          SPFLAG = 9;
          FOUND1C = 'Y';
        endif;
      else;
        if SEG_0D <> 0;                                               //  This is
          SEG_ED = SEG_0D;                                            //  used if
          SEG_FD = %scan(ENVFIELDSEP:WorkString:SEG_ST);              //  is not last
          if SEG_FD < SEG_0D and SEG_FD > 0;                          //  field
            SEG_ED2 = SEG_FD;
          else;
            SEG_ED2 = SEG_0D;
          endif;
        endif;
        SPFLAG = 9;
        SEG_LN = SEG_ED2 - SEG_ST;
        if SEG_LN > 0;
          TMPRPT = %SUBST(WorkString:SEG_ST:SEG_LN);
        else;
          TMPRPT = *BLANKS;
        endif;
        TMPRPT = ClearHL7Encdng(TMPRPT);
        LINECTR = LINECTR + 1;
        TMPRPTLIN = LINECTR;
        write HL7TMPRR;
        WorkString_ln = WorkString_ln - SEG_LN;
        WorkString = %subst(WorkString:SEG_LN + 1: WorkString_ln);
        leave;
      endif;
    endif;
    SEG_LN = SEG_ED - SEG_ST;
    if SEG_LN > 0;
      TMPRPT = %SUBST(WorkString:SEG_ST:SEG_LN);
    else;
      TMPRPT = *BLANKS;
    endif;
    TMPRPT = ClearHL7Encdng(TMPRPT);
    LINECTR = LINECTR + 1;
    TMPRPTLIN = LINECTR;
    write HL7TMPRR;
    WorkString = %subst(WorkString:SEG_LN + 1 + %LEN(%TRIM(CFG20SEPL)):WorkString_ln - SEG_LN + 1 ); //ENVSEPL
    
    WorkString_ln = WorkString_ln - ( SEG_LN + %LEN(%TRIM(CFG20SEPL)) );                              //  ENVSEPL
    SEG_ST = 1;
  enddo;
  if HEX0D = %subst(WorkString:1:1);
    WorkString = %subst(WorkString:2:
    WorkString_ln - 1);
    WorkString_ln = WorkString_ln - 1;
  endif;

  chain (ENVID:SEG_HED) HL7CFG10R;
  *IN59 = not %found();
  dow *IN59 = *OFF;
    exsr SEGMENTSR;
    reade (ENVID:SEG_HED) HL7CFG10R;
    *IN59 = %eof();
  enddo;
  SEG_HED = *BLANKS;

endsr;
//*************************************************************************
begsr SPLITOBX2;
  if CFG20CTRF <> 0;
    SPINFIELD = CFG20CTRF + 1;
    SPINSEPERATOR = ENVFIELDSEP;
    SPINSTRING = SEG;
    exsr SPLIT;
    SegCtrVal = SPOUTBACK;
  else;
    SegCtrVal = '0';
  endif;
  SPINFIELD = CFG20FLD#  + 1;                                         // ENVRPTFELD
  SPINSEPERATOR = ENVFIELDSEP;
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
  SPINSEPERATOR = ENVFIELDSEP;
  SPINSTRING    = SEG;
  exsr SPLIT;

  if CFG10ARRAY <> *ZERO;
    SPINFIELD     = CFG10ARRAY;
    SPINSEPERATOR = ENVREPSEP;
    SPINSTRING    = SPOUTBACK;
    exsr SPLIT;
  endif;
  if CFG10SFLD# <> *ZERO;
    SPINFIELD     = CFG10SFLD#;
    SPINSEPERATOR = ENVSUBFIELDSEP;
    SPINSTRING    = SPOUTBACK;
    exsr SPLIT;
    if CFG10SSFLD <> *ZERO;
      SPINFIELD     = CFG10SSFLD;
      SPINSEPERATOR = ENVSUBSUBFIELD;
      SPINSTRING    = SPOUTBACK;
      exsr SPLIT;
    endif;
  endif;
  SPOUTBACK = SCANSEP(ENVSUBFIELDSEP:SPOUTBACK);
  ERR = WRITE_KEYS(CFG10KEYDS:SPOUTBACK: CFG10GROUP:CFG10KR: CFG10TYPEX: CFG10SERCH:CFGOBJECT: CFG10BLANK);
endsr;
//**************************************************

// REMOVES THE FIELD SPEATOR

begsr SCANSR;
  SCOUT = *BLANKS;
  SCSTART = 1;
  SCTR = 1;
  SCWK = *BLANK;
  if SCIN <> *BLANK;
    SCWK = %SUBST(SCIN:SCTR:1);
    dow SCTR < 199;
      if SCWK = ENVSUBFIELDSEP;
        %SUBST(SCIN:SCTR:1) = ' ';
      endif;
      SCTR = SCTR + 1;
      SCWK = %SUBST(SCIN:SCTR:1);
    enddo;
  endif;
  SCOUT = SCIN;
  SCIN = *BLANKS;
endsr;
//*********************************************************

//   CUT UP STRING BY DELIMITER
//   INPUTS : SPINFIELD     - THE FIELD YOU WANT  5.0
//            SPINSEPERATOR - THE DELIMITER       1
//            SPINSTRING    - THE STRING TO SPLIT 32000
//   OUTPUTS: SPOUTBACK     - THE RESULT          32000
begsr SPLIT;

  SPOUTBACK = *BLANK;
  SPNOTFOUND = *ZERO;
  SPSTART = 1;
  SPFIN = *ZERO;
  SPSEPCNT = *ZERO;
  SPLENG = *ZERO;
  if %LEN(%TRIM(SPINSTRING)) > *ZERO;
    if SPINFIELD > 1;
      dou (SPINFIELD - 1) = SPSEPCNT;
        SPSTART = %SCAN(SPINSEPERATOR :SPINSTRING:SPSTART);
        if SPSTART > %LEN(%TRIMR(SPINSTRING));
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
      SPOUTBACK = *BLANK;
    else;
      if SPINSTRING <> *BLANK;
        SPFIN = %SCAN(%TRIM(SPINSEPERATOR):
        SPINSTRING:SPSTART);
        SPFIN = SPFIN - 1;
        if SPFIN < 1;
          SPFIN = %LEN(%TRIMR(SPINSTRING));
        endif;
        SPLENG =  SPFIN - SPSTART;
        if SPLENG > -1;
          SPOUTBACK=%SUBST(SPINSTRING:SPSTART:SPLENG+1);
          if SPINSEPERATOR = %SUBST(SPOUTBACK:1:1);
            SPOUTBACK=%SUBST(SPINSTRING:SPSTART+1:SPLENG);
          endif;
        endif;
        if SPSTART = 1;
          SPOUTBACK=%SUBST(SPINSTRING:SPSTART:SPLENG+1);
        endif;
      else;
        SPOUTBACK = SPINSTRING;
      endif;
      if SPSTART = 0;
        SPOUTBACK = *BLANK;
      endif;
      if SPOUTBACK = SPINSEPERATOR;
        SPOUTBACK = *BLANK;
      endif;
    endif;
  endif;
  SPINFIELD = *ZERO;
  SPINSEPERATOR = *BLANK;
  SPINSTRING = *BLANK;
endsr;
//*********************************************************
/COPY QMISCCOPY,CPPRINTLOO
/COPY QMISCCOPY,CPPRINTLOP
/COPY QMISCCOPY,CPQCMDP
//*********************************************************
//
//   CUT UP STRING BY DELIMITER
//   INPUTS : SPINFIELD     - THE FIELD YOU WANT  5.0
//            SPINSEPERATOR - THE DELIMITER       1
//            SPINSTRING    - THE STRING TO SPLIT 32000
//   OUTPUTS: SPOUTBACK     - THE RESULT          32000
//SPLITSTRING      B
//
// SPLITSTRING     PI         32000A   Varying
//  SPINFIELD                     5S 0 VALUE
//  SPINSEPERATOR                 1A   VALUE
//  SPINSTRING                32000A   VALUE Varying
//
//SpoutBack        S          32000a   Varying

//                   MOVEL     *BLANK        SPOUTBACK     32000
//                   Z-ADD     *ZERO         SPNOTFOUND        1 0
//                   Z-ADD     1             SPSTART           5 0
//                   Z-ADD     *ZERO         SPFIN             5 0
//                   Z-ADD     *ZERO         SPSEPCNT          5 0
//                   Z-ADD     *ZERO         SPLENG            5 0
//                   IF        %LEN(%TRIM(SPINSTRING)) > *ZERO              -------\
//**                                                     This get the start of the I
//                   IF        SPINFIELD > 1                                -----\ I
//                   DOU       (SPINFIELD - 1) = SPSEPCNT                   ---\ I I
//                   EVAL      SPSTART = %SCAN(SPINSEPERATOR                   I I I
//                                                    :SPINSTRING:SPSTART)     I I I
//                   IF        SPSTART > %LEN(%TRIMR(SPINSTRING))           -\ I I I
//                   LEAVE                                                   I I I I
//                   ENDIF                                                  -/ I I I
//                   IF        SPSTART <= 1                                 -\ I I I
//                   EVAL      SPNOTFOUND = 1                                I I I I
//                   LEAVE                                                   I I I I
//                   ENDIF                                                  -/ I I I
//                   EVAL      SPSEPCNT = SPSEPCNT + 1                         I I I
//                   EVAL      SPSTART  = SPSTART  + 1                         I I I
//                   ENDDO                                                  ---/ I I
//                   ELSE                                                   ----<I I
//                   EVAL      SPSTART = 1                                       I I
//                   ENDIF                                                  -----/ I
//                   IF        SPNOTFOUND = 1                               -----\ I
//                   EVAL      SPOUTBACK = *BLANK                                I I
//                   ELSE                                                   ----<I I
//                   EVAL      SPFIN = %SCAN(%TRIM(SPINSEPERATOR):               I I
//                                     SPINSTRING:SPSTART)                       I I
//                   EVAL      SPFIN = SPFIN - 1                                 I I
//                   IF        SPFIN < 1                                    -\   I I
//                   EVAL      SPFIN = %LEN(%TRIMR(SPINSTRING))              I   I I
//                   ENDIF                                                  -/   I I
//                                                                               I I
//                   EVAL      SPLENG =  SPFIN - SPSTART                         I I
//                   IF        SPLENG > -1                                  ---\ I I
//                   EVAL      SPOUTBACK=%SUBST(SPINSTRING:SPSTART:SPLENG+1)   I I I
//                   IF        SPINSEPERATOR = %SUBST(SPOUTBACK:1:1)        -\ I I I
//                   EVAL      SPOUTBACK=%SUBST(SPINSTRING:SPSTART+1:SPLENG) I I I I
//                   ENDIF                                                  -/ I I I
//                   ENDIF                                                  ---/ I I
//                   IF        SPSTART = 1                                  -\   I I
//                   EVAL      SPOUTBACK=%SUBST(SPINSTRING:SPSTART:SPLENG+1) I   I I
//                   ENDIF                                                  -/   I I
//                   IF        SPSTART = 0                                  -\   I I
//                   EVAL      SPOUTBACK = *BLANK                            I   I I
//                   ENDIF                                                  -/   I I
//                   IF        SPOUTBACK = SPINSEPERATOR                    -\   I I
//                   EVAL      SPOUTBACK = *BLANK                            I   I I
//                   ENDIF                                                  -/   I I
//                   ENDIF                                                  -----/ I
//                   ELSE                                                   ------<I
//                   EVAL      SPOUTBACK = *BLANK                                  I
//                   ENDIF                                                  -------/
//                   Z-ADD     *ZERO         SPINFIELD         5 0
//                   MOVEL     *BLANK        SPINSEPERATOR     1
//                  MOVEL     *BLANK        SPINSTRING    32000
//                   RETURN    SPOUTBACK
//                 E
//**************************************************************
dcl-proc GetString;                                                   // Get from JHXin if
  dcl-pi *N;                                                          //     needed
  end-pi;
  dcl-pi GetString            Char(7);
    String_in             VarChar(32767);
    String_in_ln           Packed(5:0) Value;
    String_out               Char(32767);
    String_out_ln          Packed(5:0);
    Reset                    Char(1) Value;
  end-pi;

  dcl-s ReadRecord            Char(1) Static Inz('Y');
  dcl-s NoMoreRecords         Char(1) Static Inz('N');
  dcl-s ReturnCode            Char(7) Inz;
  dcl-s String             VarChar(32767);
  dcl-s Number              Packed(5:0) Inz;

  if Reset = 'Y';
    ReadRecord    = 'Y';
    NoMoreRecords = 'N';
  else;
    if NoMoreRecords = 'N';
      if ReadRecord = 'Y';
        read(E) JHXIN;
        *IN50 = %error();
        *IN50 = %eof();
        ReadRecord = 'N';
      else;
        ReadRecord = 'Y';
      endif;
      if *In50 = *On;
        NoMoreRecords = 'Y';
        String_out    = String_in;
        String_out_ln = String_in_ln;
      else;
        if ReadRecord = 'N';
          String = %SUBST(IN7DATA:1:3000);
        else;
          String = %SUBST(IN7DATA:3001:3000);
        endif;
        Number = GetStringLn(String);
        if 3000 = Number;
          String_out_ln = String_in_ln + 3000;
        else;
          String_out_ln = String_in_ln + Number;
        endif;
        %SUBST(String_out:String_in_ln + 1:3000)
        = String;
      endif;
    else;
      String_out    = String_in;
      String_out_ln = String_in_ln;
    endif;
  endif;
  if 0 < %scan(HEX1C:String_out);
    NoMoreRecords = 'Y';
  endif;
  select;
    when NoMoreRecords = 'Y';
      ReturnCode = '1';                                               // No more records
    other;
      ReturnCode = '0';                                               //  every thing good
  endsl;
  return ReturnCode;
end-proc GetString;
//#----------------------------------------------------------------------------
dcl-proc GetStringLn;

  dcl-pi GetStringLn        Packed(5:0);
    InString              VarChar(32767);
  end-pi;

  dcl-s Number              Packed(5:0) Inz;
  InString = %trimr(InString);
  Number = %scan(HEX1C:InString);
  if Number < 1;
    Number = 3000;
  endif;
  return Number;
end-proc;
//********************************************** REPLACE CHAR WITH BLANK.
dcl-proc SCANSEP;

  dcl-pi SCANSEP           VarChar(6000);
    SCANSEPERATOR            Char(1) VALUE;
    SCANSTRING            VarChar(6000);
  end-pi;

  if SCANSTRING <> *BLANK;
    SCANSTRING = %trimr(SCANSTRING);
    dow 0 <> %SCAN(SCANSEPERATOR:%TRIM(SCANSTRING):1);
      if SCANSTRING = *BLANK;
        leave;
      endif;
      %SUBST(SCANSTRING:
      %SCAN(SCANSEPERATOR:SCANSTRING:1):1) = ' ';
      if SCANSTRING = *BLANK;
        leave;
      endif;
    enddo;
  endif;
  return SCANSTRING;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc ClearHL7Encdng;
  dcl-pi ClearHL7Encdng    VarChar(32767);
    SCANSTRING            VarChar(32767);
  end-pi;

  dcl-s COUNTER              Zoned(5:0) INZ;
  dcl-s Pos                  Zoned(5:0) INZ(1);

  if SCANSTRING <> *BLANK;
    SCANSTRING = %trimr(SCANSTRING);
    Pos = %SCAN(ENVESCSEP:SCANSTRING:POS);
    dow Pos <> 0;
      select;
        when 'F' = %Subst(SCANSTRING:Pos + 1:1);
          SCANSTRING = %Replace(ENVFIELDSEP:
          SCANSTRING:Pos:3);
        when 'S' = %Subst(SCANSTRING:Pos + 1:1);
          SCANSTRING = %Replace(ENVSUBFIELDSEP:
          SCANSTRING:Pos:3);
        when 'T' = %Subst(SCANSTRING:Pos + 1:1);
          SCANSTRING = %Replace(ENVSUBSUBFIELD:
          SCANSTRING:Pos:3);
        when 'R' = %Subst(SCANSTRING:Pos + 1:1);
          SCANSTRING = %Replace(ENVREPSEP:
          SCANSTRING:Pos:3);
        when 'E' = %Subst(SCANSTRING:Pos + 1:1);
          SCANSTRING = %Replace(ENVESCSEP:
          SCANSTRING:Pos:3);
        other;
      endsl;
      if (POS + 1) >= %len(%trimr(SCANSTRING));
        leave;
      endif;
      Pos = %SCAN(ENVESCSEP:SCANSTRING:POS + 1);
    enddo;
  endif;
  return SCANSTRING;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc WRITE_KEYS;
  dcl-pi WRITE_KEYS           Char(7);
    KEYNAME                  Char(50) VALUE;
    KEYVALUE              VarChar(500);
    KEYGROUP                 Char(1) VALUE;
    KEYTYPE                  Char(1) VALUE;
    KEYTYPEX                 Char(1) VALUE;
    KEYSEARCH                Char(1) VALUE;
    KEYOBJECT                Char(1) VALUE;
    ALLOW_BLANK              Char(1) VALUE;
  end-pi;

  if KEYVALUE <> *BLANK or ALLOW_BLANK = 'Y' or
  ALLOW_BLANK = 'y';
    TMPKEY    = KEYNAME;
    TMPOBJECT = KEYOBJECT;
    TMPGRP    = KEYGROUP;
    TMPKEYT   = KEYTYPE;
    TMPTYPEX  = KEYTYPEX;
    TMPSERCH  = KEYSEARCH;
    TMPVAL    = KEYVALUE;
    write HL7TMPKR;
  endif;

  return 'writeky';
end-proc;
//#----------------------------------------------------------------------------
dcl-proc CheckReportSeg;
  dcl-pi CheckReportSeg       Char(3);
    InSeg                    Char(3) Value;
  end-pi;
  dcl-s RetCode               Char(3) Inz;

// >>>>> Automatically removed by conversion
//C     ENVID1        Klist
//C                   Kfld                    ENVID
//C                   Kfld                    InSeg
  chain (ENVID:INSEG) HL7CFG20R;
  if %Found(JHXCFG20L1) = *On;
    RetCode = InSeg;
  else;
    RetCode = 'not';
  endif;
  return RetCode;
end-proc;


**FREE

//
/COPY QMISCCOPY,HSPEC_H


dcl-f JHXTMPK                UsrOpn;
dcl-f JHXIN                  UsrOpn;


// Procedure Interface
Dcl-PI JHXADTSTR;
   ENVORMENT                 Like(ENVORMENT);
End-PI;

/COPY QMISCCOPY,ALPHABETD
/COPY QMISCCOPY,XLATE_D
/COPY QMISCCOPY,GETTIME_D
/COPY QMISCCOPY,STRPROC_D
/COPY QMISCCOPY,GETNWBID_D
/COPY QMISCCOPY,MMMODVAL_D
/COPY QMISCCOPY,CPYENVPASS

dcl-s WB_ID                 Char(10);
dcl-s WBPath                Char(5);
dcl-s Err                   Char(7);

exsr OpenFiles;

/COPY QMISCCOPY,MMMODVAL_C


exsr Main;
exsr CloseFiles;
return;
if 'x' = 'y';                                                         // -\
  *InLR = *On;                                                        //  I
endif;                                                                // -/

begsr OpenFiles;
  open JHXTMPK;
  open JHXIN;
endsr;
begsr CloseFiles;
  close JHXTMPK;
  close JHXIN;
endsr;
//#----------------------------------------------------------------------------
begsr Main;
  Err = GetNewWBID(%subst(ENVPATH:1:2) %subst(ENVPATH:3:12):*Blank:*Blank:*Blank:'ADT Interface.' + GetTime:WB_ID:WBPath);

  read HL7INR;
  Err=MMModVal(WB_ID:'HL7DATE':%char(IN7DATIM));
  read HL7TMPKR;
  dow %eof(JHXTMPK) = *Off;                                           // -\
    Err = MMModVal(WB_ID:TMPKEY:TMPVAL);                              //  I
    read HL7TMPKR;                                                    //  I
  enddo;                                                              // -/

  Err = MMModWriteVars;

  Err = StartProcess(%subst(ENVPATH:15:10)
  :wb_id);
endsr;
//*************************************************************************

/COPY QMISCCOPY,XLATE_P
/COPY QMISCCOPY,GETTIME_P
/COPY QMISCCOPY,STRPROC_P
/COPY QMISCCOPY,GETNWBID_P
/COPY QMISCCOPY,MMMODVAL_P


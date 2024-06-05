**FREE

//
/COPY QMISCCOPY,HSPEC_H

dcl-f JHXCON10L1             Keyed                                   /// CONSTANTS
dcl-f JHXTMPKL2              Usage(*UPDATE:*DELETE:*OUTPUT) Keyed    /// HOLD KEYS
dcl-f SMISPHN0U1             Keyed;


// Procedure Interface
Dcl-PI JHX200FAX;
   ENVORMENT                 Like(ENVORMENT);
End-PI;

/Copy QMiscCopy,XLATE_D
/Copy QMiscCopy,AD0103_D
/Copy QMiscCopy,ALPHABETD
/Copy QMiscCopy,SMISDBG0_D
/Copy QMiscCopy,WRITE0000D
/Copy QMiscCopy,CPYENVPASS

dcl-s Err                   Char(1) Inz;
dcl-s Bla                   Char(26) Inz;

dcl-s DoctorNumber          Char(50);
dcl-s DoctorName            Char(50);
dcl-s AddressLine1          Char(50);
dcl-s City                  Char(50);
dcl-s Zip                   Char(50);
dcl-s PhoneNumber           Char(50);
dcl-s TempPhoneNumber       Char(50);
dcl-s DialOut               Char(50);
dcl-s InActive              Char(50);
dcl-s ActiveDeactive        Char(1);
dcl-s Exchange              Char(3);
dcl-s Local                 Char(1);

dcl-pr GetKeyValue       VarChar(1000);
  InString                 Char(10) Value;
end-pr;

dcl-pr StripChar            Char(50);
  InString                 Char(50) Value;
end-pr;

dcl-pr LongDist             Char(1);
  InExchange               Char(3) Value;
end-pr;


// >>>>> Automatically removed by conversion
//C     *ENTRY        PList
//C                   Parm                    ENVORMENT

callp GetDebugValue;
callp WriteDbg('0':
       'Update Fax nickname table. Starting');
callp WriteDbg('1':ENVORMENT);
callp WriteDbg('2':'Main');

exsr StaticSr;

DoctorNumber   = GetKeyValue('DOCNUMBER ');
DoctorName     = GetKeyValue('DOCNAME   ');
AddressLine1   = GetKeyValue('STREET1   ');
City           = GetKeyValue('CITY      ');
Zip            = GetKeyValue('ZIP       ');
PhoneNumber    = GetKeyValue('NUMBER    ');
ActiveDeactive = GetKeyValue('ACTIVEFLAG');
DialOut        = GetKeyValue('DIALOUT   ');
InActive       = GetKeyValue('INACTIVE  ');

if ActiveDeactive = 'A';                                              // -----\
  PhoneNumber = XLate(PhoneNumber:Bla:GblUpp);                        //      I
  PhoneNumber = XLate(PhoneNumber:Bla:GblLow);                        //      I
  PhoneNumber = XLate(PhoneNumber:'   ':'()-');                       //      I
  PhoneNumber = StripChar(PhoneNumber);                               //      I
  select;                                                             // ---\ I
    when %len(%trim(PhoneNumber)) = 11;                               // --<I I
      Exchange = %subst(%trim(PhoneNumber):5:3);                      //    I I
      Local = LongDist(Exchange);                                     //    I I
      if Local = 'Y';                                                 // -\ I I
        TempPhoneNumber = %trim(DialOut) +                            //  I I I
        %subst(%triml(PhoneNumber):4:3)  + '-' +                      //  I I I
        %subst(%triml(PhoneNumber):7:4);                              //  I I I
      else;                                                           // <I I I
        TempPhoneNumber = %trim(DialOut) +                            //  I I I
        %subst(%triml(PhoneNumber):1:1)  + '-' +                      //  I I I
        %subst(%triml(PhoneNumber):2:3)  + '-' +                      //  I I I
        %subst(%triml(PhoneNumber):4:3)  + '-' +                      //  I I I
        %subst(%triml(PhoneNumber):7:4);                              //  I I I
      endif;                                                          // -/ I I
    when %len(%trim(PhoneNumber)) = 10;                               // --<I I
      Exchange = %subst(%trim(PhoneNumber):4:3);                      //    I I
      Local = LongDist(Exchange);                                     //    I I
      if Local = 'Y';                                                 // -\ I I
        TempPhoneNumber = %trim(DialOut) +                            //  I I I
        %subst(%triml(PhoneNumber):4:3)  + '-' +                      //  I I I
        %subst(%triml(PhoneNumber):7:4);                              //  I I I
      else;                                                           // <I I I
        TempPhoneNumber = %trim(DialOut) + '1' +                      //  I I I
        '-' +                                                         //  I I I
        %subst(%triml(PhoneNumber):1:3)  + '-' +                      //  I I I
        %subst(%triml(PhoneNumber):4:3)  + '-' +                      //  I I I
        %subst(%triml(PhoneNumber):7:4);                              //  I I I
      endif;                                                          // -/ I I
    when %len(%trim(PhoneNumber)) = 7;                                // --<I I
      PhoneNumber = DialOut + %trim(PhoneNumber);                     //    I I
    when %len(%trim(PhoneNumber)) = 4;                                // --<I I
      TempPhoneNumber = PhoneNumber;                                  //    I I
    other;                                                            // --<I I
      TempPhoneNumber = PhoneNumber;                                  //    I I
  endsl;                                                              // ---/ I
else;                                                                 // ----<I
  TempPhoneNumber = InActive;                                         //      I
endif;                                                                // -----/

PhoneNumber = TempPhoneNumber;

Err = UpDateFaxNick(DoctorNumber:DoctorName:
PhoneNumber:AddressLine1:
%trim(City) + ' ' + %trim(Zip) );



callp WriteDbg('0':
       'Update Fax nickname table. Stopping');


*InLR = *On;

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **

begsr StaticSr;
  callp WriteDbg('2':'StaticSr');
  chain EnvID HL7CONR;
  *IN50 = not %found();
  if %found(JHXCON10L1) = *on;
    dou %eof(JHXCON10L1) = *on;
      TMPKEY    = CONNAM;
      TMPOBJECT = CONOBJECT;
      TMPGRP    = CONGRP;
      TMPKEYT   = CONTYPE;
      TMPTYPEX  = CONTYPEX;
      TMPSERCH  = CONSERCH;
      TMPVAL    = CONVAL;
      write HL7TMPKR;
      reade EnvID HL7CONR;
      *IN50 = %eof();
    enddo;
  endif;

endsr;
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **

/Copy QMiscCopy,XLATE_P
/Copy QMiscCopy,AD0103_P
/Copy QMiscCopy,SMISDBG0_P
/Copy QMiscCopy,WRITE0000P

dcl-proc GetKeyValue;
  dcl-pi GetKeyValue       VarChar(1000);
    InString                 Char(10) Value;
  end-pi;

  callp WriteDbg('2':'GetKeyValue');
  callp WriteDbg('3':InString);
  if InString <> *blank;                                              // ---\
    chain InString HL7TMPKR;                                          //    I
    if %found(JHXTMPKL2) = *Off;                                      // -\ I
      TmpVal = *Blank;                                                //  I I
    endif;                                                            // -/ I
  else;                                                               // --<I
    TmpVal = *Blank;                                                  //    I
  endif;                                                              // ---/
  callp WriteDbg('4':TMPVAL);
  return %trim(TMPVAL);
end-proc;
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **

dcl-proc StripChar;
  dcl-pi StripChar            Char(50);
    InString                 Char(50) Value;
  end-pi;

  dcl-s Pos                  Zoned(9:0) Inz;

  callp WriteDbg('2':'StripChar');
  callp WriteDbg('3':InString);
  if %len(%trim(InString)) > *Zero;                                   // -----\
    Pos = %scan(' ':%trim(InString));                                 //      I
    dow Pos > *Zero;                                                  // ---\ I
      InString = %replace('':%trim(InString):Pos:1);                  //    I I
      if InString = *blank;                                           // -\ I I
        leave;                                                        //  I I I
      endif;                                                          // -/ I I
      Pos = %scan(' ':%trim(InString));                               //    I I
    enddo;                                                            // ---/ I
  endif;                                                              // -----/
  callp WriteDbg('4':InString);
  return InString;
end-proc;
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **

dcl-proc LongDist;
  dcl-pi LongDist             Char(1);
    InExchange               Char(3) Value;
  end-pi;

  dcl-s Return                Char(1) Inz;

  callp WriteDbg('2':'LongDist');
  callp WriteDbg('3':InExchange);
  chain InExchange SMISPHN0R;
  if %found(SMISPHN0U1);
    return = 'Y';
  else;
    return = 'N';
  endif;
  callp WriteDbg('4':Return);
  return Return;
end-proc;


**FREE


/COPY QMISCCOPY,HSPEC_H


dcl-f JHXIN                  ;


// Procedure Interface
Dcl-PI JHX200ADT;
   ENVORMENT                 Like(ENVORMENT);
End-PI;

// Prototypes
Dcl-PR ADTCNTL                  ExtPgm('ADTCNTL');
   AdtPass                   Like(AdtPass);
End-PR;

/Copy QMiscCopy,CPYENVPASS

dcl-s Err                   Char(1) Inz;
dcl-s AdtPass               Char(4096) Inz;


read HL7INR;

AdtPass = IN7DATA;

callp ADTCNTL(AdtPass);

*InLR = *On;



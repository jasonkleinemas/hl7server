**FREE

/COPY QMISCCOPY,HSPEC_H
//***************************************************************
//
//  WILL CLEAN OUT MESSAGES OLDER THAN ONE WEEK.
//
//***************************************************************

dcl-s TIMENOW          TimeStamp Inz;
dcl-s Date             TimeStamp Inz;
dcl-s ERR                   Char(7) Inz;
Exec SQL
  Set option commit = *none;
TIMENOW = %dec(%time());
Date = TimeNow - %days(30);                                           //   days ago

Exec SQL
  DELETE FROM JHXLOG WHERE LOGDATIM < :Date;

*INLR = *ON;


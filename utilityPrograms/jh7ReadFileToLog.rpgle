**FREE

//ctl-opt option(*srcstmt) dftactgrp(*no);
/copy ../cb_rpgle/genericHeaders/controlOptions.rpgle

dcl-f JH7LOG  keyed qualified usage(*update:*delete:*output);

dcl-ds myLogR likerec(jh7log.logFileR:*all);

dcl-pi *n;
  is_pathfileName  char(300); // Full /path/file.name
end-pi;

/copy ../cb_rpgle/generalSystemOsHeaders/apiFormatERRC0100.rpgle
/copy ../cb_rpgle/genericHeaders/programStatusDataStructure.rpgle

/copy cb/general_dcl.rpgle

dcl-pr ifsOpenFile  pointer extProc( '_C_IFS_fopen' );  // Opens/Creates a file pointer
  *n pointer value options(*string);                 // File Name
  *n pointer value options(*string);                 // Access Mode String
end-pr;

dcl-pr ifsReadFile   pointer extproc('_C_IFS_fgets');
  *n                 pointer value; //Retrieved data
  *n                 int(10) value; //Data size
  *n                 pointer value; //Misc pointer
end-pr;

dcl-pr ifsCloseFile extproc('_C_IFS_fclose');
  *n                 pointer value; //Misc pointer
end-pr;

//#----------------------------------------------------------------------------
//
//dcl-pr ifs_fputs int(10:0) extProc('_C_IFS_fputs');  // Puts Data to File
//  *n pointer value  options( *string );              // String to Write
//  *n pointer value;                                  // File pointer from open
//end-pr;                                                                                
//
//#----------------------------------------------------------------------------

  dcl-s pFH           pointer inz;

  dcl-s ws_pathFile   varchar(300);
  dcl-s RtvData       char(3000)  inz('');

  *inlr = *on;


  is_pathfileName = %xlate(null:' ':is_pathfileName);
  ws_pathFile = %trim(is_pathfileName);
// displayLongText('***' + %trim(ws_pathFile) + '***');

  pFH = ifsOpenFile(%trim(ws_pathFile):'r');

  if pFH = *null;
    displayLongText('Unable to open IFS file.<*>' + %trim(ws_pathFile) + '<*>');
    return;
  endif;

//  displayLongText('***' + %trim(RtvData) + '***');
  myLogR.LOGDATA = hl7StartOfBlock;
  dow ifsReadFile(%addr(RtvData):3000:pFH) <> *null;
//displayLongText('***' + %trim(RtvData) + '***');
    RtvData = %trim(%xlate(x'25':' ':RtvData));
    RtvData = %trim(%xlate(null:' ':RtvData));
    RtvData = %xlate(lineFeed:' ':RtvData);
    RtvData = %xlate(carrigeReturn:' ':RtvData);
    myLogR.LOGDATA = %trim(myLogR.LOGDATA) + %trim(RtvData) + hl7SegmentTerm;
    RtvData = ' ';
  enddo;
//displayLongText('***' + %trim(RtvData) + '***');
  myLogR.LOGDATA = %trim(myLogR.LOGDATA) + hl7EndOfBlock + hl7SegmentTerm;
  ifsCloseFile(%addr(pFH));

  myLogR.LOGDATIM   = %timeStamp();
  myLogR.LOGCOUNTER = 1;
  myLogR.LOGJOB#    = %char(pgmPsds.jobNumber);
  write jh7log.logFileR myLogR;

  return;


/copy ../cb_rpgle/text/displayLongText.rpgle
**free

dcl-ds enviornmentTemplate len(1000) qualified template;
  id                       char( 10) inz(*blank);
  sendingApp               char(180) inz('1LDFKGSAAJGASLKJGASDKNGRASLJGF');
  sendingFacility          char(180) inz(*blank);
  recevingApp              char(180) inz(*blank);
  recevingFaciity          char(180) inz(*blank);
  messageType              char(  3) inz(*blank);
  messageEvent             char(  3) inz(*blank);
  programCallArray         char( 10) dim(9);
  sperators                char(  5) inz(*blank);
   fieldChar               char(  1) overlay(sperators:1); // |
   subFieldChar            char(  1) overlay(sperators:2); // ^
   fieldRepChar            char(  1) overlay(sperators:3); // ~
   escapeChar              char(  1) overlay(sperators:4); // \
   subSubFieldChar         char(  1) overlay(sperators:5); // &
  logToFile                char(  1) inz(*blank); // 'Y' = true
  logToPrinter             char(  1) inz(*blank); // 'Y' = true
  testingFlag              char(  1) inz(*blank); // 'Y' = true
end-ds;
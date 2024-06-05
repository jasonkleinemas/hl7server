**free
dcl-s ws_msh               char(750);  // Working var for parseMshSegment SR
dcl-ds mshSegment qualified;
  sndApplication           char(180);
  sndFacility              char(180);
  rcvApplication           char(180);
  rcvFacility              char(180);
  type                     char(  3);
  event                    char(  3);
end-ds;
**free
/if not defined(parseMshSegment)
/define parseMshSegment
begsr parseMshSegment;
  posStartBlock = %scan(hl7StartOfBlock:IN7DATA:1);
  if posStartBlock <> 0;
    
    posSegmentTerminator = %scan(hl7SegmentTerm:IN7DATA:posStartBlock);
    ws_msh = %subst(IN7DATA:posStartBlock:posSegmentTerminator - posStartBlock);
    enviornment.sperators  = %subst(IN7DATA:posStartBlock + 4:5);
    
    SPINFIELD     = 3;
    SPINSEPERATOR = enviornment.fieldChar;
    SPINSTRING    = ws_msh;
    exsr getField;
    mshSegment.sndApplication = %xlate(enviornment.subFieldChar:' ':SPOUTBACK); // Just remove the seperators to get the whole value.
    
    SPINFIELD     = 4;
    SPINSEPERATOR = enviornment.fieldChar;
    SPINSTRING    = ws_msh;
    exsr getField;
    mshSegment.sndFacility = %xlate(enviornment.subFieldChar:' ':SPOUTBACK); // Just remove the seperators to get the whole value.
    
    SPINFIELD     = 5;
    SPINSEPERATOR = enviornment.fieldChar;
    SPINSTRING    = ws_msh;
    exsr getField;
    mshSegment.rcvApplication = %xlate(enviornment.subFieldChar:' ':SPOUTBACK); // Just remove the seperators to get the whole value.
    
    SPINFIELD     = 6;
    SPINSEPERATOR = enviornment.fieldChar;
    SPINSTRING    = ws_msh;
    exsr getField;
    mshSegment.rcvFacility = %xlate(enviornment.subFieldChar:' ':SPOUTBACK); // Just remove the seperators to get the whole value.
    
    SPINFIELD     = 9;
    SPINSEPERATOR = enviornment.fieldChar;
    SPINSTRING    = ws_msh;
    exsr getField;
    SPINFIELD     = 1;
    SPINSEPERATOR = enviornment.subFieldChar;
    SPINSTRING    = SPOUTBACK;
    exsr getField;
    mshSegment.type = SPOUTBACK;
    
    SPINFIELD     = 9;
    SPINSEPERATOR = enviornment.fieldChar;
    SPINSTRING    = ws_msh;
    exsr getField;
    SPINFIELD     = 2;
    SPINSEPERATOR = enviornment.subFieldChar;
    SPINSTRING    = SPOUTBACK;
    exsr getField;
    mshSegment.event = SPOUTBACK;
  endif;
endsr;
/endif
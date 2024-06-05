**free
//   CUT UP STRING BY DELIMITER
//   INPUTS : SPINFIELD     - THE FIELD YOU WANT  5.0
//            SPINSEPERATOR - THE DELIMITER       1
//            SPINSTRING    - THE STRING TO SPLIT 32000
//   OUTPUTS: SPOUTBACK     - THE RESULT          32000
begsr getField;

  SPOUTBACK = *BLANK;
  SPNOTFOUND = *ZERO;
  SPSTART = 1;
  SPFIN = *ZERO;
  SPSEPCNT = *ZERO;
  SPLENG = *ZERO;
  if %LEN(%TRIM(SPINSTRING)) > *ZERO;                                 // ---------\
//*                                                     This get the start of the I
    if SPINFIELD > 1;                                                 // ------\  I
      dou (SPINFIELD - 1) = SPSEPCNT;                                 // ----\ I  I
        SPSTART = %SCAN(SPINSEPERATOR                                 //     I I  I
        :SPINSTRING:SPSTART);                                         //     I I  I
        if SPSTART > %LEN(%TRIMR(SPINSTRING));                        // --\ I I  I
          leave;                                                      //   I I I  I
        endif;                                                        // --/ I I  I
        if SPSTART <= 1;                                              // --\ I I  I
          SPNOTFOUND = 1;                                             //   I I I  I
          leave;                                                      //   I I I  I
        endif;                                                        // --/ I I  I
        SPSEPCNT = SPSEPCNT + 1;                                      //     I I  I
        SPSTART  = SPSTART  + 1;                                      //     I I  I
      enddo;                                                          // ----/ I  I
    else;                                                             // ------<  I
      SPSTART = 1;                                                    //       I  I
    endif;                                                            // ------/  I
    if SPNOTFOUND = 1;                                                // ------\  I
      SPOUTBACK = *BLANK;                                             //       I  I
    else;                                                             // ------<  I
      SPFIN = %SCAN(%TRIM(SPINSEPERATOR):                             //       I  I
      SPINSTRING:SPSTART);                                            //       I  I
      SPFIN = SPFIN - 1;                                              //       I  I
      if SPFIN < 1;                                                   // ----\ I  I
        SPFIN = %LEN(%TRIMR(SPINSTRING));                             //     I I  I
      endif;                                                          // ----/ I  I
                                                                      //       I  I
      SPLENG =  SPFIN - SPSTART;                                      //       I  I
      if SPLENG > -1;                                                 // ----\ I  I
        SPOUTBACK=%SUBST(SPINSTRING:SPSTART:SPLENG+1);                //     I I  I
        if SPINSEPERATOR = %SUBST(SPOUTBACK:1:1);                     // --\ I I  I
          SPOUTBACK=%SUBST(SPINSTRING:SPSTART+1:SPLENG);              //   I I I  I
        endif;                                                        // --/ I I  I
      endif;                                                          // ----/ I  I
      if SPSTART = 1;                                                 // ----\ I  I
        SPOUTBACK=%SUBST(SPINSTRING:SPSTART:SPLENG+1);                //     I I  I
      endif;                                                          // ----/ I  I
      if SPSTART = 0;                                                 // ----\ I  I
        SPOUTBACK = *BLANK;                                           //     I I  I
      endif;                                                          // ----/ I  I
      if SPOUTBACK = SPINSEPERATOR;                                   // ----\ I  I
        SPOUTBACK = *BLANK;                                           //     I I  I
      endif;                                                          // ----/ I  I
    endif;                                                            // ------/  I
  endif;                                                              // ---------/
  SPINFIELD = *ZERO;
  SPINSEPERATOR = *BLANK;
  SPINSTRING = *BLANK;
endsr;
//*********************************************************

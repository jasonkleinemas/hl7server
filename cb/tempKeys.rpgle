**free
/if defined(dclf_JH7TMPK)
/if not defined(tempKeys)
/define tempKeys

//#----------------------------------------------------------------------------
dcl-proc tempKeyWrite;
  dcl-pi *n        ind;
    is_keyName    char(  10) value;
    is_keyValue   char(5000) value options(*convert);
    is_allowBlank char(   1) value options(*nopass);
  end-pi;
  
  if %parms() = 2;
    is_allowBlank = 'Y';
  endif;
  if %trim(is_keyValue) <> *blank or %upper(is_allowBlank) = 'Y';
    chain is_keyName HL7TMPKR;
    TMPKEY = %trim(is_keyName);
    TMPVAL = %trim(is_keyValue);
    if %found(JH7TMPK);
      update HL7TMPKR;
    else;
      write HL7TMPKR;
    endif;
  endif;

  return true;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc tempKeyGetValue;
  dcl-pi *n       char(1000);
    is_keyName    char(  10) value;
  end-pi;

  if is_keyName <> *blank;
    chain is_keyName HL7TMPKR;
    if not %found(JH7TMPK);
      TMPVAL = *blank;
    endif;
  else;
    TMPVAL = *blank;
  endif;

  return %trim(TMPVAL);
end-proc;
/endif
/endif
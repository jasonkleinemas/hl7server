**free
/if defined(dclf_JH7DOC10)
/if not defined(proc_JH7DOC10)
/define proc_JH7DOC10
//#----------------------------------------------------------------------------
dcl-proc openJH7DOC10;
  if not %open(JH7DOC10);
    open JH7DOC10;
  endif;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc closeJH7DOC10;
  if %open(JH7DOC10);
    close JH7DOC10;
  endif;
end-proc;
//#----------------------------------------------------------------------------
/endif
/endif
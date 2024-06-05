**free
/if defined(dclf_JH7CON10L1)
/if not defined(proc_JH7CON10L1)
/define proc_JH7CON10L1
//#----------------------------------------------------------------------------
dcl-proc openJH7CON10L1;
  if not %open(JH7CON10L1);
    open JH7CON10L1;
  endif;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc closeJH7CON10L1;
  if %open(JH7CON10L1);
    close JH7CON10L1;
  endif;
end-proc;
//#----------------------------------------------------------------------------
/endif
/endif
**free
/if defined(dclf_JH7GEN10L1)
/if not defined(proc_JH7GEN10L1)
/define proc_JH7GEN10L1
//#----------------------------------------------------------------------------
dcl-proc openJH7GEN10L1;
  if not %open(JH7GEN10L1);
    open JH7GEN10L1;
  endif;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc closeJH7GEN10L1;
  if %open(JH7GEN10L1);
    close JH7GEN10L1;
  endif;
end-proc;
//#----------------------------------------------------------------------------
/endif
/endif
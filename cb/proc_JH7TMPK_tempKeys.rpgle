**free
/if defined(dclf_JH7TMPK)
/if not defined(proc_JH7TMPK)
/define proc_JH7TMPK
//#----------------------------------------------------------------------------
dcl-proc openJH7TMPK;
  if not %open(JH7TMPK);
    open JH7TMPK;
  endif;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc closeJH7TMPK;
  if %open(JH7TMPK);
    close JH7TMPK;
  endif;
end-proc;
//#----------------------------------------------------------------------------
/endif
/endif
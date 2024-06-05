**free
/if defined(dclf_JH7TMPD)
/if not defined(proc_JH7TMPD)
/define proc_JH7TMPD
//#----------------------------------------------------------------------------
dcl-proc openJH7TMPD;
  if not %open(JH7TMPD);
    open JH7TMPD;
  endif;
end-proc;
//#----------------------------------------------------------------------------
dcl-proc closeJH7TMPD;
  if %open(JH7TMPD);
    close JH7TMPD;
  endif;
end-proc;
//#----------------------------------------------------------------------------
/endif
/endif
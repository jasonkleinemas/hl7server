**free
/if not defined(srSetEnvSperators)
/define srSetEnvSperators
begsr srSetEnvSperators;
  enviornment.sperators  = %subst(IN7DATA:posStartBlock + 4:5);
endsr;
/endif
**free
/if not defined(ipPortGood)
/define ipPortGood
dcl-proc ipPortGood;
  dcl-pi *n ind;
    is_portNumber uns(10) value;
  end-pi;
  if is_portNumber > ipSocketPortMin-1 and is_portNumber < ipSocketPortMax+1;
    return true;
  endif;

  if is_portNumber < ipSocketPortMin;
    qPrintLog('<<< Port Number to Low. Min' + %char(ipSocketPortMin));
  else;
    qPrintLog('<<< Port Number to High. Max' + %char(ipSocketPortMax));
  endif;
  return false;
end-proc;
/endif
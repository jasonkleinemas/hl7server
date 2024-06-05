**free
/if not defined(ipStartListen)
/define ipStartListen
dcl-proc ipStartListen;
  dcl-pi *n ind;
  end-pi;
  
  qPrintLog('*** Server Starting.');

  socketDescripton = ipSocket(addressFamily_inet:socketType_stream:0); // Obtain a socket descriptor for itself

  if socketDescripton < 0;                                             // If socket failed - End the server
    qPrintLog('<<< Unable to Create Socket.');
    return false;
  endif;
                                                                     // Allow socket description to be reusable
  socketReturnCode = ipSetSockOpt(socketDescripton:socketType_sol:socketLevel_reuseAddr:%addr(socketOptions):%size(socketOptions));
                                                                     // Bind the socket to an IP address
  ipSocketInfo = *allx'00';
  ipSocketInfo.family = addressFamily_inet;
  ipSocketInfo.port   = socketPortNumber;
  ipSocketInfo.addr   = internetAddress_any;

  qPrintLog('*** Start of Bind To Port ' +  %trim(%char(socketPortNumber)) + '.');
  socketReturnCode = ipBind(socketDescripton:%addr(ipSocketInfo):%size(ipSocketInfo));

  if socketReturnCode < 0;                                           // If bind failed - End the server
    qPrintLog('<<< Unable to Bind to Port ' +  %trim(%char(socketPortNumber))  + '.');
    return false;
  endif;
  
  qPrintLog('*** Bound To Port ' +  %trim(%char(socketPortNumber)) + '.');
  qPrintLog('*** Start of Listen.');                               // If listen failed - End the server
  socketReturnCode = ipListen(socketDescripton:1);                 // Listen to one client only

  if socketReturnCode < 0;
    qPrintLog('<<< Unable to Listen.');
    return false;
  endif;

  qPrintLog('*** Listening.');
                                                                 // Accept incoming connection request from the client.
                                                                 // A new socket (socketDescripton2) is created for the client.
  socketDescripton2 = ipAccept(socketDescripton:%addr(ipSocketInfo):%addr(AddressLen));

  qPrintLog('*** Start of Accept.');
  if socketReturnCode < 0;                                       // If accept failed - End the server
    qPrintLog('<<< Unable to Accept.');
  else;
//          qPrintLog('*** Start of Receve.');
//          dow endProgram = *off;                                       // Enter read/write loop
//            exsr readSocketdata;
//          enddo;
    return true;
  endif;
end-proc;
/endif
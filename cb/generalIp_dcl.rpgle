**free

dcl-s SocketData           char(32000);                               // Socket data buffer
dcl-s SocketData@        pointer       inz(%addr(SocketData));        // Socket data pointer
dcl-s socketDataLength       int(10:0) inz(%size(SocketData));        // Socket data length
dcl-s socketPortNumber       int(10:0) inz(0);                        // Port number
dcl-s socketDescripton       int(10:0);                               // Socket# for the serv
dcl-s socketDescripton2      int(10:0);                               // Socket# for the clie
dcl-s socketReturnCode       int(10:0);                               // Return code for sock
dcl-s socketOptions          uns(10:0) inz(1);                        // Option name for SetSockOpt funct


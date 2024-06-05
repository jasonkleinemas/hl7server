**FREE

//================================================================
//   D a t a   d e f i n i t i o n s
//================================================================

dcl-c ipSocketPortMin 1;
dcl-c ipSocketPortMax 65535;

//-- Socket address information structure ------------------------
dcl-ds ipSocketInfo qualified;
  family            int( 5:0);
  port              uns( 5:0);
  addr              uns(10:0);
  zero              char(  8) inz(*allx'00');
end-ds;
// This might beable to remove
//dcl-s pIpSocketInfo pointer inz(%addr(ipSocketInfo));
dcl-s AddressLen    int(10:0) inz(%len(ipSocketInfo)) ;
//dcl-s pAddressLen   pointer inz(%addr(AddressLen));

//-- Address families --------------------------------------------

dcl-c addressFamily_unix         1;
dcl-c addressFamily_inet         2;
//dcl-c AF_NS                     6;
//dcl-c AF_TELEPHONY              99;


//-- Socket types ------------------------------------------------

dcl-c socketType_stream          1;
//dcl-c SOCK_DGRAM                2;
//dcl-c SOCK_RAW                  3;
//dcl-c SOCK_SEQPACKET            5;

dcl-c socketType_sol            -1;


//-- Socket level options ----------------------------------------

dcl-c socketLevel_broadcast      5;
dcl-c socketLevel_debug         10;
dcl-c socketLevel_dontRoute     15;
dcl-c socketLevel_error         20;
dcl-c socketLevel_keppAlive     25;
dcl-c socketLevel_linger        30;
dcl-c socketLevel_reuseAddr     55;


//-- Internet address specifications -----------------------------

dcl-c internetAddress_any        0;
dcl-c internetAddress_broadcast -1;
dcl-c internetAddress_loopBack   X'7F000000';
dcl-c internetAddress_none      -1;




//================================================================
//   S u b p r o c e d u r e   p r o t o t y p e s
//================================================================

dcl-pr ipSocket     int(10:0) extProc('socket');       // Socket - Create a socket
  *n                int(10:0) value;                   // Address Faimily
  *n                int(10:0) value;                   // Address Type
  *n                int(10:0) value;                   // Protocol
end-pr;

dcl-pr ipSetSockOpt int(10:0) extProc('setsockopt');   // Setsockopt - Set socket options
  *n                int(10:0) value;                   // Socket Descriptor
  *n                int(10:0) value;                   // Level
  *n                int(10:0) value;                   // Option Name
  *n                pointer   value;                   // Option Value
  *n                int(10:0) value;                   // Option Length
end-pr;

dcl-pr ipBind       int(10:0) extProc('bind');         // Bind - Bind to a socket
  *n                int(10:0) value;                   // Socket Descriptor
  *n                pointer   value;                   // struct sockaddr *local_address,
  *n                int(10:0) value;                   // Address Length
end-pr;

dcl-pr ipListen     int(10:0) extProc('listen');       // Listen - Invite for the incoming connections requests
  *n                int(10:0) value;                   // Socket Descriptor
  *n                int(10:0) value;                   // Back log.
end-pr;

dcl-pr ipAccept      int(10:0) extProc('accept');       // Accept - Accept an incoming connections request
  *n                 int(10:0) value;                   // Socket Descriptor
  *n                 pointer   value;                   // struct sockaddr *address
//  *n                 int(10:0);                         // Address Length
  *n                 pointer   value;                   // Address Length
end-pr;

dcl-pr ipInet_addr   uns(10:0) extProc('inet_addr');    // InetAddr - Transform IP address from dotted form
  *n                 pointer value options(*string);    // *address_string
end-pr;

dcl-pr ipConnect    int(10:0) extProc('connect');      // Connect - Connect to the server
  *n                int(10:0) value;                   // Socket Descriptor
  *n                pointer   value;                   // struct sockaddr *destination_address
  *n                int(10:0) value;                   // Address Length
end-pr;

//-- ----------------
//-- Host entry returned pointers --------------------------------

dcl-ds HostEnt                  Align based(Host@);
  HName@                pointer;
  HAliases@             pointer;
  HAddrType                 int(10:0);
  HLength                   int(10:0);
  HAddrList@            pointer;
end-ds;

//-- Host entry data ---------------------------------------------

dcl-ds HostEntData              Align based(HostEntData@);
  HName                    char(256);
  HAliasesArr@          pointer dim(65);
  HAliasesArr              char(256) dim(64);
  HAddrArr@             pointer dim(101);
  HAddrArr                  uns(10:0) dim(100);
  OpenFlag                  int(10:0);
  F0@                   pointer;
  FileP0                   char(260);
  Reserved0                char(150);
  F1@                   pointer;
  FileP1                   char(260);
  Reserved1                char(150);
  F2@                   pointer;
  FileP2                   char(260);
  Reserved2                char(150);
end-ds;

dcl-s Server@            pointer inz;
dcl-s HostentData@       pointer inz;
dcl-s Host@              pointer inz;

//   struct HostEnt {
//      char   *h_name;
//      char   **h_aliases;
//      int    h_addrtype;
//      int    h_length;
//      char   **h_addr_list;
//   };

//   struct HostEnt *GetHostByName(char *host_name);

dcl-pr getHostByName pointer extProc('gethostbyname');// GetHostByName - Get host address from name
  *n                 pointer value;                   // 
end-pr;

dcl-pr ipFcntl      int(10:0) extProc('fcntl');       // FCntl - Change flags
  *n                int(10:0) value;                  // Socket descriptor
  *n                int(10:0) value;                  // Command
  *n                int(10:0) value options(*noPass); // Arg
end-pr;

//-- I/O options (Fcntl) -----------------------------------------

dcl-s F_SETFL                int(10:0) inz(7);
dcl-s O_NONBLOCK             int(10:0) inz(128);
dcl-c EWOULDBLOCK               3406;

//-- Socket descritption bits in 4 byte unsigned integers

//dcl-ds FD_Set;
//  FDes                      uns(10:0) dim(7);
//end-ds;

//-- FDzero --- Zero socket description bit (for Select function)

//   #define FD_ZERO(fds)  (memset(fds,0,sizeof(fd_set)))

//dcl-pr FDZero;
//  FDes                      uns(10:0) dim(7);
//end-pr;


//-- FDSet --- Set socket description bit (for Select function)

//   #define FD_SET(fd, fds)  \
//         set bits

//dcl-pr FDSet;
//  FD                        int(10:0) value;
//  FDes                      uns(10:0) dim(7);
//end-pr;


//-- FDClr --- Clear socket description bit (for Select function)

//   #define FD_CLR(fd, fds)   \


//dcl-pr FDClr;
//  FD                        int(10:0) value;
//  FDes                      uns(10:0) dim(7);
//end-pr;


//-- FDIsSet --- Test if a socket description bit is set on
//               (for Select function)

//   #define FD_ISSET(fd, fds)  \


//dcl-pr FDIsSet               int(10:0);
//  FD                        int(10:0) value;
//  FDes                      uns(10:0) dim(7);
//end-pr;


//-- Select -  Wait for events on multiple sockets
//             and set bits for active sockets

//   int select(int max_descriptor,
//              fd_set *read_set,
//              fd_set *write_set,
//              fd_set *exception_set,
//              struct timeval *wait_time);

//dcl-pr Select                int(10:0) extProc('select');
//  MaxDescr                  int(10:0) value;
//  ReadSet               pointer value;
//  WriteSet              pointer value;
//  ExceptSet             pointer value;
//  WaitTime              pointer value;
//end-pr;

dcl-pr ipRead       int(10:0) extProc('read');        // Read - Read data from the socket
  *n                int(10:0) value;                  // Socket descriptor
  *n                pointer   value;                  // Buffer
  *n                uns(10:0) value;                  // Buffer Length
end-pr;

dcl-pr ipRecv       int(10:0) extProc('recv');        // Recv - Receive data from the socket
  *n                int(10:0) value;                  // Socket descriptor
  *n                pointer   value;                  // Buffer
  *n                int(10:0) value;                  // Buffer Length
  *n                int(10:0) value;                  // Flags
end-pr;

dcl-pr ipWrite      int(10:0) extProc('write');       // Write - Write data to the socket
  *n                int(10:0) value;                  // Socket descriptor
  *n                pointer   value;                  // Buffer
  *n                uns(10:0) value;                  // Buffer Length
end-pr;

dcl-pr ipSend       int(10:0) extProc('send');        // Send - Send data to the socket
  *n                int(10:0) value;                  // Socket descriptor
  *n                pointer   value;                  // Buffer
  *n                int(10:0) value;                  // Buffer Length
  *n                int(10:0) value;                  // Flags
end-pr;

dcl-pr ipClose      extProc('close');                 // Close --- Close a socket
  *n                int(10:0) value;                  // Socket descriptor
end-pr;
//#----------------------------------------------------------------------------
//-- Error number information ------------------------------------

dcl-s ErrNo         int(10:0) based(ErrNo@);
dcl-s ErrNo@        pointer   inz;
dcl-s ErrMsg        char( 60) based(ErrMsg@);
dcl-s ErrMsg@       pointer   inz;

dcl-pr getErrNo     pointer extProc('__errno');       // GetErrNo - Get error number
end-pr;

dcl-pr strError     pointer extProc('strerror');      // StrError - Get error text
  *n                int(10:0) value;
end-pr;

//dcl-pr sleep        uns(10:0) extProc('sleep');      // Sleep - Sleep function (delay job) 
//  *n                uns(10:0) value;                 // Seconds
//end-pr;


//-- Inheritance structure for Spawn function --------------------

dcl-c SETSIGMASK                X'00000002';
dcl-c SETSIGDEF                 X'00000004';
dcl-c SETPGROUP                 X'00000008';
dcl-c SETTHREAD_NP              X'00000010';
dcl-c SETPJ_NP                  X'00000020';
dcl-c FDCLOSED                  -1;
dcl-c NEWPGROUP                 -1;
dcl-c MAX_NUM_ARGS              255;

//--  -----------------

//   pid_t spawn( const char                *path,
//                const int                 fd_count,
//                const int                 fd_map[],
//                const struct inheritance  *inherit,
//                const char                *argv[],
//                const char                *envp[]);

dcl-pr spawn        int(10:0) extProc('Qp0zSpawn');  // Spawn - Spawn function (create a process)
  *n                pointer   value;                 // 
  *n                int(10:0) value;                 // 
  *n                pointer   value;                 // 
  *n                pointer   value;                 // 
  *n                pointer   value;                 // 
  *n                pointer   value;                 // 
end-pr;

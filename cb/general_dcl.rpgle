**free

dcl-c null                      x'00';
dcl-c lineFeed                  x'0A'; // Line feed (LF)
dcl-c carrigeReturn             x'0D'; // Carriage return (CR)

dcl-c hl7StartOfBlock           x'0B'; // VT Virtical Tab - Start of Block - Start of message
dcl-c hl7SegmentTerm            x'0D'; // CR              - Segment Terminator
dcl-c hl7EndOfBlock             x'1C'; // IFS FS          - End of Block - End of message
dcl-c HEX5F                     x'5F'; // ¬ _

dcl-ds dc qualified;
  asc char(32000) pos(1) ccsid(819);
  ebc char(32000) pos(1);
end-ds;


: @CELL+ DUP CELL+ SWAP @ ;
: @CHAR+ DUP CHAR+ SWAP @ ;
: TYPE-NAME 4 - RSTR TYPE ;
: SEE-XT @CELL+ CASE
['] (lit) OF @CELL+ . ENDOF 
['] (slit) OF 83 EMIT 34 EMIT 32 EMIT @CELL+
0 ?DO @CHAR+ EMIT LOOP 34 EMIT ENDOF
['] (branch) OF ." (branch)" @CELL+ . ENDOF
['] (0branch) OF ." (0branch)" @CELL+ . ENDOF
['] (do) OF ." DO" CELL+ ENDOF
['] (?do) OF ." ?DO" CELL+ ENDOF
['] (loop) OF ." LOOP" CELL+ ENDOF
['] (+loop) OF ." +LOOP" CELL+ ENDOF
['] EXIT OF R> DROP ENDOF
DUP TYPE-NAME
ENDCASE 32 EMIT ;
: SEE-WORD BEGIN SEE-XT AGAIN ;
: SEE ' @CHAR+ 42 = IF 1+ SEE-WORD ELSE
S" Coded in assembly" THEN ;

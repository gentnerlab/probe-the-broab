                SET      0.100 1 0     ;Get rate & scaling OK
                ;VAR    V1=65280

;0000 WZRO:      DIBEQ  [.......0],WZRO ;                   >wzr
;0001 WZR2:      DIBEQ  [......0.],WZR2 ;                   >wzr
;0002 WZR3:      DIBEQ  [.....0..],WZR3 ;                   >wzr
;0003 WZR4:      DIBEQ  [....0...],WZR4 ;                   >wzr
;0004 WZR5:      DIBEQ  [...0....],WZR5 ;                   >wzr
;0005 WZR6:      DIBEQ  [..0.....],WZR6 ;                   >wzr
;0006 WZR7:      DIBEQ  [.0......],WZR7 ;                   >wzr
;0007 WZR8:      DIBEQ  [0.......],WZR8 ;                   >wzr
0000 WZRO:      WAIT   [11111111]      ;                   >wait till no input
0001 WIN:       DIBEQ  [11111111],WIN  ;                   >win
0002            DISBEQ [.......0],RESP1
;0003            DISBEQ [......0.],RESP2
0004            DISBEQ [.....0..],RESP3
0005            DISBEQ [....0...],RESP4
0006            DISBEQ [...0....],RESP5
0007            DISBEQ [..0.....],RESP6
0008            DISBEQ [.0......],RESP7
0009            DISBEQ [0.......],RESP8
0010            JUMP   WZRO

0011         '0 DIGOUT [00000000]      ;turn all low
0012            DIGLOW [00000000],WIN

0013         '9 DIGOUT [11111111]      ;turn all high
0014            DIGLOW [11111111],WIN

0015         'q DIGLOW [11111110],WIN
0016         'w DIGLOW [11111101],WIN
0017         'e DIGLOW [11111011],WIN
0018         'r DIGLOW [11110111],WIN
0019         't DIGLOW [11101111],WIN
0020         'y DIGLOW [11011111],WIN
0021         'u DIGLOW [10111111],WIN
0022         'i DIGLOW [01111111],WIN

0023         '1 DIGLOW [00000001],WIN
0024         '2 DIGLOW [00000010],WIN
0025         '3 DIGLOW [00000100],WIN
0026         '4 DIGLOW [00001000],WIN
0027         '5 DIGLOW [00010000],WIN
0028         '6 DIGLOW [00100000],WIN
0029         '7 DIGLOW [01000000],WIN
0030         '8 DIGLOW [10000000],WIN

;0024         'q DIGOUT [00000001],WIN
;0025         'w DIGOUT [00000010],WIN
;0026         'e DIGOUT [00000100],WIN
;0027         'r DIGOUT [00001000],WIN
;0028         't DIGOUT [00010000],WIN
;0029         'y DIGOUT [00100000],WIN
;0030         'u DIGOUT [01000000],WIN
;0031         'i DIGOUT [10000000],WIN
;

0031 RESP1:     MARK   76              ;                   >L
0032            WAIT   [.......1]
0033            JUMP   WIN
0034 RESP2:     MARK   67              ;                   >C
0035            WAIT   [......1.]
0036            JUMP   WIN
0037 RESP3:     MARK   82              ;                   >R
0038            WAIT   [.....1..]
0039            JUMP   WIN
0040 RESP4:     MARK   70              ;                   >Hopper
0041            WAIT   [....1...]
0042            JUMP   WIN
0043 RESP5:     MARK   53              ;                  
0044            WAIT   [...1....]
0045            JUMP   WIN
0046 RESP6:     MARK   54
0047            WAIT   [..1.....]
0048            JUMP   WIN
0049 RESP7:     MARK   55
0050            WAIT   [.1......]
0051            JUMP   WIN
0052 RESP8:     MARK   56
0053            WAIT   [1.......]
0054            JUMP   WIN
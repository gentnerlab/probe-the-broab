
;turns everything off except the houselight
                SET      0.100 1 0
                VAR    V1=1
                VAR    V2=2

0000            DIGOUT [11111111]
0001            DIGLOW [11111111]
0002            MOV    V1,V2
0003            HALT   

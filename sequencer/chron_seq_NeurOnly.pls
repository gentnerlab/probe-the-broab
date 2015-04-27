;go here for ascii codes:      http://www.asciitable.com/           
                SET    0.020,1,0       ;Get rate & scaling OK

                VAR    V1,YES=1
                VAR    V2,NO=0

                VAR    V5,nobug=0      ;keep script from bugging seq., (eg jumping out of feed per.)

                VAR    V4,itiVal       ;itival to be passed from script
                VAR    V6,itiStpCt     ;this will hold the sequencer steps since start of ITI

                VAR    V9,WvStps       ;stim length in seq steps, passed from script
                VAR    V10,WvStpCnt    ;this will hold the sequencer steps since wavest T

0000            JUMP   PTPK            ;End of this sequence section >HALT

; start the sequence for a single trial, sent here by script's 'samplekey()'
0001 TSTART: 'S WAVEGO a,TW            ;ready stim with trigger to be tripped by wavest T >TSTART
;wait for center key press to start stimulus
0002            MOV    nobug,YES
0003            WAVEST T               ;start stim here    >Start Stim
0004            MARK   60              ;make digmark for time the stim starts >Start Stim
0005            MOV    WvStpCnt,NO,3   ;reset, add 3 to stimcnt for this,next,prev ln >Start Stim
0006            JUMP   CHKPK           ;start checking for pecks>Start Stim
;
0007 STOPWV:    WAVEST S               ;stop output now, trig. by cnter exeeding stimdur >Stop Stim
0008            MARK   62              ;make digmark for time the stim ends >Stop Stim

0009            JUMP   STITI           ;                   >Stop Stim

;End of Trial
0010 END:       MARK   41              ;mark end of ITI w/ ')'>Post Trial
0011            DIGLOW [11111111]      ;turn all off but house light >Post Trial
0012            MOV    nobug,NO        ;                   >Post Trial
0013            JUMP   PTPK            ;                   >Post Trial

;utilities for sending a peck marker code without missing wavestop
;need to add timeout for the DIBEQs (eg. what if a key is stuck with food?)
0014 CHKPK:     ADD    WvStpCnt,NO,6   ;add for this line and next 5 >AudOut
0015            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>AudOut
0016            DIBEQ  [.......0],MRKLT ;check for left key peck >AudOut
0017            DIBEQ  [......0.],MRKCT ;check for center key peck >AudOut
0018            DIBEQ  [.....0..],MRKRT ;check for right key peck >AudOut
0019            JUMP   CHKPK           ;loop until called away >AudOut

0020 MRKLT:     MARK   76              ;left key peck      >L,AudOut
0021            ADD    WvStpCnt,NO,1   ;mark+this+bge, -2 unused from last add >L,AudOut
0022            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>L,AudOut
0023 MLL:       DIBEQ  [.......1],MLE  ;will branch to MLE when the key is 'unpecked'>L,AudOut
0024            ADD    WvStpCnt,NO,4   ;for MLL loop       >L,AudOut
0025            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>L,AudOut
0026            JUMP   MLL             ;                   >L,AudOut
0027 MLE:       ADD    WvStpCnt,NO,4   ;dibeq(above)+add+bge+jump >L,AudOut
0028            BGE    WvStpCnt,WvStps,STOPWV ;            >L,AudOut
0029            JUMP   CHKPK           ;                   >L,AudOut
;
0030 MRKCT:     MARK   67              ;center key peck    >C,AudOut
0031            ADD    WvStpCnt,NO,2   ;mark+this+BGE, -1 unused from last add >C,AudOut
0032            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>C,AudOut
0033 MCC:       DIBEQ  [......1.],MCE  ;will branch to MCE when the key is 'unpecked'>C,AudOut
0034            ADD    WvStpCnt,NO,4   ;for MCC loop       >C,AudOut
0035            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>C,AudOut
0036            JUMP   MCC             ;                   >C,AudOut
0037 MCE:       ADD    WvStpCnt,NO,4   ;dibeq(above)+add+bge+jump >C,AudOut
0038            BGE    WvStpCnt,WvStps,STOPWV ;            >C,AudOut
0039            JUMP   CHKPK           ;                   >C,AudOut
;
0040 MRKRT:     MARK   82              ;Right key peck     >R,AudOut
0041            ADD    WvStpCnt,NO,3   ;mark+this+bge      >R,AudOut
0042            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>R,AudOut
0043 MRR:       DIBEQ  [.....1..],MRE  ;will branch to MRE when the key is 'unpecked'>R,AudOut
0044            ADD    WvStpCnt,NO,4   ;for MRR loop       >R,AudOut
0045            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>R,AudOut
0046            JUMP   MRR             ;                   >R,AudOut
0047 MRE:       ADD    WvStpCnt,NO,4   ;dibeq(above)+add+bge+jump >R,AudOut
0048            BGE    WvStpCnt,WvStps,STOPWV ;            >R,AudOut
0049            JUMP   CHKPK           ;                   >R,AudOut


;
;ITI peck checks starting
0050 STITI:     NOP                    ;prevent 'greater than symbol', '(' being assigned same time
0051            NOP    
0052            MARK   40              ;mark start of ITI w/ '(' >ITI
0053            MOV    itiStpCt,NO,2   ;reset iti step count, add one for prev and one for this >ITI
0054 ITI:       ADD    itiStpCt,NO,6   ;this line and next 5>ITI
0055            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >ITI
0056            DIBEQ  [.......0],ILT  ;check for left key peck>ITI
0057            DIBEQ  [......0.],ICT  ;check for center key peck >ITI
0058            DIBEQ  [.....0..],IRT  ;check for right key peck >ITI
0059            JUMP   ITI             ;loop until ITI over >ITI
;
0060 ILT:       MARK   76              ;left key peck      >L,ITI
0061            ADD    itiStpCt,NO,1   ;mark+this+BGE, -2 unused from last add >L,ITI
0062            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >L,ITI
0063 IMLL:      DIBEQ  [.......1],IMLE ;will branch to IMLE when the key is 'unpecked' >L,ITI
0064            ADD    itiStpCt,NO,4   ;for IMLL loop      >L,ITI
0065            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >L,ITI
0066            JUMP   IMLL            ;                   >L,ITI
0067 IMLE:      ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >L,ITI
0068            BGE    itiStpCt,itiVal,END ;               >L,ITI
0069            JUMP   ITI             ;                   >L,ITI
;
0070 ICT:       MARK   67              ;center key peck    >C,ITI
0071            ADD    itiStpCt,NO,2   ;mark+this+BGE, -1 unused from last add >C,ITI
0072            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >C,ITI
0073 IMCC:      DIBEQ  [......1.],IMCE ;will branch to IMCE when the key is 'unpecked' >C,ITI
0074            ADD    itiStpCt,NO,4   ;for IMCC loop      >C,ITI
0075            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >C,ITI
0076            JUMP   IMCC            ;                   >C,ITI
0077 IMCE:      ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >C,ITI
0078            BGE    itiStpCt,itiVal,END ;               >C,ITI
0079            JUMP   ITI             ;                   >C,ITI
;
0080 IRT:       MARK   82              ;Right key peck     >R,ITI
0081            ADD    itiStpCt,NO,3   ;mark+this+BGE, -0 unused from last add >R,ITI
0082            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >R,ITI
0083 IMRR:      DIBEQ  [.....1..],IMRE ;will branch to IMRE when the key is 'unpecked' >R,ITI
0084            ADD    itiStpCt,NO,4   ;for IMRR loop      >R,ITI
0085            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >R,ITI
0086            JUMP   IMRR            ;                   >R,ITI
0087 IMRE:      ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >R,ITI
0088            BGE    itiStpCt,itiVal,END ;               >R,ITI
0089            JUMP   ITI             ;                   >R,ITI
;ITI peck checks done


;
;
;post/pre trial peck checks
0090 PTPK:  'P  DIBEQ  [.......0],PMLT ;left key peck      >PeckChecks
0091            DIBEQ  [......0.],PMCT ;center key peck    >PeckChecks
0092            DIBEQ  [.....0..],PMRT ;right key peck     >PeckChecks
0093            JUMP   PTPK            ;loop until called away >PeckChecks
;
0094 PMLT:      MARK   76              ;left key peck      >L,PeckChecks
0095            WAIT   [.......1]      ;                   >L,PeckChecks
0096            JUMP   PTPK            ;                   >L,PeckChecks
0097 PMRT:      MARK   82              ;right key peck     >R,PeckChecks
0098            WAIT   [.....1..]      ;                   >R,PeckChecks
0099            JUMP   PTPK            ;                   >R,PeckChecks
0100 PMCT:      MARK   67              ;center key peck    >C,PeckChecks
0101            WAIT   [......1.]      ;                   >C,PeckChecks
0102            JUMP   PTPK            ;                   >C,PeckChecks
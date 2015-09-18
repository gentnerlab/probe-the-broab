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
0003            DIGOUT [.......0]      ;turn off digout    >Start Stim
0004            WAVEST T               ;start stim here    >Start Stim
0005            MARK   60              ;make digmark for time the stim starts >Start Stim
0006            MOV    WvStpCnt,NO,3   ;reset, add 3 to stimcnt for this,next,prev ln >Start Stim
0007            JUMP   CHKPK           ;start checking for pecks>Start Stim
;
0008 STOPWV:    WAVEST S               ;stop output now, trig. by cnter exeeding stimdur >Stop Stim
0009            MARK   62              ;make digmark for time the stim ends >Stop Stim
0010            DIGOUT [.......1]      ;turn on digout     >Stop Stim
0011            JUMP   STITI           ;                   >Stop Stim

;End of Trial
0012 END:       MARK   41              ;mark end of ITI w/ ')'>Post Trial
0013            DIGLOW [11111111]      ;turn all off but house light >Post Trial
0014            MOV    nobug,NO        ;                   >Post Trial
0015            JUMP   PTPK            ;                   >Post Trial

;utilities for sending a peck marker code without missing wavestop
;need to add timeout for the DIBEQs (eg. what if a key is stuck with food?)
0016 CHKPK:     ADD    WvStpCnt,NO,6   ;add for this line and next 5 >AudOut
0017            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>AudOut
0018            DIBEQ  [.......0],MRKLT ;check for left key peck >AudOut
0019            DIBEQ  [......0.],MRKCT ;check for center key peck >AudOut
0020            DIBEQ  [.....0..],MRKRT ;check for right key peck >AudOut
0021            JUMP   CHKPK           ;loop until called away >AudOut

0022 MRKLT:     MARK   76              ;left key peck      >L,AudOut
0023            ADD    WvStpCnt,NO,1   ;mark+this+bge, -2 unused from last add >L,AudOut
0024            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>L,AudOut
0025 MLL:       DIBEQ  [.......1],MLE  ;will branch to MLE when the key is 'unpecked'>L,AudOut
0026            ADD    WvStpCnt,NO,4   ;for MLL loop       >L,AudOut
0027            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>L,AudOut
0028            JUMP   MLL             ;                   >L,AudOut
0029 MLE:       ADD    WvStpCnt,NO,4   ;dibeq(above)+add+bge+jump >L,AudOut
0030            BGE    WvStpCnt,WvStps,STOPWV ;            >L,AudOut
0031            JUMP   CHKPK           ;                   >L,AudOut
;
0032 MRKCT:     MARK   67              ;center key peck    >C,AudOut
0033            ADD    WvStpCnt,NO,2   ;mark+this+BGE, -1 unused from last add >C,AudOut
0034            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>C,AudOut
0035 MCC:       DIBEQ  [......1.],MCE  ;will branch to MCE when the key is 'unpecked'>C,AudOut
0036            ADD    WvStpCnt,NO,4   ;for MCC loop       >C,AudOut
0037            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>C,AudOut
0038            JUMP   MCC             ;                   >C,AudOut
0039 MCE:       ADD    WvStpCnt,NO,4   ;dibeq(above)+add+bge+jump >C,AudOut
0040            BGE    WvStpCnt,WvStps,STOPWV ;            >C,AudOut
0041            JUMP   CHKPK           ;                   >C,AudOut
;
0042 MRKRT:     MARK   82              ;Right key peck     >R,AudOut
0043            ADD    WvStpCnt,NO,3   ;mark+this+bge      >R,AudOut
0044            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>R,AudOut
0045 MRR:       DIBEQ  [.....1..],MRE  ;will branch to MRE when the key is 'unpecked'>R,AudOut
0046            ADD    WvStpCnt,NO,4   ;for MRR loop       >R,AudOut
0047            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>R,AudOut
0048            JUMP   MRR             ;                   >R,AudOut
0049 MRE:       ADD    WvStpCnt,NO,4   ;dibeq(above)+add+bge+jump >R,AudOut
0050            BGE    WvStpCnt,WvStps,STOPWV ;            >R,AudOut
0051            JUMP   CHKPK           ;                   >R,AudOut


;
;ITI peck checks starting
0052 STITI:     NOP                    ;prevent 'greater than symbol', '(' being assigned same time
0053            NOP    
0054            MARK   40              ;mark start of ITI w/ '(' >ITI
0055            MOV    itiStpCt,NO,2   ;reset iti step count, add one for prev and one for this >ITI
0056 ITI:       ADD    itiStpCt,NO,6   ;this line and next 5>ITI
0057            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >ITI
0058            DIBEQ  [.......0],ILT  ;check for left key peck>ITI
0059            DIBEQ  [......0.],ICT  ;check for center key peck >ITI
0060            DIBEQ  [.....0..],IRT  ;check for right key peck >ITI
0061            JUMP   ITI             ;loop until ITI over >ITI
;
0062 ILT:       MARK   76              ;left key peck      >L,ITI
0063            ADD    itiStpCt,NO,1   ;mark+this+BGE, -2 unused from last add >L,ITI
0064            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >L,ITI
0065 IMLL:      DIBEQ  [.......1],IMLE ;will branch to IMLE when the key is 'unpecked' >L,ITI
0066            ADD    itiStpCt,NO,4   ;for IMLL loop      >L,ITI
0067            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >L,ITI
0068            JUMP   IMLL            ;                   >L,ITI
0069 IMLE:      ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >L,ITI
0070            BGE    itiStpCt,itiVal,END ;               >L,ITI
0071            JUMP   ITI             ;                   >L,ITI
;
0072 ICT:       MARK   67              ;center key peck    >C,ITI
0073            ADD    itiStpCt,NO,2   ;mark+this+BGE, -1 unused from last add >C,ITI
0074            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >C,ITI
0075 IMCC:      DIBEQ  [......1.],IMCE ;will branch to IMCE when the key is 'unpecked' >C,ITI
0076            ADD    itiStpCt,NO,4   ;for IMCC loop      >C,ITI
0077            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >C,ITI
0078            JUMP   IMCC            ;                   >C,ITI
0079 IMCE:      ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >C,ITI
0080            BGE    itiStpCt,itiVal,END ;               >C,ITI
0081            JUMP   ITI             ;                   >C,ITI
;
0082 IRT:       MARK   82              ;Right key peck     >R,ITI
0083            ADD    itiStpCt,NO,3   ;mark+this+BGE, -0 unused from last add >R,ITI
0084            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >R,ITI
0085 IMRR:      DIBEQ  [.....1..],IMRE ;will branch to IMRE when the key is 'unpecked' >R,ITI
0086            ADD    itiStpCt,NO,4   ;for IMRR loop      >R,ITI
0087            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >R,ITI
0088            JUMP   IMRR            ;                   >R,ITI
0089 IMRE:      ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >R,ITI
0090            BGE    itiStpCt,itiVal,END ;               >R,ITI
0091            JUMP   ITI             ;                   >R,ITI
;ITI peck checks done


;
;
;post/pre trial peck checks
0092 PTPK:  'P  DIBEQ  [.......0],PMLT ;left key peck      >PeckChecks
0093            DIBEQ  [......0.],PMCT ;center key peck    >PeckChecks
0094            DIBEQ  [.....0..],PMRT ;right key peck     >PeckChecks
0095            JUMP   PTPK            ;loop until called away >PeckChecks
;
0096 PMLT:      MARK   76              ;left key peck      >L,PeckChecks
0097            WAIT   [.......1]      ;                   >L,PeckChecks
0098            JUMP   PTPK            ;                   >L,PeckChecks
0099 PMRT:      MARK   82              ;right key peck     >R,PeckChecks
0100            WAIT   [.....1..]      ;                   >R,PeckChecks
0101            JUMP   PTPK            ;                   >R,PeckChecks
0102 PMCT:      MARK   67              ;center key peck    >C,PeckChecks
0103            WAIT   [......1.]      ;                   >C,PeckChecks
0104            JUMP   PTPK            ;                   >C,PeckChecks
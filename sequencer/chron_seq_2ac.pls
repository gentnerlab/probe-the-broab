;go here for ascii codes:      http://www.asciitable.com/           
                SET    0.020,1,0       ;Get rate & scaling OK

                VAR    V1,YES=1
                VAR    V2,NO=0

                VAR    V5,nobug=0      ;keep script from bugging seq., (eg jumping out of feed per.)

                VAR    V4,itiVal       ;itival to be passed from script
                VAR    V6,itiStpCt     ;this will hold the sequencer steps since start of ITI

                VAR    V9,WvStps       ;stim length in seq steps, passed from script
                VAR    V10,WvStpCnt    ;this will hold the sequencer steps since wavest T

                VAR    V20,rspStVal    ;response window to be set by script
                VAR    V21,rspStCt     ;this will hold the sequencer steps since end of stim

                VAR    V22,sclass      ;stim class to be set by script on each trial

                VAR    V11,fdStpVal    ;seq steps in feed time, to be set by script
                VAR    V12,fdStpCt     ;this will hold the sequencer steps since start of feed
                VAR    V25,pnofeed     ;rate of reinf for correct responses. set by script

                VAR    V13,toStpVal    ;seq steps in TO time, to be set by script
                VAR    V14,toStpCt     ;this will hold the sequencer steps since start of feed
                VAR    V26,pnoto       ;rate of no reinf for incorrect responses. set by script

0000            HALT                   ;End of this sequence section >HALT

; start the sequence for a single trial, sent here by script's 'samplekey()'
0001 TSTART: 'S WAVEGO a,TW            ;ready stim with trigger to be tripped by wavest T >TSTART
;wait for center key press to start stimulus
0002 WCTR:      DIBEQ  [.......0],MKLT ;left key peck      >Wait center peck
0003            DIBEQ  [......0.],TRLREQ ;center key peck  >Wait center peck
0004            DIBEQ  [.....0..],MKRT ;right key peck     >Wait center peck
0005            JUMP   WCTR            ;loop until called away >Wait center peck
0006 TRLREQ:    MARK   67              ;center key peck    >C,Start Trial
0007            WAIT   [......1.]      ;only start trial after center key is unpecked >C,Start Trial
;here is a good place for preStim interval
0008            WAVEST T               ;start stim here    >Start Stim
0009            MARK   60              ;make digmark for time the stim starts >Start Stim
0010            MOV    WvStpCnt,NO,3   ;reset, add 3 to stimcnt for this,next,prev ln >Start Stim
0011            JUMP   CHKPK           ;start checking for pecks>Start Stim
;
0012 STOPWV:    WAVEST S               ;stop output now, trig. by cnter exeeding stimdur >Stop Stim
0013            MARK   62              ;make digmark for time the stim ends >Stop Stim
0014            MOV    nobug,YES       ;                   >Stop Stim


;Response peck checks (RSPPC) starting
0015            MOV    rspStCt,NO,3    ;rst fd stp cnt, +1 for prev mark,1 for this>Resp Window
0016 RSPPC:     ADD    rspStCt,NO,6    ;this line and next 5>Resp Window
0017            BGE    rspStCt,rspStVal,NORESP ;immediately stops feed if ready >Resp Window
0018            DIBEQ  [.......0],LRESP ;check for left key peck >Resp Window
0019            DIBEQ  [......0.],CRESP ;check for center key peck >Resp Window
0020            DIBEQ  [.....0..],RRESP ;check for right key peck >Resp Window
0021            JUMP   RSPPC           ;loop until feed over >Resp Window
;
0022 CRESP:     MARK   67              ;center key peck    >C,Resp Window
0023            ADD    rspStCt,NO,1    ;mark+this+BGE, -2 unused from last add >C,Resp Window
0024            BGE    rspStCt,rspStVal,NORESP ;immediately stops feed if ready >C,Resp Window
0025 RMCC:      DIBEQ  [......1.],RMCE ;branch to RMCE when the key is 'unpecked' >C,Resp Window
0026            ADD    rspStCt,NO,4    ;for RMCC loop      >C,Resp Window
0027            BGE    rspStCt,rspStVal,NORESP ;immediately stops feed if ready >C,Resp Window
0028            JUMP   RMCC            ;                   >C,Resp Window
0029 RMCE:      ADD    rspStCt,NO,4    ;dibeq(above)+add+bge+jump >C,Resp Window
0030            BGE    rspStCt,rspStVal,NORESP ;           >C,Resp Window
0031            JUMP   RSPPC           ;                   >C,Resp Window
;Response peck checks done

0032 NORESP:    MARK   78,STITI        ;Mark 'N' for no resp,(no consequence for NR) >No Response
;
0033 RRESP:     MARK   82              ;Mark 'R' for right key peck>R,consequate
0034            BEQ    sclass,2,FEED   ;feed if R resp to class 2 >R,consequate
0035            BEQ    sclass,1,TMOUT  ;timeout if R resp to class 1 >R,consequate
0036 LRESP:     MARK   76              ;Mark 'L' for left key peck >L,consequate
0037            BEQ    sclass,2,TMOUT  ;timeout if R resp to class 2 >L,consequate
0038            BEQ    sclass,1,FEED   ;feed if R resp to class 1 >L,consequate
;
;do feed with some probability
0039 FEED:      BRAND  NOFEED,pnofeed  ;                   >consequate
0040            DIGLOW [11110111]      ;raise the feeder   >feed
0041            MARK   70,FDDEL        ;uppercase F, bird is fed >feed
;need hopper up, resp during feed check here
0042 NOFEED:    MARK   102,FDDONE      ;lowercase f, bird is correct, but not fed >no feed
0043 FDELDN:    MARK   125             ;Mark end of Feed Period >feed
0044 FDDONE:    DIGLOW [11111111],STITI ;lower the feeder & goto intertrial interval >ITI
;need hopper down check here
;
;do timeout with some probability
0045 TMOUT:     BRAND  NOTO,pnoto      ;                   >consequate
0046            DIGLOW [11101111]      ;turn off everything >time out
0047            MARK   84,TODEL        ;POSTTO       ;uppercase T, timeout >time out
0048 NOTO:      MARK   116,TODONE      ;lowercase t, bird is wrong, but no timeout >no time out
0049 TDELDN:    MARK   93              ;mark end of TimeOut period >time out
0050 TODONE:    DIGLOW [11111111],STITI ;turn on the houselight & goto intertrial interval >ITI
;
;utilities for sending a peck marker code without missing wavestop
;need to add timeout for the DIBEQs (eg. what if a key is stuck with food?)
0051 CHKPK:     ADD    WvStpCnt,NO,6   ;add for this line and next 5 >AudOut
0052            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>AudOut
0053            DIBEQ  [.......0],MRKLT ;check for left key peck >AudOut
0054            DIBEQ  [......0.],MRKCT ;check for center key peck >AudOut
0055            DIBEQ  [.....0..],MRKRT ;check for right key peck >AudOut
0056            JUMP   CHKPK           ;loop until called away >AudOut

0057 MRKLT:     MARK   76              ;left key peck      >L,AudOut
0058            ADD    WvStpCnt,NO,1   ;mark+this+bge, -2 unused from last add >L,AudOut
0059            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>L,AudOut
0060 MLL:       DIBEQ  [.......1],MLE  ;will branch to MLE when the key is 'unpecked'>L,AudOut
0061            ADD    WvStpCnt,NO,4   ;for MLL loop       >L,AudOut
0062            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>L,AudOut
0063            JUMP   MLL             ;                   >L,AudOut
0064 MLE:       ADD    WvStpCnt,NO,4   ;dibeq(above)+add+bge+jump >L,AudOut
0065            BGE    WvStpCnt,WvStps,STOPWV ;            >L,AudOut
0066            JUMP   CHKPK           ;                   >L,AudOut
;
0067 MRKCT:     MARK   67              ;center key peck    >C,AudOut
0068            ADD    WvStpCnt,NO,2   ;mark+this+BGE, -1 unused from last add >C,AudOut
0069            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>C,AudOut
0070 MCC:       DIBEQ  [......1.],MCE  ;will branch to MCE when the key is 'unpecked'>C,AudOut
0071            ADD    WvStpCnt,NO,4   ;for MCC loop       >C,AudOut
0072            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>C,AudOut
0073            JUMP   MCC             ;                   >C,AudOut
0074 MCE:       ADD    WvStpCnt,NO,4   ;dibeq(above)+add+bge+jump >C,AudOut
0075            BGE    WvStpCnt,WvStps,STOPWV ;            >C,AudOut
0076            JUMP   CHKPK           ;                   >C,AudOut
;
0077 MRKRT:     MARK   82              ;Right key peck     >R,AudOut
0078            ADD    WvStpCnt,NO,3   ;mark+this+bge      >R,AudOut
0079            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>R,AudOut
0080 MRR:       DIBEQ  [.....1..],MRE  ;will branch to MRE when the key is 'unpecked'>R,AudOut
0081            ADD    WvStpCnt,NO,4   ;for MRR loop       >R,AudOut
0082            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>R,AudOut
0083            JUMP   MRR             ;                   >R,AudOut
0084 MRE:       ADD    WvStpCnt,NO,4   ;dibeq(above)+add+bge+jump >R,AudOut
0085            BGE    WvStpCnt,WvStps,STOPWV ;            >R,AudOut
0086            JUMP   CHKPK           ;                   >R,AudOut


;Feed peck checks (FDPC) starting
0087 FDDEL:     MOV    fdStpCt,NO,2    ;reset feed step cnt, add 1 for prev mark,1 for this >Feed
0088 FDPC:      ADD    fdStpCt,NO,6    ;this line and next 5>Feed
0089            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >Feed
0090            DIBEQ  [.......0],FLT  ;check for left key peck>Feed
0091            DIBEQ  [......0.],FCT  ;check for center key peck >Feed
0092            DIBEQ  [.....0..],FRT  ;check for right key peck >Feed
0093            JUMP   FDPC            ;loop until feed over >Feed

0094 FLT:       MARK   76              ;left key peck      >L,Feed
0095            ADD    fdStpCt,NO,1    ;mark+this+BGE, -2 unused from last add >L,Feed
0096            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >L,Feed
0097 FMLL:      DIBEQ  [.......1],FMLE ;will branch to FMLE when the key is 'unpecked' >L,Feed
0098            ADD    fdStpCt,NO,4    ;for FMLL loop      >L,Feed
0099            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >L,Feed
0100            JUMP   FMLL            ;                   >L,Feed
0101 FMLE:      ADD    fdStpCt,NO,4    ;dibeq(above)+add+bge+jump >L,Feed
0102            BGE    fdStpCt,fdStpVal,FDELDN ;           >L,Feed
0103            JUMP   FDPC            ;                   >L,Feed
;
0104 FCT:       MARK   67              ;center key peck    >C,Feed
0105            ADD    fdStpCt,NO,2    ;mark+this+BGE, -1 unused from last add >C,Feed
0106            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >C,Feed
0107 FMCC:      DIBEQ  [......1.],FMCE ;will branch to FMCE when the key is 'unpecked' >C,Feed
0108            ADD    fdStpCt,NO,4    ;for FMCC loop      >C,Feed
0109            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >C,Feed
0110            JUMP   FMCC            ;                   >C,Feed
0111 FMCE:      ADD    fdStpCt,NO,4    ;dibeq(above)+add+bge+jump >C,Feed
0112            BGE    fdStpCt,fdStpVal,FDELDN ;           >C,Feed
0113            JUMP   FDPC            ;                   >C,Feed
;
0114 FRT:       MARK   82              ;Right key peck     >R,Feed
0115            ADD    fdStpCt,NO,3    ;mark+this+BGE, -0 unused from last add >R,Feed
0116            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >R,Feed
0117 FMRR:      DIBEQ  [.....1..],FMRE ;will branch to FMRE when the key is 'unpecked' >R,Feed
0118            ADD    fdStpCt,NO,4    ;for FMRR loop      >R,Feed
0119            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >R,Feed
0120            JUMP   FMRR            ;                   >R,Feed
0121 FMRE:      ADD    fdStpCt,NO,4    ;dibeq(above)+add+bge+jump >R,Feed
0122            BGE    fdStpCt,fdStpVal,FDELDN ;           >R,Feed
0123            JUMP   FDPC            ;                   >R,Feed
;Feed peck checks done
;
;TO peck checks (TOPC) starting
0124 TODEL:     MOV    toStpCt,NO,2    ;reset TO step cnt, add 1 for prev mark,1 for this>TimeOut
0125 TOPC:      ADD    toStpCt,NO,6    ;this line and next 5>TimeOut
0126            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >TimeOut
0127            DIBEQ  [.......0],TLT  ;check for left key peck>TimeOut
0128            DIBEQ  [......0.],TCT  ;check for center key peck >TimeOut
0129            DIBEQ  [.....0..],TRT  ;check for right key peck >TimeOut
0130            JUMP   TOPC            ;loop until TO over >TimeOut
;
0131 TLT:       MARK   76              ;left key peck      >L,TimeOut
0132            ADD    toStpCt,NO,1    ;mark+this+BGE, -2 unused from last add >L,TimeOut
0133            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >L,TimeOut
0134 TMLL:      DIBEQ  [.......1],TMLE ;will branch to TMLE when the key is 'unpecked' >L,TimeOut
0135            ADD    toStpCt,NO,4    ;for TMLL loop      >L,TimeOut
0136            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >L,TimeOut
0137            JUMP   TMLL            ;                   >L,TimeOut
0138 TMLE:      ADD    toStpCt,NO,4    ;dibeq(above)+add+bge+jump >L,TimeOut
0139            BGE    toStpCt,toStpVal,TDELDN ;           >L,TimeOut
0140            JUMP   TOPC            ;                   >L,TimeOut
;
0141 TCT:       MARK   67              ;center key peck    >C,TimeOut
0142            ADD    toStpCt,NO,2    ;mark+this+BGE, -1 unused from last add >C,TimeOut
0143            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >C,TimeOut
0144 TMCC:      DIBEQ  [......1.],TMCE ;will branch to TMCE when the key is 'unpecked' >C,TimeOut
0145            ADD    toStpCt,NO,4    ;for TMCC loop      >C,TimeOut
0146            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >C,TimeOut
0147            JUMP   TMCC            ;                   >C,TimeOut
0148 TMCE:      ADD    toStpCt,NO,4    ;dibeq(above)+add+bge+jump >C,TimeOut
0149            BGE    toStpCt,toStpVal,TDELDN ;           >C,TimeOut
0150            JUMP   TOPC            ;                   >C,TimeOut
;
0151 TRT:       MARK   82              ;Right key peck     >R,TimeOut
0152            ADD    toStpCt,NO,3    ;mark+this+BGE, -0 unused from last add >R,TimeOut
0153            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >R,TimeOut
0154 TMRR:      DIBEQ  [.....1..],TMRE ;will branch to TMRE when the key is 'unpecked' >R,TimeOut
0155            ADD    toStpCt,NO,4    ;for TMRR loop      >R,TimeOut
0156            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >R,TimeOut
0157            JUMP   TMRR            ;                   >R,TimeOut
0158 TMRE:      ADD    toStpCt,NO,4    ;dibeq(above)+add+bge+jump >R,TimeOut
0159            BGE    toStpCt,toStpVal,TDELDN ;           >R,TimeOut
0160            JUMP   TOPC            ;                   >R,TimeOut
;TO peck checks done
;
;ITI peck checks starting
0161 STITI:     NOP                    ;prevents the 'N' and '(' from being assigned the same time
0162            MARK   40              ;mark start of ITI w/ '(' >ITI
0163            MOV    itiStpCt,NO,3   ;reset iti step count, add 2 for prev lns and 1 for this >ITI
0164 ITI:       ADD    itiStpCt,NO,6   ;this line and next 5>ITI
0165            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >ITI
0166            DIBEQ  [.......0],ILT  ;check for left key peck>ITI
0167            DIBEQ  [......0.],ICT  ;check for center key peck >ITI
0168            DIBEQ  [.....0..],IRT  ;check for right key peck >ITI
0169            JUMP   ITI             ;loop until ITI over >ITI
;
0170 ILT:       MARK   76              ;left key peck      >L,ITI
0171            ADD    itiStpCt,NO,1   ;mark+this+BGE, -2 unused from last add >L,ITI
0172            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >L,ITI
0173 IMLL:      DIBEQ  [.......1],IMLE ;will branch to IMLE when the key is 'unpecked' >L,ITI
0174            ADD    itiStpCt,NO,4   ;for IMLL loop      >L,ITI
0175            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >L,ITI
0176            JUMP   IMLL            ;                   >L,ITI
0177 IMLE:      ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >L,ITI
0178            BGE    itiStpCt,itiVal,END ;               >L,ITI
0179            JUMP   ITI             ;                   >L,ITI
;
0180 ICT:       MARK   67              ;center key peck    >C,ITI
0181            ADD    itiStpCt,NO,2   ;mark+this+BGE, -1 unused from last add >C,ITI
0182            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >C,ITI
0183 IMCC:      DIBEQ  [......1.],IMCE ;will branch to IMCE when the key is 'unpecked' >C,ITI
0184            ADD    itiStpCt,NO,4   ;for IMCC loop      >C,ITI
0185            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >C,ITI
0186            JUMP   IMCC            ;                   >C,ITI
0187 IMCE:      ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >C,ITI
0188            BGE    itiStpCt,itiVal,END ;               >C,ITI
0189            JUMP   ITI             ;                   >C,ITI
;
0190 IRT:       MARK   82              ;Right key peck     >R,ITI
0191            ADD    itiStpCt,NO,3   ;mark+this+BGE, -0 unused from last add >R,ITI
0192            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >R,ITI
0193 IMRR:      DIBEQ  [.....1..],IMRE ;will branch to IMRE when the key is 'unpecked' >R,ITI
0194            ADD    itiStpCt,NO,4   ;for IMRR loop      >R,ITI
0195            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >R,ITI
0196            JUMP   IMRR            ;                   >R,ITI
0197 IMRE:      ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >R,ITI
0198            BGE    itiStpCt,itiVal,END ;               >R,ITI
0199            JUMP   ITI             ;                   >R,ITI
;ITI peck checks done

;End of Trial
0200 END:       MARK   41              ;mark end of ITI w/ ')'>Post Trial
0201            DIGLOW [11111111]      ;turn all off but house light >Post Trial
0202            MOV    nobug,NO        ;                   >Post Trial
0203            JUMP   PTPK            ;                   >Post Trial
;
;Utils for marking digmark during pre-trial interval
0204 MKLT:      MARK   76              ;left key peck      >L,Wait Center
0205            WAIT   [.......1]      ;                   >L,Wait Center
0206            JUMP   WCTR            ;                   >L,Wait Center
0207 MKRT:      MARK   82              ;right key peck     >R,Wait Center
0208            WAIT   [.....1..]      ;                   >R,Wait Center
0209            JUMP   WCTR            ;                   >R,Wait Center
;
;post trial/Paused peck checks
0210 PTPK:  'P  DIBEQ  [.......0],PMLT ;left key peck      >Post Trial
0211            DIBEQ  [......0.],PMCT ;center key peck    >Post Trial
0212            DIBEQ  [.....0..],PMRT ;right key peck     >Post Trial
0213            JUMP   PTPK            ;loop until called away >Post Trial
;
0214 PMLT:      MARK   76              ;left key peck      >L,Post Trial
0215            WAIT   [.......1]      ;                   >L,Post Trial
0216            JUMP   PTPK            ;                   >L,Post Trial
0217 PMRT:      MARK   82              ;right key peck     >R,Post Trial
0218            WAIT   [.....1..]      ;                   >R,Post Trial
0219            JUMP   PTPK            ;                   >R,Post Trial
0220 PMCT:      MARK   67              ;center key peck    >C,Post Trial
0221            WAIT   [......1.]      ;                   >C,Post Trial
0222            JUMP   PTPK            ;                   >C,Post Trial


0223        'I  DIGLOW [......i.]      ;center key light invert >Hey Over Here
0224            JUMP   WCTR

0225        'N  DIGLOW [11101111]      ;turn off everything >Night Night
0226            HALT

0237        'R  DIGLOW [11111111]      ;turn off everything except house light >ResetBox
0238            HALT
;go here for ascii codes:      http://www.asciitable.com/           
                SET    0.010,1,0       ;Get rate & scaling OK

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
;
;;;Response peck checks (RSPPC) starting
0015            MOV    rspStCt,NO,3    ;rst fd stp cnt, +1 for prev mark,1 for this>Resp Window
0016 RSPPC:     ADD    rspStCt,NO,6    ;this line and next 5>Resp Window
0017            BGE    rspStCt,rspStVal,NORESP ;immediately stops respwin if ready >Resp Window
0018            DIBEQ  [.......0],LRESP ;check for left key peck >Resp Window
0019            DIBEQ  [......0.],CRESP ;check for center key peck >Resp Window
0020            DIBEQ  [.....0..],RRESP ;check for right key peck >Resp Window
0021            JUMP   RSPPC           ;loop until feed over >Resp Window
;
;consequate C response
0022 CRESP:     MARK   67              ;center key peck    >C,Resp Window
0023            BEQ    sclass,1,FEED   ;feed if C resp to class 1 >C,consequate
0024            BEQ    sclass,2,TMOUT  ;timeout if C resp to class 2 >C,consequate
;end consequate C response
;
;consequate R response
0025 RRESP:     MARK   82              ;Mark 'R' for right key peck>R,Resp Window
0026            ADD    rspStCt,NO,2    ;mark+this+BGE, -1 unused from last add >R,Resp Window
0027            BGE    rspStCt,rspStVal,NORESP ;immediately stops respwin if ready >R,Resp Window
0028 RMRC:      DIBEQ  [.....1..],RMRE ;branch to RMRE when the key is 'unpecked' >R,Resp Window
0029            ADD    rspStCt,NO,4    ;for RMRC loop      >R,Resp Window
0030            BGE    rspStCt,rspStVal,NORESP ;immediately stops respwin if ready >R,Resp Window
0031            JUMP   RMRC            ;                   >R,Resp Window
0032 RMRE:      ADD    rspStCt,NO,4    ;dibeq(above)+add+bge+jump >R,Resp Window
0033            BGE    rspStCt,rspStVal,NORESP ;           >R,Resp Window
0034            JUMP   RSPPC           ;                   >R,Resp Window
;end check and consequate R response
;
;consequate L response
0035 LRESP:     MARK   76              ;Mark 'L' for left key peck >L,Resp Window
0036            ADD    rspStCt,NO,0    ;mark+this+BGE, -3 unused from last add >L,Resp Window
0037            BGE    rspStCt,rspStVal,NORESP ;immediately stops respwin if ready >L,Resp Window
0038 RMLC:      DIBEQ  [.......1],RMLE ;branch to RMLE when the key is 'unpecked' >L,Resp Window
0039            ADD    rspStCt,NO,4    ;for RMLC loop      >L,Resp Window
0040            BGE    rspStCt,rspStVal,NORESP ;immediately stops respwin if ready >L,Resp Window
0041            JUMP   RMLC            ;                   >L,Resp Window
0042 RMLE:      ADD    rspStCt,NO,4    ;dibeq(above)+add+bge+jump >L,Resp Window
0043            BGE    rspStCt,rspStVal,NORESP ;           >L,Resp Window
0044            JUMP   RSPPC           ;                   >L,Resp Window
;end consequate L response
;
0045 NORESP:    MARK   78,STITI        ;Mark 'N' for no resp,(no consequence for NR) >No Response
;
;;;Response peck checks done
;
;do feed with some probability
0046 FEED:      BRAND  NOFEED,pnofeed  ;                   >consequate
0047            DIGLOW [11110111]      ;raise the feeder   >feed
0048            MARK   70,FDDEL        ;uppercase F, bird is fed >feed
;need hopper up, resp during feed check here
0049 NOFEED:    MARK   102,FDDONE      ;lowercase f, bird is correct, but not fed >no feed
0050 FDELDN:    MARK   125             ;Mark end of Feed Period >feed
0051 FDDONE:    DIGLOW [11111111],STITI ;lower the feeder & goto intertrial interval >ITI
;need hopper down check here
;
;do timeout with some probability
0052 TMOUT:     BRAND  NOTO,pnoto      ;                   >consequate
0053            DIGLOW [11101111]      ;turn off everything >time out
0054            MARK   84,TODEL        ;POSTTO       ;uppercase T, timeout >time out
0055 NOTO:      MARK   116,TODONE      ;lowercase t, bird is wrong, but no timeout >no time out
0056 TDELDN:    MARK   93              ;mark end of TimeOut period >time out
0057 TODONE:    DIGLOW [11111111],STITI ;turn on the houselight & goto intertrial interval >ITI
;
;utilities for sending a peck marker code without missing wavestop
;need to add timeout for the DIBEQs (eg. what if a key is stuck with food?)
0058 CHKPK:     ADD    WvStpCnt,NO,6   ;add for this line and next 5 >AudOut
0059            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>AudOut
0060            DIBEQ  [.......0],MRKLT ;check for left key peck >AudOut
0061            DIBEQ  [......0.],MRKCT ;check for center key peck >AudOut
0062            DIBEQ  [.....0..],MRKRT ;check for right key peck >AudOut
0063            JUMP   CHKPK           ;loop until called away >AudOut

0064 MRKLT:     MARK   76              ;left key peck      >L,AudOut
0065            ADD    WvStpCnt,NO,1   ;mark+this+bge, -2 unused from last add >L,AudOut
0066            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>L,AudOut
0067 MLL:       DIBEQ  [.......1],MLE  ;will branch to MLE when the key is 'unpecked'>L,AudOut
0068            ADD    WvStpCnt,NO,4   ;for MLL loop       >L,AudOut
0069            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>L,AudOut
0070            JUMP   MLL             ;                   >L,AudOut
0071 MLE:       ADD    WvStpCnt,NO,4   ;dibeq(above)+add+bge+jump >L,AudOut
0072            BGE    WvStpCnt,WvStps,STOPWV ;            >L,AudOut
0073            JUMP   CHKPK           ;                   >L,AudOut
;
0074 MRKCT:     MARK   67              ;center key peck    >C,AudOut
0075            ADD    WvStpCnt,NO,2   ;mark+this+BGE, -1 unused from last add >C,AudOut
0076            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>C,AudOut
0077 MCC:       DIBEQ  [......1.],MCE  ;will branch to MCE when the key is 'unpecked'>C,AudOut
0078            ADD    WvStpCnt,NO,4   ;for MCC loop       >C,AudOut
0079            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>C,AudOut
0080            JUMP   MCC             ;                   >C,AudOut
0081 MCE:       ADD    WvStpCnt,NO,4   ;dibeq(above)+add+bge+jump >C,AudOut
0082            BGE    WvStpCnt,WvStps,STOPWV ;            >C,AudOut
0083            JUMP   CHKPK           ;                   >C,AudOut
;
0084 MRKRT:     MARK   82              ;Right key peck     >R,AudOut
0085            ADD    WvStpCnt,NO,3   ;mark+this+bge      >R,AudOut
0086            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>R,AudOut
0087 MRR:       DIBEQ  [.....1..],MRE  ;will branch to MRE when the key is 'unpecked'>R,AudOut
0088            ADD    WvStpCnt,NO,4   ;for MRR loop       >R,AudOut
0089            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>R,AudOut
0090            JUMP   MRR             ;                   >R,AudOut
0091 MRE:       ADD    WvStpCnt,NO,4   ;dibeq(above)+add+bge+jump >R,AudOut
0092            BGE    WvStpCnt,WvStps,STOPWV ;            >R,AudOut
0093            JUMP   CHKPK           ;                   >R,AudOut


;Feed peck checks (FDPC) starting
0094 FDDEL:     MOV    fdStpCt,NO,2    ;reset feed step cnt, add 1 for prev mark,1 for this >Feed
0095 FDPC:      ADD    fdStpCt,NO,6    ;this line and next 5>Feed
0096            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >Feed
0097            DIBEQ  [.......0],FLT  ;check for left key peck>Feed
0098            DIBEQ  [......0.],FCT  ;check for center key peck >Feed
0099            DIBEQ  [.....0..],FRT  ;check for right key peck >Feed
0100            JUMP   FDPC            ;loop until feed over >Feed

0101 FLT:       MARK   76              ;left key peck      >L,Feed
0102            ADD    fdStpCt,NO,1    ;mark+this+BGE, -2 unused from last add >L,Feed
0103            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >L,Feed
0104 FMLL:      DIBEQ  [.......1],FMLE ;will branch to FMLE when the key is 'unpecked' >L,Feed
0105            ADD    fdStpCt,NO,4    ;for FMLL loop      >L,Feed
0106            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >L,Feed
0107            JUMP   FMLL            ;                   >L,Feed
0108 FMLE:      ADD    fdStpCt,NO,4    ;dibeq(above)+add+bge+jump >L,Feed
0109            BGE    fdStpCt,fdStpVal,FDELDN ;           >L,Feed
0110            JUMP   FDPC            ;                   >L,Feed
;
0111 FCT:       MARK   67              ;center key peck    >C,Feed
0112            ADD    fdStpCt,NO,2    ;mark+this+BGE, -1 unused from last add >C,Feed
0113            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >C,Feed
0114 FMCC:      DIBEQ  [......1.],FMCE ;will branch to FMCE when the key is 'unpecked' >C,Feed
0115            ADD    fdStpCt,NO,4    ;for FMCC loop      >C,Feed
0116            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >C,Feed
0117            JUMP   FMCC            ;                   >C,Feed
0118 FMCE:      ADD    fdStpCt,NO,4    ;dibeq(above)+add+bge+jump >C,Feed
0119            BGE    fdStpCt,fdStpVal,FDELDN ;           >C,Feed
0120            JUMP   FDPC            ;                   >C,Feed
;
0121 FRT:       MARK   82              ;Right key peck     >R,Feed
0122            ADD    fdStpCt,NO,3    ;mark+this+BGE, -0 unused from last add >R,Feed
0123            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >R,Feed
0124 FMRR:      DIBEQ  [.....1..],FMRE ;will branch to FMRE when the key is 'unpecked' >R,Feed
0125            ADD    fdStpCt,NO,4    ;for FMRR loop      >R,Feed
0126            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >R,Feed
0127            JUMP   FMRR            ;                   >R,Feed
0128 FMRE:      ADD    fdStpCt,NO,4    ;dibeq(above)+add+bge+jump >R,Feed
0129            BGE    fdStpCt,fdStpVal,FDELDN ;           >R,Feed
0130            JUMP   FDPC            ;                   >R,Feed
;Feed peck checks done
;
;TO peck checks (TOPC) starting
0131 TODEL:     MOV    toStpCt,NO,2    ;reset TO step cnt, add 1 for prev mark,1 for this>TimeOut
0132 TOPC:      ADD    toStpCt,NO,6    ;this line and next 5>TimeOut
0133            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >TimeOut
0134            DIBEQ  [.......0],TLT  ;check for left key peck>TimeOut
0135            DIBEQ  [......0.],TCT  ;check for center key peck >TimeOut
0136            DIBEQ  [.....0..],TRT  ;check for right key peck >TimeOut
0137            JUMP   TOPC            ;loop until TO over >TimeOut
;
0138 TLT:       MARK   76              ;left key peck      >L,TimeOut
0139            ADD    toStpCt,NO,1    ;mark+this+BGE, -2 unused from last add >L,TimeOut
0140            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >L,TimeOut
0141 TMLL:      DIBEQ  [.......1],TMLE ;will branch to TMLE when the key is 'unpecked' >L,TimeOut
0142            ADD    toStpCt,NO,4    ;for TMLL loop      >L,TimeOut
0143            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >L,TimeOut
0144            JUMP   TMLL            ;                   >L,TimeOut
0145 TMLE:      ADD    toStpCt,NO,4    ;dibeq(above)+add+bge+jump >L,TimeOut
0146            BGE    toStpCt,toStpVal,TDELDN ;           >L,TimeOut
0147            JUMP   TOPC            ;                   >L,TimeOut
;
0148 TCT:       MARK   67              ;center key peck    >C,TimeOut
0149            ADD    toStpCt,NO,2    ;mark+this+BGE, -1 unused from last add >C,TimeOut
0150            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >C,TimeOut
0151 TMCC:      DIBEQ  [......1.],TMCE ;will branch to TMCE when the key is 'unpecked' >C,TimeOut
0152            ADD    toStpCt,NO,4    ;for TMCC loop      >C,TimeOut
0153            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >C,TimeOut
0154            JUMP   TMCC            ;                   >C,TimeOut
0155 TMCE:      ADD    toStpCt,NO,4    ;dibeq(above)+add+bge+jump >C,TimeOut
0156            BGE    toStpCt,toStpVal,TDELDN ;           >C,TimeOut
0157            JUMP   TOPC            ;                   >C,TimeOut
;
0158 TRT:       MARK   82              ;Right key peck     >R,TimeOut
0159            ADD    toStpCt,NO,3    ;mark+this+BGE, -0 unused from last add >R,TimeOut
0160            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >R,TimeOut
0161 TMRR:      DIBEQ  [.....1..],TMRE ;will branch to TMRE when the key is 'unpecked' >R,TimeOut
0162            ADD    toStpCt,NO,4    ;for TMRR loop      >R,TimeOut
0163            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >R,TimeOut
0164            JUMP   TMRR            ;                   >R,TimeOut
0165 TMRE:      ADD    toStpCt,NO,4    ;dibeq(above)+add+bge+jump >R,TimeOut
0166            BGE    toStpCt,toStpVal,TDELDN ;           >R,TimeOut
0167            JUMP   TOPC            ;                   >R,TimeOut
;TO peck checks done
;
;ITI peck checks starting
0168 STITI:     NOP                    ;prevents the 'N' and '(' from being assigned the same time
0169            MARK   40              ;mark start of ITI w/ '(' >ITI
0170            MOV    itiStpCt,NO,3   ;reset iti step count, add 2 for prev lns and 1 for this >ITI
0171 ITI:       ADD    itiStpCt,NO,6   ;this line and next 5>ITI
0172            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >ITI
0173            DIBEQ  [.......0],ILT  ;check for left key peck>ITI
0174            DIBEQ  [......0.],ICT  ;check for center key peck >ITI
0175            DIBEQ  [.....0..],IRT  ;check for right key peck >ITI
0176            JUMP   ITI             ;loop until ITI over >ITI
;
0177 ILT:       MARK   76              ;left key peck      >L,ITI
0178            ADD    itiStpCt,NO,1   ;mark+this+BGE, -2 unused from last add >L,ITI
0179            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >L,ITI
0180 IMLL:      DIBEQ  [.......1],IMLE ;will branch to IMLE when the key is 'unpecked' >L,ITI
0181            ADD    itiStpCt,NO,4   ;for IMLL loop      >L,ITI
0182            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >L,ITI
0183            JUMP   IMLL            ;                   >L,ITI
0184 IMLE:      ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >L,ITI
0185            BGE    itiStpCt,itiVal,END ;               >L,ITI
0186            JUMP   ITI             ;                   >L,ITI
;
0187 ICT:       MARK   67              ;center key peck    >C,ITI
0188            ADD    itiStpCt,NO,2   ;mark+this+BGE, -1 unused from last add >C,ITI
0189            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >C,ITI
0190 IMCC:      DIBEQ  [......1.],IMCE ;will branch to IMCE when the key is 'unpecked' >C,ITI
0191            ADD    itiStpCt,NO,4   ;for IMCC loop      >C,ITI
0192            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >C,ITI
0193            JUMP   IMCC            ;                   >C,ITI
0194 IMCE:      ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >C,ITI
0195            BGE    itiStpCt,itiVal,END ;               >C,ITI
0196            JUMP   ITI             ;                   >C,ITI
;
0197 IRT:       MARK   82              ;Right key peck     >R,ITI
0198            ADD    itiStpCt,NO,3   ;mark+this+BGE, -0 unused from last add >R,ITI
0199            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >R,ITI
0200 IMRR:      DIBEQ  [.....1..],IMRE ;will branch to IMRE when the key is 'unpecked' >R,ITI
0201            ADD    itiStpCt,NO,4   ;for IMRR loop      >R,ITI
0202            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >R,ITI
0203            JUMP   IMRR            ;                   >R,ITI
0204 IMRE:      ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >R,ITI
0205            BGE    itiStpCt,itiVal,END ;               >R,ITI
0206            JUMP   ITI             ;                   >R,ITI
;ITI peck checks done

;End of Trial
0207 END:       MARK   41              ;mark end of ITI w/ ')'>Post Trial
0208            DIGLOW [11111111]      ;turn all off but house light >Post Trial
0209            MOV    nobug,NO        ;                   >Post Trial
0210            JUMP   PTPK            ;                   >Post Trial
;
;Utils for marking digmark during pre-trial interval
0211 MKLT:      MARK   76              ;left key peck      >L,Wait Center
0212            WAIT   [.......1]      ;                   >L,Wait Center
0213            JUMP   WCTR            ;                   >L,Wait Center
0214 MKRT:      MARK   82              ;right key peck     >R,Wait Center
0215            WAIT   [.....1..]      ;                   >R,Wait Center
0216            JUMP   WCTR            ;                   >R,Wait Center
;
;post trial/Paused peck checks
0217 PTPK:  'P  DIBEQ  [.......0],PMLT ;left key peck      >Post Trial
0218            DIBEQ  [......0.],PMCT ;center key peck    >Post Trial
0219            DIBEQ  [.....0..],PMRT ;right key peck     >Post Trial
0220            JUMP   PTPK            ;loop until called away >Post Trial
;
0221 PMLT:      MARK   76              ;left key peck      >L,Post Trial
0222            WAIT   [.......1]      ;                   >L,Post Trial
0223            JUMP   PTPK            ;                   >L,Post Trial
0224 PMRT:      MARK   82              ;right key peck     >R,Post Trial
0225            WAIT   [.....1..]      ;                   >R,Post Trial
0226            JUMP   PTPK            ;                   >R,Post Trial
0227 PMCT:      MARK   67              ;center key peck    >C,Post Trial
0228            WAIT   [......1.]      ;                   >C,Post Trial
0229            JUMP   PTPK            ;                   >C,Post Trial


0230        'I  DIGLOW [......i.]      ;center key light invert
0231            JUMP   WCTR

0232        'N  DIGLOW [11101111]      ;turn off everything >Night Night
0233            HALT

0237        'R  DIGLOW [11111111]      ;turn off everything except house light >ResetBox
0238            HALT
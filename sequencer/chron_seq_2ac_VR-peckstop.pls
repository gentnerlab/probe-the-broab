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

                VAR    V15,flashper=ms(100)-2 ;on/off half period of cue light flashing in msec
                VAR    V16,flashnum=5  ;number of cue light flash periods
                VAR    V17,flshnumi    ;number of cue light flash period incrementer variable

                VAR    V11,fdStpVal    ;seq steps in feed time, to be set by script
                VAR    V12,fdStpCt     ;this will hold the sequencer steps since start of feed
                VAR    V25,pnofeed     ;rate of reinf for correct responses. set by script

                VAR    V13,toStpVal    ;seq steps in TO time, to be set by script
                VAR    V14,toStpCt     ;this will hold the sequencer steps since start of feed
                VAR    V26,pnoto       ;rate of no reinf for incorrect responses. set by script

                VAR    V27,corrCnt=0   ;count of cumulative
                VAR    V28,corrThr=1   ;current threshold to get a feed
                VAR    V29,corrMax=1   ;current threshold to get a feed. set by script

0000            HALT                   ;End of this sequence section >HALT

; start the sequence for a single trial, sent here by script's 'samplekey()'
0001 TSTART: 'S WAVEGO a,TW            ;ready stim with trigger to be tripped by wavest T >TSTART
0002            DIGLOW [......0.]      ;turn on cue light  >TSTART
;wait for center key press to start stimulus
0003 WCTR:      DIBEQ  [.......0],MKLT ;left key peck      >Wait center peck
0004            DIBEQ  [......0.],TRLREQ ;center key peck  >Wait center peck
0005            DIBEQ  [.....0..],MKRT ;right key peck     >Wait center peck
0006            JUMP   WCTR            ;loop until called away >Wait center peck
0007 TRLREQ:    MARK   67              ;center key peck    >C,Start Trial
0008            DIGOUT [.......0]      ;turn off digout    >C,Start Trial
0009            WAIT   [......1.]      ;only start trial after center key is unpecked >C,Start Trial
;here is a good place for preStim interval
0010            WAVEST T               ;start stim here    >Start Stim
0011            MARK   60              ;make digmark for time the stim starts >Start Stim
0012            DIGLOW [11111111]      ;make sure cue light is off >Start Stim
0013            MOV    WvStpCnt,NO,4   ;reset, add 4 to stimcnt for this,next,prev 2 ln >Start Stim
0014            JUMP   CHKPK           ;start checking for pecks>Start Stim
;
0015 STOPWVP:   WAVEST S               ;stop output now, trig. by keypeck >Premature Stop
0016            MARK   35              ;make digmark for time of premature stimstop >Premature Stop
0017            MOV    nobug,YES       ;don't allow script input
0018            DIGOUT [.......1]      ;turn on digout     >Premature Stop
0019            JUMP   STITI           ;go to ITI          >Premature Stop
;
0020 STOPWV:    WAVEST S               ;stop output now, trig. by cnter exeeding stimdur >Stop Stim
0021            MARK   62              ;make digmark for time the stim ends >Stop Stim
0022            DIGOUT [.......1]      ;turn on digout     >Stop Stim
0023            MOV    nobug,YES       ;                   >Stop Stim


;Response peck checks (RSPPC) starting
0024            MOV    rspStCt,NO,3    ;rst fd stp cnt, +1 for prev mark,1 for this>Resp Window
0025 RSPPC:     ADD    rspStCt,NO,7    ;this line and next 6>Resp Window
0026            BGE    rspStCt,rspStVal,NORESP ;immediately stops feed if ready >Resp Window
0027            DIGLOW [.....0.0]      ;turn on L & R LEDs
0028            DIBEQ  [.......0],LRESP ;check for left key peck >Resp Window
0029            DIBEQ  [......0.],CRESP ;check for center key peck >Resp Window
0030            DIBEQ  [.....0..],RRESP ;check for right key peck >Resp Window
0031            JUMP   RSPPC           ;loop until feed over >Resp Window
;
0032 CRESP:     MARK   67              ;center key peck    >C,Resp Window
0033            ADD    rspStCt,NO,1    ;mark+this+BGE, -2 unused from last add >C,Resp Window
0034            BGE    rspStCt,rspStVal,NORESP ;immediately stops feed if ready >C,Resp Window
0035 RMCC:      DIBEQ  [......1.],RMCE ;branch to RMCE when the key is 'unpecked' >C,Resp Window
0036            ADD    rspStCt,NO,4    ;for RMCC loop      >C,Resp Window
0037            BGE    rspStCt,rspStVal,NORESP ;immediately stops feed if ready >C,Resp Window
0038            JUMP   RMCC            ;                   >C,Resp Window
0039 RMCE:      ADD    rspStCt,NO,4    ;dibeq(above)+add+bge+jump >C,Resp Window
0040            BGE    rspStCt,rspStVal,NORESP ;           >C,Resp Window
0041            JUMP   RSPPC           ;                   >C,Resp Window
;Response peck checks done

0042 NORESP:    MARK   78              ;Mark 'N' for no resp,(no consequence for NR) >No Response
0043            DIGLOW [11111111],STITI ;reset box & goto intertrial interval >No Response
;
0044 RRESP:     MARK   82              ;Mark 'R' for right key peck>R,consequate
0045            BEQ    sclass,2,FEED   ;feed if R resp to class 2 >R,consequate
0046            BEQ    sclass,1,TMOUT  ;timeout if R resp to class 1 >R,consequate
0047 LRESP:     MARK   76              ;Mark 'L' for left key peck >L,consequate
0048            BEQ    sclass,2,TMOUT  ;timeout if R resp to class 2 >L,consequate
0049            BEQ    sclass,1,FEED   ;feed if R resp to class 1 >L,consequate
;
;do feed with some probability
0050 FEED:      CALL   FLSHQ           ;flash regardless of feed if correct >flash cue light
0051            BEQ    pnofeed,-1,NOFEED ;only time 'pnofeed'==-1 is when crxn trial AND no feed on crxn. skip counter increment.
0052            ADDI   corrCnt,1       ;increment correct counter
0053            BLT    corrCnt,corrThr,NOFEED ;if threshold not reached, don't feed. >consequate
0054            BRAND  NOFEED,pnofeed  ;consequate probabilistically >consequate
0055            MOVI   corrCnt,0       ;reset the feed counter
0056 SAMPVR:    MOVRND corrThr,3,1     ;resample from 1 to 2^3 (8)> feed
0057            BGT    corrThr,corrMax,SAMPVR ;if the sampled threshold is greater than the max, then resample it. >feed
0058            DIGLOW [11110111]      ;raise the feeder   >feed
0059            MARK   70,FDDEL        ;uppercase F, bird is fed >feed
;need hopper up, resp during feed check here
0060 NOFEED:    MARK   102,FDDONE      ;lowercase f, bird is correct, but not fed >no feed
0061 FDELDN:    MARK   125             ;Mark end of Feed Period >feed
0062 FDDONE:    DIGLOW [11111111]      ;lower the feeder
0063            JUMP   STITI           ;goto intertrial interval >ITI
;need hopper down check here
;
;do timeout with some probability
0064 TMOUT:     DIGLOW [......1.]      ;turn off cue light regardless of TO>off key light
0065            MOVI   corrCnt,0
0066            BRAND  NOTO,pnoto      ;                   >consequate
0067            DIGLOW [11101111]      ;turn off everything >time out
0068            MARK   84,TODEL        ;POSTTO       ;uppercase T, timeout >time out
0069 NOTO:      MARK   116,TODONE      ;lowercase t, bird is wrong, but no timeout >no time out
0070 TDELDN:    MARK   93              ;mark end of TimeOut period >time out
0071 TODONE:    DIGLOW [11111111],STITI ;turn on the houselight & goto intertrial interval >ITI
;
;utilities for sending a peck marker code without missing wavestop
;need to add timeout for the DIBEQs (eg. what if a key is stuck with food?)
0072 CHKPK:     ADD    WvStpCnt,NO,6   ;add for this line and next 5 >AudOut
0073            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>AudOut
0074            DIBEQ  [.......0],MRKLT ;check for left key peck >AudOut
0075            DIBEQ  [......0.],MRKCT ;check for center key peck >AudOut
0076            DIBEQ  [.....0..],MRKRT ;check for right key peck >AudOut
0077            JUMP   CHKPK           ;loop until called away >AudOut

0078 MRKLT:     MARK   76              ;left key peck      >L, Stop Stim
0079            JUMP   STOPWVP         ;                   >L, Stop Stim
;
0080 MRKCT:     MARK   67              ;center key peck    >C,
0081            JUMP   CHKPK           ;                   >C,
;
0082 MRKRT:     MARK   82              ;Right key peck     >R, Stop Stim
0083            JUMP   STOPWVP         ;                   >R, Stop Stim


;Feed peck checks (FDPC) starting
0084 FDDEL:     MOV    fdStpCt,NO,2    ;reset feed step cnt, add 1 for prev mark,1 for this >Feed
0085 FDPC:      ADD    fdStpCt,NO,6    ;this line and next 5>Feed
0086            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >Feed
0087            DIBEQ  [.......0],FLT  ;check for left key peck>Feed
0088            DIBEQ  [......0.],FCT  ;check for center key peck >Feed
0089            DIBEQ  [.....0..],FRT  ;check for right key peck >Feed
0090            JUMP   FDPC            ;loop until feed over >Feed

0091 FLT:       MARK   76              ;left key peck      >L,Feed
0092            ADD    fdStpCt,NO,1    ;mark+this+BGE, -2 unused from last add >L,Feed
0093            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >L,Feed
0094 FMLL:      DIBEQ  [.......1],FMLE ;will branch to FMLE when the key is 'unpecked' >L,Feed
0095            ADD    fdStpCt,NO,4    ;for FMLL loop      >L,Feed
0096            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >L,Feed
0097            JUMP   FMLL            ;                   >L,Feed
0098 FMLE:      ADD    fdStpCt,NO,4    ;dibeq(above)+add+bge+jump >L,Feed
0099            BGE    fdStpCt,fdStpVal,FDELDN ;           >L,Feed
0100            JUMP   FDPC            ;                   >L,Feed
;
0101 FCT:       MARK   67              ;center key peck    >C,Feed
0102            ADD    fdStpCt,NO,2    ;mark+this+BGE, -1 unused from last add >C,Feed
0103            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >C,Feed
0104 FMCC:      DIBEQ  [......1.],FMCE ;will branch to FMCE when the key is 'unpecked' >C,Feed
0105            ADD    fdStpCt,NO,4    ;for FMCC loop      >C,Feed
0106            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >C,Feed
0107            JUMP   FMCC            ;                   >C,Feed
0108 FMCE:      ADD    fdStpCt,NO,4    ;dibeq(above)+add+bge+jump >C,Feed
0109            BGE    fdStpCt,fdStpVal,FDELDN ;           >C,Feed
0110            JUMP   FDPC            ;                   >C,Feed
;
0111 FRT:       MARK   82              ;Right key peck     >R,Feed
0112            ADD    fdStpCt,NO,3    ;mark+this+BGE, -0 unused from last add >R,Feed
0113            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >R,Feed
0114 FMRR:      DIBEQ  [.....1..],FMRE ;will branch to FMRE when the key is 'unpecked' >R,Feed
0115            ADD    fdStpCt,NO,4    ;for FMRR loop      >R,Feed
0116            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >R,Feed
0117            JUMP   FMRR            ;                   >R,Feed
0118 FMRE:      ADD    fdStpCt,NO,4    ;dibeq(above)+add+bge+jump >R,Feed
0119            BGE    fdStpCt,fdStpVal,FDELDN ;           >R,Feed
0120            JUMP   FDPC            ;                   >R,Feed
;Feed peck checks done
;
;TO peck checks (TOPC) starting
0121 TODEL:     MOV    toStpCt,NO,2    ;reset TO step cnt, add 1 for prev mark,1 for this>TimeOut
0122 TOPC:      ADD    toStpCt,NO,6    ;this line and next 5>TimeOut
0123            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >TimeOut
0124            DIBEQ  [.......0],TLT  ;check for left key peck>TimeOut
0125            DIBEQ  [......0.],TCT  ;check for center key peck >TimeOut
0126            DIBEQ  [.....0..],TRT  ;check for right key peck >TimeOut
0127            JUMP   TOPC            ;loop until TO over >TimeOut
;
0128 TLT:       MARK   76              ;left key peck      >L,TimeOut
0129            ADD    toStpCt,NO,1    ;mark+this+BGE, -2 unused from last add >L,TimeOut
0130            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >L,TimeOut
0131 TMLL:      DIBEQ  [.......1],TMLE ;will branch to TMLE when the key is 'unpecked' >L,TimeOut
0132            ADD    toStpCt,NO,4    ;for TMLL loop      >L,TimeOut
0133            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >L,TimeOut
0134            JUMP   TMLL            ;                   >L,TimeOut
0135 TMLE:      ADD    toStpCt,NO,4    ;dibeq(above)+add+bge+jump >L,TimeOut
0136            BGE    toStpCt,toStpVal,TDELDN ;           >L,TimeOut
0137            JUMP   TOPC            ;                   >L,TimeOut
;
0138 TCT:       MARK   67              ;center key peck    >C,TimeOut
0139            ADD    toStpCt,NO,2    ;mark+this+BGE, -1 unused from last add >C,TimeOut
0140            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >C,TimeOut
0141 TMCC:      DIBEQ  [......1.],TMCE ;will branch to TMCE when the key is 'unpecked' >C,TimeOut
0142            ADD    toStpCt,NO,4    ;for TMCC loop      >C,TimeOut
0143            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >C,TimeOut
0144            JUMP   TMCC            ;                   >C,TimeOut
0145 TMCE:      ADD    toStpCt,NO,4    ;dibeq(above)+add+bge+jump >C,TimeOut
0146            BGE    toStpCt,toStpVal,TDELDN ;           >C,TimeOut
0147            JUMP   TOPC            ;                   >C,TimeOut
;
0148 TRT:       MARK   82              ;Right key peck     >R,TimeOut
0149            ADD    toStpCt,NO,3    ;mark+this+BGE, -0 unused from last add >R,TimeOut
0150            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >R,TimeOut
0151 TMRR:      DIBEQ  [.....1..],TMRE ;will branch to TMRE when the key is 'unpecked' >R,TimeOut
0152            ADD    toStpCt,NO,4    ;for TMRR loop      >R,TimeOut
0153            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >R,TimeOut
0154            JUMP   TMRR            ;                   >R,TimeOut
0155 TMRE:      ADD    toStpCt,NO,4    ;dibeq(above)+add+bge+jump >R,TimeOut
0156            BGE    toStpCt,toStpVal,TDELDN ;           >R,TimeOut
0157            JUMP   TOPC            ;                   >R,TimeOut
;TO peck checks done
;
;ITI peck checks starting
0158 STITI:     NOP                    ;prevents the 'N' and '(' from being assigned the same time
0159            NOP    
0160            NOP    
0161            MARK   40              ;mark start of ITI w/ '(' >ITI
0162            MOV    itiStpCt,NO,5   ;reset iti step count, add 2 for prev lns and 1 for this >ITI
0163 ITI:       ADD    itiStpCt,NO,6   ;this line and next 5>ITI
0164            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >ITI
0165            DIBEQ  [.......0],ILT  ;check for left key peck>ITI
0166            DIBEQ  [......0.],ICT  ;check for center key peck >ITI
0167            DIBEQ  [.....0..],IRT  ;check for right key peck >ITI
0168            JUMP   ITI             ;loop until ITI over >ITI
;
0169 ILT:       MARK   76              ;left key peck      >L,ITI
0170            ADD    itiStpCt,NO,1   ;mark+this+BGE, -2 unused from last add >L,ITI
0171            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >L,ITI
0172 IMLL:      DIBEQ  [.......1],IMLE ;will branch to IMLE when the key is 'unpecked' >L,ITI
0173            ADD    itiStpCt,NO,4   ;for IMLL loop      >L,ITI
0174            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >L,ITI
0175            JUMP   IMLL            ;                   >L,ITI
0176 IMLE:      ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >L,ITI
0177            BGE    itiStpCt,itiVal,END ;               >L,ITI
0178            JUMP   ITI             ;                   >L,ITI
;
0179 ICT:       MARK   67              ;center key peck    >C,ITI
0180            ADD    itiStpCt,NO,2   ;mark+this+BGE, -1 unused from last add >C,ITI
0181            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >C,ITI
0182 IMCC:      DIBEQ  [......1.],IMCE ;will branch to IMCE when the key is 'unpecked' >C,ITI
0183            ADD    itiStpCt,NO,4   ;for IMCC loop      >C,ITI
0184            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >C,ITI
0185            JUMP   IMCC            ;                   >C,ITI
0186 IMCE:      ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >C,ITI
0187            BGE    itiStpCt,itiVal,END ;               >C,ITI
0188            JUMP   ITI             ;                   >C,ITI
;
0189 IRT:       MARK   82              ;Right key peck     >R,ITI
0190            ADD    itiStpCt,NO,3   ;mark+this+BGE, -0 unused from last add >R,ITI
0191            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >R,ITI
0192 IMRR:      DIBEQ  [.....1..],IMRE ;will branch to IMRE when the key is 'unpecked' >R,ITI
0193            ADD    itiStpCt,NO,4   ;for IMRR loop      >R,ITI
0194            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >R,ITI
0195            JUMP   IMRR            ;                   >R,ITI
0196 IMRE:      ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >R,ITI
0197            BGE    itiStpCt,itiVal,END ;               >R,ITI
0198            JUMP   ITI             ;                   >R,ITI
;ITI peck checks done

;End of Trial
0199 END:       MARK   41              ;mark end of ITI w/ ')'>Post Trial
0200            DIGLOW [11111111]      ;turn all off but house light >Post Trial
0201            MOV    nobug,NO        ;                   >Post Trial
0202            JUMP   PTPK            ;                   >Post Trial
;
;Utils for marking digmark during pre-trial interval
0203 MKLT:      MARK   76              ;left key peck      >L,Wait Center
0204            WAIT   [.......1]      ;                   >L,Wait Center
0205            JUMP   WCTR            ;                   >L,Wait Center
0206 MKRT:      MARK   82              ;right key peck     >R,Wait Center
0207            WAIT   [.....1..]      ;                   >R,Wait Center
0208            JUMP   WCTR            ;                   >R,Wait Center
;
;post trial/Paused peck checks
0209        'P  DIGLOW [11111111]      ;the sequencer told us to pause>Post Trial
0210 PTPK:      DIBEQ  [.......0],PMLT ;left key peck      >Post Trial
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

0223 FLSHQ:     MOV    flshnumi,flashnum ;                 >flash cue light
0224 FLOOP:     DIGLOW [.....000]      ;turn on cue light  >flash cue light
0225            DELAY  flashper        ;wait flashper msec >flash cue light
0226            DIGLOW [.....111]      ;turn off cue light >flash cue light
0227            DELAY  flashper        ;wait flashper msec >flash cue light
0228            DBNZ   flshnumi,FLOOP  ;                   >flash cue light
0229            RETURN                 ;                   >flash cue light


0230        'I  DIGLOW [......i.]      ;center key light invert >Hey Over Here
0231            JUMP   WCTR

0232        'N  DIGLOW [11101111]      ;turn off everything >Night Night
0233            HALT   

0234        'R  DIGLOW [11111111]      ;turn off everything except house light >ResetBox
0235            HALT   

0236        'H  DIGLOW [....i...]      ;hopper invert      >Hopper up or down
0237            JUMP   WCTR
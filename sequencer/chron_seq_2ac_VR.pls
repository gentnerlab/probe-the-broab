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

            HALT                   ;End of this sequence section >HALT

; start the sequence for a single trial, sent here by script's 'samplekey()'
TSTART: 'S  WAVEGO a,TW            ;ready stim with trigger to be tripped by wavest T >TSTART
            DIGLOW [......0.]      ;turn on cue light  >TSTART
;wait for center key press to start stimulus
WCTR:       DIBEQ  [.......0],MKLT ;left key peck      >Wait center peck
            DIBEQ  [......0.],TRLREQ ;center key peck  >Wait center peck
            DIBEQ  [.....0..],MKRT ;right key peck     >Wait center peck
            JUMP   WCTR            ;loop until called away >Wait center peck
TRLREQ:     MARK   67              ;center key peck    >C,Start Trial
            WAIT   [......1.]      ;only start trial after center key is unpecked >C,Start Trial
;here is a good place for preStim interval
            WAVEST T               ;start stim here    >Start Stim
            MARK   60              ;make digmark for time the stim starts >Start Stim
            DIGLOW [11111111]      ;make sure cue light is off >Start Stim
            MOV    WvStpCnt,NO,4   ;reset, add 4 to stimcnt for this,next,prev 2 ln >Start Stim
            JUMP   CHKPK           ;start checking for pecks>Start Stim
;
STOPWV:     WAVEST S               ;stop output now, trig. by cnter exeeding stimdur >Stop Stim
            MARK   62              ;make digmark for time the stim ends >Stop Stim
            MOV    nobug,YES       ;                   >Stop Stim


;Response peck checks (RSPPC) starting
            MOV    rspStCt,NO,3    ;rst fd stp cnt, +1 for prev mark,1 for this>Resp Window
RSPPC:      ADD    rspStCt,NO,7    ;this line and next 6>Resp Window
            BGE    rspStCt,rspStVal,NORESP ;immediately stops feed if ready >Resp Window
            DIGLOW [.....0.0]      ;turn on L & R LEDs
            DIBEQ  [.......0],LRESP ;check for left key peck >Resp Window
            DIBEQ  [......0.],CRESP ;check for center key peck >Resp Window
            DIBEQ  [.....0..],RRESP ;check for right key peck >Resp Window
            JUMP   RSPPC           ;loop until feed over >Resp Window
;
CRESP:      MARK   67              ;center key peck    >C,Resp Window
            ADD    rspStCt,NO,1    ;mark+this+BGE, -2 unused from last add >C,Resp Window
            BGE    rspStCt,rspStVal,NORESP ;immediately stops feed if ready >C,Resp Window
RMCC:       DIBEQ  [......1.],RMCE ;branch to RMCE when the key is 'unpecked' >C,Resp Window
            ADD    rspStCt,NO,4    ;for RMCC loop      >C,Resp Window
            BGE    rspStCt,rspStVal,NORESP ;immediately stops feed if ready >C,Resp Window
            JUMP   RMCC            ;                   >C,Resp Window
RMCE:       ADD    rspStCt,NO,4    ;dibeq(above)+add+bge+jump >C,Resp Window
            BGE    rspStCt,rspStVal,NORESP ;           >C,Resp Window
            JUMP   RSPPC           ;                   >C,Resp Window
;Response peck checks done

NORESP:     MARK   78              ;Mark 'N' for no resp,(no consequence for NR) >No Response
            DIGLOW [11111111],STITI ;reset box & goto intertrial interval >No Response
;
RRESP:      MARK   82              ;Mark 'R' for right key peck>R,consequate
            BEQ    sclass,2,FEED   ;feed if R resp to class 2 >R,consequate
            BEQ    sclass,1,TMOUT  ;timeout if R resp to class 1 >R,consequate
LRESP:      MARK   76              ;Mark 'L' for left key peck >L,consequate
            BEQ    sclass,2,TMOUT  ;timeout if R resp to class 2 >L,consequate
            BEQ    sclass,1,FEED   ;feed if R resp to class 1 >L,consequate
;
;do feed with some probability
FEED:       CALL   FLSHQ           ;flash regardless of feed if correct >flash cue light
            BEQ    pnofeed,-1,NOFEED ;only time 'pnofeed'==-1 is when crxn trial AND no feed on crxn. skip counter increment.
            ADDI   corrCnt,1       ;increment correct counter
            BLT    corrCnt,corrThr,NOFEED ;if threshold not reached, don't feed. >consequate
            BRAND  NOFEED,pnofeed  ;consequate probabilistically >consequate
            MOVI   corrCnt,0       ; reset the feed counter
SAMPVR:     MOVRND corrThr,3,1     ;resample from 1 to 2^3 (8) > feed
            BGT    corrThr,corrMax,SAMPVR ;if the sampled threshold is greater than the max, then resample it. >feed
            DIGLOW [11110111]      ;raise the feeder   >feed
            MARK   70,FDDEL        ;uppercase F, bird is fed >feed
;need hopper up, resp during feed check here
NOFEED:     MARK   102,FDDONE      ;lowercase f, bird is correct, but not fed >no feed
FDELDN:     MARK   125             ;Mark end of Feed Period >feed
FDDONE:     DIGLOW [11111111]      ;lower the feeder 
            JUMP   STITI           ;goto intertrial interval >ITI
;need hopper down check here
;
;do timeout with some probability
TMOUT:      DIGLOW [......1.]      ;turn off cue light regardless of TO>off key light
            MOVI   corrCnt,0
            BRAND  NOTO,pnoto      ;                   >consequate
            DIGLOW [11101111]      ;turn off everything >time out
            MARK   84,TODEL        ;POSTTO       ;uppercase T, timeout >time out
NOTO:       MARK   116,TODONE      ;lowercase t, bird is wrong, but no timeout >no time out
TDELDN:     MARK   93              ;mark end of TimeOut period >time out
TODONE:     DIGLOW [11111111],STITI ;turn on the houselight & goto intertrial interval >ITI
;
;utilities for sending a peck marker code without missing wavestop
;need to add timeout for the DIBEQs (eg. what if a key is stuck with food?)
CHKPK:      ADD    WvStpCnt,NO,6   ;add for this line and next 5 >AudOut
            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>AudOut
            DIBEQ  [.......0],MRKLT ;check for left key peck >AudOut
            DIBEQ  [......0.],MRKCT ;check for center key peck >AudOut
            DIBEQ  [.....0..],MRKRT ;check for right key peck >AudOut
            JUMP   CHKPK           ;loop until called away >AudOut

MRKLT:      MARK   76              ;left key peck      >L,AudOut
            ADD    WvStpCnt,NO,1   ;mark+this+bge, -2 unused from last add >L,AudOut
            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>L,AudOut
MLL:        DIBEQ  [.......1],MLE  ;will branch to MLE when the key is 'unpecked'>L,AudOut
            ADD    WvStpCnt,NO,4   ;for MLL loop       >L,AudOut
            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>L,AudOut
            JUMP   MLL             ;                   >L,AudOut
MLE:        ADD    WvStpCnt,NO,4   ;dibeq(above)+add+bge+jump >L,AudOut
            BGE    WvStpCnt,WvStps,STOPWV ;            >L,AudOut
            JUMP   CHKPK           ;                   >L,AudOut
;
MRKCT:      MARK   67              ;center key peck    >C,AudOut
            ADD    WvStpCnt,NO,2   ;mark+this+BGE, -1 unused from last add >C,AudOut
            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>C,AudOut
MCC:        DIBEQ  [......1.],MCE  ;will branch to MCE when the key is 'unpecked'>C,AudOut
            ADD    WvStpCnt,NO,4   ;for MCC loop       >C,AudOut
            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>C,AudOut
            JUMP   MCC             ;                   >C,AudOut
MCE:        ADD    WvStpCnt,NO,4   ;dibeq(above)+add+bge+jump >C,AudOut
            BGE    WvStpCnt,WvStps,STOPWV ;            >C,AudOut
            JUMP   CHKPK           ;                   >C,AudOut
;
MRKRT:      MARK   82              ;Right key peck     >R,AudOut
            ADD    WvStpCnt,NO,3   ;mark+this+bge      >R,AudOut
            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>R,AudOut
MRR:        DIBEQ  [.....1..],MRE  ;will branch to MRE when the key is 'unpecked'>R,AudOut
            ADD    WvStpCnt,NO,4   ;for MRR loop       >R,AudOut
            BGE    WvStpCnt,WvStps,STOPWV ;immediately stops wave output if ready>R,AudOut
            JUMP   MRR             ;                   >R,AudOut
MRE:        ADD    WvStpCnt,NO,4   ;dibeq(above)+add+bge+jump >R,AudOut
            BGE    WvStpCnt,WvStps,STOPWV ;            >R,AudOut
            JUMP   CHKPK           ;                   >R,AudOut


;Feed peck checks (FDPC) starting
FDDEL:      MOV    fdStpCt,NO,2    ;reset feed step cnt, add 1 for prev mark,1 for this >Feed
FDPC:       ADD    fdStpCt,NO,6    ;this line and next 5>Feed
            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >Feed
            DIBEQ  [.......0],FLT  ;check for left key peck>Feed
            DIBEQ  [......0.],FCT  ;check for center key peck >Feed
            DIBEQ  [.....0..],FRT  ;check for right key peck >Feed
            JUMP   FDPC            ;loop until feed over >Feed

FLT:        MARK   76              ;left key peck      >L,Feed
            ADD    fdStpCt,NO,1    ;mark+this+BGE, -2 unused from last add >L,Feed
            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >L,Feed
FMLL:       DIBEQ  [.......1],FMLE ;will branch to FMLE when the key is 'unpecked' >L,Feed
            ADD    fdStpCt,NO,4    ;for FMLL loop      >L,Feed
            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >L,Feed
            JUMP   FMLL            ;                   >L,Feed
FMLE:       ADD    fdStpCt,NO,4    ;dibeq(above)+add+bge+jump >L,Feed
            BGE    fdStpCt,fdStpVal,FDELDN ;           >L,Feed
            JUMP   FDPC            ;                   >L,Feed
;
FCT:        MARK   67              ;center key peck    >C,Feed
            ADD    fdStpCt,NO,2    ;mark+this+BGE, -1 unused from last add >C,Feed
            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >C,Feed
FMCC:       DIBEQ  [......1.],FMCE ;will branch to FMCE when the key is 'unpecked' >C,Feed
            ADD    fdStpCt,NO,4    ;for FMCC loop      >C,Feed
            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >C,Feed
            JUMP   FMCC            ;                   >C,Feed
FMCE:       ADD    fdStpCt,NO,4    ;dibeq(above)+add+bge+jump >C,Feed
            BGE    fdStpCt,fdStpVal,FDELDN ;           >C,Feed
            JUMP   FDPC            ;                   >C,Feed
;
FRT:        MARK   82              ;Right key peck     >R,Feed
            ADD    fdStpCt,NO,3    ;mark+this+BGE, -0 unused from last add >R,Feed
            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >R,Feed
FMRR:       DIBEQ  [.....1..],FMRE ;will branch to FMRE when the key is 'unpecked' >R,Feed
            ADD    fdStpCt,NO,4    ;for FMRR loop      >R,Feed
            BGE    fdStpCt,fdStpVal,FDELDN ;immediately stops feed if ready >R,Feed
            JUMP   FMRR            ;                   >R,Feed
FMRE:       ADD    fdStpCt,NO,4    ;dibeq(above)+add+bge+jump >R,Feed
            BGE    fdStpCt,fdStpVal,FDELDN ;           >R,Feed
            JUMP   FDPC            ;                   >R,Feed
;Feed peck checks done
;
;TO peck checks (TOPC) starting
TODEL:      MOV    toStpCt,NO,2    ;reset TO step cnt, add 1 for prev mark,1 for this>TimeOut
TOPC:       ADD    toStpCt,NO,6    ;this line and next 5>TimeOut
            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >TimeOut
            DIBEQ  [.......0],TLT  ;check for left key peck>TimeOut
            DIBEQ  [......0.],TCT  ;check for center key peck >TimeOut
            DIBEQ  [.....0..],TRT  ;check for right key peck >TimeOut
            JUMP   TOPC            ;loop until TO over >TimeOut
;
TLT:        MARK   76              ;left key peck      >L,TimeOut
            ADD    toStpCt,NO,1    ;mark+this+BGE, -2 unused from last add >L,TimeOut
            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >L,TimeOut
TMLL:       DIBEQ  [.......1],TMLE ;will branch to TMLE when the key is 'unpecked' >L,TimeOut
            ADD    toStpCt,NO,4    ;for TMLL loop      >L,TimeOut
            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >L,TimeOut
            JUMP   TMLL            ;                   >L,TimeOut
TMLE:       ADD    toStpCt,NO,4    ;dibeq(above)+add+bge+jump >L,TimeOut
            BGE    toStpCt,toStpVal,TDELDN ;           >L,TimeOut
            JUMP   TOPC            ;                   >L,TimeOut
;
TCT:        MARK   67              ;center key peck    >C,TimeOut
            ADD    toStpCt,NO,2    ;mark+this+BGE, -1 unused from last add >C,TimeOut
            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >C,TimeOut
TMCC:       DIBEQ  [......1.],TMCE ;will branch to TMCE when the key is 'unpecked' >C,TimeOut
            ADD    toStpCt,NO,4    ;for TMCC loop      >C,TimeOut
            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >C,TimeOut
            JUMP   TMCC            ;                   >C,TimeOut
TMCE:       ADD    toStpCt,NO,4    ;dibeq(above)+add+bge+jump >C,TimeOut
            BGE    toStpCt,toStpVal,TDELDN ;           >C,TimeOut
            JUMP   TOPC            ;                   >C,TimeOut
;
TRT:        MARK   82              ;Right key peck     >R,TimeOut
            ADD    toStpCt,NO,3    ;mark+this+BGE, -0 unused from last add >R,TimeOut
            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >R,TimeOut
TMRR:       DIBEQ  [.....1..],TMRE ;will branch to TMRE when the key is 'unpecked' >R,TimeOut
            ADD    toStpCt,NO,4    ;for TMRR loop      >R,TimeOut
            BGE    toStpCt,toStpVal,TDELDN ;immediately stops TO if ready >R,TimeOut
            JUMP   TMRR            ;                   >R,TimeOut
TMRE:       ADD    toStpCt,NO,4    ;dibeq(above)+add+bge+jump >R,TimeOut
            BGE    toStpCt,toStpVal,TDELDN ;           >R,TimeOut
            JUMP   TOPC            ;                   >R,TimeOut
;TO peck checks done
;
;ITI peck checks starting
STITI:      NOP                    ;prevents the 'N' and '(' from being assigned the same time
            NOP    
            NOP    
            MARK   40              ;mark start of ITI w/ '(' >ITI
            MOV    itiStpCt,NO,5   ;reset iti step count, add 2 for prev lns and 1 for this >ITI
ITI:        ADD    itiStpCt,NO,6   ;this line and next 5>ITI
            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >ITI
            DIBEQ  [.......0],ILT  ;check for left key peck>ITI
            DIBEQ  [......0.],ICT  ;check for center key peck >ITI
            DIBEQ  [.....0..],IRT  ;check for right key peck >ITI
            JUMP   ITI             ;loop until ITI over >ITI
;
ILT:        MARK   76              ;left key peck      >L,ITI
            ADD    itiStpCt,NO,1   ;mark+this+BGE, -2 unused from last add >L,ITI
            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >L,ITI
IMLL:       DIBEQ  [.......1],IMLE ;will branch to IMLE when the key is 'unpecked' >L,ITI
            ADD    itiStpCt,NO,4   ;for IMLL loop      >L,ITI
            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >L,ITI
            JUMP   IMLL            ;                   >L,ITI
IMLE:       ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >L,ITI
            BGE    itiStpCt,itiVal,END ;               >L,ITI
            JUMP   ITI             ;                   >L,ITI
;
ICT:        MARK   67              ;center key peck    >C,ITI
            ADD    itiStpCt,NO,2   ;mark+this+BGE, -1 unused from last add >C,ITI
            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >C,ITI
IMCC:       DIBEQ  [......1.],IMCE ;will branch to IMCE when the key is 'unpecked' >C,ITI
            ADD    itiStpCt,NO,4   ;for IMCC loop      >C,ITI
            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >C,ITI
            JUMP   IMCC            ;                   >C,ITI
IMCE:       ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >C,ITI
            BGE    itiStpCt,itiVal,END ;               >C,ITI
            JUMP   ITI             ;                   >C,ITI
;
IRT:        MARK   82              ;Right key peck     >R,ITI
            ADD    itiStpCt,NO,3   ;mark+this+BGE, -0 unused from last add >R,ITI
            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >R,ITI
IMRR:       DIBEQ  [.....1..],IMRE ;will branch to IMRE when the key is 'unpecked' >R,ITI
            ADD    itiStpCt,NO,4   ;for IMRR loop      >R,ITI
            BGE    itiStpCt,itiVal,END ;immediately stops ITI if ready >R,ITI
            JUMP   IMRR            ;                   >R,ITI
IMRE:       ADD    itiStpCt,NO,4   ;dibeq(above)+add+bge+jump >R,ITI
            BGE    itiStpCt,itiVal,END ;               >R,ITI
            JUMP   ITI             ;                   >R,ITI
;ITI peck checks done

;End of Trial
END:        MARK   41              ;mark end of ITI w/ ')'>Post Trial
            DIGLOW [11111111]      ;turn all off but house light >Post Trial
            MOV    nobug,NO        ;                   >Post Trial
            JUMP   PTPK            ;                   >Post Trial
;
;Utils for marking digmark during pre-trial interval
MKLT:       MARK   76              ;left key peck      >L,Wait Center
            WAIT   [.......1]      ;                   >L,Wait Center
            JUMP   WCTR            ;                   >L,Wait Center
MKRT:       MARK   82              ;right key peck     >R,Wait Center
            WAIT   [.....1..]      ;                   >R,Wait Center
            JUMP   WCTR            ;                   >R,Wait Center
;
;post trial/Paused peck checks
        'P  DIGLOW [11111111]      ;the sequencer told us to pause>Post Trial
PTPK:       DIBEQ  [.......0],PMLT ;left key peck      >Post Trial
            DIBEQ  [......0.],PMCT ;center key peck    >Post Trial
            DIBEQ  [.....0..],PMRT ;right key peck     >Post Trial
            JUMP   PTPK            ;loop until called away >Post Trial
;
PMLT:       MARK   76              ;left key peck      >L,Post Trial
            WAIT   [.......1]      ;                   >L,Post Trial
            JUMP   PTPK            ;                   >L,Post Trial
PMRT:       MARK   82              ;right key peck     >R,Post Trial
            WAIT   [.....1..]      ;                   >R,Post Trial
            JUMP   PTPK            ;                   >R,Post Trial
PMCT:       MARK   67              ;center key peck    >C,Post Trial
            WAIT   [......1.]      ;                   >C,Post Trial
            JUMP   PTPK            ;                   >C,Post Trial

FLSHQ:      MOV    flshnumi,flashnum ;                 >flash cue light
FLOOP:      DIGLOW [.....000]      ;turn on cue light  >flash cue light
            DELAY  flashper        ;wait flashper msec >flash cue light
            DIGLOW [.....111]      ;turn off cue light >flash cue light
            DELAY  flashper        ;wait flashper msec >flash cue light
            DBNZ   flshnumi,FLOOP  ;                   >flash cue light
            RETURN                 ;                   >flash cue light


        'I  DIGLOW [......i.]      ;center key light invert >Hey Over Here
            JUMP   WCTR

        'N  DIGLOW [11101111]      ;turn off everything >Night Night
            HALT   

        'R  DIGLOW [11111111]      ;turn off everything except house light >ResetBox
            HALT

        'H  DIGLOW [....i...]      ;hopper invert >Hopper up or down
            JUMP   WCTR
; -------------------------------------------
; "Spy VS Spy III - Arctic Antics" Amiga.
; Disassembled by Franck "hitchhikr" Charlet.
; -------------------------------------------

                    mc68000
                    opt      o+
                    opt      all+

; -------------------------------------------

_LVOAllocMem        equ      -198
_LVOOpenLibrary     equ      -552

_LVOOpen            equ      -30
_LVOClose           equ      -36
_LVORead            equ      -42

; -------------------------------------------

                    section  spyvspy3,code_c

START_CODE:         bra      START

COPPER_LIST:
PLANES:             dc.w     $E2,0,$E0,0
                    dc.w     $E6,0,$E4,0
                    dc.w     $EA,0,$E8,0
                    dc.w     $EE,0,$EC,0
COPPER_SPRITE:      dc.w     $120,0,$122,0,$124,0,$126,0,$128,0,$12A,0,$12C,0,$12E,0
                    dc.w     $130,0,$132,0,$134,0,$136,0,$138,0,$13A,0,$13C,0,$13E,0
                    dc.w     $192
TOP_GREEN:          dc.w     $7B3
                    dc.w     $7D01,$FFFE,$192,$7B3
                    dc.w     $FFFF,$FFFE
END_COPPER_LIST:
DUMMY_SPRITE:       dcb.w    2,0

WAIT_FOR_RASTER:    move.l   d1,d2
                    add.w    #$B00,d2
.WAIT:              move.l   $DFF004,d0
                    and.l    #$1FFFF,d0
                    cmp.l    d1,d0
                    bls.b    .WAIT
                    cmp.l    d2,d0
                    bhi.b    .WAIT
                    rts

ATARI_COPY:         move.l   #((200*40)/2)-1,d0
.COPY:              move.w   (a0)+,(a1)+
                    move.w   (a0)+,(200*40)-2(a1)
                    move.w   (a0)+,(200*2*40)-2(a1)
                    move.w   (a0)+,(200*3*40)-2(a1)
                    dbra     d0,.COPY
                    rts

COLOUR_COPY:        lea      $DFF180,a1
                    move.w   #16-1,d0
.COPY:              move.w   (a0)+,d1
                    add.w    d1,d1
                    move.w   d1,(a1)+
                    dbra     d0,.COPY
                    rts

LOAD_FILE:          move.l   d2,-(sp)
                    move.l   d1,-(sp)
                    move.l   4.w,a6
                    moveq    #0,d0
                    lea      DOS_NAME,a1
                    jsr      _LVOOpenLibrary(a6)
                    move.l   d0,DOS_BASE
                    move.l   d0,a6
                    move.l   (sp)+,d1
                    move.l   #$3ED,d2
                    jsr      _LVOOpen(a6)
                    move.l   d0,DOS_HANDLE
                    move.l   d0,d1
                    move.l   (sp)+,d2
                    move.l   #32128,d3
                    jsr      _LVORead(a6)
                    move.l   DOS_HANDLE,d1
                    jmp      _LVOClose(a6)

SETUP_SCREEN:       move.l   ONESCREEN,SCREEN1
                    move.l   TWOSCREEN,SCREEN2
                    lea      $DFF000,a6
                    move.w   #$3FF,$96(a6)
                    move.l   SCREEN2,d1
                    bsr      WHICH_PLANES
                    move.w   #7,d0
                    lea      COPPER_SPRITE+2,a0
                    move.l   #DUMMY_SPRITE,d1
.bET_SPRS:          swap     d1
                    move.w   d1,(a0)
                    addq.w   #4,a0
                    swap     d1
                    move.w   d1,(a0)
                    addq.w   #4,a0
                    dbra     d0,.bET_SPRS
                    move.w   #((END_COPPER_LIST-COPPER_LIST)/2)-1,d0
                    lea      COPPER_LIST,a0
                    lea      COPPER_LIST2,a1
.COPY:              move.w   (a0)+,(a1)+
                    dbra     d0,.COPY
                    move.l   SCREEN1,d1
                    bsr      WHICH_PLANES
                    move.l   #COPPER_LIST,COPPER1
                    move.l   #COPPER_LIST2,COPPER2
                    move.l   #COPPER_LIST,$80(a6)
                    move.l   #$2C81F4C1,$8E(a6)
                    move.l   #$3800D0,$92(a6)
                    clr.w    $108(a6)
                    clr.w    $10A(a6)
                    clr.w    $102(a6)
                    clr.w    $106(a6)
                    clr.w    $1FC(a6)
                    move.w   #$4200,$100(a6)
                    move.w   #4,$104(a6)
                    clr.w    $88(a6)
                    move.w   #$83FF,$96(a6)
                    rts

WHICH_PLANES:       move.w   #3,d0
                    lea      PLANES,a0
.bET_BPS:           move.w   d1,2(a0)
                    swap     d1
                    move.w   d1,6(a0)
                    swap     d1
                    add.l    #(200*40),d1
                    addq.w   #8,a0
                    dbra     d0,.bET_BPS
                    rts

BLIT:               bsr      WAIT_BLIT
                    move.l   d0,$DFF060
                    move.l   d1,$DFF064
                    move.l   d2,$DFF040
                    move.l   #-1,$DFF044
BLIT2:              move.l   a0,$DFF050
                    move.l   a1,$DFF04C
                    move.l   a2,$DFF048
                    move.l   a3,$DFF054
                    move.w   d3,$DFF058
                    rts

WAIT_BLIT:          btst     #6,$DFF002
                    bne.b    WAIT_BLIT
                    rts

SWAP_SCREEN:        movem.l  d0/d1,-(sp)
                    bsr.b    WAIT_BLIT
                    move.l   SCREEN1,d0
                    move.l   SCREEN2,SCREEN1
                    move.l   d0,SCREEN2
                    move.l   COPPER1,d0
                    move.l   COPPER2,COPPER1
                    move.l   d0,COPPER2
                    move.l   COPPER1,$DFF080
                    move.w   #1,INT_REQ
.WAIT_INT:          tst.w    INT_REQ
                    bne.b    .WAIT_INT
                    movem.l  (sp)+,d0/d1
                    rts

CLEAR_SCREEN:       move.w   #((200*40)/4)-1,d0
.CLEAR:             clr.l    (a0)+
                    clr.l    (a0)+
                    clr.l    (a0)+
                    clr.l    (a0)+
                    dbra     d0,.CLEAR
                    rts

MYINT2:             movem.l  d0-d2/a0,-(sp)
                    bsr      ADD_MATRIX
                    bset     #6,$BFEE01
                    move.b   #0,$BFEC01
                    move.w   #81-1,d0
.WAIT:              dbra     d0,.WAIT
                    bclr     #6,$BFEE01
                    tst.b    $BFED01
                    movem.l  (sp)+,d0-d2/a0
                    move.w   #8,$DFF09C
                    rte

ADD_MATRIX:         move.b   $BFEC01,d0
                    ror.b    #1,d0
                    move.b   d0,d1
                    lea      KB_MATRIX,a0
                    and.w    #$7F,d0
                    eor.w    #$7F,d0
                    move.w   d0,d2
                    and.w    #7,d2
                    lsr.w    #3,d0
                    tst.b    d1
                    bmi.b    DOWN_STROKE
UP_STROKE:          bset     d2,0(a0,d0.w)
                    rts

DOWN_STROKE:        bclr     d2,0(a0,d0.w)
                    rts

INIT_KEY:           moveq    #-1,d0
                    lea      KB_MATRIX,a0
                    move.l   d0,(a0)+
                    move.l   d0,(a0)+
                    move.l   d0,(a0)+
                    move.l   d0,(a0)+
                    rts

INKEY:              movem.l  d2/a0,-(sp)
                    move.w   d0,d2
                    and.w    #7,d2
                    lsr.w    #3,d0
                    lea      KB_MATRIX,a0
                    btst     d2,0(a0,d0.w)
                    bne      .NOT_PRESSED
                    moveq    #-1,d0
                    bra      .PRESSED

.NOT_PRESSED:       moveq    #0,d0
.PRESSED:           movem.l  (sp)+,d2/a0
                    rts

SCAN_JOY:           movem.l  d0/d1,-(sp)
                    move.w   $DFF00A,d0
                    move.w   d0,d1
                    and.w    #$202,d0
                    move.w   d0,LEFT0
                    lsr.w    #1,d0
                    eor.w    d0,d1
                    and.w    #$101,d1
                    move.w   d1,UP0
                    move.w   $DFF00C,d0
                    move.w   d0,d1
                    and.w    #$202,d0
                    move.w   d0,LEFT1
                    lsr.w    #1,d0
                    eor.w    d0,d1
                    and.w    #$101,d1
                    move.w   d1,UP1
                    clr.w    FIRE0
                    moveq    #0,d0
                    move.b   $BFE001,d0
                    btst     #6,d0
                    bne      .MOUSE_LBUTTON
                    move.w   #$FFFF,FIRE0
.MOUSE_LBUTTON:     clr.w    FIRE1
                    btst     #7,d0
                    bne      .JOY_BUTTON1
                    move.w   #$FFFF,FIRE1
.JOY_BUTTON1:       move.w   #$4C,d0
                    bsr      INKEY
                    move.b   d0,KUP1
                    move.w   #$4D,d0
                    bsr      INKEY
                    move.b   d0,KDOWN1
                    move.w   #$4F,d0
                    bsr      INKEY
                    move.b   d0,KLEFT1
                    move.w   #$4E,d0
                    bsr      INKEY
                    move.b   d0,KRIGHT1
                    movem.l  (sp)+,d0/d1
                    rts

KB_MATRIX:          dcb.l    4,-1
LEFT0:              dc.b     -1
RIGHT0:             dc.b     -1
UP0:                dc.b     0
DOWN0:              dc.b     1
FIRE0:              dc.w     0
LEFT1:              dc.b     -1
RIGHT1:             dc.b     -1
UP1:                dc.b     -1
DOWN1:              dc.b     -1
FIRE1:              dc.w     0

HANDLE_MOUSE:       movem.l  d0-d2/a0,-(sp)
                    move.w   $DFF00A,d0
                    lea      LAST_MOUSE0,a0
                    bsr      DO_MOUSE
                    move.w   $DFF00C,d0
                    lea      LAST_MOUSE1,a0
                    bsr      DO_MOUSE
                    clr.w    MFIRE0
                    move.w   $DFF016,d0
                    btst     #10,d0
                    bne      .MOUSE_RBUTTON
                    move.w   #-1,MFIRE0
.MOUSE_RBUTTON:     clr.w    MFIRE1
                    btst     #14,d0
                    bne      .JOY_BUTTON2
                    move.w   #-1,MFIRE1
.JOY_BUTTON2:       movem.l  (sp)+,d0-d2/a0
                    rts

DO_MOUSE:           move.l   2(a0),d1
                    beq      CHECK_MOUSE
                    tst.b    d1
                    beq      .NO_VAL1
                    sub.b    #1,d1
.NO_VAL1:           rol.l    #8,d1
                    tst.b    d1
                    beq      .NO_VAL2
                    sub.b    #1,d1
.NO_VAL2:           rol.l    #8,d1
                    tst.b    d1
                    beq      .NO_VAL3
                    sub.b    #1,d1
.NO_VAL3:           rol.l    #8,d1
                    tst.b    d1
                    beq      .NO_VAL4
                    sub.b    #1,d1
.NO_VAL4:           rol.l    #8,d1
                    move.l   d1,2(a0)
CHECK_MOUSE:        move.w   d0,d2
                    sub.b    1(a0),d0
                    beq      DOM_UD
                    bpl      DOM_RIGHT
                    neg.b    d0
                    cmp.b    #1,d0
                    bls      DOM_UD
                    move.b   #$14,2(a0)
                    bra      DOM_UD

DOM_RIGHT:          cmp.b    #1,d0
                    bls      DOM_UD
                    move.b   #$14,3(a0)
DOM_UD:             move.w   d2,d0
                    lsr.w    #8,d0
                    sub.b    (a0),d0
                    beq      DOM_RET
                    bpl      DOM_DOWN
                    neg.b    d0
                    cmp.b    #1,d0
                    bls      DOM_RET
                    move.b   #$14,4(a0)
                    bra      DOM_RET

DOM_DOWN:           cmp.b    #1,d0
                    bls      DOM_RET
                    move.b   #$14,5(a0)
DOM_RET:            move.w   d2,(a0)
                    rts

LAST_MOUSE0:        dc.w     0
MLEFT0:             dc.b     0
MRIGHT0:            dc.b     0
MUP0:               dc.b     0
MDOWN0:             dc.b     0
MFIRE0:             dc.w     0
LAST_MOUSE1:        dc.w     0
MLEFT1:             dc.b     0
MRIGHT1:            dc.b     0
MUP1:               dc.b     0
MDOWN1:             dc.b     0
MFIRE1:             dc.w     0
KLEFT1:             dc.b     0
KRIGHT1:            dc.b     0
KUP1:               dc.b     0
KDOWN1:             dc.b     0

ALLOCATE_MEMORY:    move.w   #$100,d7
                    move.w   #$700,d6
                    bsr      FIND32K
                    bsr      CLEARD0
                    move.l   d0,ONESCREEN
                    move.w   #$10,d7
                    move.w   #$70,d6
                    bsr      FIND32K
                    bsr      CLEARD0
                    move.w   #1,d7
                    move.w   #7,d6
                    move.l   d0,TWOSCREEN
                    bsr      FIND32K
                    move.l   d0,BACK
                    rts

CLEARD0:            move.l   d0,a0
                    move.w   #(200*40)-1,d1
                    ; *4 bitplanes
.CLEAR:             clr.l    (a0)+
                    dbra     d1,.CLEAR
                    rts

FIND32K:            move.l   4.w,a6
                    move.l   #32768,d0
                    moveq    #2,d1
                    jsr      _LVOAllocMem(a6)
                    tst.l    d0
                    beq      WHOS_REMOVED_THE_RAM_CHIPS
                    rts

WHOS_REMOVED_THE_RAM_CHIPS:
                    move.w   d7,$DFF180
                    move.w   d6,$DFF180
                    bra.b    WHOS_REMOVED_THE_RAM_CHIPS

DECO_PIC:           move.l   d2,-(sp)
                    move.l   BACK,d2
                    bsr      LOAD_FILE
                    move.l   (sp)+,a1
DECO:               move.l   BACK,a0
                    addq.w   #2,a0
                    addq.w   #4,a1
                    move.w   #16-1,d0
DECO_PAL:           move.w   (a0)+,(a1)+
                    dbra     d0,DECO_PAL
                    lea      (92)(a1),a1
                    move.w   #4-1,d0
DECO_THREE:         move.l   a1,a2
                    move.w   #(200*40),d1
                    clr.w    FLAG
DECO_LOOP:          move.b   (a0)+,d2
                    cmp.b    #$CD,d2
                    bne      DECO_ORD
                    move.b   (a0)+,d2
                    bne      NOT_CD_DECO
                    move.b   #$CD,d2
                    bra      DECO_ORD

NOT_CD_DECO:        bra      DECO_REP

DECO_ORD:           move.b   d2,(a1)
                    tst.w    FLAG
                    bne      ADD_LOTS
                    addq.w   #1,FLAG
                    addq.w   #1,a1
                    subq.w   #1,d1
                    beq      DONE_DECO
                    bra.b    DECO_LOOP

ADD_LOTS:           clr.w    FLAG
                    addq.w   #7,a1
                    subq.w   #1,d1
                    beq      DONE_DECO
                    bra.b    DECO_LOOP

DECO_REP:           move.w   d2,d3
                    and.w    #$7F,d3
                    tst.b    d2
                    bmi      USE_FF
                    clr.w    d2
                    bra      DECO_LOTS

USE_FF:             move.w   #-1,d2
DECO_LOTS:          move.b   d2,(a1)
                    tst.w    FLAG
                    bne      ADD_LOTS2
                    addq.w   #1,FLAG
                    addq.w   #1,a1
                    subq.w   #1,d1
                    beq      DONE_DECO
                    subq.b   #1,d3
                    bne.b    DECO_LOTS
                    bra      DECO_LOOP

ADD_LOTS2:          clr.w    FLAG
                    addq.w   #7,a1
                    subq.w   #1,d1
                    beq      DONE_DECO
                    subq.b   #1,d3
                    bne.b    DECO_LOTS
                    bra      DECO_LOOP

DONE_DECO:          lea      2(a2),a1
                    dbra     d0,DECO_THREE
                    rts

FLAG:               dc.w     0
DOS_NAME:           dc.b     'dos.library',0
                    even
DOS_BASE:           dc.l     0
DOS_HANDLE:         dc.l     0
ONESCREEN:          dc.l     0
TWOSCREEN:          dc.l     0
LOADSCREEN:         dc.l     0
SCREEN2:            dc.l     0
SCREEN1:            dc.l     0
COPPER1:            dc.l     0
COPPER2:            dc.l     0
COPPER_LIST2:       dcb.b    (END_COPPER_LIST-COPPER_LIST),0

FREQS:              dc.w     404,381,359,339,320,302,285,269,254,240,226,213
ENVELOPE1:          dc.w     1,50,0,25,-2,0,-1
ENVELOPE2:          dc.w     1,30,0,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,1,-1
                    dc.w     -4,1,0,4,-1
ENVELOPE3:          dc.w     1,30,0,15,-2,1,-1
DUMMY:              dc.w     -1
TRIANGLE32:         dc.b     -128,-112,-96,80,-64,-48,-32,-16,0,16,32,48,64
                    dc.b     80,96,112,127,112,96,80,64,48,32,16,0,-16
                    dc.b     -32,-48,-64,-80,-96,-112
WAVEFORM128:        dc.b     0,6,13,19,25,31,37,43,49,55,60,66,71
                    dc.b     76,81,86,91,95,99,103,106,110,113,116,118
                    dc.b     121,122,124,126,127,127,127,127,127,127,127,126
                    dc.b     124,122,121,118,116,113,110,106,103,99,95,91
                    dc.b     86,81,76,71,66,60,55,49,43,37,31,25
                    dc.b     19,13,6,0,-6,-13,-19,-25,-31,-37,-43,-49,-55
                    dc.b     -60,-66,-71,-76,-81,-86,-91,-95,-99,-103,-106,-110
                    dc.b     -113,-116,-118,-121,-122,-124,-126,-127,-127,-128,-128,-128
                    dc.b     -127,-127,-126,-124,-122,-121,-118,-116,-113,-110,-106,-103
                    dc.b     -99,-95,-91,-86,-81,-76,-71,-66,-60,-55,-49,-43
                    dc.b     -37,-31,-25,-19,-13,-6
WAVEFORM64:         dc.b     0,13,25,37,49,60,71,81,91,99,106,113,118
                    dc.b     122,126,127,127,127,126,122,118,113,106,99,91
                    dc.b     81,71,60,49,37,25,13,0,-13,-25,-37,-49,-60
                    dc.b     -71,-81,-91,-99,-106,-113,-118,-122,-126,-127,-128,-127
                    dc.b     -126,-122,-118,-113,-106,-99,-91,-81,-71,-60,-49,-37,-25,-13
WAVEFORM32:         dc.b     0,25,49,71,91,106,118,126,127,126,118,106,91
                    dc.b     71,49,25,0,-25,-49,-71,-91,-106,-118,-126,-128,-126,-118,-106,-91,-71,-49,-25
WAVEFORM16:         dc.b     0,49,91,118,127,118,91,49,0,-49,-91,-118,-128,-118,-91,-49
WAVEFORM8:          dc.b     0,91,127,91,0,-91,-128,-91
WAVEFORM4:          dc.b     0,127,0,-128
WAVEFORM2:          dc.b     -64,64
WHICH_WAVE:         dc.l     WAVEFORM128
                    dc.l     WAVEFORM64
                    dc.l     WAVEFORM32
                    dc.l     WAVEFORM16
                    dc.l     WAVEFORM8
                    dc.l     WAVEFORM4
                    dc.l     WAVEFORM2
WAVE_LENGTH:        dc.w     128/2,64/2,32/2,16/2,8/2,4/2,2/2
E_HIGH_PING:        dc.w     1,32,0,5,0,1,32,-1,0,-1
E_MEDIUM_PING:      dc.w     1,32,0,5,0,1,32,-1,0,-1
E_LOW_PING:         dc.w     1,32,0,5,0,1,32,-1,0,-1
E_MEDIUM_BEEP:      dc.w     1,64,0,25,0,0,1,-64,0,-1
E_BANG:             dc.w     1,64,0,32,-2,0,-1
E_BOOM:             dc.w     1,64,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,1,-1
                    dc.w     0,7,0,0,-1
E_GRAVE:            dc.w     1,64,0,864,0,0,64,-1
                    dc.w     0,-1
E_BURY:             dc.w     64,1,-3,1,-64,0,180,0,0,-1
E_SPLASH:           dc.w     32,2,0,40,0,-4,64,-1
                    dc.w     0,-1
E_SUB:              dc.w     1,24,0,10,0,-2,400,0,0,24,-1
                    dc.w     0,-1
E_FEET:             dc.w     10,1,-5,1,-10,0,-1
E_PICK:             dc.w     1,55,0,1,0,0,5,-11,0,40,0,0,1,55,0,1,0,0,5,-11,0,40,0,0,1,55,0,1,0,0,5,-11,0,40,0,0,1
                    dc.w     55,0,1,0,0,5,-11,0,40,0,0,1,55,0,1,0,0,5,-11,0,40,0,0,1,55,0,1,0,0,5,-11,0,40,0,0,1
                    dc.w     55,0,1,0,0,5,-11,0,40,0,0,1,55,0,1,0,0,5,-11,0,40,0,0,1,55,0,1,0,0,5,-11,0,40,0,0,1
                    dc.w     55,0,1,0,0,5,-11,0,40,0,0,1,55,0,1,0,0,5,-11,0,40,0,0,-1
E_SAW:              dc.w     1,30,0,20,0,0,1,-30,0,$14,0,0,1,30,1000,20,0,0,1,-30,-1000,20,0,0,1,30,0,20,0,0,1,-30
                    dc.w     0,20,0,0,1,30,1000,20,0,0,1,-30,-1000,20,0,0,1,30,0,$14,0,0,1,-30,0,20,0,0,1,30,1000
                    dc.w     20,0,0,1,-30,-1000,20,0,0,1,30,0,20,0,0,1,-30,0,20,0,0,1,30,1000,20,0,0,1,-30,-1000
                    dc.w     20,0,0,1,30,0,20,0,0,1,-30,0,20,0,0,1,30,1000,20,0,0,1,-30,-1000,20,0,0,1,30,0,20,0
                    dc.w     0,1,-30,0,20,0,0,1,30,1000,20,0,0,1,-30,-1000,20,0,0,-1
E_KISS:             dc.w     1,15,0,20,0,-13,1,-15,0,-1
E_RUMBLE:           dc.w     1,64,0,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,50,0,0,1,-1
                    dc.w     1,-1

START_SOUNDS:       move.w   #1,MASTER_ENABLE
                    clr.w    MUSIC_POINTER
                    clr.w    MUSIC_DELAY
                    lea      RANDOM_AREA,a0
                    move.w   #8192-1,d0
.GEN_RND:           move.l   RND1,d1
                    add.l    RND2,d1
                    add.w    $DFF006,d1
                    ror.l    #1,d1
                    move.l   d1,RND1
                    sub.l    RND3,d1
                    rol.l    #1,d1
                    add.w    d1,RND2
                    and.w    #$FF,d1
                    move.b   d1,(a0)+
                    dbra     d0,.GEN_RND
                    clr.w    MUSIC_SWITCH
                    move.w   #$F,$DFF096
                    move.w   #$FF,$DFF09E
                    lea      $DFF0A0,a5
                    lea      MUSINF_0,a6
                    clr.w    (a6)
                    clr.w    6(a6)
                    move.w   #64/2,4(a5)
                    move.w   #$8001,8(a6)
                    move.l   #ENVELOPE1,10(a6)
                    move.l   10(a6),16(a6)
                    move.l   #DUMMY,10(a6)
                    clr.w    4(a6)
                    move.w   #-1,14(a6)
                    lea      $DFF0B0,a5
                    lea      MUSINF_1,a6
                    clr.w    (a6)
                    clr.w    6(a6)
                    move.w   #64/2,4(a5)
                    move.w   #$8002,8(a6)
                    move.l   #ENVELOPE2,10(a6)
                    move.l   10(a6),16(a6)
                    move.l   #DUMMY,10(a6)
                    clr.w    4(a6)
                    move.w   #-1,14(a6)
                    lea      $DFF0C0,a5
                    lea      MUSINF_2,a6
                    clr.w    (a6)
                    clr.w    6(a6)
                    move.w   #64/2,4(a5)
                    move.w   #$8004,8(a6)
                    move.l   #ENVELOPE3,10(a6)
                    move.l   10(a6),16(a6)
                    move.l   #DUMMY,10(a6)
                    clr.w    4(a6)
                    move.w   #-1,14(a6)
                    lea      $DFF0D0,a5
                    lea      MUSINF_3,a6
                    clr.w    (a6)
                    move.w   #64/2,4(a5)
                    clr.w    6(a6)
                    move.w   #$8008,8(a6)
                    move.l   #ENVELOPE1,10(a6)
                    move.l   10(a6),16(a6)
                    move.l   #DUMMY,10(a6)
                    clr.w    4(a6)
                    move.w   #0,14(a6)
                    bsr      INITMUSC
                    move.l   $78.w,SAVEINT6
                    move.l   #MYINT6,$78.w
                    lea      $BFD000,a0
                    move.b   #0,$600(a0)
                    move.b   #14,$700(a0)
                    move.b   #$11,$F00(a0)
                    move.b   #$82,$D00(a0)
                    move.w   #$A000,$DFF09A
                    clr.b    lbB001F19
                    rts

; d0=length
; d1=period
; a1=waveform
GO_SOUND:           move.l   a1,(a5)
                    move.w   #$FF,$DFF09E
                    move.w   d0,4(a5)
                    move.w   d1,20(a6)
                    move.w   d1,6(a5)
                    clr.w    6(a6)
                    clr.w    (a6)
                    clr.w    4(a6)
                    move.w   #1,14(a6)
                    move.l   a0,10(a6)
                    rts

HIGH_PING:          move.w   #16/2,d0
                    move.w   #220,d1
                    lea      E_HIGH_PING,a0
                    lea      WAVEFORM16,a1
                    bra.b    GO_SOUND

MEDIUM_PING:        move.w   #16/2,d0
                    move.w   #400,d1
                    lea      E_MEDIUM_PING,a0
                    lea      WAVEFORM16,a1
                    bra.b    GO_SOUND

LOW_PING:           move.w   #8/2,d0
                    move.w   #1800,d1
                    lea      E_LOW_PING,a0
                    lea      WAVEFORM8,a1
                    bra.b    GO_SOUND

DROP_PING:          move.w   #8/2,d0
                    move.w   #2200,d1
                    lea      E_LOW_PING,a0
                    lea      WAVEFORM8,a1
                    bra      GO_SOUND

TAKE_PING:          move.w   #8/2,d0
                    move.w   #2500,d1
                    lea      E_LOW_PING,a0
                    lea      WAVEFORM8,a1
                    bra      GO_SOUND

MEDIUM_BEEP:        move.w   #8/2,d0
                    move.w   #600,d1
                    lea      E_MEDIUM_BEEP,a0
                    lea      WAVEFORM8,a1
                    bra      GO_SOUND

BOP:                move.w   #8192/2,d0
                    move.w   #4000,d1
                    lea      E_BANG,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

BANG:               move.w   #8192/2,d0
                    move.w   #700,d1
                    lea      E_BANG,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

OTHER_SMACK:        move.w   #8192/2,d0
                    move.w   #500,d1
                    lea      E_BANG,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

GRAVESOUND:         move.w   #532/2,d0
                    move.w   #5700,d1
                    lea      E_GRAVE,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

BOOM:               move.w   #8192/2,d0
                    move.w   #4500,d1
                    lea      E_BOOM,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

BURY:               move.w   #8192/2,d0
                    move.w   #1500,d1
                    lea      E_BURY,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

SPLASH:             move.w   #8192/2,d0
                    move.w   #1000,d1
                    lea      E_SPLASH,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

RUMBLE:             move.w   #8192/2,d0
                    move.w   #4600,d1
                    lea      E_RUMBLE,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

FEET:               move.w   #8192/2,d0
                    move.w   #1500,d1
                    lea      E_FEET,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

PICKY:              move.w   #8192/2,d0
                    move.w   #1500,d1
                    lea      E_PICK,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

SAWY:               move.w   #8192/2,d0
                    move.w   #3000,d1
                    lea      E_SAW,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

KISS:               move.w   #8192/2,d0
                    move.w   #132,d1
                    lea      E_KISS,a0
                    lea      RANDOM_AREA,a1
                    bra      GO_SOUND

SUB:                move.w   #8/2,d0
                    move.w   #5000,d1
                    lea      E_SUB,a0
                    lea      WAVEFORM16,a1
                    bra      GO_SOUND

HANDLE_SOUNDS:      lea      $DFF0A0,a5
                    lea      MUSINF_0,a6
                    bsr      HANDLE_REQUEST
                    bne      lbC00179E
                    lea      $DFF0B0,a5
                    lea      MUSINF_1,a6
                    bsr      HANDLE_REQUEST
                    bne      lbC00179E
                    lea      $DFF0C0,a5
                    lea      MUSINF_2,a6
                    bsr      HANDLE_REQUEST
                    bne      lbC00179E
                    lea      $DFF0D0,a5
                    lea      MUSINF_3,a6
                    bra      HANDLE_REQUEST
lbC00179E:          rts

HANDLE_REQUEST:     lea      REQUESTS,a0
                    tst.w    14(a6)
                    bne      lbC0017F6
                    tst.w    (a0)+
                    bmi      lbC0017B8
                    bne      lbC0017D6
lbC0017B8:          tst.w    (a0)+
                    bmi      lbC0017C2
                    bne      lbC0017D6
lbC0017C2:          tst.w    (a0)+
                    bmi      lbC0017CC
                    bne      lbC0017D6
lbC0017CC:          tst.w    (a0)+
                    bmi      lbC0017FA
                    beq      lbC0017FA
lbC0017D6:          move.w   -(a0),d0
                    and.w    #$FF,d0
                    or.w     #$8000,(a0)
                    and.w    #$9FFF,(a0)
                    move.l   a0,22(a6)
                    add.w    d0,d0
                    add.w    d0,d0
                    lea      SOUND_ROUTINES,a0
                    move.l   (a0,d0.w),a0
                    jsr      (a0)
lbC0017F6:          moveq    #0,d0
                    rts

lbC0017FA:          moveq    #-1,d0
                    rts

NEW_SOUND:          movem.l  d0-d2/a0,-(sp)
                    move.w   d7,d0
                    move.w   d0,d2
                    and.w    #$3FF,d0
                    btst     #13,d2
                    beq      lbC001828
                    tst.w    BSND_FLAG
                    bne      NEW_RET
                    move.w   #1,BSND_FLAG
                    bra      NO_MATCH

lbC001828:          lea      REQUESTS,a0
                    move.w   (a0)+,d1
                    and.w    #$3FF,d1
                    cmp.w    d1,d0
                    beq      MATCH_SOUND
                    move.w   (a0)+,d1
                    and.w    #$3FF,d1
                    cmp.w    d1,d0
                    beq      MATCH_SOUND
                    move.w   (a0)+,d1
                    and.w    #$3FF,d1
                    cmp.w    d1,d0
                    beq      MATCH_SOUND
                    move.w   (a0)+,d1
                    and.w    #$3FF,d1
                    cmp.w    d1,d0
                    bne      NO_MATCH
MATCH_SOUND:        tst.w    d2
                    bmi      NEW_RET
                    or.w     #$4000,-(a0)
                    bra      NEW_RET

NO_MATCH:           lea      REQUESTS,a0
                    tst.w    (a0)+
                    beq      lbC001896
                    tst.w    (a0)+
                    beq      lbC001896
                    tst.w    (a0)+
                    beq      lbC001896
                    tst.w    (a0)+
                    beq      lbC001896
                    btst     #14,d2
                    bne      lbC001896
                    bra      NEW_RET

lbC001896:          move.w   d0,-(a0)
NEW_RET:            movem.l  (sp)+,d0-d2/a0
                    rts

REQUESTS:           dcb.w    4,0
SOUND_ROUTINES:     dc.l     HIGH_PING
                    dc.l     HIGH_PING
                    dc.l     BANG
                    dc.l     BURY
                    dc.l     BOOM
                    dc.l     SPLASH
                    dc.l     MEDIUM_PING
                    dc.l     LOW_PING
                    dc.l     MEDIUM_BEEP
                    dc.l     RUMBLE
                    dc.l     SUB
                    dc.l     FEET
                    dc.l     GRAVESOUND
                    dc.l     KISS
                    dc.l     TAKE_PING
                    dc.l     DROP_PING
                    dc.l     OTHER_SMACK
                    dc.l     PICKY
                    dc.l     SAWY
                    dc.l     BOP

MYINT6:             tst.b    $BFDD00
                    bsr      HANDLE_MOUSE
                    tst.w    MASTER_ENABLE
                    beq      MYINT6_RET
                    movem.l  d0-d7/a0-a6,-(sp)
                    tst.w    MUSIC_DELAY
                    beq      .WAIT
                    subq.w   #1,MUSIC_DELAY
                    bra      ENVS

.WAIT:              move.w   #3,MUSIC_DELAY
                    tst.w    MUSIC_SWITCH
                    beq      ENVS
                    bsr      PLAYMUS
                    bsr      X8912
ENVS:               lea      $DFF0A0,a5
                    lea      MUSINF_0,a6
                    tst.w    14(a6)
                    beq      .CHNG_ENV_1
                    bsr      CHANGE_ENVELOPE
.CHNG_ENV_1:        lea      $DFF0B0,a5
                    lea      MUSINF_1,a6
                    tst.w    14(a6)
                    beq      .CHNG_ENV_2
                    bsr      CHANGE_ENVELOPE
.CHNG_ENV_2:        lea      $DFF0C0,a5
                    lea      MUSINF_2,a6
                    tst.w    14(a6)
                    beq      .CHNG_ENV_3
                    bsr      CHANGE_ENVELOPE
.CHNG_ENV_3:        lea      $DFF0D0,a5
                    lea      MUSINF_3,a6
                    tst.w    14(a6)
                    beq      .CHNG_ENV_4
                    bsr      CHANGE_ENVELOPE
.CHNG_ENV_4:        bsr      HANDLE_SOUNDS
                    movem.l  (sp)+,d0-d7/a0-a6
MYINT6_RET:         move.w   #$2000,$DFF09C
                    rte

CHANGE_ENVELOPE:    tst.w    (a6)
                    bne      SAME_STEP
                    or.w     #$8000,8(a6)
                    tst.w    14(a6)
                    bmi      lbC0019C8
                    clr.w    14(a6)
lbC0019C8:          move.l   10(a6),a0
CE_1:               move.w   (a0),d0
                    bmi      END_OF_ENVY
                    or.w     #1,14(a6)
                    addq.w   #2,a0
                    move.w   d0,(a6)
                    move.w   (a0)+,2(a6)
                    move.w   (a0)+,4(a6)
                    move.l   a0,10(a6)
SAME_STEP:          tst.w    (a6)
                    beq      DO_VOLUME
                    subq.w   #1,(a6)
                    move.w   6(a6),d0
                    add.w    2(a6),d0
                    move.w   d0,6(a6)
                    move.w   20(a6),d0
                    add.w    4(a6),d0
                    move.w   d0,20(a6)
                    bra      DO_VOLUME

END_OF_ENVY:        cmp.w    #-2,d0
                    bne      lbC001A3A
                    move.l   22(a6),a1
                    move.w   (a1),d0
                    btst     #14,d0
                    beq      lbC001A36
                    bclr     #14,d0
                    move.w   d0,(a1)
                    move.w   2(a0),d0
                    sub.w    d0,a0
                    bra.b    CE_1

lbC001A36:          addq.w   #4,a0
                    bra.b    CE_1

lbC001A3A:          tst.w    6(a6)
                    bne      lbC001A48
                    and.w    #$7FFF,8(a6)
lbC001A48:          move.l   22(a6),a0
                    move.w   (a0),d0
                    and.w    #$4000,d0
                    bne      ALLOW_AGAIN
                    clr.w    (a0)
                    bra      DO_VOLUME

ALLOW_AGAIN:        and.w    #$3FF,(a0)
DO_VOLUME:          move.w   20(a6),6(a5)
                    move.w   6(a6),8(a5)
                    move.w   8(a6),$DFF096
                    rts

X8912:              lea      REGS,a4
                    lea      $DFF0A0,a5
                    lea      MUSINF_0,a6
                    move.b   7(a4),d0
                    move.w   d0,d1
                    and.w    #9,d1
                    cmp.w    #9,d1
                    beq      XDONE1
                    and.w    #8,d1
                    beq      XNOISE1
                    moveq    #0,d2
                    moveq    #0,d3
                    move.b   (a4),d2
                    move.b   1(a4),d3
                    add.w    d2,d2
                    lea      WAVE_LENGTH,a0
                    move.w   (a0,d2.w),4(a5)
                    add.w    d2,d2
                    lea      WHICH_WAVE,a0
                    move.l   (a0,d2.w),(a5)
                    add.w    d3,d3
                    lea      FREQS,a0
ISITENV1:           cmp.b    #16,8(a4)
                    beq      DO_ENVEL1
                    move.w   (a0,d3.w),6(a5)
                    move.w   (a0,d3.w),20(a6)
                    clr.w    4(a6)
                    move.b   8(a4),d0
                    and.w    #$F,d0
                    add.w    d0,d0
                    move.w   d0,6(a6)
                    bra      XDONE1

DO_ENVEL1:          tst.b    13(a4)
                    beq      XDONE1
                    move.w   (a0,d3.w),6(a5)
                    move.w   (a0,d3.w),20(a6)
                    clr.w    4(a6)
                    move.l   16(a6),10(a6)
                    clr.w    6(a6)
                    clr.w    (a6)
                    bra      XDONE1

XNOISE1:            lea      $DFF0C0,a5
                    lea      MUSINF_2,a6
                    move.l   #RANDOM_AREA,(a5)
                    move.w   #8192/2,4(a5)
                    moveq    #0,d0
                    move.b   6(a4),d0
                    and.w    #$1F,d0
                    lsl.w    #7,d0
                    move.w   d0,TEMP_MUSIC
                    lea      TEMP_MUSIC,a0
                    clr.w    d3
                    bra      ISITENV1

XDONE1:             lea      $DFF0B0,a5
                    lea      MUSINF_1,a6
                    move.b   7(a4),d0
                    move.w   d0,d1
                    and.w    #$12,d1
                    cmp.w    #$12,d1
                    beq      XDONE2
                    and.w    #$A,d1
                    bne      XNOISE2
                    moveq    #0,d2
                    moveq    #0,d3
                    move.b   2(a4),d2
                    move.b   3(a4),d3
                    add.w    d2,d2
                    lea      WAVE_LENGTH,a0
                    move.w   (a0,d2.w),4(a5)
                    add.w    d2,d2
                    lea      WHICH_WAVE,a0
                    move.l   (a0,d2.w),(a5)
                    add.w    d3,d3
                    lea      FREQS,a0
ISITENV2:           cmp.b    #16,9(a4)
                    beq      DO_ENVEL2
                    move.w   (a0,d3.w),6(a5)
                    move.w   (a0,d3.w),20(a6)
                    clr.w    4(a6)
                    move.b   9(a4),d0
                    and.w    #$F,d0
                    add.w    d0,d0
                    move.w   d0,6(a6)
                    bra      XDONE2

DO_ENVEL2:          tst.b    13(a4)
                    beq      XDONE2
                    move.w   (a0,d3.w),6(a5)
                    move.w   (a0,d3.w),20(a6)
                    clr.w    4(a6)
                    move.l   16(a6),10(a6)
                    clr.w    6(a6)
                    clr.w    (a6)
                    bra      XDONE2

XNOISE2:            lea      $DFF0C0,a5
                    lea      MUSINF_2,a6
                    move.l   #RANDOM_AREA,(a5)
                    move.w   #8192/2,4(a5)
                    moveq    #0,d0
                    move.b   6(a4),d0
                    and.w    #$1F,d0
                    lsl.w    #7,d0
                    move.w   d0,TEMP_MUSIC
                    lea      TEMP_MUSIC,a0
                    clr.w    d3
                    bra      ISITENV2

XDONE2:             clr.b    13(a4)
                    rts

PSGW:               move.l   a0,-(sp)
                    lea      REGS,a0
                    move.b   d1,(a0,d0.w)
                    move.l   (sp)+,a0
                    rts

INITMUSC:           move.w   #1,MUSICON
                    move.w   #7,d0
                    move.w   #$FC,d1
                    bsr.b    PSGW
                    move.w   #8,d0
                    move.w   #0,d1
                    bsr.b    PSGW
                    move.w   #9,d0
                    move.w   #0,d1
                    bsr.b    PSGW
                    move.l   #NOTES1,POINTERA
                    move.l   #NOTES2,POINTERB
                    clr.w    DELAYA
                    clr.w    DELAYB
                    clr.w    FLAGA
                    clr.w    FLAGB
                    rts

PLAYMUS:            tst.w    MUSICON
                    beq.b    .NOT_PLAYING
                    move.l   POINTERA,a4
                    move.w   DELAYA,d7
                    clr.w    d5
                    bsr      PLAY_CHANNEL
                    move.w   d7,DELAYA
                    move.l   a4,POINTERA
                    move.l   POINTERB,a4
                    move.w   DELAYB,d7
                    move.w   #-1,d5
                    bsr      PLAY_CHANNEL
                    move.w   d7,DELAYB
                    move.l   a4,POINTERB
                    rts

.NOT_PLAYING:       move.w   #8,d0
                    move.w   #0,d1
                    bsr      PSGW
                    move.w   #9,d0
                    move.w   #0,d1
                    bra      PSGW

PLAY_CHANNEL:       tst.w    d7
                    beq      PLAY2
                    subq.w   #1,d7
                    tst.w    d5
                    bne      lbC001D36
                    tst.w    FLAGA
                    beq      lbC001D52
                    cmp.w    #9,d7
                    bgt      lbC001D52
                    move.w   d7,d1
                    move.w   #8,d0
                    bsr      PSGW
lbC001D36:          tst.w    FLAGB
                    beq      lbC001D52
                    cmp.w    #10,d7
                    bgt      lbC001D52
                    move.w   d7,d1
                    move.w   #9,d0
                    bra      PSGW
lbC001D52:          rts

PLAY2:              tst.w    (a4)
                    bpl      lbC001D5E
                    move.l   2(a4),a4
lbC001D5E:          move.w   (a4)+,d2
                    move.w   (a4)+,d3
                    move.w   (a4)+,d7
                    subq.w   #1,d7
                    tst.w    d3
                    bmi      lbC001DCC
                    tst.w    d5
                    bne      lbC001DA0
                    subq.w   #1,d2
                    move.w   #-1,FLAGA
                    move.w   #8,d0
                    move.w   #9,d1
                    bsr      PSGW
                    move.w   #0,d0
                    move.w   d2,d1
                    bsr      PSGW
                    move.w   #1,d0
                    move.w   d3,d1
                    bsr      PSGW
                    bra      lbC001DF6

lbC001DA0:          move.w   #-1,FLAGB
                    move.w   #9,d0
                    move.w   #10,d1
                    bsr      PSGW
                    move.w   #2,d0
                    move.w   d2,d1
                    bsr      PSGW
                    move.w   #3,d0
                    move.w   d3,d1
                    bsr      PSGW
                    bra      lbC001DF6

lbC001DCC:          tst.w    d5
                    bne      lbC001DE4
                    move.w   #8,d0
                    move.w   #0,d1
                    bsr      PSGW
                    clr.w    FLAGA
lbC001DE4:          move.w   #9,d0
                    move.w   #0,d1
                    bsr      PSGW
                    clr.w    FLAGB
lbC001DF6:          rts

NOTES1:             dc.w     0,-1,320
NOTES1A:            dc.w     0,-1,640,4,7,160,4,6,160,4,2,160,4,0,160,3,7,160,3,6,160,3,2,160,3,0,160,2,7,160,2,6,160,2,2,160,2,0,160,-1
                    dc.l     NOTES1A
NOTES2:             dc.w     1,2,10,1,2,10,1,2,20,0,-1,40,0,-1,80,1,2,10,1,2,10,1,2,20,0,-1,40,0,-1,80
NOTES2A:            dc.w     1,2,10,1,2,10,2,9,10,1,2,10,2,0,10,1,2,10,2,9,10,2,7,20,1,2,10,2,6,10,1,2,10,2,4,10,1,2,10,2,0,10,1,9,10,-1
                    dc.l     NOTES2A
MUSICON:            dc.w     0
DELAYA:             dc.w     0
DELAYB:             dc.w     0
POINTERA:           dc.l     0
POINTERB:           dc.l     0
FLAGA:              dc.w     0
FLAGB:              dc.w     0
WARBLEA:            dc.w     0
FREQA:              dc.w     0
MUSIC_SWITCH:       dc.w     0
SAVE_INT2:          dc.l     0
TEMP_MUSIC:         dc.w     0
REGS:               dcb.b    13,0
lbB001F19:          dc.b     0
REG7:               dcb.b    2,0
SAVEINT6:           dc.l     0
MUSINF_0:           dcb.b    14,0
lbW001F2E:          dcb.w    6,0
MUSINF_1:           dcb.b    14,0
lbW001F48:          dcb.w    6,0
MUSINF_2:           dcb.b    14,0
lbW001F62:          dcb.w    6,0
MUSINF_3:           dcb.b    26,0
MUSIC_POINTER:      dc.w     0
MUSIC_DELAY:        dc.w     0
FRED:               dc.w     0
MASTER_ENABLE:      dc.w     0
BSND_FLAG:          dc.w     0

START:              move.l   sp,MY_VERY_OWN_STACK
                    jsr      ALLOCATE_MEMORY
                    jsr      INIT_KEY
                    jsr      START_SOUNDS
                    move.l   $68.w,SAVE_INT2
                    move.w   #1,MUSIC_SWITCH
                    jsr      SETUP_SCREEN
                    move.l   TWOSCREEN,SCREEN2
                    move.l   ONESCREEN,SCREEN1
                    bsr      READALL
                    move.l   #1245184,d0
lbC001FDA:          subq.l   #1,d0
                    bne.b    lbC001FDA
                    move.l   #MYINT3,$6C.w
                    move.l   #MYINT2,$68.w
                    move.w   #2,S1MODE
                    clr.w    S2MODE
DEVICE:             move.l   MY_VERY_OWN_STACK,sp
                    jsr      GETMODE
                    move.w   d1,S1MODE
                    move.w   d2,S2MODE
PLAY:               move.w   #$23,DANGER
                    bsr      PLAYINIT
                    tst.w    ABORT
                    beq      _DO_GAME
                    clr.w    ABORT
                    bra.b    DEVICE

_DO_GAME:           bsr      DO_GAME
                    bra.b    PLAY

READALL:            lea      SPYPIX,a0
                    bsr      READPIX
                    move.l   BACK,a0
                    move.w   #0,d1
                    move.w   #0,d2
                    lea      BUF11,a1
                    bsr      GRABBIG
                    move.w   #8,d1
                    move.w   #0,d2
                    lea      BUF12,a1
                    bsr      GRABBIG
                    move.w   #0,d1
                    move.w   #42,d2
                    lea      BUF13,a1
                    bsr      GRABBIG
                    move.w   #8,d1
                    move.w   #42,d2
                    lea      BUF14,a1
                    bsr      GRABBIG
                    move.w   #16,d1
                    move.w   #83,d2
                    lea      BUF16,a1
                    move.w   #2,d6
                    move.w   #30,d7
                    jsr      RSAVE_BUFF
                    move.w   #0,d1
                    move.w   #83,d2
                    lea      BUF21,a1
                    bsr      GRABBIG
                    move.w   #8,d1
                    move.w   #83,d2
                    lea      BUF22,a1
                    bsr      GRABBIG
                    move.w   #0,d1
                    move.w   #124,d2
                    lea      BUF23,a1
                    bsr      GRABBIG
                    move.w   #8,d1
                    move.w   #124,d2
                    lea      BUF24,a1
                    bsr      GRABBIG
                    move.w   #16,d1
                    move.w   #124,d2
                    lea      BUF26,a1
                    move.w   #2,d6
                    move.w   #30,d7
                    jsr      RSAVE_BUFF
                    move.w   #30,d7
                    move.w   #2,d6
                    move.w   #83,d2
                    move.w   #18,d1
                    lea      BUFWL1,a1
                    jsr      RSAVE_BUFF
                    lea      BUFWL2,a1
                    move.w   #168,d2
                    move.w   #4,d1
                    bsr      RSAVE_BUFF
                    move.w   #6,d1
                    lea      BUFWL3,a1
                    bsr      RSAVE_BUFF
                    move.w   #30,d7
                    move.w   #2,d6
                    move.w   #83,d2
                    move.w   #16,d1
                    lea      BUFWR1,a1
                    jsr      RSAVE_BUFF
                    lea      BUFWR2,a1
                    move.w   #168,d2
                    move.w   #0,d1
                    bsr      RSAVE_BUFF
                    move.w   #2,d1
                    lea      BUFWR3,a1
                    bsr      RSAVE_BUFF
                    move.w   #30,d7
                    move.w   #2,d6
                    move.w   #124,d2
                    move.w   #18,d1
                    lea      BUFBL1,a1
                    jsr      RSAVE_BUFF
                    lea      BUFBL2,a1
                    move.w   #168,d2
                    move.w   #12,d1
                    bsr      RSAVE_BUFF
                    move.w   #14,d1
                    lea      BUFBL3,a1
                    bsr      RSAVE_BUFF
                    move.w   #30,d7
                    move.w   #2,d6
                    move.w   #124,d2
                    move.w   #16,d1
                    lea      BUFBR1,a1
                    jsr      RSAVE_BUFF
                    lea      BUFBR2,a1
                    move.w   #168,d2
                    move.w   #8,d1
                    bsr      RSAVE_BUFF
                    move.w   #10,d1
                    lea      BUFBR3,a1
                    bsr      RSAVE_BUFF
                    move.l   #SPYPIX2,a0
                    bsr      READPIX
                    move.l   BACK,a0
                    move.w   #51,d2
                    move.w   #4,d1
                    lea      WLAUGH1,a1
                    bsr      RSAVE_BUFF
                    move.w   #6,d1
                    lea      WLAUGH2,a1
                    bsr      RSAVE_BUFF
                    move.w   #129,d2
                    move.w   #4,d1
                    lea      BLAUGH1,a1
                    bsr      RSAVE_BUFF
                    move.w   #6,d1
                    lea      BLAUGH2,a1
                    bsr      RSAVE_BUFF
                    move.w   #0,d1
                    move.w   #0,d2
                    lea      WSPYSAT,a1
                    move.w   #30,d7
                    move.w   #2,d6
                    bsr      RSAVE_BUFF
                    move.w   #2,d1
                    lea      BSPYSAT,a1
                    bsr      RSAVE_BUFF
                    move.w   #41,d7
                    move.w   #0,d2
                    lea      WPOURR1,a1
                    move.w   #6,d1
                    bsr      RSAVE_BUFF
                    lea      WPOURR2,a1
                    move.w   #4,d1
                    bsr      RSAVE_BUFF
                    move.w   #8,d1
                    lea      WPOURL1,a1
                    bsr      RSAVE_BUFF
                    move.w   #10,d1
                    lea      WPOURL2,a1
                    bsr      RSAVE_BUFF
                    move.w   #85,d2
                    lea      BPOURR1,a1
                    move.w   #2,d1
                    bsr      RSAVE_BUFF
                    lea      BPOURR2,a1
                    move.w   #0,d1
                    bsr      RSAVE_BUFF
                    move.w   #4,d1
                    lea      BPOURL1,a1
                    bsr      RSAVE_BUFF
                    move.w   #6,d1
                    lea      BPOURL2,a1
                    bsr      RSAVE_BUFF
                    move.w   #8,d1
                    move.w   #41,d7
                    move.w   #85,d2
                    lea      WSAWR1,a1
                    bsr      RSAVE_BUFF
                    lea      WSAWR2,a1
                    move.w   #10,d1
                    bsr      RSAVE_BUFF
                    move.w   #12,d1
                    lea      WSAWL1,a1
                    bsr      RSAVE_BUFF
                    move.w   #14,d1
                    lea      WSAWL2,a1
                    bsr      RSAVE_BUFF
                    move.w   #158,d2
                    lea      BSAWR1,a1
                    move.w   #0,d1
                    bsr      RSAVE_BUFF
                    lea      BSAWR2,a1
                    move.w   #2,d1
                    bsr      RSAVE_BUFF
                    move.w   #4,d1
                    lea      BSAWL1,a1
                    bsr      RSAVE_BUFF
                    move.w   #6,d1
                    lea      BSAWL2,a1
                    bsr      RSAVE_BUFF
                    move.w   #8,d1
                    move.w   #41,d7
                    move.w   #159,d2
                    lea      WPICKR1,a1
                    bsr      RSAVE_BUFF
                    lea      WPICKR2,a1
                    move.w   #10,d1
                    bsr      RSAVE_BUFF
                    move.w   #12,d1
                    lea      WPICKL1,a1
                    bsr      RSAVE_BUFF
                    move.w   #14,d1
                    lea      WPICKL2,a1
                    bsr      RSAVE_BUFF
                    move.w   #1,d2
                    lea      BPICKR1,a1
                    move.w   #12,d1
                    bsr      RSAVE_BUFF
                    lea      BPICKR2,a1
                    move.w   #14,d1
                    bsr      RSAVE_BUFF
                    move.w   #51,d2
                    move.w   #12,d1
                    lea      BPICKL1,a1
                    bsr      RSAVE_BUFF
                    move.w   #14,d1
                    lea      BPICKL2,a1
                    bsr      RSAVE_BUFF
                    move.w   #10,d1
                    move.w   #128,d2
                    lea      WHOLE1,a1
                    bsr      RSAVE_BUFF
                    move.w   #12,d1
                    lea      HOLE2,a1
                    bsr      RSAVE_BUFF
                    move.w   #18,d1
                    lea      HOLE3,a1
                    bsr      RSAVE_BUFF
                    move.w   #16,d1
                    lea      HOLE4,a1
                    bsr      RSAVE_BUFF
                    move.w   #14,d1
                    lea      HOLE5,a1
                    bsr      RSAVE_BUFF
                    move.w   #16,d1
                    move.w   #85,d2
                    lea      BHOLE1,a1
                    bsr      RSAVE_BUFF
                    move.w   #0,d1
                    move.w   #4,d2
                    lea      BUF17,a1
                    bsr      GRAB
                    move.w   #8,d1
                    move.w   #4,d2
                    lea      BUF18,a1
                    bsr      GRAB
                    move.w   #2,d1
                    move.w   #47,d2
                    lea      BUF19,a1
                    bsr      GRAB1
                    move.w   #10,d1
                    move.w   #47,d2
                    lea      BUF1A,a1
                    bsr      GRAB1
                    move.w   #0,d1
                    move.w   #82,d2
                    lea      BUF27,a1
                    bsr      GRAB
                    move.w   #8,d1
                    move.w   #82,d2
                    lea      BUF28,a1
                    bsr      GRAB
                    move.w   #2,d1
                    move.w   #124,d2
                    lea      BUF29,a1
                    bsr      GRAB1
                    move.w   #8,d1
                    move.w   #124,d2
                    lea      BUF2A,a1
                    bsr      GRAB1
                    move.w   #12,d2
                    move.w   #16,d1
                    move.w   #2,d6
                    move.w   #41,d7
                    lea      BUF1D,a1
                    jsr      RSAVE_BUFF
                    move.w   #12,d2
                    move.w   #18,d1
                    move.w   #2,d6
                    move.w   #41,d7
                    lea      lbL019EF8,a1
                    jsr      RSAVE_BUFF
                    move.w   #51,d2
                    move.w   #16,d1
                    move.w   #2,d6
                    move.w   #41,d7
                    move.l   #BUF2D,a1
                    jsr      RSAVE_BUFF
                    move.w   #51,d2
                    move.w   #18,d1
                    move.w   #2,d6
                    move.w   #41,d7
                    lea      lbL01D420,a1
                    jsr      RSAVE_BUFF
                    lea      GRAVE,a1
                    move.w   #16,d1
                    move.w   #159,d2
                    move.w   #2,d6
                    move.w   #41,d7
                    jsr      RSAVE_BUFF
                    move.w   #120,d2
                    move.w   #0,d1
                    move.w   #1,d6
                    move.w   #8,d7
                    lea      MAPBOX,a1
                    jsr      RSAVE_BUFF
                    move.w   #128,d2
                    move.w   #0,d1
                    move.w   #1,d6
                    move.w   #8,d7
                    lea      MAPSPOT,a1
                    jsr      RSAVE_BUFF
                    move.w   #2,d1
                    lea      480(a1),a1
                    jsr      RSAVE_BUFF
                    lea      LANDPIX,a0
                    bsr      READPIX
                    move.l   BACK,a0
                    move.w   #0,d1
                    move.w   #3,d2
                    move.l   #LAND,a1
                    bsr      GRABLAND
                    move.w   #0,d1
                    move.w   #69,d2
                    bsr      GRABLAND
                    move.w   #0,d1
                    move.w   #135,d2
                    bsr      GRABLAND
                    movem.l  a0/a1,-(sp)
                    lea      LANDPIX3,a0
                    bsr      READPIX
                    movem.l  (sp)+,a0/a1
                    move.w   #0,d1
                    move.w   #136,d2
                    move.w   #14,d3
                    bsr      GRABLAND2
                    move.w   #2,d6
                    move.w   #74,d7
                    move.w   #124,d2
                    move.w   #15,d1
                    lea      WROCKET1,a1
                    bsr      RSAVE_BUFF
                    move.w   #17,d1
                    lea      WROCKET2,a1
                    bsr      RSAVE_BUFF
                    move.w   #39,d2
                    move.w   #15,d1
                    lea      BROCKET1,a1
                    bsr      RSAVE_BUFF
                    move.w   #17,d1
                    lea      BROCKET2,a1
                    bsr      RSAVE_BUFF
                    move.w   #2,d6
                    move.w   #41,d7
                    move.w   #67,d2
                    move.w   #0,d1
                    lea      WICICLED1,a1
                    bsr      RSAVE_BUFF
                    move.w   #2,d1
                    lea      WICICLED2,a1
                    bsr      RSAVE_BUFF
                    move.w   #4,d1
                    lea      WICICLED3,a1
                    bsr      RSAVE_BUFF
                    move.w   #2,d6
                    move.w   #41,d7
                    move.w   #100,d2
                    move.w   #0,d1
                    lea      BICICLED1,a1
                    bsr      RSAVE_BUFF
                    move.w   #2,d1
                    lea      BICICLED2,a1
                    bsr      RSAVE_BUFF
                    move.w   #4,d1
                    lea      BICICLED3,a1
                    bsr      RSAVE_BUFF
                    move.w   #0,d1
                    move.w   #$25,d2
                    lea      WPLUNGER1,a1
                    bsr      RSAVE_BUFF
                    move.w   #2,d1
                    lea      WPLUNGER2,a1
                    bsr      RSAVE_BUFF
                    move.w   #6,d1
                    lea      WPLUNGEL1,a1
                    bsr      RSAVE_BUFF
                    move.w   #4,d1
                    lea      WPLUNGEL2,a1
                    bsr      RSAVE_BUFF
                    move.w   #0,d1
                    move.w   #0,d2
                    lea      BPLUNGER1,a1
                    bsr      RSAVE_BUFF
                    move.w   #2,d1
                    lea      BPLUNGER2,a1
                    bsr      RSAVE_BUFF
                    move.w   #6,d1
                    lea      BPLUNGEL1,a1
                    bsr      RSAVE_BUFF
                    move.w   #4,d1
                    lea      BPLUNGEL2,a1
                    bsr      RSAVE_BUFF
                    move.w   #36,d2
                    move.w   #8,d1
                    lea      WBLUP1,a1
                    bsr      RSAVE_BUFF
                    move.w   #10,d1
                    lea      WBLUP2,a1
                    bsr      RSAVE_BUFF
                    move.w   #12,d1
                    lea      WBLUP3,a1
                    bsr      RSAVE_BUFF
                    move.w   #66,d2
                    move.w   #8,d1
                    lea      BBLUP1,a1
                    bsr      RSAVE_BUFF
                    move.w   #10,d1
                    lea      BBLUP2,a1
                    bsr      RSAVE_BUFF
                    move.w   #12,d1
                    lea      BBLUP3,a1
                    bsr      RSAVE_BUFF
                    movem.l  a0/a1,-(sp)
                    lea      LANDPIX2,a0
                    bsr      READPIX
                    movem.l  (sp)+,a0/a1
                    move.w   #10,d6
                    move.w   #32,d7
                    move.w   #0,d1
                    move.w   #0,d2
                    lea      SNOWSLAB,a1
                    jsr      RSAVE_BUFF
                    move.w   #10,d6
                    move.w   #32,d7
                    move.w   #0,d1
                    move.w   #33,d2
                    lea      SLEETSLAB,a1
                    jsr      RSAVE_BUFF
                    move.w   #10,d6
                    move.w   #32,d7
                    move.w   #0,d1
                    move.w   #67,d2
                    lea      DRYSLAB,a1
                    jsr      RSAVE_BUFF
                    move.w   #1,d6
                    move.w   #110,d2
                    move.w   #0,d1
                    move.w   #3,d7
                    lea      G_EMPTY,a1
                    jsr      RSAVE_BUFF
                    lea      G_FULL,a1
                    move.w   #114,d2
                    jsr      RSAVE_BUFF
                    lea      G_SNOWBALL,a1
                    move.w   #10,d1
                    move.w   #153,d2
                    move.w   #5,d7
                    bsr      RSAVE_BUFF
                    bsr      READ_G
                    lea      MAPPIX,a0
                    bsr      READPIX
                    move.l   BACK,a0
                    move.w   #0,d1
                    move.w   #0,d2
                    lea      MAPS,a1
                    bsr      GRABMAP
                    add.w    #7,d1
                    move.w   #0,d2
                    bsr      GRABMAP
                    move.w   #3,d6
                    move.w   #21,d7
                    move.w   #1,d2
                    move.w   #13,d1
                    lea      GO_H,a1
                    bsr      RSAVE_BUFF
                    move.w   #16,d1
                    lea      GO_D,a1
                    bsr      RSAVE_BUFF
                    move.w   #7,d7
                    move.w   #13,d1
                    move.w   #22,d2
                    lea      SHOW_H,a1
                    bsr      RSAVE_BUFF
                    move.w   #16,d1
                    lea      SHOW_D,a1
                    bsr      RSAVE_BUFF
                    move.w   #13,d1
                    move.w   #30,d2
                    lea      HIDE_H,a1
                    bsr      RSAVE_BUFF
                    move.w   #16,d1
                    lea      HIDE_D,a1
                    bsr      RSAVE_BUFF
                    move.w   #2,d6
                    move.w   #28,d7
                    move.w   #13,d1
                    move.w   #42,d2
                    lea      MISSILE_H,a1
                    bsr      RSAVE_BUFF
                    move.w   #15,d1
                    lea      MISSILE_D,a1
                    bsr      RSAVE_BUFF
                    move.w   #29,d7
                    move.w   #13,d1
                    move.w   #106,d2
                    lea      WSPY_D,a1
                    bsr      RSAVE_BUFF
                    move.w   #15,d1
                    lea      BSPY_D,a1
                    bsr      RSAVE_BUFF
                    move.w   #13,d1
                    move.w   #140,d2
                    lea      WSPY_H,a1
                    bsr      RSAVE_BUFF
                    move.w   #15,d1
                    lea      BSPY_H,a1
                    bsr      RSAVE_BUFF
                    move.w   #18,d1
                    move.w   #107,d2
                    move.w   #30,d7
                    move.w   #2,d6
                    lea      COMP_H,a1
                    bsr      RSAVE_BUFF
                    move.w   #138,d2
                    lea      COMP_D,a1
                    bsr      RSAVE_BUFF
                    lea      NUMS,a1
                    move.w   #0,d1
                    move.w   #175,d2
                    move.w   #1,d6
                    move.w   #6,d7
                    bsr      RSAVE_BUFF
                    lea      48(a1),a1
                    addq.w   #1,d1
                    bsr      RSAVE_BUFF
                    lea      48(a1),a1
                    addq.w   #1,d1
                    bsr      RSAVE_BUFF
                    lea      48(a1),a1
                    addq.w   #1,d1
                    bsr      RSAVE_BUFF
                    lea      48(a1),a1
                    addq.w   #1,d1
                    bsr      RSAVE_BUFF
                    lea      BACKPIX,a0
                    bsr      READPIX
                    move.l   BACK,a0
                    move.w   #14,d1
                    move.w   #10,d2
                    lea      RTCOVER,a1
                    move.w   #64,d7
                    move.w   #2,d6
                    bsr      RSAVE_BUFF
                    move.w   #6,d1
                    move.w   #115,d2
                    move.w   #7,d6
                    move.w   #55,d7
                    lea      CONTROLS,a1
                    bsr      RSAVE_BUFF
                    move.w   #96,d1
                    move.w   #115,d2
                    move.w   #9,d6
                    move.w   #55,d7
                    bsr      RCLEARBLOCK
                    move.w   #3,d1
                    move.w   #9,d2
                    move.w   #1,d6
                    move.w   #65,d7
                    lea      STRENGTH_FULL,a1
                    bsr      RSAVE_BUFF
                    move.w   #3,d1
                    move.w   #110,d2
                    move.w   #1,d6
                    move.w   #65,d7
                    lea      STRENGTH_EMPTY,a1
                    bsr      RSAVE_BUFF
                    move.w   #4,d6
                    move.w   #11,d7
                    move.w   #1,d1
                    move.w   #83,d2
                    lea      G_HOLD_BACK,a1
                    bsr      RSAVE_BUFF
                    lea      SPY2PICA,a0
                    bsr      READPIX
                    move.l   BACK,a0
                    lea      BACKPIX,a0
                    bsr      READPIX
                    move.l   BACK,a0
                    move.w   #96,d1
                    move.w   #115,d2
                    move.w   #9,d6
                    move.w   #53,d7
                    bra      RCLEARBLOCK

MYINT3:             addq.w   #1,FERDINAND
                    clr.w    INT_REQ
                    move.w   #$70,$DFF09C
                    rte

GRAB:               move.w   #4-1,d3
.LOOP:              move.w   #2,d6
                    move.w   #$1E,d7
                    bsr      RSAVE_BUFF
                    lea      480(a1),a1
                    addq.w   #2,d1
                    dbra     d3,.LOOP
                    rts

GRABBIG:            move.w   #4-1,d3
.LOOP:              move.w   #2,d6
                    move.w   #$29,d7
                    bsr      RSAVE_BUFF
                    lea      656(a1),a1
                    addq.w   #2,d1
                    dbra     d3,.LOOP
                    rts

GRAB1:              move.w   #2,d6
                    move.w   #$1E,d7
                    bsr      RSAVE_BUFF
                    lea      480(a1),a1
                    addq.w   #2,d1
                    rts

GRABOBJ:            move.w   #20-1,d3
GRABOBJ1:           move.w   #1,d6
                    move.w   #8,d7
                    bsr      RSAVE_BUFF
                    lea      64(a1),a1
                    addq.w   #1,d1
                    dbra     d3,GRABOBJ1
                    rts

GRABLAND:           move.w   #20-1,d3
GRABLAND2:          move.w   #$40,d7
                    move.w   #1,d6
                    bsr      RSTUFF_BUFF_SHORT
                    lea      520(a1),a1
                    addq.w   #1,d1
                    dbra     d3,GRABLAND2
                    rts

GRABMAP:            move.w   #4-1,d3
.LOOP:              move.w   #6,d6
                    move.w   #$29,d7
                    bsr      RSAVE_BUFF
                    lea      1968(a1),a1
                    add.w    #44,d2
                    dbra     d3,.LOOP
                    rts

PLAYINIT:           move.w   #2,REFRESH
                    bsr      CLEANTRAIL
                    clr.w    S1FLASH
                    clr.w    S2FLASH
                    bsr      CLEANTRAIL
                    bsr      PARMS
                    bsr      CLEANTRAIL
PLAYINIT0:          bsr      CLEANTRAIL
                    clr.w    S1MENU
                    clr.w    S2MENU
                    clr.w    S1NUDGE
                    clr.w    S2NUDGE
                    clr.w    HATCH_RAND
                    move.w   #0,S1AUTO
                    move.w   #0,S2AUTO
                    cmp.w    #1,PLAYERS
                    bne      lbC002BCC
                    move.w   #1,S2AUTO
lbC002BCC:          move.w   LEVEL,d1
                    mulu     #3840,d1
                    ; copy the map into the map place holder block
                    lea      MAP,a1
                    add.l    a1,d1
                    move.l   d1,a0
                    move.w   #(3840/2)-1,d1
PLAYINIT1:          move.w   (a0)+,(a1)+
                    dbra     d1,PLAYINIT1
                    move.w   LEVEL,d1
                    mulu     #960,d1
                    lea      TERRAIN,a0
                    move.l   a0,a1
                    add.w    d1,a0
                    move.w   #(960/4)-1,d1
lbC002C02:          move.l   (a0)+,(a1)+
                    dbra     d1,lbC002C02
                    clr.w    SNOW_LINE
                    move.l   #XROCKET,S1CHOICEX
                    move.l   #YROCKET,S1CHOICEY
                    move.l   #XROCKET,S2CHOICEX
                    move.l   #YROCKET,S2CHOICEY
                    clr.w    XROCKET
                    clr.w    YROCKET
                    clr.w    XMIDNOSE
                    clr.w    YMIDNOSE
                    clr.w    XMIDTAIL
                    clr.w    YMIDTAIL
                    move.l   #BUF11,S1FADDR
                    move.l   #BUF21,S2FADDR
                    move.w   #63,S1ENERGY
                    move.w   #63,S2ENERGY
                    move.w   #100-1,d1
                    lea      TRAPLIST,a4
.CLEAR_TRAPS:       clr.l    (a4)+
                    clr.w    (a4)+
                    dbra     d1,.CLEAR_TRAPS
                    clr.l    IN_CASE
                    move.w   #8-1,d0
                    lea      SNOW_LIST,a0
.CLEAR_SNOW:        clr.l    (a0)+
                    clr.l    (a0)+
                    clr.w    (a0)+
                    dbra     d0,.CLEAR_SNOW
                    clr.w    S1OFFSETX
                    clr.w    S2OFFSETX
                    clr.w    S1OFFSETY
                    clr.w    S2OFFSETY
                    move.w   #60,RY
                    clr.w    RHT
                    move.w   #74,RLEN
                    clr.w    S1WIN
                    clr.w    S2WIN
                    clr.w    S1ROCKET
                    clr.w    S2ROCKET
                    clr.w    S1SHCT
                    clr.w    S2SHCT
                    clr.w    S1BRAIN
                    clr.w    S2BRAIN
                    clr.w    S1CT
                    clr.w    S2CT
                    clr.w    S1DEAD
                    clr.w    S2DEAD
                    clr.w    S1SWAMP
                    clr.w    S2SWAMP
                    clr.w    S1DEPTH
                    clr.w    S2DEPTH
                    clr.w    BUF1X
                    move.w   #-1,BUF1Y
                    clr.w    BUF2X
                    move.w   #-1,BUF2Y
                    clr.w    TENMINS
                    clr.w    ONEMINS
                    clr.w    TENSECS
                    clr.w    ONESECS
                    clr.w    S1IGLOO
                    clr.w    S2IGLOO
                    clr.w    S1SNSH
                    clr.w    S2SNSH
                    clr.w    S1TNT
                    clr.w    S2TNT
                    clr.w    S1SAW
                    clr.w    S2SAW
                    clr.w    S1BUCKET
                    clr.w    S2BUCKET
                    clr.w    S1PICK
                    clr.w    S2PICK
                    clr.w    S1PLUNGER
                    clr.w    S2PLUNGER
                    clr.w    S1HAND
                    clr.w    S2HAND
                    bsr      STUFFSPY
                    move.w   #1,d1
                    move.w   #30,d2
                    bsr      STIT
                    lea      XJAR,a1
                    lea      YJAR,a2
                    bsr      SETXY
                    move.w   #1,d1
                    move.w   #22,d2
                    bsr      STIT
                    lea      XCARD,a1
                    lea      YCARD,a2
                    bsr      SETXY
                    move.w   #1,d1
                    move.w   #14,d2
                    bsr      STIT
                    lea      XCASE,a1
                    lea      YCASE,a2
                    bsr      SETXY
                    move.w   #1,d1
                    move.w   #38,d2
                    bsr      STIT
                    lea      XGYRO,a1
                    lea      YGYRO,a2
                    bsr      SETXY
                    move.w   LEVEL,d2
                    subq.w   #1,d2
                    add.w    d2,d2
                    add.w    d2,d2
                    lea      WHICHTABLE,a4
                    add.w    d2,a4
                    move.l   (a4),a4
                    move.w   (a4)+,XIGLOO1
                    move.w   (a4)+,YIGLOO1
                    move.w   (a4)+,XIGLOO2
                    move.w   (a4)+,YIGLOO2
                    bsr      GETA4
                    move.w   d1,TENMINS
                    bsr      GETA4
                    move.w   d1,ONEMINS
                    bsr      GETA4
                    move.w   d1,S1TNT
                    move.w   d1,S2TNT
                    bsr      GETA4
                    move.w   d1,S1SAW
                    move.w   d1,S2SAW
                    bsr      GETA4
                    move.w   d1,S1PICK
                    move.w   d1,S2PICK
                    bsr      GETA4
                    move.w   d1,S1SNSH
                    move.w   d2,S2SNSH
                    bsr      GETA4
                    move.w   #86,d2
                    bsr      STIT
                    bsr      GETA4
                    move.w   #46,d2
                    bsr      STIT
                    bsr      GETA4
                    move.w   #70,d2
                    bsr      STIT
                    bsr      GETA4
                    move.w   #78,d2
                    bsr      STIT
                    bsr      GETA4
                    move.w   #54,d2
                    move.w   d1,-(sp)
                    bsr      STIT
                    lea      XWBUCK,a1
                    lea      YWBUCK,a2
                    bsr      SETXY
                    move.w   #62,d2
                    move.w   (sp)+,d1
                    bsr      STIT
                    lea      XBBUCK,a1
                    lea      YBBUCK,a2
                    bsr      SETXY
                    bsr      GETA4
                    move.w   #94,d2
                    move.w   d1,-(sp)
                    bsr      STIT
                    lea      XBPLUNG,a1
                    lea      YBPLUNG,a2
                    bsr      SETXY
                    move.w   #102,d2
                    move.w   (sp)+,d1
                    bsr      STIT
                    lea      XWPLUNG,a1
                    lea      YWPLUNG,a2
                    bsr      SETXY
                    clr.l    HATCHAD
                    clr.w    XROCKET
                    clr.w    YROCKET
                    move.w   #96,MAXMAPX
                    move.w   #20,MAXMAPY
                    rts

GETA4:              clr.w    d1
                    move.b   (a4)+,d1
                    rts

WHICHTABLE:         dc.l     WHICH1
                    dc.l     WHICH2
                    dc.l     WHICH3
                    dc.l     WHICH4
                    dc.l     WHICH5
                    dc.l     WHICH6
                    dc.l     WHICH7
WHICH1:             dc.w     29,5,29,9
                    dc.b     0,6,9,1,1,1,6,0,0,0,1,1
WHICH2:             dc.w     30,5,18,9
                    dc.b     0,8,10,1,1,1,12,0,0,0,1,1
WHICH3:             dc.w     36,5,17,9
                    dc.b     1,1,10,1,1,0,20,0,0,2,1,1
WHICH4:             dc.w     30,5,48,9
                    dc.b     1,4,8,0,0,0,24,2,2,2,1,1
WHICH5:             dc.w     46,5,21,1
                    dc.b     1,8,6,0,0,0,24,2,2,2,1,1
WHICH6:             dc.w     7,5,23,9
                    dc.b     2,2,4,0,0,0,24,2,2,2,1,1
WHICH7:             dc.w     5,5,40,9
                    dc.b     2,7,2,0,0,0,20,2,2,2,1,1

READ_G:             move.w   #76-1,d0
                    lea      ITEMS_GRAPHICS,a2
                    lea      ITEMS_X,a3
                    lea      ITEMS_Y,a4
                    lea      ITEMS_HEIGHT,a5
lbC003078:          move.l   (a2)+,a1
                    move.w   (a3)+,d1
                    move.w   (a4)+,d2
                    move.w   (a5)+,d7
                    beq      lbC00308C
                    move.w   #1,d6
                    bsr      RSAVE_BUFF
lbC00308C:          dbra     d0,lbC003078
                    rts

ITEMS_GRAPHICS:     dc.l     G_MOUND
                    dc.l     G_CASE
                    dc.l     G_CARD
                    dc.l     G_URANIUM
                    dc.l     G_GYRO
                    dc.l     G_SAW
                    dc.l     G_WHITE_BUCKET
                    dc.l     G_BLACK_BUCKET
                    dc.l     G_PICKAXE
                    dc.l     G_SNOWSHOES
                    dc.l     G_TNT
                    dc.l     G_BLACK_PLUNGER
                    dc.l     G_WHITE_PLUNGER,0,0,0
                    dc.l     G_ICEHOLE
                    dc.l     G_ICEPATCH,0
                    dc.l     G_EXIT_NORTH1,0,0,0,0,0
                    dc.l     G_IGLOO_LEFT1
                    dc.l     G_IGLOO_LEFT2
                    dc.l     G_IGLOO_LEFT3
                    dc.l     G_IGLOO_LEFT4
                    dc.l     G_IGLOO_LEFT5,0,0
                    dc.l     G_IGLOO_RIGHT1
                    dc.l     G_IGLOO_RIGHT2
                    dc.l     G_IGLOO_RIGHT3
                    dc.l     G_IGLOO_RIGHT4
                    dc.l     G_IGLOO_RIGHT5
                    dc.l     G_POLAR_BEARA1
                    dc.l     G_POLAR_BEARA2
                    dc.l     G_POLAR_BEARA3
                    dc.l     G_POLAR_BEARB1
                    dc.l     G_POLAR_BEARB2
                    dc.l     G_POLAR_BEARB3
                    dc.l     G_POLAR_BEARC1
                    dc.l     G_POLAR_BEARC2
                    dc.l     G_POLAR_BEARC3,0,0,0
                    dc.l     G_EXIT_SOUTH
                    dc.l     G_EXIT_NORTH1
                    dc.l     G_EXIT_NORTH2
                    dc.l     G_EXIT_NORTH3,0
                    dc.l     G_FIREL1
                    dc.l     G_FIRER1
                    dc.l     G_FIREL2
                    dc.l     G_FIRER2
                    dc.l     G_SNOW1
                    dc.l     G_SNOW2
                    dc.l     G_SNOW3
                    dc.l     G_SNOW4
                    dc.l     G_ICE1
                    dc.l     G_ICE2
                    dc.l     G_CASE
                    dc.l     G_CARDR
                    dc.l     G_URANIUM
                    dc.l     G_GYRO
                    dc.l     G_SAWR
                    dc.l     G_WHITE_BUCKET
                    dc.l     G_BLACK_BUCKET
                    dc.l     G_PICKAXER
                    dc.l     G_SNOWSHOES
                    dc.l     G_TNTR
                    dc.l     G_BLACK_PLUNGER
                    dc.l     G_WHITE_PLUNGER
ITEMS_X:            dc.w     18,12,13,14,15,16,17,18,19,12,13,14,15,0,0,0
                    dc.w     16,17,0,5,0,0,0,0,0,13,14,15,16,17,0,0,12,13
                    dc.w     14,15,16,17,18,19,17,18,19,17,18,19,17
                    dc.w     18,19,19,5,6,7,0,16,17,18,19,0,1,2,3,5,6
                    dc.w     12,0,14,15,1,17,18,2,12,3,14,15
ITEMS_Y:            dc.w     11,0,0,0,0,0,0,0,0,12,11,11,11,0,0,0,12,11,0,101
                    dc.w     0,0,0,0,0,25,25,25,25,25,0,0,62,62,62,62
                    dc.w     62,97,97,97,109,109,109,138,138,138,92,92
                    dc.w     92,169,101,101,101,0,177,177,177,177,144,144,144
                    dc.w     144,143,143,0,100,0,0,100,0,0,100,12,100,11,11
ITEMS_HEIGHT:       dc.w     7,10,10,10,10,10,10,10,11,9,12,10,10,0,0,0,5,9,0
                    dc.w     28,0,0,0,0,0,35,35,35,35,35,0,0,35,35,35
                    dc.w     35,35,11,11,11,29,29,29,31,31,31,0,0,0,3
                    dc.w     28,28,28,0,14,14,14,14,32,32,32,32,32,32
                    dc.w     10,9,10,10,7,10,10,11,9,12,10,10
LANDPIX2:           dc.b     'gfx/land2.pi1',0
LANDPIX3:           dc.b     'gfx/pica.pi1',0
SPY2PICA:           dc.b     'gfx/spy2pica.pi1',0
                    even
INT_REQ:            dc.w     0
INT_FLAG:           dc.w     0
MY_VERY_OWN_STACK:  dc.l     0

DRAW_NEW_SEL:       move.l   SCREEN2,a0
                    move.w   #64,d1
                    move.w   #10,d2
                    move.w   #62,d7
                    move.w   #19,d6
                    bsr      RCLEARBLOCK
                    move.w   #111,d2
                    bsr      RCLEARBLOCK
                    cmp.w    #1,d3
                    bne      lbC00343E
                    move.w   d3,-(sp)
                    move.w   #14,d7
                    move.w   #95,d1
                    move.w   #21,d2
                    move.w   d1,d3
                    move.w   #63,d4
                    bsr      DRAW_LINE
                    subq.w   #1,d1
                    move.w   d1,d3
                    bsr      DRAW_LINE
                    move.w   #192,d1
                    move.w   d1,d3
                    bsr      DRAW_LINE
                    addq.w   #1,d1
                    move.w   d1,d3
                    bsr      DRAW_LINE
                    move.w   #94,d1
                    move.w   #193,d3
                    move.w   #20,d2
                    move.w   d2,d4
                    bsr      DRAW_LINE
                    subq.w   #1,d2
                    move.w   d2,d4
                    bsr      DRAW_LINE
                    move.w   #63,d2
                    move.w   d2,d4
                    bsr      DRAW_LINE
                    addq.w   #1,d2
                    move.w   d2,d4
                    bsr      DRAW_LINE
                    move.w   (sp)+,d3
lbC00343E:          move.w   LEVEL,d1
                    subq.w   #1,d1
                    mulu     #1968,d1
                    add.l    #MAPS,d1
                    move.l   d1,a1
                    move.w   #96,d1
                    move.w   #21,d2
                    move.w   #6,d6
                    move.w   #41,d7
                    bsr      RSPRITER
                    move.w   #2,d6
                    move.w   #29,d7
                    move.w   #64,d1
                    move.w   #130,d2
                    lea      WSPY_D,a1
                    cmp.w    #2,d3
                    bne      _RSPRITER
                    lea      WSPY_H,a1
_RSPRITER:          bsr      RSPRITER
                    cmp.w    #2,PLAYERS
                    bne      lbC0034BA
                    move.w   #96,d1
                    move.w   #130,d2
                    lea      BSPY_D,a1
                    cmp.w    #2,d3
                    bne      _RSPRITER0
                    lea      BSPY_H,a1
_RSPRITER0:         bsr      RSPRITER
lbC0034BA:          move.w   #28,d7
                    move.w   #136,d1
                    move.w   #112,d2
                    lea      MISSILE_D,a1
                    cmp.w    #3,d3
                    bne      _RSPRITER1
                    lea      MISSILE_H,a1
_RSPRITER1:         bsr      RSPRITER
                    move.w   #128,d1
                    move.w   #141,d2
                    move.w   #3,d6
                    move.w   #7,d7
                    cmp.w    #3,d3
                    beq      lbC003510
                    lea      HIDE_D,a1
                    tst.w    DRAWSUB
                    beq      _RSPRITER2
                    lea      SHOW_D,a1
                    bra      _RSPRITER2

lbC003510:          lea      HIDE_H,a1
                    tst.w    DRAWSUB
                    beq      _RSPRITER2
                    lea      SHOW_H,a1
_RSPRITER2:         bsr      RSPRITER
                    move.w   #184,d1
                    move.w   #127,d2
                    move.w   #30,d7
                    move.w   #2,d6
                    lea      COMP_D,a1
                    cmp.w    #4,d3
                    bne      _RSPRITER3
                    lea      COMP_H,a1
_RSPRITER3:         bsr      RSPRITER
                    move.w   IQ,d6
                    subq.w   #1,d6
                    mulu     #48,d6
                    lea      NUMS,a1
                    add.w    d6,a1
                    move.w   #1,d6
                    move.w   #198,d1
                    move.w   #144,d2
                    move.w   #6,d7
                    bsr      RSPRITER
                    move.w   #128,d1
                    move.w   #152,d2
                    move.w   #3,d6
                    move.w   #21,d7
                    lea      GO_D,a1
                    cmp.w    #5,d3
                    bne      _RSPRITER4
                    lea      GO_H,a1
_RSPRITER4:         bsr      RSPRITER
                    bra      SWAPSCREEN

PARMS:              clr.w    INT_REQ
                    clr.w    SOUNDNUM
                    clr.w    SOUNDCT
                    moveq    #7,d7
                    bsr      NEW_SOUND
                    clr.w    DEMO
                    clr.w    S1AUTO
                    clr.w    S2AUTO
                    clr.w    S1DEAD
                    clr.w    S2DEAD
                    move.w   #5,d3
                    move.w   #(200*40)-1,d0
                    move.l   SCREEN2,a0
                    move.l   SCREEN1,a1
lbC0035F8:          move.l   (a0)+,(a1)+
                    dbra     d0,lbC0035F8
PARMS1:             bsr      READ_TRIGS
                    move.w   COUNTER,d1
                    and.w    #3,d1
                    beq      PARMS1_0_1
                    cmp.w    #2,d1
                    beq      PARMS1_0_2
                    bra      PARMSEND

PARMS1_0_1:         moveq    #0,d0
                    move.w   d3,-(sp)
                    bsr      JOYMOVE
                    move.w   (sp)+,d3
                    bra      PARMS1_0_3

PARMS1_0_2:         move.w   #1,d0
                    move.w   d3,-(sp)
                    bsr      JOYMOVE
                    move.w   (sp)+,d3
PARMS1_0_3:         tst.w    d2
                    bne      PARMS1_5
                    tst.w    d1
                    beq      PARMS2
                    bmi      PARMS1_3
                    moveq    #7,d7
                    bsr      NEW_SOUND
                    clr.w    DEMO
                    move.w   #4,d3
                    bra      PARMS2

PARMS1_3:           moveq    #7,d7
                    bsr      NEW_SOUND
                    clr.w    DEMO
                    move.w   #2,d3
                    bra      PARMS2

PARMS1_5:           bmi      PARMS1_6
                    moveq    #7,d7
                    bsr      NEW_SOUND
                    clr.w    DEMO
                    cmp.w    #1,d3
                    bne      lbC00369A
                    move.w   #3,d3
                    bra      PARMS2

lbC00369A:          move.w   #5,d3
                    bra      PARMS2

PARMS1_6:           moveq    #7,d7
                    bsr      NEW_SOUND
                    clr.w    DEMO
                    cmp.w    #3,d3
                    bne      lbC0036C2
                    move.w   #1,d3
                    bra      PARMS2

lbC0036C2:          cmp.w    #1,d3
                    beq      PARMS2
                    move.w   #3,d3
PARMS2:             tst.w    JOY1TRIG
                    bne      PARMS2_1
                    tst.w    JOY2TRIG
                    beq      PARMSEND
PARMS2_1:           clr.w    DEMO
                    moveq    #1,d7
                    bsr      NEW_SOUND
                    cmp.w    #1,d3
                    bne      PARMS2_2
                    addq.w   #1,LEVEL
                    cmp.w    #8,LEVEL
                    blt      PARMSEND
                    move.w   #1,LEVEL
                    bra      PARMSEND

PARMS2_2:           cmp.w    #2,d3
                    bne      PARMS2_3
                    cmp.w    #1,PLAYERS
                    beq      lbC003738
                    move.w   #1,PLAYERS
                    bra      PARMSEND

lbC003738:          move.w   #2,PLAYERS
                    bra      PARMSEND

PARMS2_3:           cmp.w    #3,d3
                    bne      PARMS2_4
                    eor.w    #-1,DRAWSUB
                    bra      PARMSEND

PARMS2_4:           cmp.w    #4,d3
                    bne      PARMS2_5
                    addq.w   #1,IQ
                    cmp.w    #6,IQ
                    bne      PARMSEND
                    move.w   #1,IQ
                    bra      PARMSEND

PARMS2_5:           bra      PARMSRET

PARMSEND:           bsr      DRAW_NEW_SEL
                    addq.w   #1,DEMO
                    add.w    #1,COUNTER
                    cmp.w    #400,DEMO
                    bne      lbC0037D2
                    bsr      PLAYINIT0
                    move.w   #1,S1AUTO
                    move.w   #1,S2AUTO
                    movem.l  d0-d7/a0-a6,-(sp)
                    bsr      CLEANTRAIL
                    bsr      DO_GAME
                    movem.l  (sp)+,d0-d7/a0-a6
                    move.w   #1,d3
                    clr.w    DEMO
                    bra      PARMS

lbC0037D2:          tst.w    ABORT
                    bne      PARMSRET
                    bra      PARMS1

PARMSRET:           clr.w    DEMO
                    rts

DO_GAME:            bsr      CLEAROUTCRAP
                    move.l   #DRYSLAB,CURRENT_SNOW
                    move.l   #DRYSLAB,PREVIOUS_SNOW
                    clr.w    SNOW_CHANGE
                    move.w   #$700,S1CT
                    move.w   #$700,S2CT
                    move.w   #4,COUNTER
                    clr.w    B1TIME
                    clr.w    B2TIME
DO_GAME_AGAIN:      move.w   HATCH_RAND,d6
                    tst.l    HATCHAD
                    bne      lbC0038D0
                    tst.w    DRAWSUB
                    bne      lbC00385A
                    move.b   IN_CASE,d1
                    and.b    lbB00B239,d1
                    and.b    lbB00B23A,d1
                    beq      lbC0038D0
lbC00385A:          lea      MAP+(288*2),a1
                    move.w   #5-1,d3
lbC003864:          move.l   a1,a0
                    move.w   #64-1,d4
_RNDER:             bsr      RNDER
                    and.w    #$1F,d0
                    cmp.w    d6,d0
                    bgt      lbC00388E
                    tst.w    (a0)
                    bne      lbC00388E
                    tst.w    2(a0)
                    bne      lbC00388E
                    tst.w    4(a0)
                    beq      lbC0038A6
lbC00388E:          addq.w   #2,a0
                    dbra     d4,_RNDER
                    add.w    #$300,a1
                    dbra     d3,lbC003864
                    addq.w   #1,HATCH_RAND
                    bra      lbC0038D0

lbC0038A6:          move.w   #$128,(a0)
                    move.w   #$130,2(a0)
                    move.w   #$138,4(a0)
                    lea      2(a0),a0
                    move.l   a0,HATCHAD
                    lea      XHATCH,a1
                    lea      YHATCH,a2
                    bsr      SETXY
lbC0038D0:          tst.w    S1CT
                    bne      NO_SHOW_HATCH
                    tst.w    S2CT
                    bne      NO_SHOW_HATCH
                    tst.l    HATCHAD
                    beq      NO_SHOW_HATCH
                    move.l   HATCHAD,a0
                    move.w   #$128,-2(a0)
                    move.w   #$130,(a0)
                    move.w   #$138,2(a0)
NO_SHOW_HATCH:      tst.w    ABORT
                    beq      lbC003916
                    clr.w    ABORT
                    rts

lbC003916:          cmp.w    #$1B1,IGGY
                    bne      lbC00392E
                    move.w   #$1C1,IGGY
                    bra      lbC003936

lbC00392E:          move.w   #$1B1,IGGY
lbC003936:          clr.w    FEET_FLAG
                    move.w   #0,d0
                    clr.w    DONE_MOVE
                    move.w   S1CT,d1
                    bsr      BUSY
DO1_0:              move.w   S1MAPX,SPYX
                    move.w   S1MAPY,SPYY
                    bsr      SETWINDOW
                    move.w   S1CT,OLD_BUSY
                    tst.w    S1CT
                    bne      _CHECKMEET
                    tst.w    JOY1TRIG
                    bne      _CHECKMEET
                    tst.w    S1ROCKET
                    bne      _CHECKMEET
                    move.w   COUNTER,d7
                    and.w    #1,d7
                    bne      lbC0039DE
                    tst.w    S1SWAMP
                    bne      _CHECKMEET
                    tst.w    TENMINS
                    bne      lbC0039DE
                    tst.w    ONEMINS
                    bne      lbC0039DE
                    tst.w    S1IGLOO
                    bne      lbC0039DE
                    move.w   COUNTER,d7
                    and.w    #3,d7
                    bne      _CHECKMEET
                    subq.w   #1,S1ENERGY
                    bra      _CHECKMEET

lbC0039DE:          move.w   #-1,DONE_MOVE
                    bsr      MOVE
                    move.w   SPYX,S1MAPX
                    move.w   SPYY,S1MAPY
_CHECKMEET:         bsr      CHECKMEET
                    move.w   SPYX,d1
                    lsr.w    #2,d1
                    move.w   d1,S1CELLX
                    move.w   SPYY,d1
                    lsr.w    #2,d1
                    move.w   d1,S1CELLY
                    bsr      GETWINDOW
                    tst.w    DONE_MOVE
                    beq      DO2_0
                    tst.w    OLD_BUSY
                    bne      DO2_0
                    tst.w    S1DEAD
                    bne      DO2_0
                    bsr      DIRFIX
                    tst.w    JOY1TRIG
                    beq      DO2_0
                    clr.w    S1F
DO2_0:              move.w   #1,d0
                    clr.w    DONE_MOVE
                    move.w   S2CT,d1
                    bsr      BUSY
                    move.w   S2CT,OLD_BUSY
DO2_1:              move.w   S2MAPX,SPYX
                    move.w   S2MAPY,SPYY
                    bsr      SETWINDOW
                    tst.w    S2CT
                    bne      _CHECKMEET0
                    tst.w    JOY2TRIG
                    bne      _CHECKMEET0
                    tst.w    S2ROCKET
                    bne      _CHECKMEET0
                    move.w   COUNTER,d7
                    and.w    #1,d7
                    bne      lbC003AF6
                    tst.w    S2SWAMP
                    bne      _CHECKMEET0
                    tst.w    TENMINS
                    bne      lbC003AF6
                    tst.w    ONEMINS
                    bne      lbC003AF6
                    tst.w    S2IGLOO
                    bne      lbC003AF6
                    move.w   COUNTER,d7
                    and.w    #3,d7
                    bne      _CHECKMEET0
                    subq.w   #1,S2ENERGY
                    bra      _CHECKMEET0

lbC003AF6:          move.w   #-1,DONE_MOVE
                    bsr      MOVE
                    move.w   SPYX,S2MAPX
                    move.w   SPYY,S2MAPY
_CHECKMEET0:        bsr      CHECKMEET
                    move.w   SPYX,d1
                    lsr.w    #2,d1
                    move.w   d1,S2CELLX
                    move.w   SPYY,d1
                    lsr.w    #2,d1
                    move.w   d1,S2CELLY
                    bsr      GETWINDOW
                    tst.w    DONE_MOVE
                    beq      DO3_0
                    tst.w    OLD_BUSY
                    bne      DO3_0
                    tst.w    S2DEAD
                    bne      DO3_0
                    bsr      DIRFIX
                    tst.w    JOY2TRIG
                    beq      DO3_0
                    clr.w    S2F
DO3_0:              bsr      DRAWMOVE
                    move.w   S1CT,d1
                    move.w   d1,d2
                    lsr.w    #8,d2
                    and.w    #$FF,d1
                    cmp.w    #5,d2
                    bne      lbC003B8C
                    clr.w    d0
                    bsr      BUSY5_0
lbC003B8C:          move.w   S2CT,d1
                    move.w   d1,d2
                    lsr.w    #8,d2
                    and.w    #$FF,d1
                    cmp.w    #5,d2
                    bne      _SWAPSCREEN
                    move.w   #1,d0
                    bsr      BUSY5_0
_SWAPSCREEN:        bsr      SWAPSCREEN
WAITFLY:            cmp.w    #6,FERDINAND
                    blt.b    WAITFLY
                    clr.w    FERDINAND
                    move.w   #7,d1
                    and.w    COUNTER,d1
                    bne      DO4_0
                    tst.w    TENMINS
                    bne      lbC003BFC
                    tst.w    ONEMINS
                    bne      lbC003BFC
                    move.l   #8,d7
                    bsr      NEW_SOUND
                    move.w   TENSECS,d1
                    or.w     ONESECS,d1
                    beq      DO4_0
lbC003BFC:          subq.w   #1,ONESECS
                    bge      DO4_0
                    move.w   #9,ONESECS
                    subq.w   #1,TENSECS
                    bge      DO4_0
                    move.w   #5,TENSECS
                    subq.w   #1,ONEMINS
                    bge      DO4_0
                    move.w   #9,ONEMINS
                    subq.w   #1,TENMINS
DO4_0:              move.w   S1DEAD,d1
                    add.w    S2DEAD,d1
                    cmp.w    #2,d1
                    bne      lbC003C5C
                    move.w   S1CT,d1
                    or.w     S2CT,d1
                    beq      TIMEGONE
lbC003C5C:          move.w   TENMINS,d1
                    add.w    ONEMINS,d1
                    add.w    TENSECS,d1
                    add.w    ONESECS,d1
                    beq      TIMEGONE
                    addq.w   #1,COUNTER
                    tst.w    RLEN
                    bne      DO_GAMEEND
                    clr.w    TENMINS
                    clr.w    ONEMINS
                    clr.w    TENSECS
                    clr.w    ONESECS
                    rts

DO_GAMEEND:         cmp.w    #40,DEMO
                    bne      lbC003CB8
                    rts

lbC003CB8:          clr.w    LOOPTIME
                    bra      DO_GAME_AGAIN

TIMEGONE:           rts

READPIX:            move.l   a0,d1
                    move.l   SCREEN2,d2
                    jsr      DECO_PIC
                    move.l   SCREEN2,a0
                    lea      128(a0),a0
                    move.l   BACK,a1
                    jsr      ATARI_COPY
                    move.l   SCREEN2,a0
                    addq.w   #4,a0
                    move.w   (a0),d7
                    jmp      COLOUR_COPY

STIT:               tst.w    d1
                    beq      STUFFITEND
                    bsr      GETRAND
                    move.w   d2,(a0)
                    subq.w   #1,d1
                    addq.w   #1,COUNTER
                    bra.b    STIT

STUFFITEND:         rts

STUFFSPY:           movem.l  d0-d5,-(sp)
STUFFSPY0:          bsr      GETRAND
                    lea      S1MAPX,a1
                    lea      S1MAPY,a2
                    bsr      SETXY
                    move.w   S1MAPX,d5
                    add.w    d5,d5
                    add.w    d5,d5
                    addq.w   #1,d5
                    move.w   d5,S1MAPX
                    move.w   S1MAPY,d0
                    add.w    d0,d0
                    add.w    d0,d0
                    move.w   d0,S1MAPY
                    and.w    #$FFF0,d0
                    move.w   d0,WIN1Y
                    sub.w    #13,d5
                    cmp.w    #2,d5
                    ble.b    STUFFSPY0
                    move.w   d5,WIN1X
STUFFSPY1:          bsr      GETRAND
                    lea      S2MAPX,a1
                    lea      S2MAPY,a2
                    bsr      SETXY
                    move.w   S2MAPX,d5
                    add.w    d5,d5
                    add.w    d5,d5
                    addq.w   #1,d5
                    move.w   d5,S2MAPX
                    move.w   S2MAPY,d0
                    add.w    d0,d0
                    add.w    d0,d0
                    move.w   d0,S2MAPY
                    and.w    #$FFF0,d0
                    move.w   d0,WIN2Y
                    sub.w    #13,d5
                    cmp.w    #2,d5
                    ble.b    STUFFSPY1
                    move.w   d5,WIN2X
                    move.w   S1MAPY,d0
                    move.w   S2MAPY,d1
                    lsr.w    #4,d0
                    lsr.w    #4,d1
                    cmp.w    d0,d1
                    bgt      lbC003DE4
                    move.w   S1MAPX,d0
                    sub.w    S2MAPX,d0
                    bge      lbC003DDA
                    neg.w    d0
lbC003DDA:          cmp.w    #40,d0
                    bgt      lbC003DE4
                    bra      STUFFSPY1

lbC003DE4:          movem.l  (sp)+,d0-d5
                    rts

RNDER:              move.l   RND1,d0
                    add.l    RND2,d0
                    move.l   d0,RND1
                    add.l    RND3,d0
                    move.l   d0,RND2
                    rol.l    #3,d0
                    sub.l    RND1,d0
                    add.l    #$FED11137,d0
                    eor.l    d0,RND3
                    rts

RNDER2:             move.l   d0,-(sp)
                    bsr.b    RNDER
                    move.l   d0,d1
                    move.l   (sp)+,d0
                    rts

GETRAND:            move.l   d1,-(sp)
lbC003E2A:          lea      MAP,a0
                    bsr.b    RNDER
                    and.w    #1,d0
                    move.w   d0,d1
                    bsr.b    RNDER
                    and.w    #3,d0
                    add.w    d1,d0
                    move.w   d0,SLABY
                    mulu     #768,d0
                    add.w    d0,a0
                    bsr.b    RNDER
                    and.w    #3,d0
                    mulu     #192,d0
                    add.w    d0,a0
                    bsr.b    RNDER
                    and.w    #$7E,d0
                    move.w   d0,SLABX
                    add.w    d0,a0
                    tst.w    (a0)
                    bne.b    lbC003E2A
                    move.l   a0,d0
                    move.l   (sp)+,d1
                    rts

SETXY:              move.l   d0,-(sp)
                    move.l   a0,d0
                    sub.l    #MAP,d0
                    lsr.w    #1,d0
                    divu     #96,d0
                    move.w   d0,(a2)
                    swap     d0
                    move.w   d0,(a1)
                    move.l   (sp)+,d0
                    rts

CLEAROUTCRAP:       move.l   #-1,d0
                    lea      L_TENMINS,a0
                    move.l   d0,(a0)
                    move.l   d0,4(a0)
                    move.l   d0,8(a0)
                    move.l   d0,12(a0)
                    move.l   d0,16(a0)
                    move.l   d0,20(a0)
                    rts

L_TENMINS:          dc.l     0
L_ONEMINS:          dc.l     0
L_TENSECS:          dc.l     0
L_ONESECS:          dc.l     0
L_S1FUEL:           dc.l     0
L_S2FUEL:           dc.l     0
FERDINAND:          dc.w     0
SLABX:              dc.w     0
SLABY:              dc.w     0
OLD_BUSY:           dc.w     0
RND1:               dc.l     $343411FD
RND2:               dc.l     $8787112F
RND3:               dc.l     $716721ED

DRAWSPY:            tst.w    d0
                    bne      DRAWSPY2_0
                    move.w   SPYWIN,d1
                    cmp.w    #2,d1
                    beq      DRAWSPY3_0
                    moveq    #0,d2
                    move.w   S1MAPX,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d4
                    bne      DRAWSPY1_2
                    move.w   S1MAPX,d2
                    sub.w    WIN1X,d2
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    #48,d2
                    add.w    S1OFFSETX,d2
                    move.w   d2,X
                    moveq    #0,d2
                    move.w   S1MAPY,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d5
                    bne      DRAWSPY1_2
                    tst.w    S1DEPTH
                    beq      lbC004422
                    move.w   #38,d2
                    bra      lbC00443A

lbC004422:          move.w   S1MAPY,d2
                    sub.w    WIN1Y,d2
                    add.w    d2,d2
                    add.w    #14,d2
                    add.w    S1SWAMP,d2
lbC00443A:          add.w    S1DEPTH,d2
                    sub.w    S1ALTITUDE,d2
                    add.w    S1OFFSETY,d2
                    move.w   d2,Y
                    move.l   #656,d2
                    mulu     S1F,d2
                    add.l    S1FADDR,d2
                    move.w   #2,WIDTH
                    move.w   #30,d3
                    sub.w    S1SWAMP,d3
                    sub.w    S1DEPTH,d3
                    move.w   d3,HEIGHT
                    move.l   d2,BUFFER
                    move.l   SCREEN2,SCREEN
                    move.w   X,S1PLOTX
                    move.w   Y,S1PLOTY
                    move.w   Y,-(sp)
                    move.w   X,-(sp)
                    movem.l  d0,-(sp)
                    move.w   #10,RYOFF
                    bsr      SPRITER_MOD
                    movem.l  (sp)+,d0
                    move.w   (sp)+,X
                    move.w   (sp)+,Y
                    bsr      DRAWHANDS
DRAWSPY1_2:         move.w   SPYWIN,d1
                    cmp.w    #1,d1
                    bne      DRAWSPY3_0
                    moveq    #0,d2
                    move.w   S2MAPX,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d4
                    bne      DRAWSPY2_0
                    move.w   S2MAPX,d2
                    sub.w    WIN1X,d2
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    #48,d2
                    add.w    S2OFFSETX,d2
                    move.w   d2,X
                    moveq    #0,d2
                    move.w   S2MAPY,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d5
                    bne      DRAWSPY2_0
                    tst.w    S2DEPTH
                    beq      lbC004534
                    move.w   #38,d2
                    bra      lbC00454C

lbC004534:          move.w   S2MAPY,d2
                    sub.w    WIN1Y,d2
                    add.w    d2,d2
                    add.w    #14,d2
                    add.w    S2SWAMP,d2
lbC00454C:          add.w    S2DEPTH,d2
                    sub.w    S2ALTITUDE,d2
                    add.w    S2OFFSETY,d2
                    move.w   d2,Y
                    move.l   #656,d2
                    mulu     S2F,d2
                    add.l    S2FADDR,d2
                    move.w   #2,WIDTH
                    move.w   #30,d3
                    sub.w    S2SWAMP,d3
                    sub.w    S2DEPTH,d3
                    move.w   d3,HEIGHT
                    move.l   d2,BUFFER
                    move.l   SCREEN2,SCREEN
                    move.w   X,S2PLOTX
                    move.w   Y,S2PLOTY
                    move.w   Y,-(sp)
                    move.w   X,-(sp)
                    movem.l  d0,-(sp)
                    move.w   #1,d0
                    move.w   #10,RYOFF
                    bsr      SPRITER_MOD
                    movem.l  (sp)+,d0
                    move.w   (sp)+,X
                    move.w   (sp)+,Y
                    moveq    #1,d0
                    bsr      DRAWHANDS
                    moveq    #0,d0
                    bra      DRAWSPY3_0

DRAWSPY2_0:         move.w   SPYWIN,d1
                    cmp.w    #1,d1
                    beq      DRAWSPY3_0
                    moveq    #0,d2
                    move.w   S2MAPX,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d4
                    bne      DRAWSPY2_1
                    move.w   S2MAPX,d2
                    sub.w    WIN2X,d2
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    #48,d2
                    add.w    S2OFFSETX,d2
                    move.w   d2,X
                    moveq    #0,d2
                    move.w   S2MAPY,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d5
                    bne      DRAWSPY2_1
                    tst.w    S2DEPTH
                    beq      lbC004652
                    move.w   #139,d2
                    bra      lbC00466A

lbC004652:          move.w   S2MAPY,d2
                    sub.w    WIN2Y,d2
                    add.w    d2,d2
                    add.w    #115,d2
                    add.w    S2SWAMP,d2
lbC00466A:          add.w    S2DEPTH,d2
                    sub.w    S2ALTITUDE,d2
                    add.w    S2OFFSETY,d2
                    move.w   d2,Y
                    move.l   #656,d2
                    mulu     S2F,d2
                    add.l    S2FADDR,d2
                    move.w   #2,WIDTH
                    move.w   #30,d3
                    sub.w    S2SWAMP,d3
                    sub.w    S2DEPTH,d3
                    move.w   d3,HEIGHT
                    move.l   d2,BUFFER
                    move.l   SCREEN2,SCREEN
                    move.w   X,S2PLOTX
                    move.w   Y,S2PLOTY
                    move.w   Y,-(sp)
                    move.w   X,-(sp)
                    movem.l  d0,-(sp)
                    move.w   #111,RYOFF
                    bsr      SPRITER_MOD
                    movem.l  (sp)+,d0
                    move.w   (sp)+,X
                    move.w   (sp)+,Y
                    bsr      DRAWHANDS
DRAWSPY2_1:         move.w   SPYWIN,d1
                    cmp.w    #2,d1
                    bne      DRAWSPY3_0
                    moveq    #0,d2
                    move.w   S1MAPX,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d4
                    bne      DRAWSPY3_0
                    move.w   S1MAPX,d2
                    sub.w    WIN2X,d2
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    #48,d2
                    add.w    S1OFFSETX,d2
                    move.w   d2,X
                    moveq    #0,d2
                    move.w   S1MAPY,d2
                    lsr.w    #2,d2
                    cmp.w    d2,d5
                    bne      DRAWSPY3_0
                    tst.w    S1DEPTH
                    beq      lbC004764
                    move.w   #139,d2
                    bra      lbC00477C

lbC004764:          move.w   S1MAPY,d2
                    sub.w    WIN2Y,d2
                    add.w    d2,d2
                    add.w    #115,d2
                    add.w    S1SWAMP,d2
lbC00477C:          add.w    S1DEPTH,d2
                    sub.w    S1ALTITUDE,d2
                    add.w    S1OFFSETY,d2
                    move.w   d2,Y
                    move.l   #656,d2
                    mulu     S1F,d2
                    add.l    S1FADDR,d2
                    move.w   #2,WIDTH
                    move.w   #30,d3
                    sub.w    S1SWAMP,d3
                    sub.w    S1DEPTH,d3
                    move.w   d3,HEIGHT
                    move.l   d2,BUFFER
                    move.l   SCREEN2,SCREEN
                    move.w   X,S1PLOTX
                    move.w   Y,S1PLOTY
                    move.w   Y,-(sp)
                    move.w   X,-(sp)
                    movem.l  d0,-(sp)
                    clr.w    d0
                    move.w   #111,RYOFF
                    bsr      SPRITER_MOD
                    movem.l  (sp)+,d0
                    move.w   (sp)+,X
                    move.w   (sp)+,Y
                    moveq    #0,d0
                    bsr      DRAWHANDS
                    moveq    #1,d0
DRAWSPY3_0:         rts

DRAWHANDS:          movem.l  d0-d3/a0,-(sp)
                    move.w   #0,d7
                    move.w   #0,d6
                    tst.w    d0
                    bne      DRAWHANDS1
                    tst.w    S1CT
                    bne      DRAWHANDS3
                    cmp.w    #8,S1DEPTH
                    bge      DRAWHANDS3
                    cmp.w    #8,S1SWAMP
                    bge      DRAWHANDS3
                    move.w   S1HAND,d2
                    move.l   S1FADDR,d1
                    cmp.l    #BUF14,d1
                    bne      lbC004882
                    move.w   #8,d6
                    addq.w   #7,X
                    add.w    #14,Y
                    bra      DRAWHANDS2

lbC004882:          cmp.l    #BUF13,d1
                    beq      DRAWHANDS3
                    add.w    #17,X
                    add.w    #14,Y
                    cmp.l    #BUF12,d1
                    bne      DRAWHANDS2
                    sub.w    #17,X
                    move.w   #63,d7
                    bra      DRAWHANDS2

DRAWHANDS1:         tst.w    S2CT
                    bne      DRAWHANDS3
                    cmp.w    #8,S2DEPTH
                    bge      DRAWHANDS3
                    cmp.w    #8,S2SWAMP
                    bge      DRAWHANDS3
                    move.w   S2HAND,d2
                    move.l   S2FADDR,d1
                    cmp.l    #BUF24,d1
                    bne      lbC004906
                    move.w   #8,d6
                    addq.w   #7,X
                    add.w    #14,Y
                    bra      DRAWHANDS2

lbC004906:          cmp.l    #BUF23,d1
                    beq      DRAWHANDS3
                    add.w    #17,X
                    add.w    #14,Y
                    cmp.l    #BUF22,d1
                    bne      DRAWHANDS2
                    sub.w    #17,X
                    move.w   #63,d7
DRAWHANDS2:         move.w   d2,d1
                    lsr.w    #3,d1
                    beq      DRAWHANDS3
                    cmp.w    #8,d1
                    bne      lbC004952
                    subq.w   #6,Y
                    add.w    d6,X
lbC004952:          cmp.w    #9,d1
                    beq      DRAWHANDS3
                    add.w    d7,d1
                    add.w    d1,d1
                    lea      ITEMS_HEIGHT,a0
                    move.w   (a0,d1.w),d7
                    add.w    d1,d1
                    lea      ITEMS_GRAPHICS,a0
                    move.l   (a0,d1.w),a1
                    move.l   SCREEN2,a0
                    move.w   X,d1
                    move.w   Y,d2
                    move.w   #1,d6
                    bsr      RSPRITER
DRAWHANDS3:         movem.l  (sp)+,d0-d3/a0
                    rts

DRAWBUTTONS:        tst.w    d0
                    bne      DRAWBUTTONS1
                    move.w   #79,d2
                    lea      S1PLUNGER,a0
                    lea      S1SAW,a1
                    lea      S1BUCKET,a2
                    lea      S1PICK,a3
                    lea      S1SNSH,a4
                    lea      S1TNT,a6
                    move.w   S1FLASH,d4
                    beq      DRAWBUTTONS2
                    move.w   S1MENU,d4
                    bra      DRAWBUTTONS2

DRAWBUTTONS1:       move.w   #180,d2
                    lea      S2PLUNGER,a0
                    lea      S2SAW,a1
                    lea      S2BUCKET,a2
                    lea      S2PICK,a3
                    lea      S2SNSH,a4
                    lea      S2TNT,a6
                    move.w   S2FLASH,d4
                    beq      DRAWBUTTONS2
                    move.w   S2MENU,d4
DRAWBUTTONS2:       move.w   COUNTER,d5
                    and.w    #1,d5
                    move.w   #94,d1
                    cmp.w    #1,d4
                    bne      DRAWBUTTONS2_A
                    move.w   d5,d3
                    bra      DRAWBUTTONS2_B

DRAWBUTTONS2_A:     move.w   (a0),d3
DRAWBUTTONS2_B:     bsr      ONEBUTTON
                    add.w    #22,d1
                    cmp.w    #2,d4
                    bne      DRAWBUTTONS2_0
                    move.w   d5,d3
                    bra      DRAWBUTTONS2_1

DRAWBUTTONS2_0:     move.w   (a1),d3
DRAWBUTTONS2_1:     bsr      ONEBUTTON
                    add.w    #22,d1
                    cmp.w    #3,d4
                    bne      DRAWBUTTONS2_2
                    move.w   d5,d3
                    bra      DRAWBUTTONS2_3

DRAWBUTTONS2_2:     move.w   (a2),d3
DRAWBUTTONS2_3:     bsr      ONEBUTTON
                    add.w    #22,d1
                    cmp.w    #4,d4
                    bne      DRAWBUTTONS2_4
                    move.w   d5,d3
                    bra      DRAWBUTTONS2_5

DRAWBUTTONS2_4:     move.w   (a3),d3
DRAWBUTTONS2_5:     bsr      ONEBUTTON
                    add.w    #22,d1
                    cmp.w    #5,d4
                    bne      DRAWBUTTONS2_6
                    move.w   d5,d3
                    bra      DRAWBUTTONS2_7

DRAWBUTTONS2_6:     move.w   (a4),d3
DRAWBUTTONS2_7:     bsr      ONEBUTTON
                    add.w    #22,d1
                    cmp.w    #6,d4
                    bne      DRAWBUTTONS2_8
                    move.w   d5,d3
                    bra      DRAWBUTTONS2_9

DRAWBUTTONS2_8:     move.w   (a6),d3
DRAWBUTTONS2_9:     bsr      ONEBUTTON
                    add.w    #22,d1
                    cmp.w    #7,d4
                    bne      DRAWBUTTONS2_10
                    move.w   d5,d3
                    bra      DRAWBUTTONS2_11

DRAWBUTTONS2_10:    move.w   #1,d3
DRAWBUTTONS2_11:    ;bsr      ONEBUTTON
                    ;rts
                    ; no rts

ONEBUTTON:          movem.l  d0-d5/a0-a4,-(sp)
                    move.w   d1,X
                    move.w   d2,Y
                    move.l   SCREEN2,SCREEN
                    move.w   #1,WIDTH
                    move.w   #3,HEIGHT
                    tst.w    d3
                    bne      ONEBUTTON1
                    move.l   #G_EMPTY,BUFFER
                    bra      ONEBUTTON2

ONEBUTTON1:         move.l   #G_FULL,BUFFER
ONEBUTTON2:         bsr      SPRITER
                    movem.l  (sp)+,d0-d5/a0-a4
                    rts

SWAPSCREEN:         jmp      SWAP_SCREEN

DRAWTIME:           move.l   SCREEN2,a0
                    add.w    #$EFA,a0
                    move.w   TENMINS,d0
                    lea      L_TENMINS,a6
                    bsr      COMPARETWICE
                    beq      lbC004B40
                    jsr      NEXTCHAR
lbC004B40:          addq.w   #1,a0
                    move.w   ONEMINS,d0
                    lea      L_ONEMINS,a6
                    bsr      COMPARETWICE
                    beq      lbC004B5C
                    jsr      NEXTCHAR
lbC004B5C:          addq.w   #2,a0
                    move.w   TENSECS,d0
                    lea      L_TENSECS,a6
                    bsr      COMPARETWICE
                    beq      lbC004B78
                    jsr      NEXTCHAR
lbC004B78:          addq.w   #1,a0
                    move.w   ONESECS,d0
                    lea      L_ONESECS,a6
                    bsr      COMPARETWICE
                    beq      lbC004B94
                    jmp      NEXTCHAR
lbC004B94:          rts

HLINE:              movem.l  d0-d7/a0-a6,-(sp)
                    move.w   COLOR,d7
                    move.w   X,a2
                    move.w   a2,a3
                    add.w    COUNT,a3
                    move.l   SCREEN,a0
                    move.w   Y,d2
                    bsr      HORLINE
                    movem.l  (sp)+,d0-d7/a0-a6
                    rts

METER:              move.w   S1ENERGY,d3
                    bpl      .MIN_ENERGY_1
                    clr.w    d3
                    bra      .MAX_ENERGY_1

.MIN_ENERGY_1:      cmp.w    #65,d3
                    bls      .MAX_ENERGY_1
                    move.w   #65,d3
.MAX_ENERGY_1:      move.w   #1,d6
                    move.w   #9,d2
                    move.w   #3,d1
                    move.w   #65,d7
                    move.l   SCREEN2,a0
                    sub.w    d3,d7
                    beq      .ENERGY_EMPTY_1
                    lea      STRENGTH_EMPTY,a1
                    bsr      RDRAW_BUFF
.ENERGY_EMPTY_1:    lea      STRENGTH_FULL,a1
                    move.w   d7,d2
                    lsl.w    #3,d7
                    add.w    d7,a1
                    move.w   d3,d7
                    beq      METER_2
                    add.w    #9,d2
                    bsr      RDRAW_BUFF
METER_2:            move.w   S2ENERGY,d3
                    bpl      .MIN_ENERGY_2
                    clr.w    d3
                    bra      .MAX_ENERGY_2

.MIN_ENERGY_2:      cmp.w    #65,d3
                    bls      .MAX_ENERGY_2
                    move.w   #65,d3
.MAX_ENERGY_2:      move.w   #1,d6
                    move.w   #110,d2
                    move.w   #3,d1
                    move.w   #65,d7
                    move.l   SCREEN2,a0
                    sub.w    d3,d7
                    beq      .ENERGY_EMPTY_2
                    lea      STRENGTH_EMPTY,a1
                    bsr      RDRAW_BUFF
.ENERGY_EMPTY_2:    lea      STRENGTH_FULL,a1
                    move.w   d7,d2
                    lsl.w    #3,d7
                    add.w    d7,a1
                    move.w   d3,d7
                    beq      METER3
                    add.w    #110,d2
                    bra      RDRAW_BUFF
METER3:             rts

OUNTER:             dc.w     0

FLASH:              move.w   #16,d1
                    move.w   #184,d2
                    move.l   #G_HOLD_BACK,a1
                    move.w   #4,d6
                    move.w   #11,d7
                    move.l   SCREEN2,a0
                    bsr      RSPRITER
                    move.w   #83,d2
                    bsr      RSPRITER
                    move.w   COUNTER,d3
                    and.w    #2,d3
                    beq      lbC004CE2
                    move.w   #1,d6
                    move.w   #10,d7
                    move.w   S1HAND,d3
                    lea      S1WIN,a6
                    bsr      FLASH_ONE
                    move.w   #184,d2
                    move.w   S2HAND,d3
                    lea      S2WIN,a6
                    bra      FLASH_ONE
lbC004CE2:          rts

FLASH_ONE:          clr.w    (a6)
                    tst.w    d3
                    beq      lbC004D6C
                    lsr.w    #3,d3
                    cmp.w    #2,d3
                    beq      lbC004D0A
                    cmp.w    #1,d3
                    bne      lbC004D18
                    tst.b    IN_CASE
                    beq      lbC004D18
                    addq.w   #1,(a6)
lbC004D0A:          move.w   #26,d1
                    lea      G_CARD,a1
                    bsr      RSPRITER
lbC004D18:          cmp.w    #3,d3
                    beq      lbC004D34
                    cmp.w    #1,d3
                    bne      lbC004D42
                    tst.b    lbB00B239
                    beq      lbC004D42
                    addq.w   #1,(a6)
lbC004D34:          move.w   #42,d1
                    lea      G_URANIUM,a1
                    bsr      RSPRITER
lbC004D42:          cmp.w    #4,d3
                    beq      lbC004D5E
                    cmp.w    #1,d3
                    bne      lbC004D6C
                    tst.b    lbB00B23A
                    beq      lbC004D6C
                    addq.w   #1,(a6)
lbC004D5E:          move.w   #58,d1
                    lea      G_GYRO,a1
                    bra      RSPRITER
lbC004D6C:          rts

COMPARETWICE:       cmp.w    (a6),d0
                    bne      lbC004D80
                    lea      2(a6),a6
                    cmp.w    (a6),d0
                    bne      lbC004D80
                    rts

lbC004D80:          move.w   d0,(a6)
                    cmp.w    #-2,d0
                    rts

SPRITER_MOD:        tst.w    d0
                    bne      lbC004DA8
                    tst.w    S1ROCKET
                    bne      SPRITER_ROCKET1
                    move.w   S1HAND,d7
                    move.w   S1CT,d6
                    bra      SP_M2

lbC004DA8:          tst.w    S2ROCKET
                    bne      SPRITER_ROCKET2
                    move.w   S2HAND,d7
                    move.w   S2CT,d6
SP_M2:              tst.w    d6
                    bne      SP_M9
                    cmp.w    #72,d7
                    bne      SP_M9
                    cmp.w    #20,HEIGHT
                    ble      SP_M9
                    move.w   HEIGHT,-(sp)
                    move.w   #20,HEIGHT
                    bsr      SPRITER
                    move.w   (sp)+,d7
                    sub.w    #20,d7
                    move.w   d7,HEIGHT
                    add.w    #20,Y
                    add.l    #496,BUFFER
SP_M9:              bra      SPRITER

SPRITER_ROCKET1:    clr.w    S1HAND
                    bra      DO_R1

SPRITER_ROCKET2:    clr.w    S2HAND
DO_R1:              move.w   RYOFF,d2
                    move.w   X,d1
                    tst.w    RLEN
                    beq      DO_R4
                    cmp.w    #60,RHT
                    beq      lbC004E50
                    addq.w   #2,RHT
                    subq.w   #2,RY
                    bra      DO_R3

lbC004E50:          add.l    #32,RDATA
                    subq.w   #2,RLEN
                    move.w   RLEN,d3
                    bne      lbC004E74
                    clr.w    SOUNDCT
                    bra      DO_R4

lbC004E74:          cmp.w    #60,d3
                    bge      DO_R3
                    move.w   d3,d7
                    bra      DO_R3A

DO_R3:              move.w   RHT,d7
DO_R3A:             move.w   #2,d6
                    add.w    RY,d2
                    move.l   RDATA,a1
                    move.w   COUNTER,d3
                    and.w    #1,d3
                    beq      lbC004EAA
                    lea      1184(a1),a1
lbC004EAA:          move.l   SCREEN2,a0
                    bra      RSPRITER
DO_R4:              rts

RSPRITER:           movem.l  d0-d7/a0-a2,-(sp)
                    subq.w   #1,d6
                    subq.w   #1,d7
                    move.w   d1,d4
                    and.w    #$F,d4
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    and.w    #$FFF0,d1
                    asr.w    #3,d1
                    add.w    d1,a0
lbC004ED4:          move.l   a0,a2
                    move.w   d6,d0
lbC004ED8:          moveq    #0,d2
                    move.w   (a1),d2
                    or.w     2(a1),d2
                    or.w     4(a1),d2
                    or.w     6(a1),d2
                    ror.l    d4,d2
                    not.l    d2
                    and.w    d2,(a0)
                    and.w    d2,(200*40)(a0)
                    and.w    d2,(200*2*40)(a0)
                    and.w    d2,(200*3*40)(a0)
                    swap     d2
                    and.w    d2,2(a0)
                    and.w    d2,(200*40)+2(a0)
                    and.w    d2,(200*2*40)+2(a0)
                    and.w    d2,(200*3*40)+2(a0)
                    tst.w    d4
                    beq      lbC004F52
                    moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(a0)+
                    swap     d2
                    or.w     d2,(a0)
                    moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(200*40)-2(a0)
                    swap     d2
                    or.w     d2,(200*40)(a0)
                    moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(200*2*40)-2(a0)
                    swap     d2
                    or.w     d2,(200*2*40)(a0)
                    moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(200*3*40)-2(a0)
                    swap     d2
                    or.w     d2,(200*3*40)(a0)
                    bra      lbC004F68

lbC004F52:          move.w   (a1)+,d2
                    or.w     d2,(a0)+
                    move.w   (a1)+,d2
                    or.w     d2,(200*40)-2(a0)
                    move.w   (a1)+,d2
                    or.w     d2,(200*2*40)-2(a0)
                    move.w   (a1)+,d2
                    or.w     d2,(200*3*40)-2(a0)
lbC004F68:          dbra     d0,lbC004ED8
                    lea      40(a2),a0
                    dbra     d7,lbC004ED4
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

RBACKER:            movem.l  d0-d7/a0-a2,-(sp)
                    subq.w   #1,d6
                    subq.w   #1,d7
                    move.w   d1,d4
                    and.w    #$F,d4
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    and.w    #$FFF0,d1
                    asr.w    #3,d1
                    add.w    d1,a0
lbC004F98:          move.l   a0,a2
                    move.w   d6,d0
                    clr.w    (a0)
                    clr.w    (200*40)(a0)
                    clr.w    (200*2*40)(a0)
                    clr.w    (200*3*40)(a0)
lbC004FAA:          moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(a0)+
                    swap     d2
                    move.w   d2,(a0)
                    moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(200*40)-2(a0)
                    swap     d2
                    move.w   d2,(200*40)(a0)
                    moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(200*2*40)-2(a0)
                    swap     d2
                    move.w   d2,(200*2*40)(a0)
                    moveq    #0,d2
                    move.w   (a1)+,d2
                    ror.l    d4,d2
                    or.w     d2,(200*3*40)-2(a0)
                    swap     d2
                    move.w   d2,(200*3*40)(a0)
                    bra      lbC004FEA

lbC004FEA:          dbra     d0,lbC004FAA
                    lea      40(a2),a0
                    dbra     d7,lbC004F98
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

RSAVE_BUFF:         movem.l  d0-d7/a0-a2,-(sp)
                    subq.w   #1,d6
                    subq.w   #1,d7
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    asl.w    #1,d1
                    add.w    d1,a0
lbC005010:          move.l   a0,a2
                    move.w   d6,d0
lbC005014:          move.w   (a0)+,(a1)+
                    move.w   (200*40)-2(a0),(a1)+
                    move.w   (200*2*40)-2(a0),(a1)+
                    move.w   (200*3*40)-2(a0),(a1)+
                    dbra     d0,lbC005014
                    lea      40(a2),a0
                    dbra     d7,lbC005010
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

RDRAW_BUFF:         movem.l  d0-d7/a0-a2,-(sp)
                    subq.w   #1,d6
                    subq.w   #1,d7
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    asl.w    #1,d1
                    add.w    d1,a0
lbC005048:          move.l   a0,a2
                    move.w   d6,d0
lbC00504C:          move.w   (a1)+,(a0)+
                    move.w   (a1)+,(200*40)-2(a0)
                    move.w   (a1)+,(200*2*40)-2(a0)
                    move.w   (a1)+,(200*3*40)-2(a0)
                    dbra     d0,lbC00504C
                    lea      40(a2),a0
                    dbra     d7,lbC005048
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

RSTUFF_BUFF:        movem.l  d0-d7/a0-a2,-(sp)
                    move.w   d6,d3
                    mulu     d7,d3
                    add.w    d3,d3
                    move.l   d3,(a1)+
                    move.w   d6,(a1)+
                    move.w   d7,(a1)+
                    subq.w   #2,d6
                    subq.w   #1,d7
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    asl.w    #1,d1
                    add.w    d1,a0
lbC00508C:          move.l   a0,a2
                    move.w   d6,d0
lbC005090:          move.w   (a0),d1
                    or.w     (200*40)(a0),d1
                    or.w     (200*2*40)(a0),d1
                    or.w     (200*3*40)(a0),d1
                    move.w   d1,(a1)
                    move.w   d3,d2
                    move.w   (a0),(a1,d2.w)
                    add.w    d3,d2
                    move.w   (200*40)(a0),(a1,d2.w)
                    add.w    d3,d2
                    move.w   (200*2*40)(a0),(a1,d2.w)
                    add.w    d3,d2
                    move.w   (200*3*40)(a0),(a1,d2.w)
                    addq.w   #2,a1
                    addq.w   #2,a0
                    dbra     d0,lbC005090
                    clr.w    (a1)+
                    lea      40(a2),a0
                    dbra     d7,lbC00508C
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

RSTUFF_BUFF_SHORT:  movem.l  d0-d7/a0-a2,-(sp)
                    move.w   d6,d3
                    mulu     d7,d3
                    add.w    d3,d3
                    move.l   d3,(a1)+
                    move.w   d6,(a1)+
                    move.w   d7,(a1)+
                    subq.w   #1,d6
                    subq.w   #1,d7
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    asl.w    #1,d1
                    add.w    d1,a0
lbC0050F6:          move.l   a0,a2
                    move.w   d6,d0
lbC0050FA:          move.w   d3,d2
                    move.w   (a0),(a1)
                    move.w   (200*40)(a0),(a1,d2.w)
                    add.w    d3,d2
                    move.w   (200*2*40)(a0),(a1,d2.w)
                    add.w    d3,d2
                    move.w   (200*3*40)(a0),(a1,d2.w)
                    addq.w   #2,a1
                    addq.w   #2,a0
                    dbra     d0,lbC0050FA
                    lea      40(a2),a0
                    dbra     d7,lbC0050F6
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

RSPRITER_AM:        movem.l  d0-d7/a0-a4,-(sp)
                    move.w   MINTERMS,d5
                    lea      $DFF000,a2
                    move.w   #$8440,$96(a2)
                    move.w   4(a1),d6
                    cmp.w    #$FE2,d5
                    beq      lbC00514E
                    subq.w   #1,d6
lbC00514E:          lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    move.w   d1,d3
                    and.w    #$F,d3
                    lsr.w    #3,d1
                    and.w    #$FFFE,d1
                    add.w    d1,a0
                    move.l   #-1,$44(a2)
                    ror.w    #4,d3
                    move.w   d3,$42(a2)
                    or.w     d5,d3
                    move.w   d3,$40(a2)
                    move.w   #0,$64(a2)
                    cmp.w    #$FE2,d5
                    beq      lbC005190
                    move.w   #2,$64(a2)
lbC005190:          move.w   #0,$62(a2)
                    move.w   #40,d3
                    sub.w    d6,d3
                    sub.w    d6,d3
                    move.w   d3,$60(a2)
                    move.w   d3,$66(a2)
                    lsl.w    #6,d7
                    or.w     d6,d7
                    move.l   (a1),a3
                    lea      8(a1),a1
                    move.l   a1,a4
                    add.l    a3,a1
                    move.l   a1,$50(a2)
                    move.l   a4,$4C(a2)
                    move.l   a0,$48(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    lea      (200*40)(a0),a0
                    add.l    a3,a1
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a4,$4C(a2)
                    move.l   a0,$48(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    lea      (200*40)(a0),a0
                    add.l    a3,a1
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a4,$4C(a2)
                    move.l   a0,$48(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    lea      (200*40)(a0),a0
                    add.l    a3,a1
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a4,$4C(a2)
                    move.l   a0,$48(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    movem.l  (sp)+,d0-d7/a0-a4
                    rts

SPRITER:            movem.l  d0-d7/a0/a1,-(sp)
                    move.w   WIDTH,d6
                    move.w   HEIGHT,d7
                    move.w   X,d1
                    move.w   Y,d2
                    move.l   SCREEN,a0
                    move.l   BUFFER,a1
                    bsr      RSPRITER
                    movem.l  (sp)+,d0-d7/a0/a1
                    rts

SPRITER_AM:         movem.l  d0-d7/a0/a1,-(sp)
                    move.w   X,d1
                    move.w   Y,d2
                    move.w   HEIGHT,d7
                    move.l   SCREEN,a0
                    move.l   BUFFER,a1
                    bsr      RSPRITER_AM
                    movem.l  (sp)+,d0-d7/a0/a1
                    rts

BACKER:             movem.l  d0-d7/a0/a1,-(sp)
                    move.w   WIDTH,d6
                    move.w   HEIGHT,d7
                    move.w   X,d1
                    move.w   Y,d2
                    move.l   SCREEN,a0
                    move.l   BUFFER,a1
                    bsr      RBACKER
                    movem.l  (sp)+,d0-d7/a0/a1
                    rts

X:                  dc.w     0
Y:                  dc.w     0
WIDTH:              dc.w     0
HEIGHT:             dc.w     0
BUFFER:             dc.l     0
SCREEN:             dc.l     0
MINTERMS:           dc.w     $FE2

RSNOWING:           move.w   #63,d7
                    tst.w    SNOW_CHANGE
                    bne      lbC005326
                    move.l   CURRENT_SNOW,PREVIOUS_SNOW
                    lea      DRYSLAB,a3
                    tst.w    TENMINS
                    bne      lbC00538C
                    cmp.w    #1,ONEMINS
                    bhi      lbC00538C
                    lea      SLEETSLAB,a3
                    cmp.w    #1,ONEMINS
                    beq      lbC005316
                    lea      SNOWSLAB,a3
lbC005316:          move.l   a3,CURRENT_SNOW
                    move.w   d7,SNOW_CHANGE
                    bra      lbC00532C

lbC005326:          subq.w   #1,SNOW_CHANGE
lbC00532C:          move.l   CURRENT_SNOW,a3
                    move.l   SCREEN2,a0
                    lea      408(a0),a0
                    move.w   SNOWCOUNT,d4
                    subq.w   #1,d4
                    and.w    #15,d4
                    move.w   d4,SNOWCOUNT
                    cmp.w    #2,SPYWIN
                    beq      lbC005368
                    tst.w    S1IGLOO
                    bne      lbC005368
                    bsr      DOSNOW
lbC005368:          move.l   SCREEN2,a0
                    lea      4448(a0),a0
                    cmp.w    #1,SPYWIN
                    beq      lbC00538C
                    tst.w    S2IGLOO
                    bne      lbC00538C
                    bra      DOSNOW
lbC00538C:          rts

DOSNOW:             movem.l  d7/a3/a4,-(sp)
                    move.w   SNOWCOUNT,d4
                    mulu     #80,d4
                    add.w    d4,a3
                    move.l   a3,a4
                    move.w   #0,d3
lbC0053A4:          cmp.w    SNOW_CHANGE,d7
                    bne      lbC0053C6
                    sub.l    CURRENT_SNOW,a3
                    add.l    PREVIOUS_SNOW,a3
                    sub.l    CURRENT_SNOW,a4
                    add.l    PREVIOUS_SNOW,a4
lbC0053C6:          cmp.w    #1,d7
                    bgt      lbC0053D6
                    move.l   #DRYSLAB,a3
                    move.l   a3,a4
lbC0053D6:          and.w    #$F,d3
                    bne      lbC0053E0
                    move.l   a3,a4
lbC0053E0:          subq.w   #1,d3
                    move.l   a0,a2
                    move.w   #9,d0
lbC0053E8:          move.w   (a4)+,d2
                    and.w    d2,(a0)+
                    move.w   (a4)+,d2
                    or.w     d2,(200*40)-2(a0)
                    move.w   (a4)+,d2
                    or.w     d2,(200*2*40)-2(a0)
                    move.w   (a4)+,d2
                    or.w     d2,(200*3*40)-2(a0)
                    dbra     d0,lbC0053E8
                    lea      40(a2),a0
                    dbra     d7,lbC0053A4
                    movem.l  (sp)+,d7/a3/a4
                    rts

SNOWCOUNT:          dc.w     0
CURRENT_SNOW:       dc.l     0
PREVIOUS_SNOW:      dc.l     0
SNOW_CHANGE:        dc.w     0

PUTCHAR:            movem.l  d2/a0,-(sp)
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    add.w    d1,a0
                    bsr      NEXTCHAR
                    movem.l  (sp)+,d2/a0
                    rts

NEXTCHAR:           movem.l  d1/a0/a1,-(sp)
                    and.w    #$F,d0
                    lsl.w    #5,d0
                    lea      FONT,a1
                    add.w    d0,a1
                    move.w   #8-1,d0
lbC00544A:          move.b   (a1)+,(a0)
                    move.b   (a1)+,(200*40)(a0)
                    move.b   (a1)+,(200*2*40)(a0)
                    move.b   (a1)+,(200*3*40)(a0)
                    lea      40(a0),a0
                    dbra     d0,lbC00544A
                    movem.l  (sp)+,d1/a0/a1
                    rts

; plane 1,plane 2,plane 3,plane 4
FONT:               dc.b     %11000011,%00111110,%00111110,%11111111
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    dc.b     %10011001,%01110111,%01110111,%11111111
                    dc.b     %10011001,%01110111,%01110111,%11111111
                    dc.b     %10011001,%01110111,%01110111,%11111111
                    dc.b     %10011001,%01110111,%01110111,%11111111
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    dc.b     %11000011,%00111100,%00111100,%11111111
                    
                    dc.b     %11100111,%00011100,%00011100,%11111111
                    dc.b     %11000111,%00111100,%00111100,%11111111
                    dc.b     %11000111,%00111100,%00111100,%11111111
                    dc.b     %11100111,%00011100,%00011100,%11111111
                    dc.b     %11100111,%00011100,%00011100,%11111111
                    dc.b     %11100111,%00011100,%00011100,%11111111
                    dc.b     %11000011,%00111110,%00111110,%11111111
                    dc.b     %11000011,%00111110,%00111110,%11111111
                    
                    dc.b     %11100011,%00011100,%00011100,%11111111
                    dc.b     %11000001,%00111111,%00111111,%11111111
                    dc.b     %10011001,%01110111,%01110111,%11111111
                    dc.b     %11110001,%00001111,%00001111,%11111111
                    dc.b     %11100011,%00011110,%00011110,%11111111
                    dc.b     %11000111,%00111100,%00111100,%11111111
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    
                    dc.b     %11000011,%00111110,%00111110,%11111111
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    dc.b     %11111001,%00000111,%00000111,%11111111
                    dc.b     %11100001,%00011111,%00011111,%11111111
                    dc.b     %11100001,%00011111,%00011111,%11111111
                    dc.b     %11111001,%00000111,%00000111,%11111111
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    dc.b     %11000011,%00111110,%00111110,%11111111
                    
                    dc.b     %10011111,%01100000,%01100000,%11111111
                    dc.b     %10011111,%01110000,%01110000,%11111111
                    dc.b     %10010011,%01111100,%01111100,%11111111
                    dc.b     %10010011,%01111110,%01111110,%11111111
                    dc.b     %10010001,%01111111,%01111111,%11111111
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    dc.b     %11110011,%00001110,%00001110,%11111111
                    dc.b     %11110011,%00001110,%00001110,%11111111
                    
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    dc.b     %10011111,%01110000,%01110000,%11111111
                    dc.b     %10000011,%01111100,%01111100,%11111111
                    dc.b     %11111001,%00000111,%00000111,%11111111
                    dc.b     %10111001,%01100111,%01100111,%11111111
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    dc.b     %11000011,%00111110,%00111110,%11111111

                    dc.b     %11100111,%00011000,%00011000,%11111111
                    dc.b     %11000001,%00111111,%00111111,%11111111
                    dc.b     %10011111,%01110000,%01110000,%11111111
                    dc.b     %10000011,%01111110,%01111110,%11111111
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    dc.b     %10011001,%01110111,%01110111,%11111111
                    dc.b     %11000001,%00111111,%00111111,%11111111
                    dc.b     %11100011,%00011110,%00011110,%11111111

                    dc.b     %10000001,%01111110,%01111110,%11111111
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    dc.b     %11111001,%00000111,%00000111,%11111111
                    dc.b     %11110001,%00000111,%00000111,%11111111
                    dc.b     %11110001,%00001101,%00001101,%11111111
                    dc.b     %11100011,%00001110,%00001110,%11111111
                    dc.b     %11100011,%00011110,%00011110,%11111111
                    dc.b     %11100111,%00011100,%00011100,%11111111
                    
                    dc.b     %11000011,%00111110,%00111110,%11111111
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    dc.b     %10011001,%01110111,%01110111,%11111111
                    dc.b     %11000011,%00111110,%00111110,%11111111
                    dc.b     %11000011,%00111110,%00111110,%11111111
                    dc.b     %10011001,%01110111,%01110111,%11111111
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    dc.b     %11000011,%00111110,%00111110,%11111111

                    dc.b     %11000001,%00111110,%00111110,%11111111
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    dc.b     %10011001,%01110111,%01110111,%11111111
                    dc.b     %10000001,%01111111,%01111111,%11111111
                    dc.b     %11000001,%00111111,%00111111,%11111111
                    dc.b     %11111001,%00000111,%00000111,%11111111
                    dc.b     %11111001,%00000111,%00000111,%11111111
                    dc.b     %11111001,%00000111,%00000111,%11111111
                    
                    dc.b     %00000000,%11111111,%01111000,%01111000
                    dc.b     %00000000,%11111111,%11111100,%11111100
                    dc.b     %00000000,%11111111,%11111100,%11111100
                    dc.b     %00000000,%11111111,%11111100,%11111100
                    dc.b     %00000000,%11111111,%11111100,%11111100
                    dc.b     %00000000,%11111111,%11111100,%11111100
                    dc.b     %00000000,%11111111,%01111000,%01111000
                    dc.b     %00000000,%11111111,%00000000,%00000000

CALCAD:             movem.l  d1/d2,-(sp)
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    move.w   d1,d6
                    lsr.w    #3,d1
                    and.w    #$FFFE,d1
                    add.w    d1,a0
                    and.w    #$F,d6
                    add.w    d6,d6
                    move.w   BITTAB(pc,d6.w),d6
                    movem.l  (sp)+,d1/d2
                    rts

BITTAB:             dc.w     %1000000000000000
                    dc.w     %0100000000000000
                    dc.w     %0010000000000000
                    dc.w     %0001000000000000
                    dc.w     %0000100000000000
                    dc.w     %0000010000000000
                    dc.w     %0000001000000000
                    dc.w     %0000000100000000
                    dc.w     %0000000010000000
                    dc.w     %0000000001000000
                    dc.w     %0000000000100000
                    dc.w     %0000000000010000
                    dc.w     %0000000000001000
                    dc.w     %0000000000000100
                    dc.w     %0000000000000010
                    dc.w     %0000000000000001

PLOTPOINT:          and.w    d6,(a0)
                    and.w    d6,(200*40)(a0)
                    and.w    d6,(200*2*40)(a0)
                    and.w    d6,(200*3*40)(a0)
                    or.w     d1,(a0)
                    or.w     d2,(200*40)(a0)
                    or.w     d3,(200*2*40)(a0)
                    or.w     d4,(200*3*40)(a0)
                    rts

LEFT_RIGHT:         tst.w    GO_LEFT
                    bne      BACKWARDS
                    ror.w    #1,d1
                    ror.w    #1,d2
                    ror.w    #1,d3
                    ror.w    #1,d4
                    ror.w    #1,d6
                    bcs      LR_RET
                    addq.w   #2,a0
                    rts

BACKWARDS:          rol.w    #1,d1
                    rol.w    #1,d2
                    rol.w    #1,d3
                    rol.w    #1,d4
                    rol.w    #1,d6
                    bcs      LR_RET
                    subq.w   #2,a0
LR_RET:             rts

UP_DOWN:            tst.w    GO_UP
                    bne      UPWARDS
                    lea      40(a0),a0
                    rts

UPWARDS:            lea      -40(a0),a0
                    rts

DRAW_LINE:          movem.l  d0-d7/a0-a2,-(sp)
                    moveq    #0,d5
                    bsr      CALCAD
                    move.w   d3,d0
                    sub.w    d1,d0
                    bpl      lbC005674
                    neg.w    d0
                    move.w   #-1,GO_LEFT
                    bra      lbC00567A

lbC005674:          clr.w    GO_LEFT
lbC00567A:          move.w   d4,d5
                    sub.w    d2,d5
                    bpl      lbC005690
                    neg.w    d5
                    move.w   #-1,GO_UP
                    bra      lbC005696

lbC005690:          clr.w    GO_UP
lbC005696:          addq.w   #1,d5
                    addq.w   #1,d0
                    lsl.w    #8,d5
                    divu     d0,d5
                    and.l    #$FFFF,d5
                    lsl.l    #8,d5
SETUPCOLOUR:        clr.w    d1
                    clr.w    d2
                    clr.w    d3
                    clr.w    d4
                    ror.w    #1,d7
                    bcc      lbC0056BE
                    move.w   d6,d1
lbC0056BE:          ror.w    #1,d7
                    bcc      lbC0056C6
                    move.w   d6,d2
lbC0056C6:          ror.w    #1,d7
                    bcc      lbC0056CE
                    move.w   d6,d3
lbC0056CE:          ror.w    #1,d7
                    bcc      lbC0056D6
                    move.w   d6,d4
lbC0056D6:          not.w    d6
                    moveq    #0,d7
MORE_POINTS:        bsr      PLOTPOINT
                    add.l    d5,d7
                    swap     d7
                    tst.w    d7
                    beq      DONE_POINT
_UP_DOWN:           bsr      UP_DOWN
                    bsr      PLOTPOINT
                    subq.w   #1,d7
                    bne.b    _UP_DOWN
DONE_POINT:         bsr      LEFT_RIGHT
                    swap     d7
                    subq.w   #1,d0
                    bne.b    MORE_POINTS
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

GO_LEFT:            dc.w     0
GO_UP:              dc.w     0

HORLINE:            movem.l  d0-d5/a0,-(sp)
                    move.w   a3,d4
                    move.w   a2,d0
                    sub.w    d0,d4
                    addq.w   #1,d4
                    move.w   a2,d1
                    bsr      POINT
                    move.w   d1,d5
                    and.w    #$F,d5
                    beq      GOT_BOUNDARY_STRAIGHT
EARLY:              tst.w    d4
                    beq      DONE_LINE
                    move.w   d1,d5
                    and.w    #$F,d5
                    beq      GOT_BOUNDARY
                    move.w   d7,d0
                    ror.w    #1,d0
                    bcc      lbC005762
                    or.w     d3,(a0)
                    bra      lbC005768

lbC005762:          not.w    d3
                    and.w    d3,(a0)
                    not.w    d3
lbC005768:          ror.w    #1,d0
                    bcc      lbC005776
                    or.w     d3,(200*40)(a0)
                    bra      lbC00577E

lbC005776:          not.w    d3
                    and.w    d3,(200*40)(a0)
                    not.w    d3
lbC00577E:          ror.w    #1,d0
                    bcc      lbC00578C
                    or.w     d3,(200*2*40)(a0)
                    bra      lbC005794

lbC00578C:          not.w    d3
                    and.w    d3,(200*2*40)(a0)
                    not.w    d3
lbC005794:          ror.w    #1,d0
                    bcc      lbC0057A2
                    or.w     d3,(200*3*40)(a0)
                    bra      lbC0057AA

lbC0057A2:          not.w    d3
                    and.w    d3,(200*3*40)(a0)
                    not.w    d3
lbC0057AA:          lsr.w    #1,d3
                    addq.w   #1,d1
                    subq.w   #1,d4
                    bra.b    EARLY

GOT_BOUNDARY:       addq.w   #2,a0
GOT_BOUNDARY_STRAIGHT:
                    cmp.w    #15,d4
                    ble      LATER
                    move.w   #$FFFF,d3
                    move.w   d7,d0
                    ror.w    #1,d0
                    bcc      lbC0057CE
                    move.w   d3,(a0)
                    bra      lbC0057D0

lbC0057CE:          clr.w    (a0)
lbC0057D0:          ror.w    #1,d0
                    bcc      lbC0057DE
                    move.w   d3,(200*40)(a0)
                    bra      lbC0057E2

lbC0057DE:          clr.w    (200*40)(a0)
lbC0057E2:          ror.w    #1,d0
                    bcc      lbC0057F0
                    move.w   d3,(200*2*40)(a0)
                    bra      lbC0057F4

lbC0057F0:          clr.w    (200*2*40)(a0)
lbC0057F4:          ror.w    #1,d0
                    bcc      lbC005802
                    move.w   d3,(200*3*40)(a0)
                    bra      lbC005806

lbC005802:          clr.w    (200*3*40)(a0)
lbC005806:          sub.w    #$10,d4
                    add.w    #$10,d1
                    bra.b    GOT_BOUNDARY

LATER:              tst.w    d4
                    beq      DONE_LINE
                    move.w   #$8000,d3
LATER2:             move.w   d7,d0
                    ror.w    #1,d0
                    bcc      lbC005828
                    or.w     d3,(a0)
                    bra      lbC00582E

lbC005828:          not.w    d3
                    and.w    d3,(a0)
                    not.w    d3
lbC00582E:          ror.w    #1,d0
                    bcc      lbC00583C
                    or.w     d3,(200*40)(a0)
                    bra      lbC005844

lbC00583C:          not.w    d3
                    and.w    d3,(200*40)(a0)
                    not.w    d3
lbC005844:          ror.w    #1,d0
                    bcc      lbC005852
                    or.w     d3,(200*2*40)(a0)
                    bra      lbC00585A

lbC005852:          not.w    d3
                    and.w    d3,(200*2*40)(a0)
                    not.w    d3
lbC00585A:          ror.w    #1,d0
                    bcc      lbC005868
                    or.w     d3,(200*3*40)(a0)
                    bra      lbC005870

lbC005868:          not.w    d3
                    and.w    d3,(200*3*40)(a0)
                    not.w    d3
lbC005870:          ror.w    #1,d3
                    subq.w   #1,d4
                    bne.b    LATER2
DONE_LINE:          movem.l  (sp)+,d0-d5/a0
BYE_BYE_LINE:       rts

POINT:              move.w   d2,d0
                    lsl.w    #3,d0
                    add.w    d0,a0
                    lsl.w    #2,d0
                    add.w    d0,a0
                    move.w   d1,d0
                    lsr.w    #3,d0
                    and.w    #$FE,d0
                    add.w    d0,a0
                    move.w   d1,d0
                    and.w    #15,d0
                    move.w   #$8000,d3
                    lsr.w    d0,d3
                    rts

GET_RANDOM:         move.l   d1,-(sp)
                    move.l   RANDOM1,d0
                    add.l    RANDOM2,d0
                    move.l   d0,RANDOM1
                    sub.l    RANDOM3,d0
                    add.l    d0,RANDOM2
                    move.w   d0,d1
                    and.w    #7,d1
                    swap     d0
                    ror.l    d1,d0
                    sub.l    d0,RANDOM3
                    add.l    d0,RANDOM1
                    move.l   (sp)+,d1
                    rts

RANDOM1:            dc.l     $98081FDD
RANDOM2:            dc.l     $FECA1919
RANDOM3:            dc.l     $121212FD

READ_TRIGS:         move.l   d0,-(sp)
                    bsr      SCAN_JOY
                    cmp.w    #2,S1MODE
                    bne      lbC005906
                    move.w   #$40,d0
                    bsr      INKEY
                    beq      ZER1
                    bra      NZ1

lbC005906:          tst.w    S1MODE
                    bne      lbC00591E
                    tst.w    FIRE1
                    bne      NZ1
                    bra      ZER1

lbC00591E:          tst.w    FIRE0
                    bne      NZ1
ZER1:               clr.w    JOY1TRIG
                    bra      RT2

NZ1:                move.w   #-1,JOY1TRIG
RT2:                cmp.w    #2,S2MODE
                    bne      lbC005956
                    move.w   #$40,d0
                    bsr      INKEY
                    beq      ZER2
                    bra      NZ2

lbC005956:          bhi      lbC005980
                    tst.w    S2MODE
                    bne      lbC005972
                    tst.w    FIRE1
                    bne      NZ2
                    bra      ZER2

lbC005972:          tst.w    FIRE0
                    bne      NZ2
                    bra      ZER2

lbC005980:          cmp.w    #3,S2MODE
                    bne      lbC00599A
                    tst.w    FIRE0
                    bne      NZ2
                    bra      ZER2

lbC00599A:          tst.w    FIRE1
                    bne      NZ2
ZER2:               clr.w    JOY2TRIG
                    bra      RT_RET

NZ2:                move.w   #-1,JOY2TRIG
RT_RET:             move.l   (sp)+,d0
                    rts

MOVE:               bsr      JOYMOVE
                    move.l   d0,-(sp)
                    tst.w    DEMO
                    beq      NO_DEMO
                    bsr      SCAN_JOY
                    tst.w    FIRE0
                    bne      OUT_DEMO
                    tst.w    FIRE1
                    bne      OUT_DEMO
                    move.w   #$40,d0
                    bsr      INKEY
                    bne      OUT_DEMO
                    move.w   #$44,d0
                    bsr      INKEY
                    bne      OUT_DEMO
                    move.w   #$45,d0
                    bsr      INKEY
                    beq      NO_DEMO
OUT_DEMO:           cmp.w    #40,DEMO
                    blt      NO_DEMO
                    move.w   #40,DEMO
NO_DEMO:            move.l   (sp)+,d0
                    tst.w    d0
                    bne      lbC005A36
                    lea      S1BDIR,a4
                    tst.w    S1AUTO
                    beq      lbC005A78
                    bra      lbC005A46

lbC005A36:          lea      S2BDIR,a4
                    tst.w    S2AUTO
                    beq      lbC005A78
lbC005A46:          movem.l  a4,-(sp)
                    bsr      BRAINMOVE
                    cmp.w    #8,d1
                    bgt      lbC005A5E
                    cmp.w    #-8,d1
                    bgt      lbC005A60
lbC005A5E:          clr.w    d1
lbC005A60:          tst.w    d1
                    bne      _RANDMOVE
                    tst.w    d2
                    beq      lbC005A70
_RANDMOVE:          bsr      RANDMOVE
lbC005A70:          movem.l  (sp)+,a4
                    bra      lbC005A84

lbC005A78:          movem.l  a4,-(sp)
                    bsr      JOYMOVE
                    movem.l  (sp)+,a4
lbC005A84:          add.w    d1,d1
                    add.w    d2,d2
MOVE0_0:            tst.w    d2
                    beq      MOVE0_2
                    tst.w    d0
                    bne      lbC005AD2
                    move.w   S1MAPY,d3
                    move.w   d3,d5
                    move.w   S1MAPX,d6
                    tst.w    S1CT
                    beq      lbC005B0C
                    move.w   S1CT,d7
                    and.w    #$FF00,d7
                    cmp.w    #$F00,d7
                    beq      lbC005B0C
                    clr.w    d1
                    clr.w    d2
                    clr.w    SPYDIR
                    bra      lbC005B0C

lbC005AD2:          move.w   S2MAPY,d3
                    move.w   d3,d5
                    move.w   S2MAPX,d6
                    tst.w    S2CT
                    beq      lbC005B0C
                    move.w   S2CT,d7
                    and.w    #$FF00,d7
                    cmp.w    #$F00,d7
                    beq      lbC005B0C
                    clr.w    d1
                    clr.w    d2
                    clr.w    SPYDIR
lbC005B0C:          move.w   d3,d4
                    add.w    d2,d4
                    lsr.w    #4,d3
                    lsr.w    #4,d4
                    cmp.w    d3,d4
                    beq      MOVE0_2
                    lea      MAP,a0
                    move.w   SPYY,d3
                    lsr.w    #2,d3
                    mulu     MAXMAPX,d3
                    move.w   SPYX,d4
                    lsr.w    #2,d4
                    add.w    d4,d3
                    add.w    d3,d3
                    add.w    d3,a0
                    move.w   (a0),d3
                    lsr.w    #3,d3
                    cmp.w    #-2,d2
                    bne      lbC005B80
                    cmp.w    #50,d3
                    beq      MOVE0_2
                    tst.w    d0
                    bne      lbC005B64
                    tst.w    S1AUTO
                    beq      lbC005BC4
                    bra      MOVE0_7

lbC005B64:          tst.w    S2AUTO
                    beq      lbC005BC4
                    bra      MOVE0_7

                    move.w   #4,SPYDIR
                    move.w   #2,(a4)
                    rts

lbC005B80:          cmp.w    #2,d2
                    bne      lbC005BC4
                    cmp.w    #$31,d3
                    beq      MOVE0_2
                    tst.w    d0
                    bne      lbC005BA8
                    tst.w    S1AUTO
                    beq      lbC005BC4
                    bra      MOVE0_7

                    bra      lbC005BB6

lbC005BA8:          tst.w    S2AUTO
                    beq      lbC005BC4
                    bra      MOVE0_7

lbC005BB6:          move.w   #3,SPYDIR
                    move.w   #1,(a4)
                    rts

lbC005BC4:          clr.w    SPYDIR
                    clr.w    (a4)
                    rts

MOVE0_2:            move.w   MAXMAPX,d5
                    asl.w    #2,d5
                    move.w   MAXMAPY,d6
                    asl.w    #2,d6
                    moveq    #0,d3
                    move.w   SPYY,d3
                    add.w    d2,d3
                    lsr.w    #2,d3
                    mulu     MAXMAPX,d3
                    move.w   SPYX,d4
                    add.w    d1,d4
                    lsr.w    #2,d4
                    add.w    d4,d3
                    add.w    d3,d3
                    add.l    #MAP,d3
                    move.l   d3,a0
                    cmp.w    #93,d4
                    bhi      MOVE0_2_0
                    cmp.w    #1,d4
                    bls      MOVE0_2_0
                    move.w   (a0),d4
                    btst     #0,d4
                    beq      MOVE1_1
                    tst.w    d0
                    bne      lbC005CB4
                    tst.w    S1IGLOO
                    bne      lbC005C4E
                    move.w   S1AUTO,d3
                    beq      lbC005C4E
                    cmp.w    #50,S1ENERGY
                    bgt      MOVE0_2_0
lbC005C4E:          lea      S1SAVE_MAPX,a1
                    lea      S1SAVE_MAPY,a2
                    lea      S1SAVE_WINX,a3
                    lea      S1SAVE_WINY,a4
                    lea      S1IGLOO,a5
                    lea      S1HAND,a6
                    tst.w    S2IGLOO
                    beq      lbC005D36
                    move.w   S2SAVE_MAPX,d5
                    move.w   SPYX,d7
                    and.w    #$FFFC,d7
                    and.w    #$FFFC,d5
                    cmp.w    d5,d7
                    bne      lbC005D36
                    move.w   S2SAVE_MAPY,d5
                    move.w   SPYY,d7
                    and.w    #$FFF0,d7
                    and.w    #$FFF0,d5
                    cmp.w    d5,d7
                    beq      MOVE0_2_0
                    bra      lbC005D36

lbC005CB4:          tst.w    S2IGLOO
                    bne      lbC005CD4
                    move.w   S2AUTO,d3
                    beq      lbC005CD4
                    cmp.w    #50,S2ENERGY
                    bgt      MOVE0_2_0
lbC005CD4:          lea      S2SAVE_MAPX,a1
                    lea      S2SAVE_MAPY,a2
                    lea      S2SAVE_WINX,a3
                    lea      S2SAVE_WINY,a4
                    lea      S2IGLOO,a5
                    lea      S2HAND,a6
                    tst.w    S1IGLOO
                    beq      lbC005D36
                    move.w   S1SAVE_MAPX,d5
                    move.w   SPYX,d7
                    and.w    #$FFFC,d7
                    and.w    #$FFFC,d5
                    cmp.w    d5,d7
                    bne      lbC005D36
                    move.w   S1SAVE_MAPY,d5
                    move.w   SPYY,d7
                    and.w    #$FFF0,d7
                    and.w    #$FFF0,d5
                    cmp.w    d5,d7
                    beq      MOVE0_2_0
lbC005D36:          cmp.w    #$C9,(a0)
                    bne      lbC005D9E
                    cmp.w    #2,d1
                    bne      MOVE0_2_0
                    tst.w    (a6)
                    beq      lbC005D5E
                    tst.w    d3
                    beq      MOVE0_2_0
                    movem.l  d0-d7/a0-a6,-(sp)
                    bsr      BUSY4_A
                    movem.l  (sp)+,d0-d7/a0-a6
lbC005D5E:          move.w   SPYX,(a1)
                    move.w   SPYY,(a2)
                    move.w   SPYWX,(a3)
                    move.w   SPYWY,(a4)
                    move.w   #1,(a5)
                    move.w   #344,SPYX
                    move.w   #320,SPYWX
                    move.w   #12,SPYY
                    clr.w    SPYWY
                    bra      lbC005E28

lbC005D9E:          cmp.w    #$121,(a0)
                    bne      lbC005E06
                    cmp.w    #-2,d1
                    bne      MOVE0_2_0
                    tst.w    (a6)
                    beq      lbC005DC6
                    tst.w    d3
                    beq      MOVE0_2_0
                    movem.l  d0-d7/a0-a6,-(sp)
                    bsr      BUSY4_A
                    movem.l  (sp)+,d0-d7/a0-a6
lbC005DC6:          move.w   SPYX,(a1)
                    move.w   SPYY,(a2)
                    move.w   SPYWX,(a3)
                    move.w   SPYWY,(a4)
                    move.w   #1,(a5)
                    move.w   #276,SPYX
                    move.w   #256,SPYWX
                    move.w   #12,SPYY
                    clr.w    SPYWY
                    bra      lbC005E28

lbC005E06:          cmp.w    #$F9,(a0)
                    bne      MOVE0_2_0
                    move.w   (a1),SPYX
                    move.w   (a2),SPYY
                    move.w   (a3),SPYWX
                    move.w   (a4),SPYWY
                    clr.w    (a5)
lbC005E28:          tst.w    d0
                    bne      lbC005E40
                    move.w   #-1,BUF1Y
                    clr.w    S1NUDGE
                    bra      MOVE0_2_0

lbC005E40:          move.w   #-1,BUF2Y
                    clr.w    S2NUDGE
MOVE0_2_0:          tst.w    d0
                    bne      lbC005E80
                    move.w   SPYX,S1MAPX
                    move.w   SPYY,S1MAPY
                    move.w   SPYWX,WIN1X
                    move.w   SPYWY,WIN1Y
                    bra      lbC005EA8

lbC005E80:          move.w   SPYX,S2MAPX
                    move.w   SPYY,S2MAPY
                    move.w   SPYWX,WIN2X
                    move.w   SPYWY,WIN2Y
lbC005EA8:          cmp.w    #-2,d2
                    bne      MOVE0_2_0_A
                    move.w   (a0),d5
                    and.w    #$1F0,d5
                    cmp.w    #$1B0,d5
                    beq      lbC005EC6
                    cmp.w    #$1C0,d5
                    bne      MOVE0_2_0_A
lbC005EC6:          tst.w    d0
                    bne      lbC005EE6
                    lea      S1ENERGY,a1
                    move.l   #BUF13,S1FADDR
                    clr.w    S1F
                    bra      lbC005EFC

lbC005EE6:          move.l   #BUF23,S2FADDR
                    clr.w    S2F
                    lea      S2ENERGY,a1
lbC005EFC:          addq.w   #1,(a1)
                    cmp.w    #$3F,(a1)
                    ble      _MOVE0_9
                    move.w   #$3F,(a1)
_MOVE0_9:           bra      MOVE0_9

MOVE0_2_0_A:        tst.w    d0
                    bne      lbC005F36
                    lea      S1HAND,a1
                    lea      S1FUEL,a2
                    lea      S1BUMP,a3
                    lea      S1BDIR,a4
                    move.w   S1MAPY,d5
                    bra      lbC005F54

lbC005F36:          lea      S2HAND,a1
                    lea      S2FUEL,a2
                    lea      S2BUMP,a3
                    lea      S2BDIR,a4
                    move.w   S2MAPY,d5
lbC005F54:          move.w   (a0),d4
MOVE0_7:            tst.w    d0
                    bne      lbC005F6C
                    lea      S1BUMP,a3
                    lea      S1BDIR,a4
                    bra      lbC005F78

lbC005F6C:          lea      S2BUMP,a3
                    lea      S2BDIR,a4
lbC005F78:          move.w   (a4),d1
MOVE0_7_5:          and.w    #3,d1
                    bne      lbC005FA2
                    move.w   #1,d4
                    move.w   #3,d2
                    bsr      RNDER2
                    and.w    #1,d1
                    bne      lbC005FBE
                    move.w   #2,d4
                    move.w   #4,d2
                    bra      lbC005FBE

lbC005FA2:          move.w   #4,d4
                    move.w   #1,d2
                    bsr      RNDER2
                    and.w    #1,d1
                    bne      lbC005FBE
                    move.w   #8,d4
                    move.w   #2,d2
lbC005FBE:          move.w   d4,(a4)
                    move.w   d2,SPYDIR
                    bsr      RNDER2
                    and.w    #7,d1
                    tst.w    d0
                    bne      lbC005FDE
                    move.w   d1,S1NUDGE
                    bra      _MOVE0_8

lbC005FDE:          move.w   d1,S2NUDGE
_MOVE0_8:           bra      MOVE0_8

                    clr.w    (a4)
MOVE0_8:            clr.w    (a3)
MOVE0_9:            clr.w    SPYDIR
                    clr.w    d1
                    clr.w    d2
                    rts

MOVE1_1:            move.w   IQ,d3
                    tst.w    d0
                    bne      lbC006030
                    move.l   #S1BDIR,a5
                    move.w   S1WIN,d7
                    tst.w    S1AUTO
                    beq      lbC0060E4
                    tst.w    S1SAFE
                    bne      lbC0060E4
                    bra      lbC006050

lbC006030:          move.l   #S2BDIR,a5
                    move.w   S2WIN,d7
                    tst.w    S2AUTO
                    beq      lbC0060E4
                    tst.w    S2SAFE
                    bne      lbC0060E4
lbC006050:          cmp.w    #3,d7
                    beq      lbC006068
                    cmp.w    #$130,d4
                    bne      lbC006068
                    move.w   #5,d3
                    bra      lbC006078

lbC006068:          cmp.w    #$80,d4
                    blt      lbC0060E4
                    cmp.w    #$8F,d4
                    bgt      lbC0060E4
lbC006078:          movem.l  d0-d3/a0-a3,-(sp)
                    bsr      RNDER
                    and.w    #$F,d0
                    addq.w   #1,d0
                    move.w   d0,d7
                    movem.l  (sp)+,d0-d3/a0-a3
                    add.w    d3,d3
                    addq.w   #5,d3
                    cmp.w    d3,d7
                    bge      lbC00609E
                    clr.w    (a5)
                    bra      MOVE0_2_0

lbC00609E:          tst.w    d0
                    bne      lbC0060BE
                    tst.w    S1AUTO
                    beq      lbC0060E4
                    cmp.w    #3,S1WIN
                    beq      lbC0060D8
                    bra      lbC0060E4

lbC0060BE:          tst.w    S2AUTO
                    beq      lbC0060E4
                    cmp.w    #3,S2WIN
                    beq      lbC0060D8
                    bra      lbC0060E4

lbC0060D8:          movem.l  d0-d7/a0-a6,-(sp)
                    bsr      BUSY4_A
                    movem.l  (sp)+,d0-d7/a0-a6
lbC0060E4:          movem.l  d4-d6,-(sp)
                    tst.w    d0
                    bne      MOVE1_1_0
                    lea      S1DEPTH,a1
                    lea      S1ENERGY,a2
                    lea      S1WATERCT,a3
                    lea      S1SWAMP,a4
                    lea      S1DROWN,a5
                    lea      S1RUN,a6
                    move.w   S1HAND,d6
                    tst.w    S1DEAD
                    bne      MOVE1_1_1_9
                    bra      MOVE1_1_0_1

MOVE1_1_0:          lea      S2DEPTH,a1
                    lea      S2ENERGY,a2
                    lea      S2WATERCT,a3
                    lea      S2SWAMP,a4
                    lea      S2DROWN,a5
                    lea      S2RUN,a6
                    move.w   S2HAND,d6
                    tst.w    S2DEAD
                    bne      MOVE1_1_1_9
MOVE1_1_0_1:        move.w   (a0),d4
                    clr.w    (a5)
                    tst.w    d0
                    bne      lbC0061BE
                    move.l   a0,S1DIG
                    clr.w    S1TNTREADY
                    cmp.w    #$7E,d4
                    bne      MOVE1_1_0_1_5
                    cmp.w    #$58,S2HAND
                    beq      lbC006190
                    tst.w    S2PLUNGER
                    beq      lbC006198
lbC006190:          move.w   #-1,S1TNTREADY
lbC006198:          move.w   S2CT,d7
                    and.w    #$FF00,d7
                    cmp.w    #$5800,d7
                    bne      MOVE1_1_0_1_5
                    bsr      DELETE_TRAP
                    move.w   #$5900,d3
                    bsr      SETSTATE
                    movem.l  (sp)+,d4-d6
                    bra      MOVE1_1_Z

lbC0061BE:          clr.w    S2TNTREADY
                    move.l   a0,S2DIG
                    cmp.w    #$76,d4
                    bne      MOVE1_1_0_1_5
                    cmp.w    #$60,S1HAND
                    beq      lbC0061E8
                    tst.w    S1PLUNGER
                    beq      lbC0061F0
lbC0061E8:          move.w   #-1,S2TNTREADY
lbC0061F0:          move.w   S1CT,d7
                    and.w    #$FF00,d7
                    cmp.w    #$5800,d7
                    bne      MOVE1_1_0_1_5
                    move.w   #$5900,d3
                    bsr      SETSTATE
                    movem.l  (sp)+,d4-d6
                    bra      MOVE1_1_Z

MOVE1_1_0_1_5:      cmp.w    #$A8,d4
                    beq      lbC006222
                    cmp.w    #$B0,d4
                    bne      lbC00626A
lbC006222:          move.w   #1,(a5)
                    clr.w    (a6)
                    move.w   #$17,d4
                    cmp.w    (a1),d4
                    beq      lbC00624E
                    blt      lbC00624C
                    tst.w    (a1)
                    bne      lbC006246
                    move.l   #5,d7
                    bsr      NEW_SOUND
lbC006246:          addq.w   #1,(a1)
                    bra      lbC00624E

lbC00624C:          subq.w   #1,(a1)
lbC00624E:          move.w   COUNTER,d3
                    and.w    #7,d3
                    bne      lbC00625E
                    subq.w   #1,(a2)
lbC00625E:          move.w   #2,REFRESH
                    bra      lbC0062E8

lbC00626A:          tst.w    (a1)
                    beq      lbC0062E8
                    move.w   #$1500,d3
                    bsr      SETSTATE
                    tst.w    d0
                    bne      lbC0062B0
                    move.l   #BUF1D,S1FADDR
                    clr.w    S1F
                    cmp.w    #$A8,2(a0)
                    beq      lbC0062A4
                    cmp.w    #$B0,2(a0)
                    bne      lbC0062DE
lbC0062A4:          move.w   #1,S1F
                    bra      lbC0062DE

lbC0062B0:          move.l   #BUF2D,S2FADDR
                    clr.w    S2F
                    cmp.w    #$A8,2(a0)
                    beq      lbC0062D6
                    cmp.w    #$B0,2(a0)
                    bne      lbC0062DE
lbC0062D6:          move.w   #1,S2F
lbC0062DE:          clr.w    (a3)
                    movem.l  (sp)+,d4-d6
                    rts

lbC0062E8:          cmp.w    #$48,d6
                    beq      lbC0063EE
                    cmp.w    #$C0,(a0)
                    beq      lbC006310
                    cmp.w    #$80,(a0)
                    beq      lbC006330
                    cmp.w    #$1F0,(a0)
                    blt      lbC00636A
                    cmp.w    #$1FF,(a0)
                    bgt      lbC00636A
lbC006310:          move.l   d1,-(sp)
                    bsr      RNDER2
                    move.w   d1,d7
                    move.l   (sp)+,d1
                    and.w    #$F,d7
                    cmp.w    #7,d7
                    bne      lbC00636A
                    tst.w    d0
                    beq      lbC006340
                    bra      lbC006354

lbC006330:          tst.w    d0
                    bne      lbC00634A
                    tst.w    S1SAFE
                    bne      lbC00636A
lbC006340:          move.l   a0,S1DIG
                    bra      lbC00635A

lbC00634A:          tst.w    S2SAFE
                    bne      lbC00636A
lbC006354:          move.l   a0,S2DIG
lbC00635A:          move.w   #$5400,d3
                    bsr      SETSTATE
                    movem.l  (sp)+,d4-d6
                    bra      MOVE1_1_Z

lbC00636A:          cmp.w    #$88,(a0)
                    bne      lbC0063AC
                    tst.w    d0
                    bne      lbC00638C
                    tst.w    S1SAFE
                    bne      lbC0063AC
                    move.l   a0,S1DIG
                    bra      lbC00639C

lbC00638C:          tst.w    S2SAFE
                    bne      lbC0063AC
                    move.l   a0,S2DIG
lbC00639C:          move.w   #$5100,d3
                    bsr      SETSTATE
                    movem.l  (sp)+,d4-d6
                    bra      MOVE1_1_Z

lbC0063AC:          cmp.w    #$130,(a0)
                    bne      lbC0063EE
                    tst.w    d0
                    bne      lbC0063CE
                    tst.w    S1SAFE
                    bne      lbC0063EE
                    move.l   a0,S1DIG
                    bra      lbC0063DE

lbC0063CE:          tst.w    S2SAFE
                    bne      lbC0063EE
                    move.l   a0,S2DIG
lbC0063DE:          move.w   #$5700,d3
                    bsr      SETSTATE
                    movem.l  (sp)+,d4-d6
                    bra      MOVE1_1_Z

lbC0063EE:          cmp.w    #$98,(a0)
                    bne      lbC006430
                    tst.w    d0
                    bne      lbC006410
                    tst.w    S1SAFE
                    bne      lbC006430
                    move.l   a0,S1DIG
                    bra      lbC006420

lbC006410:          tst.w    S2SAFE
                    bne      lbC006430
                    move.l   a0,S2DIG
lbC006420:          move.w   #$5600,d3
                    bsr      SETSTATE
                    movem.l  (sp)+,d4-d6
                    bra      MOVE1_1_Z

lbC006430:          clr.w    (a4)
                    cmp.w    #$48,d6
                    beq      MOVE1_1_1_9
                    cmp.w    #$B8,(a0)
                    beq      MOVE1_1_1_0
                    cmp.w    #$1D0,(a0)
                    blt      MOVE1_1_1_9
                    cmp.w    #$1EF,(a0)
                    bgt      MOVE1_1_1_9
MOVE1_1_1_0:        move.w   #5,(a4)
                    move.w   COUNTER,d4
                    tst.w    (a2)
                    beq      MOVE1_1_1_9
                    subq.w   #1,(a2)
MOVE1_1_1_9:        movem.l  (sp)+,d4-d6
                    tst.w    d0
                    bne      MOVE1_1_A_0
                    tst.w    S1SWAMP
                    bne      MOVE1_1_Z
                    tst.w    S1DEPTH
                    bne      MOVE1_1_Z
                    tst.w    S1SAFE
                    bne      MOVE1_1_A_3
                    bra      MOVE1_1_A_5

MOVE1_1_A_0:        tst.w    S2SWAMP
                    bne      MOVE1_1_Z
                    tst.w    S2DEPTH
                    bne      MOVE1_1_Z
                    tst.w    S2SAFE
                    bne      MOVE1_1_A_3
                    bra      MOVE1_1_A_5

MOVE1_1_A_3:        move.w   d1,d3
                    add.w    d2,d3
                    beq      MOVE1_1_Z
                    tst.w    d0
                    bne      MOVE1_1_A_4
                    subq.w   #1,S1SAFE
                    bra      MOVE1_1_Z

MOVE1_1_A_4:        subq.w   #1,S2SAFE
                    bra      MOVE1_1_Z

MOVE1_1_A_5:        move.w   (a0),d4
                    and.w    #$FFF8,d4
MOVE1_1_Z:          add.w    d1,SPYX
                    add.w    d2,SPYY
                    bmi      MOVEABORT
                    tst.w    d0
                    bne      MOVE1_1_Z_3
                    tst.w    S1IGLOO
                    bne      MOVE1_1_2
                    movem.l  d0/d1/a0,-(sp)
                    move.w   SPYX,d0
                    lsr.w    #2,d0
                    divu     #10,d0
                    lsl.w    #8,d0
                    move.w   SPYY,d1
                    lsr.w    #4,d1
                    or.w     d1,d0
                    cmp.w    S1TRAIL,d0
                    beq      lbC006540
                    lea      S1TRAIL,a0
                    moveq    #8,d1
                    add.l    d1,a0
lbC00652E:          move.w   (a0),2(a0)
                    sub.w    #2,a0
                    sub.w    #2,d1
                    bge.b    lbC00652E
                    move.w   d0,2(a0)
lbC006540:          movem.l  (sp)+,d0/d1/a0
                    tst.w    S2DEAD
                    bne      MOVE1_1_2
                    move.w   SPYX,d3
                    sub.w    S2MAPX,d3
                    bge      MOVE1_1_Z_1
                    neg.w    d3
MOVE1_1_Z_1:        cmp.w    #4,d3
                    bge      MOVE1_1_2
                    move.w   SPYY,d3
                    move.w   S2MAPY,d4
                    lsr.w    #4,d3
                    lsr.w    #4,d4
                    cmp.w    d3,d4
                    bne      MOVE1_1_2
                    move.w   SPYY,d3
                    sub.w    S2MAPY,d3
                    bge      MOVE1_1_Z_2
                    neg.w    d3
MOVE1_1_Z_2:        cmp.w    #3,d3
                    bmi      MOVEABORT
                    bra      MOVE1_1_2

MOVE1_1_Z_3:        tst.w    S2IGLOO
                    bne      MOVE1_1_2
                    movem.l  d0/d1/a0,-(sp)
                    move.w   SPYX,d0
                    lsr.w    #6,d0
                    lsl.w    #8,d0
                    move.w   SPYY,d1
                    lsr.w    #4,d1
                    or.w     d1,d0
                    cmp.w    S2TRAIL,d0
                    beq      lbC0065E8
                    move.l   #S2TRAIL,a0
                    moveq    #8,d1
                    add.l    d1,a0
lbC0065D6:          move.w   (a0),2(a0)
                    subq.w   #2,a0
                    subq.w   #2,d1
                    bge.b    lbC0065D6
                    move.w   d0,2(a0)
lbC0065E8:          movem.l  (sp)+,d0/d1/a0
                    tst.w    S1DEAD
                    bne      MOVE1_1_2
                    move.w   SPYX,d3
                    sub.w    S1MAPX,d3
                    bge      MOVE1_1_Z_4
                    neg.w    d3
MOVE1_1_Z_4:        cmp.w    #4,d3
                    bge      MOVE1_1_2
                    move.w   SPYY,d3
                    move.w   S1MAPY,d4
                    lsr.w    #4,d3
                    lsr.w    #4,d4
                    cmp.w    d3,d4
                    bne      MOVE1_1_2
                    move.w   SPYY,d3
                    sub.w    S1MAPY,d3
                    bge      MOVE1_1_Z_5
                    neg.w    d3
MOVE1_1_Z_5:        cmp.w    #3,d3
                    bmi      MOVEABORT
MOVE1_1_2:          tst.w    SPYX
                    bmi      MOVEABORT
                    tst.w    d1
                    bne      lbC006656
                    tst.w    d2
                    beq      _CHECKMEET1
lbC006656:          tst.w    FEET_FLAG
                    bne      _CHECKMEET1
                    addq.w   #1,FEET_FLAG
                    addq.w   #1,FEET_COUNT
                    move.w   FEET_COUNT,d7
                    and.w    #1,d7
                    bne      _CHECKMEET1
                    move.l   #11,d7
                    bsr      NEW_SOUND
_CHECKMEET1:        bsr      CHECKMEET
                    move.w   SPYWIN,d3
                    tst.w    d3
                    beq      MOVE1_1_5
                    subq.w   #1,d3
                    cmp.w    d0,d3
                    bne      MOVEEND
MOVE1_1_5:          tst.w    d1
                    beq      MOVE2_0
                    move.w   SPYX,d3
                    subq.w   #4,d3
                    sub.w    SPYWX,d3
                    bgt      MOVE1_2
                    move.w   SPYX,d3
                    cmp.w    #4,d3
                    ble      MOVEABORT
                    subq.w   #2,SPYWX
                    rts

MOVE1_2:            move.w   SPYX,d3
                    sub.w    SPYWX,d3
                    sub.w    #36,d3
                    blt      MOVEEND
                    addq.w   #2,SPYWX
MOVEEND:            rts

MOVE2_0:            move.w   SPYY,d3
                    sub.w    SPYWY,d3
                    bge      MOVE2_2
                    move.w   SPYWY,d3
                    ble      MOVEABORT
                    move.w   #16,d3
                    sub.w    d3,SPYWY
                    rts

MOVE2_2:            move.w   SPYY,d3
                    sub.w    SPYWY,d3
                    sub.w    #16,d3
                    blt.b    MOVEEND
                    move.w   SPYY,d3
                    sub.w    d6,d3
                    bge      MOVEABORT
                    move.w   #16,d3
                    add.w    d3,SPYWY
                    rts

MOVEABORT:          tst.w    d0
                    bne      lbC006756
                    lea      S1BDIR,a4
                    clr.w    S1BUMP
                    clr.w    S1BDIR
                    bra      lbC006768

lbC006756:          lea      S2BDIR,a4
                    clr.w    S2BUMP
                    clr.w    S2BDIR
lbC006768:          sub.w    d1,SPYX
                    sub.w    d2,SPYY
                    bra      MOVE0_7

CHECKMEET:          movem.l  d0-d7/a0-a6,-(sp)
                    move.w   d1,d4
                    move.w   d2,d5
                    move.w   S1MAPY,d1
                    move.w   S2MAPY,d2
                    and.w    #$FFF0,d1
                    and.w    #$FFF0,d2
                    move.w   d1,WIN1Y
                    move.w   d2,WIN2Y
                    cmp.w    d1,d2
                    bne      SEPARATE
                    tst.w    S1IGLOO
                    bne      SEPARATE
                    tst.w    S2IGLOO
                    bne      SEPARATE
                    tst.w    SPYWIN
                    beq      lbC0067D4
                    move.w   SPYWIN,d1
                    sub.w    #1,d1
                    cmp.w    d0,d1
                    beq      CHECKMEETBYE
lbC0067D4:          tst.w    d0
                    bne      lbC00681A
                    move.w   WIN2X,d2
                    addq.w   #4,d2
                    move.w   S1MAPX,d1
                    cmp.w    d2,d1
                    blt      SEPARATE
                    add.w    #32,d2
                    cmp.w    d2,d1
                    bge      SEPARATE
                    move.w   WIN2Y,SPYWY
                    move.w   WIN2X,SPYWX
                    move.w   #2,SPYWIN
                    bra      FORCE_DRAW

lbC00681A:          move.w   WIN1X,d2
                    addq.w   #4,d2
                    move.w   S2MAPX,d1
                    cmp.w    d2,d1
                    blt      SEPARATE
                    add.w    #32,d2
                    cmp.w    d2,d1
                    bge      SEPARATE
                    move.w   WIN1Y,SPYWY
                    move.w   WIN1X,SPYWX
                    move.w   #1,SPYWIN
FORCE_DRAW:         move.w   #-1,BUF1Y
                    move.w   #-1,BUF2Y
                    bra      CHECKMEETBYE

                    movem.l  d0-d7/a0-a6,-(sp)
                    move.w   S1MAPY,d1
                    move.w   S2MAPY,d2
                    and.w    #$F0,d1
                    and.w    #$F0,d2
                    move.w   d1,WIN1Y
                    move.w   d2,WIN2Y
                    cmp.w    d1,d2
                    bne      SEPARATE
                    move.w   S1MAPX,d1
                    sub.w    S2MAPX,d1
                    bge      lbC0068A6
                    neg.w    d1
lbC0068A6:          cmp.w    #32,d1
                    bgt      SEPARATE
                    tst.w    SPYWIN
                    bne      CHECKMEET1
                    tst.w    d0
                    bne      lbC0068D4
                    move.w   S1CT,d1
                    move.w   WIN1X,d2
                    move.w   WIN1Y,d3
                    bra      lbC0068E6

lbC0068D4:          move.w   S2CT,d1
                    move.w   WIN2X,d2
                    move.w   WIN2Y,d3
lbC0068E6:          move.w   #2,SPYWIN
                    sub.w    d0,SPYWIN
                    move.w   d0,SPYWIN
                    add.w    #1,SPYWIN
                    move.w   d2,SPYWX
                    move.w   d3,SPYWY
CHECKMEET1:         moveq    #0,d2
lbC006910:          move.w   S1MAPX,d1
                    sub.w    SPYWX,d1
                    subq.w   #4,d1
                    bgt      lbC00693E
                    cmp.w    #1,SPYWIN
                    beq      SEPARATE
                    addq.w   #1,d2
                    subq.w   #2,SPYWX
                    bra.b    lbC006910

lbC00693E:          move.w   S1MAPX,d1
                    sub.w    SPYWX,d1
                    sub.w    #32,d1
                    blt      lbC00696C
                    cmp.w    #1,SPYWIN
                    beq      SEPARATE
                    addq.w   #1,d2
                    addq.w   #2,SPYWX
                    bra.b    lbC00693E

lbC00696C:          move.w   S2MAPX,d1
                    sub.w    SPYWX,d1
                    subq.w   #4,d1
                    bgt      lbC00699A
                    addq.w   #1,d2
                    cmp.w    #2,SPYWIN
                    beq      SEPARATE
                    subq.w   #2,SPYWX
                    bra.b    lbC00696C

lbC00699A:          move.w   S2MAPX,d1
                    sub.w    SPYWX,d1
                    sub.w    #32,d1
                    blt      CHECKMEETEND
                    cmp.w    #2,SPYWIN
                    beq      SEPARATE
                    addq.w   #1,d2
                    addq.w   #2,SPYWX
                    bra.b    lbC00699A

CHECKMEETEND:       cmp.w    #1,d2
                    ble      CHECKMEETBYE
                    move.w   #-1,BUF1Y
                    move.w   #-1,BUF2Y
CHECKMEETBYE:       movem.l  (sp)+,d0-d7/a0-a6
                    rts

SEPARATE:           tst.w    SPYWIN
                    beq.b    CHECKMEETBYE
                    move.w   #-1,BUF1Y
                    move.w   #-1,BUF2Y
                    move.w   SPYWIN,d1
                    clr.w    SPYWIN
                    cmp.w    #2,d1
                    bne      lbC006A32
                    move.w   S1MAPX,d1
                    sub.w    #21,d1
                    cmp.w    #2,d1
                    bgt      lbC006A28
                    move.w   #2,d1
lbC006A28:          move.w   d1,WIN1X
                    bra      _SETTEMPS

lbC006A32:          move.w   S2MAPX,d1
                    sub.w    #21,d1
                    cmp.w    #2,d1
                    bgt      lbC006A48
                    move.w   #2,d1
lbC006A48:          move.w   d1,WIN2X
_SETTEMPS:          bsr      SETTEMPS
                    movem.l  (sp)+,d0-d7/a0-a6
                    rts

SETTEMPS:           tst.w    d0
                    bne      lbC006A8A
                    move.w   WIN1X,SPYWX
                    move.w   WIN1Y,SPYWY
                    move.w   S1MAPX,SPYX
                    move.w   S1MAPY,SPYY
                    bra      lbC006AB2

lbC006A8A:          move.w   WIN2X,SPYWX
                    move.w   WIN2Y,SPYWY
                    move.w   S2MAPX,SPYX
                    move.w   S2MAPY,SPYY
lbC006AB2:          rts

DIRFIX:             movem.l  d1/d2,-(sp)
                    move.w   SPYDIR,d2
                    tst.w    d0
                    bne      BODY2_0
                    cmp.w    #2,d2
                    bne      BODY1_1
                    move.l   #BUF11,S1FADDR
                    bra      BODY1_20

BODY1_1:            cmp.w    #1,d2
                    bne      BODY1_2
                    move.l   #BUF12,S1FADDR
                    bra      BODY1_20

BODY1_2:            cmp.w    #3,d2
                    bne      BODY1_3
                    move.l   #BUF13,S1FADDR
                    bra      BODY1_20

BODY1_3:            cmp.w    #4,d2
                    bne      BODY1_80
                    move.l   #BUF14,S1FADDR
BODY1_20:           move.w   S1F,d1
                    addq.w   #1,d1
                    cmp.w    #4,d1
                    bne      BODY1_20_1
                    clr.w    d1
BODY1_20_1:         move.w   d1,S1F
                    bra      BODY1_99

BODY1_80:           clr.w    S1F
BODY1_99:           movem.l  (sp)+,d1/d2
                    rts

BODY2_0:            cmp.w    #2,d2
                    bne      BODY2_1
                    move.l   #BUF21,S2FADDR
                    bra      BODY2_20

BODY2_1:            cmp.w    #1,d2
                    bne      BODY2_2
                    move.l   #BUF22,S2FADDR
                    bra      BODY2_20

BODY2_2:            cmp.w    #3,d2
                    bne      BODY2_3
                    move.l   #BUF23,S2FADDR
                    bra      BODY2_20

BODY2_3:            cmp.w    #4,d2
                    bne      BODY2_80
                    move.l   #BUF24,S2FADDR
BODY2_20:           move.w   S2F,d1
                    addq.w   #1,d1
                    cmp.w    #4,d1
                    bne      BODY2_20_1
                    clr.w    d1
BODY2_20_1:         move.w   d1,S2F
                    bra      BODY2_99

BODY2_80:           clr.w    S2F
BODY2_99:           movem.l  (sp)+,d1/d2
                    rts

TEST_OPTIONS:       tst.w    SPECIAL_DELAY
                    beq      _TEST_M
                    subq.w   #1,SPECIAL_DELAY
                    bra      lbC006BE0

_TEST_M:            bra      TEST_M
lbC006BE0:          rts

TEST_M:             move.w   #$37,d0
                    bsr      INKEY
                    beq      lbC006C4C
                    move.w   #20,SPECIAL_DELAY
                    tst.w    MUSIC_SWITCH
                    bne      lbC006C22
                    move.w   #-1,lbW001F2E
                    move.w   #-1,lbW001F48
                    move.w   #-1,lbW001F62
                    move.w   #1,MUSIC_SWITCH
                    rts

lbC006C22:          clr.w    MUSIC_SWITCH
                    clr.w    lbW001F2E
                    clr.w    lbW001F48
                    clr.w    lbW001F62
                    clr.w    $DFF0A8
                    clr.w    $DFF0B8
                    clr.w    $DFF0C8
lbC006C4C:          rts

JOYMOVE:            movem.l  d0/d7/a0,-(sp)
                    move.w   d0,d7
                    bsr      SCAN_JOY
                    bsr      TEST_OPTIONS
                    move.w   #$19,d0
                    bsr      INKEY
                    beq      JM2
_LITTLE_DELAY:      bsr      LITTLE_DELAY
                    move.w   #$19,d0
                    bsr      INKEY
                    bne.b    _LITTLE_DELAY
_TEST_OPTIONS:      bsr      TEST_OPTIONS
                    bsr      LITTLE_DELAY
                    move.w   #$19,d0
                    bsr      INKEY
                    beq.b    _TEST_OPTIONS
_LITTLE_DELAY0:     bsr      LITTLE_DELAY
                    move.w   #$19,d0
                    bsr      INKEY
                    bne.b    _LITTLE_DELAY0
JM2:                move.w   #$45,d0
                    bsr      INKEY
                    beq      JM3
lbC006CA2:          move.w   #$45,d0
                    bsr      INKEY
                    bne.b    lbC006CA2
                    move.w   #1,ABORT
JM3:                move.w   d7,d0
                    tst.w    BRAINON
                    bne      lbC006D58
                    moveq    #0,d1
                    moveq    #0,d2
                    clr.w    SPYDIR
                    tst.w    d0
                    bne      lbC006CE4
                    tst.w    S1DEAD
                    bne      lbC006D58
                    move.w   S1MODE,d7
                    bra      lbC006CF4

lbC006CE4:          tst.w    S2DEAD
                    bne      lbC006D58
                    move.w   S2MODE,d7
lbC006CF4:          add.w    d7,d7
                    add.w    d7,d7
                    lea      JOY_TABLE,a0
                    move.l   0(a0,d7.w),a0
                    tst.b    (a0)+
                    beq      lbC006D18
                    move.w   #-1,d1
                    moveq    #0,d2
                    move.w   #1,SPYDIR
                    bra      lbC006D58

lbC006D18:          tst.b    (a0)+
                    beq      lbC006D30
                    move.w   #1,d1
                    moveq    #0,d2
                    move.w   #2,SPYDIR
                    bra      lbC006D58

lbC006D30:          tst.b    (a0)+
                    beq      lbC006D46
                    moveq    #0,d1
                    moveq    #-1,d2
                    move.w   #3,SPYDIR
                    bra      lbC006D58

lbC006D46:          tst.b    (a0)+
                    beq      lbC006D58
                    moveq    #0,d1
                    moveq    #1,d2
                    move.w   #4,SPYDIR
lbC006D58:          clr.w    BRAINON
                    movem.l  (sp)+,d0/d7/a0
                    rts

JOY_TABLE:          dc.l     LEFT1
                    dc.l     MLEFT0
                    dc.l     KLEFT1
                    dc.l     LEFT0
                    dc.l     MLEFT1

SETWINDOW:          cmp.w    #1,SPYWIN
                    beq      SETWINDOW1
                    cmp.w    #2,SPYWIN
                    beq      SETWINDOW2
                    tst.w    d0
                    bne      SETWINDOW2
SETWINDOW1:         move.w   WIN1X,SPYWX
                    move.w   WIN1Y,SPYWY
                    rts

SETWINDOW2:         move.w   WIN2X,SPYWX
                    move.w   WIN2Y,SPYWY
                    rts

GETWINDOW:          cmp.w    #1,SPYWIN
                    beq      GETWINDOW1
                    cmp.w    #2,SPYWIN
                    beq      GETWINDOW2
                    tst.w    d0
                    bne      GETWINDOW2
GETWINDOW1:         move.w   SPYWX,WIN1X
                    move.w   SPYWY,WIN1Y
                    rts

GETWINDOW2:         move.w   SPYWX,WIN2X
                    move.w   SPYWY,WIN2Y
                    rts

LITTLE_DELAY:       move.w   d0,-(sp)
                    move.w   #62769-1,d0
.WAIT:              dbra     d0,.WAIT
                    move.w   (sp)+,d0
                    rts

FEET_COUNT:         dc.w     0
FEET_FLAG:          dc.w     0

DRAWMOVE:           moveq    #0,d0
                    moveq    #0,d3
                    bsr      FLASH
                    clr.w    d3
                    clr.w    d0
DRAWMOVE0:          cmp.w    #2,SPYWIN
                    beq      DRAWMOVE0_1
                    bsr      DRAWLAND
                    bsr      DRAWOBJ
NOLAND:             bra      DRAWMOVE1

DRAWMOVE0_1:        move.l   SCREEN2,a0
                    move.w   #64,d1
                    move.w   #10,d2
                    move.w   #62,d7
                    move.w   #19,d6
                    bsr      RCLEARBLOCK
DRAWMOVE1:          move.w   #1,d0
                    move.w   S2CT,d1
                    beq      DRAWMOVE2
                    and.w    #$FF00,d1
                    cmp.w    #$800,d1
                    bge      DRAWMOVE2
                    cmp.w    #$200,d1
                    beq      DRAWMOVE2
DRAWMOVE2:          cmp.w    #1,SPYWIN
                    beq      DRAWMOVE2_1
                    bsr      DRAWLAND
                    bsr      DRAWOBJ
NOLAND2:            bra      DRAWMOVE3

DRAWMOVE2_1:        move.l   SCREEN2,a0
                    move.w   #64,d1
                    move.w   #111,d2
                    move.w   #62,d7
                    move.w   #19,d6
                    bsr      RCLEARBLOCK
DRAWMOVE3:          bsr      DRAWBUTTONS
                    moveq    #0,d0
                    bsr      DRAWBUTTONS
                    bsr      DRAWTIME
                    tst.w    S1ENERGY
                    bge      DRAWMOVE4
                    move.w   #-1,S1ENERGY
                    tst.w    S1DEAD
                    bne      DRAWMOVE4
                    tst.w    S1CT
                    bne      DRAWMOVE4
                    move.w   #$1400,S1CT
                    tst.w    S1DROWN
                    bne      DRAWMOVE4
DRAWMOVE4:          tst.w    S2ENERGY
                    bge      DRAWMOVE5
                    move.w   #-1,S2ENERGY
                    tst.w    S2DEAD
                    bne      DRAWMOVE5
                    tst.w    S2CT
                    bne      DRAWMOVE5
                    move.w   #$1400,S2CT
                    tst.w    S2DROWN
                    bne      DRAWMOVE5
DRAWMOVE5:          bsr      METER
                    bsr      MOVE_SNOWBALL
                    bsr      RSNOWING
                    bsr      RLINES
                    rts

RLINES:             tst.w    TENMINS
                    bne      lbC006FE0
                    tst.w    ONEMINS
                    bne      lbC006FE0
                    addq.w   #1,SNOW_LINE
                    move.w   SNOW_LINE,d1
                    lsr.w    #5,d1
                    move.l   SCREEN2,a0
                    move.l   a0,a1
                    lea      (73*40)+8(a0),a0
                    lea      (174*40)+8(a1),a1
                    tst.w    d1
                    beq      lbC006FE0
lbC006F78:          move.w   #10-1,d3
lbC006F7C:          tst.w    S1IGLOO
                    bne      lbC006FA6
                    cmp.w    #2,SPYWIN
                    beq      lbC006FA6
                    clr.w    (a0)+
                    move.w   #-1,(200*40)-2(a0)
                    move.w   #-1,(200*2*40)-2(a0)
                    move.w   #-1,(200*3*40)-2(a0)
lbC006FA6:          tst.w    S2IGLOO
                    bne      lbC006FD0
                    cmp.w    #1,SPYWIN
                    beq      lbC006FD0
                    clr.w    (a1)+
                    move.w   #-1,(200*40)-2(a1)
                    move.w   #-1,(200*2*40)-2(a1)
                    move.w   #-1,(200*3*40)-2(a1)
lbC006FD0:          dbra     d3,lbC006F7C
                    lea      -60(a0),a0
                    lea      -60(a1),a1
                    dbra     d1,lbC006F78
lbC006FE0:          rts

MOVE_SNOWBALL:      moveq    #0,d5
                    moveq    #0,d6
                    move.w   S1MAPY,d5
                    lsr.w    #2,d5
                    mulu     MAXMAPX,d5
                    move.w   S1MAPX,d7
                    lsr.w    #2,d7
                    add.w    d7,d5
                    add.w    d5,d5
                    add.l    #MAP,d5
                    move.w   S2MAPY,d6
                    lsr.w    #2,d6
                    mulu     MAXMAPX,d6
                    move.w   S2MAPX,d7
                    lsr.w    #2,d7
                    add.w    d7,d6
                    add.w    d6,d6
                    add.l    #MAP,d6
                    move.w   #8-1,d7
                    lea      SNOW_LIST,a0
lbC007030:          move.l   (a0),d1
                    beq      lbC007106
                    move.w   6(a0),d2
                    ext.l    d2
                    add.l    d2,d1
                    move.l   d1,(a0)
                    btst     #0,d1
                    bne      lbC007106
                    subq.w   #2,4(a0)
                    cmp.w    #8,4(a0)
                    blt      lbC007104
                    move.l   d1,a1
                    move.w   (a1),d2
                    and.w    #1,d2
                    bne      lbC007104
                    cmp.w    #$40,4(a0)
                    blt      lbC007106
                    tst.w    8(a0)
                    beq      lbC0070BA
                    move.l   d1,d3
                    sub.l    d5,d3
                    tst.w    6(a0)
                    bpl      lbC00708E
                    tst.l    d3
                    beq      lbC007098
                    bra      lbC0070BA

lbC00708E:          tst.l    d3
                    bne      lbC0070BA
lbC007098:          cmp.b    #80,S1CT
                    beq      lbC0070AE
                    tst.w    S1CT
                    bne      lbC007106
lbC0070AE:          move.w   #2304,S1CT
                    bra      lbC007104

lbC0070BA:          tst.w    8(a0)
                    bne      lbC007106
                    move.l   d1,d3
                    sub.l    d6,d3
                    tst.w    6(a0)
                    bpl      lbC0070DC
                    tst.l    d3
                    beq      lbC0070E6
                    bra      lbC007106

lbC0070DC:          tst.l    d3
                    bne      lbC007106
lbC0070E6:          cmp.b    #80,S2CT
                    beq      lbC0070FC
                    tst.w    S2CT
                    bne      lbC007106
lbC0070FC:          move.w   #2304,S2CT
lbC007104:          clr.l    (a0)
lbC007106:          lea      10(a0),a0
                    dbra     d7,lbC007030
                    rts

DRAWLAND:           tst.w    d0
                    bne      DRAWLAND0_0
                    move.l   S1FADDR,d1
                    sub.l    #BUF11,d1
                    move.l   #S1BACK,WHICHBACK
                    move.w   WIN1X,d2
                    move.w   WIN1Y,d3
                    move.w   BUF1X,d4
                    move.w   BUF1Y,d5
                    move.w   #50,ULX
                    move.w   #10,ULY
                    move.w   d2,BUF1X
                    move.w   d3,BUF1Y
                    bra      DRAWLAND0_1

DRAWLAND0_0:        move.l   S2FADDR,d1
                    sub.l    #BUF21,d1
                    move.l   #S2BACK,WHICHBACK
                    move.w   WIN2X,d2
                    move.w   WIN2Y,d3
                    move.w   BUF2X,d4
                    move.w   BUF2Y,d5
                    move.w   #50,ULX
                    move.w   #111,ULY
                    move.w   d2,BUF2X
                    move.w   d3,BUF2Y
DRAWLAND0_1:        movem.l  d0-d5,-(sp)
                    lsr.w    #4,d3
                    add.w    d3,d3
                    subq.w   #1,d2
                    lsr.w    #2,d2
                    add.w    d2,d2
                    mulu     #96,d3
                    add.w    d2,d3
                    move.l   d3,a0
                    add.l    #TERRAIN,a0
                    movem.l  (sp),d0-d5
                    subq.w   #1,d2
                    subq.w   #1,d4
                    lsr.w    #2,d2
                    lsr.w    #4,d3
                    lsr.w    #2,d4
                    lsr.w    #4,d5
                    cmp.w    d3,d5
                    bne      DRAWLAND1_0
                    cmp.w    d2,d4
                    beq      DRAWLAND5_0
DRAWLAND1_0:        move.w   #11-1,d1
                    moveq    #0,d3
DRAWLAND1_1:        move.w   (a0)+,d4
                    bsr      DRAWSLAB
                    addq.w   #1,d3
                    dbra     d1,DRAWLAND1_1
DRAWLAND5_0:        movem.l  (sp)+,d0-d5
                    lea      $DFF000,a2
                    move.l   WHICHBACK,a1
                    move.l   SCREEN2,a0
                    move.w   ULY,d1
                    lsl.w    #3,d1
                    add.w    d1,a0
                    add.w    d1,d1
                    add.w    d1,d1
                    add.w    d1,a0
                    addq.w   #6,a0
                    clr.w    $42(a2)
                    and.w    #3,d2
                    neg.w    d2
                    add.w    #4,d2
                    and.w    #3,d2
                    lsl.w    #2,d2
                    ror.w    #4,d2
                    or.w     #$9F0,d2
                    move.w   d2,$40(a2)
                    clr.w    $64(a2)
                    move.w   #18,$66(a2)
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   #(64<<6)+11,$58(a2)
                    lea      1408(a1),a1
                    lea      (200*40)(a0),a0
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   #(64<<6)+11,$58(a2)
                    lea      1408(a1),a1
                    lea      (200*40)(a0),a0
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   #(64<<6)+11,$58(a2)
                    lea      1408(a1),a1
                    lea      (200*40)(a0),a0
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   #(64<<6)+11,$58(a2)
                    bra      WAIT_BLIT

ONE_SLAB:           movem.l  d0-d4/a0-a4,-(sp)
                    lea      $DFF000,a2
                    tst.w    d4
                    bpl      lbC0072BC
                    moveq    #0,d4
lbC0072BC:          mulu     #520,d4
                    lea      LAND,a1
                    add.l    d4,a1
                    move.l   (a1),a4
                    addq.w   #8,a1
                    move.l   WHICHBACK,a0
                    add.w    d3,d3
                    add.w    d3,a0
                    move.w   #$8440,$96(a2)
                    move.l   #-1,$44(a2)
                    clr.w    $42(a2)
                    move.w   #$9F0,$40(a2)
                    move.w   #0,$64(a2)
                    move.w   #20,$66(a2)
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    add.w    a4,a1
                    lea      1408(a0),a0
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    add.w    a4,a1
                    lea      1408(a0),a0
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    add.w    a4,a1
                    lea      1408(a0),a0
                    bsr      WAIT_BLIT
                    move.l   a1,$50(a2)
                    move.l   a0,$54(a2)
                    move.w   d7,$58(a2)
                    bsr      WAIT_BLIT
                    movem.l  (sp)+,d0-d4/a0-a4
                    rts

DRAWSLAB:           movem.l  d3/d4,-(sp)
                    move.w   #(64<<6)+1,d7
                    bsr      ONE_SLAB
                    movem.l  (sp)+,d3/d4
                    rts

FIRE_IN_HERE:       movem.l  d2/d3,-(sp)
                    tst.w    d0
                    bne      lbC007386
                    tst.w    S1IGLOO
                    beq      lbC0073B4
                    move.w   S1SAVE_MAPY,d2
                    bra      lbC007396

lbC007386:          tst.w    S2IGLOO
                    beq      lbC0073B4
                    move.w   S2SAVE_MAPY,d2
lbC007396:          lsr.w    #4,d2
                    move.w   YIGLOO1,d3
                    lsr.w    #2,d3
                    cmp.w    d2,d3
                    beq      lbC0073B4
                    move.w   YIGLOO2,d3
                    lsr.w    #2,d3
                    cmp.w    d2,d3
                    bne      lbC0073BC
lbC0073B4:          moveq    #-1,d2
lbC0073B6:          movem.l  (sp)+,d2/d3
                    rts

lbC0073BC:          clr.w    d2
                    bra.b    lbC0073B6

DRAWOBJ:            bsr.b    FIRE_IN_HERE
                    beq      DRAWSPYOBJ
DRAWOBJ2:           tst.w    d0
                    bne      DRAWOBJ1_0
                    move.w   WIN1X,d1
                    move.w   WIN1Y,d2
                    move.w   #50,ULX
                    move.w   #2,ULY
                    lea      S1DEPTH,a0
                    bra      DRAWOBJ1_1

DRAWOBJ1_0:         move.w   WIN2X,d1
                    move.w   WIN2Y,d2
                    move.w   #50,ULX
                    move.w   #103,ULY
                    lea      S2DEPTH,a0
DRAWOBJ1_1:         move.w   d1,d3
                    lsr.w    #2,d1
                    lsr.w    #2,d2
                    move.w   d1,WINX
                    move.w   d2,WINY
                    and.w    #3,d3
                    add.w    d3,d3
                    add.w    d3,d3
                    neg.w    d3
                    add.w    #14,d3
                    move.w   d3,OFFSET
                    moveq    #0,d5
                    bra      DRAW_7

DRAW_6:             moveq    #0,d4
                    bra      DRAW_11

DRAW_10:            move.w   d5,d3
                    add.w    WINY,d3
                    move.w   MAXMAPX,d1
                    asl.w    #1,d1
                    mulu     d1,d3
                    move.w   d4,d2
                    add.w    WINX,d2
                    ext.l    d2
                    asl.l    #1,d2
                    add.l    d2,d3
                    lea      MAP,a6
                    add.w    d3,a6
                    move.w   d4,d1
                    lsl.w    #4,d1
                    add.w    ULX,d1
                    add.w    OFFSET,d1
                    move.w   d5,d2
                    lsl.w    #3,d2
                    add.w    ULY,d2
                    add.w    #46,d2
                    moveq    #0,d6
                    move.w   (a6),d6
                    beq      DRAW_14
                    btst     #2,d6
                    beq      lbC0074AC
                    move.w   #0,d6
                    bra      lbC0074E0

lbC0074AC:          move.w   d6,d3
                    and.w    #$1F0,d3
                    cmp.w    #$1B0,d3
                    beq      lbC0074C2
                    cmp.w    #$1C0,d3
                    bne      lbC0074DA
lbC0074C2:          move.w   IGGY,(a6)
                    move.w   d6,d3
                    and.w    #$F,d3
                    cmp.w    #1,d3
                    beq      lbC0074DA
                    add.w    #8,(a6)
lbC0074DA:          lsr.w    #3,d6
                    beq      DRAW_14
lbC0074E0:          move.w   d6,d3
                    lea      ITEMS_HEIGHT,a1
                    add.w    d6,d6
                    move.w   (a1,d6.w),d7
                    beq      DRAW_14
                    lea      ITEMS_GRAPHICS,a1
                    add.w    d6,d6
                    move.l   (a1,d6.w),a1
                    move.w   #1,d6
                    sub.w    d7,d2
                    cmp.w    #$13,d3
                    beq      lbC007524
                    cmp.w    #$32,d3
                    beq      lbC007524
                    cmp.w    #$33,d3
                    beq      lbC007524
                    cmp.w    #$34,d3
                    bne      lbC00752C
lbC007524:          sub.w    #10,d2
                    bra      lbC007538

lbC00752C:          cmp.w    #$31,d3
                    bne      lbC007538
                    addq.w   #2,d2
lbC007538:          move.l   SCREEN2,a0
                    bsr      RSPRITER
DRAW_14:            addq.w   #1,d4
DRAW_11:            cmp.w    #10,d4
                    ble      DRAW_10
                    clr.w    d4
                    addq.w   #1,d5
DRAW_7:             move.w   #$10,d1
                    lsr.w    #2,d1
                    cmp.w    d1,d5
                    blt      DRAW_6
                    ;bsr      DRAWSPYOBJ
                    ;rts
                    ; no rts

DRAWSPYOBJ:         tst.w    d0
                    bne      SDRAWOBJ1_0
                    move.w   WIN1X,d1
                    move.w   WIN1Y,d2
                    move.w   #50,ULX
                    move.w   #2,ULY
                    lea      S1DEPTH,a0
                    bra      SDRAWOBJ1_1

SDRAWOBJ1_0:        move.w   WIN2X,d1
                    move.w   WIN2Y,d2
                    move.w   #50,ULX
                    move.w   #103,ULY
                    lea      S2DEPTH,a0
SDRAWOBJ1_1:        move.w   d1,d3
                    lsr.w    #2,d1
                    lsr.w    #2,d2
                    move.w   d1,WINX
                    move.w   d2,WINY
                    and.w    #3,d3
                    add.w    d3,d3
                    add.w    d3,d3
                    neg.w    d3
                    add.w    #14,d3
                    move.w   d3,OFFSET
                    moveq    #0,d5
                    bra      SDRAW_7

SDRAW_6:            moveq    #0,d4
                    bra      SDRAW_11

SDRAW_10:           move.w   d5,d3
                    add.w    WINY,d3
                    move.w   MAXMAPX,d1
                    asl.w    #1,d1
                    mulu     d1,d3
                    move.w   d4,d2
                    add.w    WINX,d2
                    ext.l    d2
                    asl.l    #1,d2
                    add.l    d2,d3
                    lea      MAP,a6
                    add.w    d3,a6
                    move.w   d4,d1
                    lsl.w    #4,d1
                    add.w    ULX,d1
                    add.w    OFFSET,d1
                    move.w   d5,d2
                    lsl.w    #3,d2
                    add.w    ULY,d2
                    add.w    #46,d2
SDRAW_13A:          lea      SNOW_LIST,a4
                    move.w   #8-1,d7
lbC007638:          movem.l  d1/d2/d7,-(sp)
                    move.l   a6,d6
                    move.l   (a4),d7
                    btst     #0,d7
                    beq      lbC00764A
                    addq.w   #8,d1
lbC00764A:          and.l    #$FFFFFFFE,d6
                    and.l    #$FFFFFFFE,d7
                    cmp.l    d7,d6
                    bne      lbC007680
                    move.w   4(a4),d3
                    lsr.w    #3,d3
                    sub.w    d3,d2
                    sub.w    #5,d2
                    move.w   #1,d6
                    move.w   #5,d7
                    lea      G_SNOWBALL,a1
                    move.l   SCREEN2,a0
                    bsr      RSPRITER
lbC007680:          movem.l  (sp)+,d1/d2/d7
                    lea      10(a4),a4
                    dbra     d7,lbC007638
SDRAW_14:           movem.l  d0-d6,-(sp)
                    add.w    d4,d4
                    add.w    d4,d4
                    add.w    d5,d5
                    add.w    d5,d5
                    tst.w    d0
                    bne      SDRAW14_1
                    add.w    WIN1Y,d5
                    add.w    WIN1X,d4
                    bra      SDRAW14_2

SDRAW14_1:          add.w    WIN2Y,d5
                    add.w    WIN2X,d4
SDRAW14_2:          lsr.w    #2,d4
                    lsr.w    #2,d5
                    bsr      DRAWSPY
                    movem.l  (sp)+,d0-d6
                    addq.w   #1,d4
SDRAW_11:           cmp.w    #10,d4
                    ble      SDRAW_10
                    clr.w    d4
                    addq.w   #1,d5
SDRAW_7:            move.w   #$10,d1
                    lsr.w    #2,d1
                    cmp.w    d1,d5
                    blt      SDRAW_6
                    tst.w    d0
                    bne      SDRAWLAND5_3
                    move.w   #10,Y
                    bra      SDRAWLAND5_4

SDRAWLAND5_3:       move.w   #111,Y
SDRAWLAND5_4:       move.w   #224,X
                    move.l   #RTCOVER,BUFFER
                    move.l   SCREEN2,SCREEN
                    move.w   #2,WIDTH
                    move.w   #64,HEIGHT
                    movem.l  d0,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0
                    rts

WHICHBACK:          dcb.l    4,0
SEL_FLAG:           dc.w     0
LASTSPY:            dc.w     0
SNOW_LIST:          dcb.l    20,0

BUSY:               bsr      READ_TRIGS
                    move.w   d1,d2
                    move.w   d1,d3
                    lsr.w    #8,d2
                    and.w    #$FF,d1
                    tst.w    d2
                    beq      BUSY1_0
                    cmp.w    #2,d2
                    beq      BUSY2_0
                    cmp.w    #3,d2
                    beq      BUSY3_0
                    cmp.w    #4,d2
                    beq      BUSY4_0
                    cmp.w    #6,d2
                    beq      BUSY6_0
                    cmp.w    #7,d2
                    beq      BUSY7_0
                    cmp.w    #9,d2
                    beq      BUSY9_0
                    cmp.w    #10,d2
                    beq      BUSY10_0
                    cmp.w    #20,d2
                    beq      BUSY20_0
                    cmp.w    #21,d2
                    beq      BUSY21_0
                    cmp.w    #22,d2
                    beq      BUSY22
                    cmp.w    #64,d2
                    beq      BUSY40_0
                    cmp.w    #65,d2
                    beq      BUSY41_0
                    cmp.w    #36,d2
                    beq      BUSY36
                    cmp.w    #80,d2
                    beq      BUSY50
                    cmp.w    #81,d2
                    beq      BUSY51
                    cmp.w    #82,d2
                    beq      BUSY52
                    cmp.w    #83,d2
                    beq      BUSY53
                    cmp.w    #84,d2
                    beq      BUSY54
                    cmp.w    #85,d2
                    beq      BUSY55
                    cmp.w    #86,d2
                    beq      BUSY56
                    cmp.w    #87,d2
                    beq      BUSY57
                    cmp.w    #88,d2
                    beq      BUSY58
                    cmp.w    #89,d2
                    beq      BUSY59
                    rts

DELAY_TABLE:        dcb.w    26,0
DELAY1:             dc.w     0
DELAY2:             dc.w     0

BUSY1_0:            tst.w    d0
                    bne      lbC0078B0
                    tst.w    S1AUTO
                    beq      lbC0078BE
                    bra      BRAINBUSY

lbC0078B0:          tst.w    S2AUTO
                    beq      lbC0078BE
                    bra      BRAINBUSY

lbC0078BE:          tst.w    d0
                    bne      BUSY1_0_1
                    tst.w    S1IGLOO
                    bne      lbC0078D8
                    tst.w    S1DEAD
                    beq      lbC0078DA
lbC0078D8:          rts

lbC0078DA:          move.w   JOY1TRIG,d1
                    bra      BUSY1_0_2

BUSY1_0_1:          tst.w    S2IGLOO
                    bne      lbC0078F8
                    tst.w    S2DEAD
                    beq      lbC0078FA
lbC0078F8:          rts

lbC0078FA:          move.w   JOY2TRIG,d1
BUSY1_0_2:          bne      BUSY1_0_3
                    bsr      GETBTIME
                    add.w    #1,d1
                    cmp.w    COUNTER,d1
                    beq      BUSY1_1
                    rts

BUSY1_0_3:          bsr      GETBTIME
                    add.w    #1,d1
                    cmp.w    COUNTER,d1
                    beq      BUSY1_0_4
                    bsr      GETBTIME
                    add.w    #4,d1
                    cmp.w    COUNTER,d1
                    blt      BUSY1_0_4
                    move.w   #$600,d3
                    bra      SETSTATE

BUSY1_0_4:          tst.w    d0
                    bne      BUSY1_0_6
                    move.w   COUNTER,B1TIME
                    bsr      JOYMOVE
                    tst.w    S1DEPTH
                    bne      lbC007978
                    tst.w    S1HAND
                    bne      lbC007972
                    tst.w    d1
                    bne      BUSY_SW
lbC007972:          tst.w    d2
                    bne      BUSY4_0
lbC007978:          rts

BUSY1_0_6:          move.w   COUNTER,B2TIME
                    bsr      JOYMOVE
                    tst.w    S2DEPTH
                    bne      lbC0079A8
                    tst.w    S2HAND
                    bne      lbC0079A2
                    tst.w    d1
                    bne      BUSY_SB
lbC0079A2:          tst.w    d2
                    bne      BUSY4_0
lbC0079A8:          rts

BUSY1_1:            tst.w    d0
                    bne      BUSY1_1_0
                    move.w   S1HAND,d2
                    bra      BUSY1_1_1

BUSY1_1_0:          move.w   S2HAND,d2
BUSY1_1_1:          move.w   d2,d7
                    cmp.w    #8,d2
                    beq      BUSY1_2
                    tst.w    d2
                    beq      BUSY1_2
BUSY1_1_1_1:        bsr      JOYMOVE
                    or.w     d2,d1
                    tst.w    d1
                    bne      BUSY4_0
                    move.w   #3,d3
                    lsl.w    #8,d3
                    bsr      SETSTATE
                    bra      BUSY3_0

BUSY1_2:            tst.w    d0
                    bne      BUSY1_2_1
                    tst.w    S1SAFE
                    bne      BUSY1_3
                    move.w   S1MAPX,SPYX
                    move.w   S1MAPY,SPYY
                    bra      BUSY1_2_2

BUSY1_2_1:          tst.w    S2SAFE
                    bne      BUSY1_3
                    move.w   S2MAPX,SPYX
                    move.w   S2MAPY,SPYY
BUSY1_2_2:          move.w   SPYY,d1
                    lsr.w    #2,d1
                    add.w    d1,d1
                    mulu     MAXMAPX,d1
                    move.w   SPYX,d2
                    lsr.w    #2,d2
                    add.w    d2,d2
                    add.w    d2,d1
                    move.w   d1,a0
                    add.l    #MAP,a0
                    move.w   (a0),d1
                    and.w    #2,d1
                    bne      BUSY2_0_5
                    cmp.w    #8,d7
                    beq      BUSY1_1_1_1
BUSY1_3:            rts

BUSY_SW:            tst.w    d1
                    bmi      lbC007A84
                    move.w   S1MAPX,d1
                    addq.w   #2,d1
                    lea      BUFWR1,a0
                    move.w   #1,d3
                    bra      lbC007A98

lbC007A84:          move.w   S1MAPX,d1
                    ;sub.w    #0,d1
                    lea      BUFWL1,a0
                    move.w   #-1,d3
lbC007A98:          clr.w    S1F
                    move.l   a0,S1FADDR
                    move.w   S1MAPY,d2
                    move.w   d3,S1SAVE_DIR
                    lea      S1SAVE_ADD,a1
                    bra      BUSY_S_SETUP

BUSY_SB:            tst.w    d1
                    bmi      lbC007AD6
                    move.w   S2MAPX,d1
                    addq.w   #2,d1
                    lea      BUFBR1,a0
                    move.w   #1,d3
                    bra      lbC007AEA

lbC007AD6:          move.w   S2MAPX,d1
       ;             sub.w    #0,d1
                    lea      BUFBL1,a0
                    move.w   #-1,d3
lbC007AEA:          clr.w    S2F
                    move.l   a0,S2FADDR
                    move.w   S2MAPY,d2
                    move.w   d3,S2SAVE_DIR
                    lea      S2SAVE_ADD,a1
BUSY_S_SETUP:       lsr.w    #2,d2
                    mulu     MAXMAPX,d2
                    lsr.w    #2,d1
                    add.w    d2,d1
                    add.w    d1,d1
                    lea      MAP,a0
                    add.w    d1,a0
                    move.l   a0,(a1)
                    move.w   #$5000,d3
                    bra      SETSTATE

BUSY2_0:            tst.w    d1
                    bne      BUSY2_4
                    tst.w    d0
                    bne      lbC007B44
                    move.w   S1MAPX,d1
                    move.w   S1MAPY,d2
                    bra      lbC007B50

lbC007B44:          move.w   S2MAPX,d1
                    move.w   S2MAPY,d2
lbC007B50:          lsr.w    #2,d2
                    mulu     MAXMAPX,d2
                    lsr.w    #2,d1
                    add.w    d2,d1
                    add.w    d1,d1
                    lea      MAP,a0
                    add.w    d1,a0
                    clr.w    d1
BUSY2_0_5:          move.w   (a0),d4
                    beq      BUSY6_4
                    cmp.w    #$A7,(a0)
                    bgt      BUSY6_4
                    cmp.w    #$80,(a0)
                    beq      BUSY6_4
                    cmp.w    #$88,(a0)
                    beq      BUSY6_4
                    cmp.w    #$98,(a0)
                    beq      BUSY6_4
                    tst.w    d0
                    bne      lbC007BB6
                    tst.w    S1HAND
                    beq      lbC007BD4
                    cmp.w    #8,S1HAND
                    bne      BUSY6_4
                    cmp.w    #$28,d4
                    bge      BUSY6_4
                    bra      lbC007BD4

lbC007BB6:          tst.w    S2HAND
                    beq      lbC007BD4
                    cmp.w    #8,S2HAND
                    bne      BUSY6_4
                    cmp.w    #$28,d4
                    bge      BUSY6_4
lbC007BD4:          move.l   #14,d7
                    jsr      NEW_SOUND
                    bsr      DELETE_TRAP
                    and.w    #$FFF8,d4
                    bsr      KILLDOUBLE
                    tst.w    d0
                    bne      lbC007BFE
                    cmp.w    #$78,d4
                    beq      lbC007C06
                    bra      lbC007C0E

lbC007BFE:          cmp.w    #$70,d4
                    bne      lbC007C0E
lbC007C06:          move.w   #$5900,d3
                    bra      SETSTATE

lbC007C0E:          tst.w    d0
                    bne      lbC007C1E
                    move.w   S1HAND,d7
                    bra      lbC007C24

lbC007C1E:          move.w   S2HAND,d7
lbC007C24:          cmp.w    #8,d7
                    bne      lbC007C58
                    move.w   d4,d7
                    lsr.w    #3,d7
                    cmp.w    #1,d7
                    ble      BUSY6_4
                    cmp.w    #4,d7
                    bgt      BUSY6_4
                    subq.w   #2,d7
                    lea      IN_CASE,a2
                    move.b   #$FF,(a2,d7.w)
                    move.w   d4,d7
                    move.w   #8,d4
                    bra      lbC007C5A

lbC007C58:          move.w   d4,d7
lbC007C5A:          cmp.w    #8,d7
                    bne      lbC007C72
                    clr.w    XCASE
                    clr.w    YCASE
                    bra      lbC007D2E

lbC007C72:          cmp.w    #$10,d7
                    bne      lbC007C8A
                    clr.w    XCARD
                    clr.w    YCARD
                    bra      lbC007D2E

lbC007C8A:          cmp.w    #$18,d7
                    bne      lbC007CA2
                    clr.w    XJAR
                    clr.w    YJAR
                    bra      lbC007D2E

lbC007CA2:          cmp.w    #$20,d7
                    bne      lbC007CBA
                    clr.w    XGYRO
                    clr.w    YGYRO
                    bra      lbC007D2E

lbC007CBA:          cmp.w    #$58,d7
                    bne      lbC007CD2
                    clr.w    XBPLUNG
                    clr.w    YBPLUNG
                    bra      lbC007D2E

lbC007CD2:          cmp.w    #$60,d7
                    bne      lbC007CEA
                    clr.w    XWPLUNG
                    clr.w    YWPLUNG
                    bra      lbC007D2E

lbC007CEA:          cmp.w    #$30,d7
                    bne      lbC007D02
                    clr.w    XWBUCK
                    clr.w    YWBUCK
                    bra      lbC007D2E

lbC007D02:          cmp.w    #$38,d7
                    bne      lbC007D1A
                    clr.w    XBBUCK
                    clr.w    YBBUCK
                    bra      lbC007D2E

lbC007D1A:          cmp.w    #$70,d4
                    beq      lbC007D2A
                    cmp.w    #$78,d4
                    bne      lbC007D2E
lbC007D2A:          move.w   #$50,d4
lbC007D2E:          tst.w    d0
                    bne      BUSY2_2_1
                    move.w   d4,S1HAND
                    move.w   #0,S1F
                    move.l   #BUF16,S1FADDR
                    bra      BUSY2_4

BUSY2_2_1:          move.w   d4,S2HAND
                    clr.w    S2F
                    move.l   #BUF26,S2FADDR
BUSY2_4:            cmp.w    #4,d1
                    beq      BUSY2_5
                    add.w    #$201,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY2_5:            tst.w    d0
                    bne      BUSY2_6
                    move.l   #BUF14,S1FADDR
                    bra      BUSY2_7

BUSY2_6:            move.l   #BUF24,S2FADDR
BUSY2_7:            move.w   #$700,d3
                    bra      SETSTATE

BUSY3_0:            tst.w    d0
                    bne      BUSY3_1
                    move.w   S1MAPX,SPYX
                    move.w   S1MAPY,SPYY
                    move.w   S1HAND,d3
                    bra      BUSY3_2

BUSY3_1:            move.w   S2MAPX,SPYX
                    move.w   S2MAPY,SPYY
                    move.w   S2HAND,d3
BUSY3_2:            tst.w    d3
                    bne      BUSY3_2_0_1
                    rts

BUSY3_2_0_1:        bsr      KILLDOUBLE
                    move.l   #15,d7
                    jsr      NEW_SOUND
BUSY3_2_A:          cmp.w    #$40,d3
                    bne      BUSY3_2_B
                    tst.w    d0
                    bne      BUSY3_2_A_0
                    addq.w   #1,S1PICK
                    clr.w    S1HAND
                    bra      BUSY6_4

BUSY3_2_A_0:        addq.w   #1,S2PICK
                    clr.w    S2HAND
                    bra      BUSY6_4

BUSY3_2_B:          cmp.w    #$28,d3
                    bne      BUSY3_2_W
                    tst.w    d0
                    bne      BUSY3_2_B_0
                    addq.w   #1,S1SAW
                    clr.w    S1HAND
                    bra      BUSY6_4

BUSY3_2_B_0:        addq.w   #1,S2SAW
                    clr.w    S2HAND
                    bra      BUSY6_4

BUSY3_2_W:          cmp.w    #$50,d3
                    bne      BUSY3_2_Y
                    tst.w    d0
                    bne      BUSY3_2_W_0
                    addq.w   #1,S1TNT
                    clr.w    S1HAND
                    bra      BUSY6_4

BUSY3_2_W_0:        addq.w   #1,S2TNT
                    clr.w    S2HAND
                    bra      BUSY6_4

BUSY3_2_Y:          tst.w    d0
                    bne      BUSY3_2_Y_0
                    cmp.w    #$60,d3
                    bne      BUSY3_2_C
                    addq.w   #1,S1PLUNGER
                    clr.w    S1HAND
                    bra      BUSY6_4

BUSY3_2_Y_0:        cmp.w    #$58,d3
                    bne      BUSY3_2_C
                    addq.w   #1,S2PLUNGER
                    clr.w    S2HAND
                    bra      BUSY6_4

BUSY3_2_C:          cmp.w    #$30,d3
                    bne      BUSY3_2_C5
                    tst.w    d0
                    bne      BUSY3_2_C5
                    addq.w   #1,S1BUCKET
                    clr.w    S1HAND
                    bra      BUSY6_4

BUSY3_2_C5:         cmp.w    #$38,d3
                    bne      BUSY3_2_D
                    tst.w    d0
                    beq      BUSY3_2_D
                    addq.w   #1,S2BUCKET
                    clr.w    S2HAND
                    bra      BUSY6_4

BUSY3_2_D:          cmp.w    #$48,d3
                    bne      BUSY3_2_Z
                    tst.w    d0
                    bne      BUSY3_2_D_0
                    addq.w   #1,S1SNSH
                    clr.w    S1HAND
                    bra      BUSY6_4

BUSY3_2_D_0:        addq.w   #1,S2SNSH
                    clr.w    S2HAND
                    bra      BUSY6_4

BUSY3_2_Z:          move.w   SPYY,d1
                    lsr.w    #2,d1
                    add.w    d1,d1
                    mulu     MAXMAPX,d1
                    move.w   SPYX,d2
                    lsr.w    #2,d2
                    add.w    d2,d2
                    add.w    d2,d1
                    move.w   d1,a0
                    add.l    #MAP,a0
                    cmp.w    #$A7,(a0)
                    bgt      lbC007F7C
                    bsr      ADD_TRAP
                    movem.l  d0-d3/a0-a2,-(sp)
                    bsr      DOSETXY
                    movem.l  (sp)+,d0-d3/a0-a2
                    and.w    #$FFF8,d3
                    or.w     #2,d3
                    move.w   d3,(a0)
                    tst.w    d0
                    bne      lbC007F76
                    clr.w    S1HAND
                    bra      lbC007F7C

lbC007F76:          clr.w    S2HAND
lbC007F7C:          move.w   #$700,d3
                    bra      SETSTATE

BUSY4_0:            bsr      KILLDOUBLE
                    tst.w    d0
                    bne      BUSY4_1
                    tst.w    S1SAFE
                    bne      BUSY6_4
                    lea      S1FADDR,a6
                    move.l   #BUF11,d6
                    move.w   S1MAPX,SPYX
                    move.w   S1MAPY,SPYY
                    move.w   S1HAND,d3
                    bra      BUSY4_2

BUSY4_1:            lea      S2FADDR,a6
                    move.l   #BUF21,d6
                    tst.w    S2SAFE
                    bne      BUSY6_4
                    move.w   S2MAPX,SPYX
                    move.w   S2MAPY,SPYY
                    move.w   S2HAND,d3
BUSY4_2:            tst.w    d3
                    bne      BUSY4_2_0
                    bra      BUSY6_4

BUSY4_2_0:          bsr      KILLDOUBLE
BUSY4_2_1_0:        move.w   SPYY,d1
                    lsr.w    #2,d1
                    add.w    d1,d1
                    mulu     MAXMAPX,d1
                    move.w   SPYX,d2
                    lsr.w    #2,d2
                    add.w    d2,d2
                    add.w    d2,d1
                    move.w   d1,a0
                    add.l    #MAP,a0
                    move.w   (a0),d1
                    and.w    #$FFF8,d1
                    cmp.w    #$A7,d1
                    bgt      BUSY6_4
BUSY4_2_1:          move.l   a0,a1
                    bsr      ADD_TRAP
BUSY4_3:            and.w    #$FFF8,d3
BUSY4_4A:           tst.w    d0
                    bne      lbC008066
                    cmp.w    #$50,d3
                    bne      lbC008052
                    move.w   #$70,d3
                    bra      BUSY4_6

lbC008052:          cmp.w    #$30,d3
                    beq      lbC008096
                    cmp.w    #$60,d3
                    beq      _DELETE_TRAP
                    bra      BUSY4_5

lbC008066:          cmp.w    #$50,d3
                    bne      lbC008076
                    move.w   #$78,d3
                    bra      BUSY4_6

lbC008076:          cmp.w    #$58,d3
                    beq      _DELETE_TRAP
                    cmp.w    #$38,d3
                    bne      BUSY4_5
                    bra      lbC008096

_DELETE_TRAP:       bsr      DELETE_TRAP
                    move.w   #$5800,d3
                    bra      SETSTATE

lbC008096:          cmp.l    a0,a1
                    bne      BUSY4_5
                    clr.w    d3
                    clr.w    d1
                    bra      C99

BUSY4_5:            cmp.w    #$28,d3
                    bne      BUSY4_5A
                    clr.w    d3
                    cmp.l    a0,a1
                    bne      BUSY4_5A
                    clr.w    d1
                    bra      D99

BUSY4_5A:           cmp.w    #$40,d3
                    bne      BUSY4_6
                    bsr      DELETE_TRAP
                    move.l   a1,a0
                    clr.w    d1
                    cmp.w    #$190,(a0)
                    beq      _E99
                    cmp.w    #$190,2(a0)
                    beq      lbC008128
                    cmp.w    #$190,-2(a0)
                    beq      lbC008122
                    tst.w    d0
                    bne      lbC008108
                    tst.w    S1AUTO
                    beq      BUSY6_4
                    clr.w    S1HAND
                    addq.w   #1,S1PICK
                    bra      BUSY6_4

lbC008108:          tst.w    S2AUTO
                    beq      BUSY6_4
                    clr.w    S2HAND
                    addq.w   #1,S2PICK
                    bra      BUSY6_4

lbC008122:          subq.w   #2,a0
_E99:               bra      E99

lbC008128:          addq.w   #2,a0
                    bra      E99

BUSY4_6:            tst.w    d0
                    bne      lbC00813E
                    clr.w    S1HAND
                    bra      lbC008144

lbC00813E:          clr.w    S2HAND
lbC008144:          move.l   #3,d7
                    jsr      NEW_SOUND
                    or.w     #6,d3
                    move.w   d3,(a0)
BUSY4_7:            move.w   (a0),d3
                    beq      lbC008164
                    and.w    #$FFF8,d3
                    bsr      DOSETXY
lbC008164:          move.w   #$700,d3
                    bra      SETSTATE

BUSY4_A:            movem.l  d1-d3,-(sp)
                    tst.w    d0
                    bne      BUSY4_B
                    move.w   S1MAPX,SPYX
                    move.w   S1MAPY,SPYY
                    move.w   S1HAND,d3
                    clr.w    S1HAND
                    bra      BUSY4_C

BUSY4_B:            move.w   S2MAPX,SPYX
                    move.w   S2MAPY,SPYY
                    move.w   S2HAND,d3
                    clr.w    S2HAND
BUSY4_C:            tst.w    d3
                    bne      BUSY4_D
                    movem.l  (sp)+,d1-d3
                    rts

BUSY4_D:            move.w   SPYY,d1
                    lsr.w    #2,d1
                    add.w    d1,d1
                    mulu     MAXMAPX,d1
                    move.w   SPYX,d2
                    lsr.w    #2,d2
                    add.w    d2,d2
                    add.w    d2,d1
                    move.w   d1,a0
                    add.l    #MAP,a0
BUSY4_E:            cmp.w    #$A8,(a0)
                    beq      lbC0081FE
                    cmp.w    #$B0,(a0)
                    bne      lbC008224
lbC0081FE:          movem.l  d0-d4/a0-a3,-(sp)
                    movem.l  d0-d3,-(sp)
                    move.w   #1,d1
                    move.w   d3,d2
                    or.w     #6,d2
                    bsr      STIT
                    movem.l  (sp)+,d0-d3
                    bsr      DOSETXY
                    movem.l  (sp)+,d0-d4/a0-a3
                    bra      BUSY4_H

lbC008224:          tst.w    -(a0)
                    beq      BUSY4_G
                    tst.w    -(a0)
                    beq      BUSY4_G
                    add.w    #4,a0
BUSY4_F:            add.w    #2,a0
                    tst.w    (a0)
                    bne.b    BUSY4_F
BUSY4_G:            and.w    #$FFF8,d3
                    or.w     #6,d3
                    move.w   d3,(a0)
BUSY4_H:            movem.l  d0-d3/a0-a2,-(sp)
                    move.w   (a0),d3
                    and.w    #$FFF8,d3
                    bsr      DOSETXY
                    move.w   #$700,d3
                    bsr      SETSTATE
                    movem.l  (sp)+,d0-d3/a0-a2
                    movem.l  (sp)+,d1-d3
                    rts

DELETE_TRAP:        movem.l  d6/d7/a4,-(sp)
                    lea      TRAPLIST,a4
                    move.l   a0,d7
                    move.w   #$63,d6
lbC008276:          cmp.l    (a4),d7
                    beq      lbC008288
                    addq.w   #6,a4
                    dbra     d6,lbC008276
                    clr.w    (a0)
                    bra      lbC008292

lbC008288:          move.w   4(a4),(a0)
                    clr.l    (a4)
                    clr.w    4(a4)
lbC008292:          movem.l  (sp)+,d6/d7/a4
                    rts

ADD_TRAP:           movem.l  d3-d7/a2/a4,-(sp)
                    tst.w    d0
                    bne      lbC0082AC
                    move.w   S1AUTO,d7
                    bra      lbC0082B2

lbC0082AC:          move.w   S2AUTO,d7
lbC0082B2:          clr.w    d5
lbC0082B6:          move.w   (a0),d4
                    beq      lbC00830A
                    tst.w    d7
                    bne      lbC0082D6
                    btst     #0,d4
                    bne      lbC0082D6
                    and.w    #$1F8,d4
                    cmp.w    #$60,d4
                    ble      lbC0082EC
lbC0082D6:          clr.w    d7
                    addq.w   #2,d5
                    addq.w   #1,d3
                    and.w    #1,d3
                    beq      lbC0082E8
                    sub.w    d5,a0
                    bra.b    lbC0082B6

lbC0082E8:          add.w    d5,a0
                    bra.b    lbC0082B6

lbC0082EC:          lea      TRAPLIST,a4
                    move.w   #100-1,d6
lbC0082F6:          tst.l    (a4)
                    beq      lbC008306
                    addq.w   #6,a4
                    dbra     d6,lbC0082F6
                    bra      lbC00830A

lbC008306:          move.l   a0,(a4)+
                    move.w   (a0),(a4)
lbC00830A:          movem.l  (sp)+,d3-d7/a2/a4
                    rts

DOSETXY:            cmp.w    #8,d3
                    bne      lbC00832C
                    move.l   #XCASE,a1
                    move.l   #YCASE,a2
                    bsr      SETXY
                    bra      lbC0083EC

lbC00832C:          cmp.w    #$10,d3
                    bne      lbC008348
                    move.l   #XCARD,a1
                    move.l   #YCARD,a2
                    bsr      SETXY
                    bra      lbC0083EC

lbC008348:          cmp.w    #$18,d3
                    bne      lbC008364
                    move.l   #XJAR,a1
                    move.l   #YJAR,a2
                    bsr      SETXY
                    bra      lbC0083EC

lbC008364:          cmp.w    #$20,d3
                    bne      lbC008380
                    move.l   #XGYRO,a1
                    move.l   #YGYRO,a2
                    bsr      SETXY
                    bra      lbC0083EC

lbC008380:          cmp.w    #$58,d3
                    bne      lbC00839C
                    move.l   #XBPLUNG,a1
                    move.l   #YBPLUNG,a2
                    bsr      SETXY
                    bra      lbC0083EC

lbC00839C:          cmp.w    #$60,d3
                    bne      lbC0083B8
                    move.l   #XWPLUNG,a1
                    move.l   #YWPLUNG,a2
                    bsr      SETXY
                    bra      lbC0083EC

lbC0083B8:          cmp.w    #$30,d3
                    bne      lbC0083D4
                    move.l   #XWBUCK,a1
                    move.l   #YWBUCK,a2
                    bsr      SETXY
                    bra      lbC0083EC

lbC0083D4:          cmp.w    #$38,d3
                    bne      lbC0083EC
                    move.l   #XBBUCK,a1
                    move.l   #YBBUCK,a2
                    bsr      SETXY
lbC0083EC:          rts

COUNTER1:           dc.w     0
COUNTER2:           dc.w     0

BUSY5_0:            tst.w    SPYWIN
                    beq      lbC008400
                    bra      BUSY6_4

lbC008400:          movem.l  d0-d3,-(sp)
                    bsr      JOYMOVE
                    movem.l  (sp)+,d0-d3
                    move.w   d1,d6
                    tst.w    d0
                    bne      BUSY5_0_1
                    tst.w    S1DEPTH
                    bne      BUSY6_4
                    tst.w    S1SWAMP
                    bne      BUSY6_4
                    move.w   #2,d2
                    move.w   JOY1TRIG,d3
                    bra      BUSY5_0_2

BUSY5_0_1:          tst.w    S2DEPTH
                    bne      BUSY6_4
                    tst.w    S2SWAMP
                    bne      BUSY6_4
                    move.w   #$67,d2
                    move.w   JOY2TRIG,d3
BUSY5_0_2:          tst.w    d1
                    bne      BUSY5_1
                    tst.w    d3
                    beq      BUSY5_0_3
                    rts

BUSY5_0_3:          move.w   #$501,d3
                    bra      SETSTATE

BUSY5_1:            cmp.w    #1,d1
                    bne      BUSY5_2
                    move.w   #$29,d3
                    lsr.w    #2,d3
                    move.w   d3,HEIGHT
                    bsr      SHOWMAP
                    move.w   #$502,d3
                    bra      SETSTATE

BUSY5_2:            cmp.w    #2,d1
                    bne      BUSY5_3
                    move.w   #$29,d3
                    lsr.w    #1,d3
                    move.w   d3,HEIGHT
                    bsr      SHOWMAP
                    move.w   #$503,d3
                    bra      SETSTATE

BUSY5_3:            cmp.w    #3,d1
                    bne      BUSY5_4
                    move.w   #$29,d3
                    mulu     #3,d3
                    lsr.w    #2,d3
                    move.w   d3,HEIGHT
                    bsr      SHOWMAP
                    move.w   #$504,d3
                    bra      SETSTATE

BUSY5_4:            move.w   d3,-(sp)
                    move.w   d1,d3
                    add.w    #$501,d3
                    cmp.w    #$FF,d1
                    bne      _SETSTATE
                    sub.w    #8,d3
_SETSTATE:          bsr      SETSTATE
                    move.w   #$29,HEIGHT
                    bsr      SHOWMAP
                    tst.w    d0
                    bne      BUSY5_4_0
                    moveq    #0,d1
                    move.w   S1MAPX,d1
                    move.w   S1MAPY,d2
                    move.l   #S1TRAIL,a1
                    move.w   #$13,d5
                    bra      BUSY5_4_1

BUSY5_4_0:          moveq    #0,d1
                    move.w   S2MAPX,d1
                    move.w   S2MAPY,d2
                    move.l   #S2TRAIL,a1
                    move.w   #$78,d5
BUSY5_4_1:          bsr      GETPOS
                    move.w   COUNTER,d2
                    and.w    #1,d2
                    bne      BUSY5_4_2
                    move.w   #1,WIDTH
                    move.w   #8,HEIGHT
                    move.l   #MAPBOX,BUFFER
                    move.l   SCREEN2,SCREEN
                    movem.l  d0-d6/a0-a3,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6/a0-a3
BUSY5_4_2:          tst.w    XCASE
                    beq      lbC0085C2
                    move.w   XCASE,d1
                    move.w   YCASE,d2
                    ext.l    d1
                    ext.l    d2
                    add.w    d1,d1
                    add.w    d1,d1
                    add.w    d2,d2
                    add.w    d2,d2
                    bsr      GETPOS
                    move.w   #1,WIDTH
                    move.w   #8,HEIGHT
                    move.l   #MAPSPOT,BUFFER
                    move.l   SCREEN2,SCREEN
                    movem.l  d0-d6/a0-a3,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6/a0-a3
lbC0085C2:          tst.w    XCARD
                    beq      lbC008614
                    move.w   XCARD,d1
                    move.w   YCARD,d2
                    ext.l    d1
                    ext.l    d2
                    add.w    d1,d1
                    add.w    d1,d1
                    add.w    d2,d2
                    add.w    d2,d2
                    bsr      GETPOS
                    move.w   #1,WIDTH
                    move.w   #8,HEIGHT
                    move.l   #MAPSPOT,BUFFER
                    move.l   SCREEN2,SCREEN
                    movem.l  d0-d6/a0-a3,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6/a0-a3
lbC008614:          tst.w    XJAR
                    beq      lbC008666
                    move.w   XJAR,d1
                    move.w   YJAR,d2
                    ext.l    d1
                    ext.l    d2
                    add.w    d1,d1
                    add.w    d1,d1
                    add.w    d2,d2
                    add.w    d2,d2
                    bsr      GETPOS
                    move.w   #1,WIDTH
                    move.w   #8,HEIGHT
                    move.l   #MAPSPOT,BUFFER
                    move.l   SCREEN2,SCREEN
                    movem.l  d0-d6/a0-a3,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6/a0-a3
lbC008666:          tst.w    XGYRO
                    beq      lbC0086B8
                    move.w   XGYRO,d1
                    move.w   YGYRO,d2
                    ext.l    d1
                    ext.l    d2
                    add.w    d1,d1
                    add.w    d1,d1
                    add.w    d2,d2
                    add.w    d2,d2
                    bsr      GETPOS
                    move.w   #1,WIDTH
                    move.w   #8,HEIGHT
                    move.l   #MAPSPOT,BUFFER
                    move.l   SCREEN2,SCREEN
                    movem.l  d0-d6/a0-a3,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d6/a0-a3
lbC0086B8:          movem.l  d0-d7/a0-a4,-(sp)
lbC0086BC:          bra      lbC00874A

                    cmp.w    #-1,2(a1)
                    beq      lbC00874A
                    move.w   (a1),d2
                    move.w   2(a1),d4
                    move.w   d2,d1
                    move.w   d4,d3
                    lsr.w    #8,d1
                    and.w    #$FF,d2
                    lsr.w    #8,d3
                    and.w    #$FF,d4
                    sub.w    d1,d3
                    sub.w    d2,d4
                    add.w    d3,d3
                    add.w    d4,d4
                    movem.l  d0-d2/a1,-(sp)
                    bsr      GETPOS1
                    movem.l  (sp)+,d0-d2/a1
                    addq.w   #6,X
                    addq.w   #3,Y
                    move.w   #8,d6
                    tst.w    d3
                    bne      lbC008712
                    move.w   #4,d6
lbC008712:          move.w   #15,COLOR
                    move.w   #1,COUNT
                    movem.l  d0-d5/a1,-(sp)
                    bsr      HLINE
                    movem.l  (sp)+,d0-d5/a1
                    add.w    d3,X
                    add.w    d4,Y
                    subq.w   #1,d6
                    bne.b    lbC008712
                    addq.l   #2,a1
                    bra      lbC0086BC

lbC00874A:          movem.l  (sp)+,d0-d7/a0-a4
BUSY5_5:            move.w   d6,d1
                    move.w   (sp)+,d3
                    tst.w    d0
                    bne      lbC008766
                    tst.w    S1AUTO
                    beq      lbC008786
                    bra      lbC008770

lbC008766:          tst.w    S2AUTO
                    beq      lbC008786
lbC008770:          move.w   IQ,d2
                    lsl.w    #3,d2
                    move.w   #$3C,d3
                    sub.w    d2,d3
                    sub.w    d1,d3
                    blt      BUSY5_6
                    rts

lbC008786:          tst.w    d3
                    bne      BUSY5_6
                    rts

BUSY5_6:            clr.w    d3
                    bra      SETSTATE

BUSY6_0:            bra      lbC0087AA

                    clr.w    S1FLASH
                    clr.w    S2FLASH
                    bra      BUSY6_4

lbC0087AA:          tst.w    d0
                    bne      BUSY6_0_1
                    clr.w    S1F
                    move.w   JOY1TRIG,d2
                    move.w   S1MENU,d4
                    move.w   #1,S1FLASH
                    bra      BUSY6_0_2

BUSY6_0_1:          clr.w    S2F
                    move.w   JOY2TRIG,d2
                    move.w   S2MENU,d4
                    move.w   #1,S2FLASH
BUSY6_0_2:          tst.w    d1
                    bne      BUSY6_1
                    tst.w    d2
                    beq      BUSY6_0_3
                    rts

BUSY6_0_3:          ;bra      BUSY6_0_4

;                    movem.l  d0-d7/a0-a6,-(sp)
;                    tst.w    d0
;                    bne      lbC00881A
;                    move.l   #S1BACK,a1
;                    move.w   #10,d2
;                    move.w   #$FFFF,BUF1Y
;                    bra      lbC00882C
;
;lbC00881A:          move.l   #S2BACK,a1
;                    move.w   #$6F,d2
;                    move.w   #$FFFF,BUF2Y
;lbC00882C:          move.w   #4,d1
;                    move.w   #12,d6
;                    move.w   #$40,d7
;                    move.l   SCREEN1,a0
;                    bsr      RSAVE_BUFF
;                    move.w   #4,d1
;                    move.w   #12,d6
;                    move.w   #$40,d7
;                    move.l   SCREEN2,a0
;                    bsr      RDRAW_BUFF
;                    movem.l  (sp)+,d0-d7/a0-a6
BUSY6_0_4:          move.w   #$601,d3
                    bsr      SETSTATE
BUSY6_1:            tst.w    d2
                    bne      BUSY6_2
                    move.w   COUNTER,d1
                    and.w    #1,d1
                    beq      BUSY6_1_4
                    move.w   d4,-(sp)
                    bsr      JOYMOVE
                    move.w   (sp)+,d4
                    tst.w    d1
                    beq      lbC008892
                    move.l   #1,d7
                    jsr      NEW_SOUND
lbC008892:          add.w    d1,d4
                    tst.w    d4
                    bgt      BUSY6_1_1
                    move.w   #7,d4
                    bra      BUSY6_1_2

BUSY6_1_1:          cmp.w    #7,d4
                    ble      BUSY6_1_2
                    move.w   #1,d4
BUSY6_1_2:          tst.w    d0
                    bne      BUSY6_1_3
                    move.w   d4,S1MENU
                    rts

BUSY6_1_3:          move.w   d4,S2MENU
BUSY6_1_4:          rts

BUSY6_2:            tst.w    d0
                    bne      BUSY6_2_1
                    clr.w    S1FLASH
                    bra      BUSY6_3

BUSY6_2_1:          clr.w    S2FLASH
BUSY6_3:            tst.w    d0
                    bne      BUSY6_3_0_1
                    move.w   S1HAND,d1
                    bra      BUSY6_3_0_2

BUSY6_3_0_1:        move.w   S2HAND,d1
BUSY6_3_0_2:        tst.w    d1
                    bne      BUSY6_4
                    cmp.w    #1,d4
                    bne      BUSY6_3_1
                    tst.w    d0
                    bne      BUSY6_3_0_3
                    move.w   S1PLUNGER,d1
                    beq      BUSY6_4
                    move.w   #$60,S1HAND
                    subq.w   #1,S1PLUNGER
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_0_3:        move.w   S2PLUNGER,d1
                    beq      BUSY6_4
                    move.w   #$58,S2HAND
                    subq.w   #1,S2PLUNGER
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_1:          cmp.w    #2,d4
                    bne      BUSY6_3_2
                    tst.w    d0
                    bne      BUSY6_3_1_0
                    move.w   S1SAW,d1
                    beq      BUSY6_4
                    move.w   #$28,S1HAND
                    subq.w   #1,S1SAW
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_1_0:        move.w   S2SAW,d1
                    beq      BUSY6_4
                    move.w   #$28,S2HAND
                    subq.w   #1,S2SAW
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_2:          cmp.w    #3,d4
                    bne      BUSY6_3_3
                    tst.w    d0
                    bne      BUSY6_3_2_0
                    move.w   S1BUCKET,d1
                    beq      BUSY6_4
                    move.w   #$30,S1HAND
                    subq.w   #1,S1BUCKET
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_2_0:        move.w   S2BUCKET,d1
                    beq      BUSY6_4
                    move.w   #$38,S2HAND
                    subq.w   #1,S2BUCKET
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_3:          cmp.w    #4,d4
                    bne      BUSY6_3_4
                    tst.w    d0
                    bne      BUSY6_3_3_0
                    move.w   S1PICK,d1
                    beq      BUSY6_4
                    move.w   #$40,S1HAND
                    subq.w   #1,S1PICK
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_3_0:        move.w   S2PICK,d1
                    beq      BUSY6_4
                    move.w   #$40,S2HAND
                    subq.w   #1,S2PICK
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_4:          cmp.w    #5,d4
                    bne      BUSY6_3_4A
                    tst.w    d0
                    bne      BUSY6_3_4_0
                    move.w   S1SNSH,d1
                    beq      BUSY6_4
                    move.w   #$48,S1HAND
                    subq.w   #1,S1SNSH
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_4_0:        move.w   S2SNSH,d1
                    beq      BUSY6_4
                    move.w   #$48,S2HAND
                    subq.w   #1,S2SNSH
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_4A:         cmp.w    #6,d4
                    bne      BUSY6_3_5
                    tst.w    d0
                    bne      BUSY6_3_4A_0
                    move.w   S1TNT,d1
                    beq      BUSY6_4
                    move.w   #$50,S1HAND
                    subq.w   #1,S1TNT
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_4A_0:       move.w   S2TNT,d1
                    beq      BUSY6_4
                    move.w   #$50,S2HAND
                    subq.w   #1,S2TNT
                    move.w   #$700,d3
                    bra      SETSTATE

BUSY6_3_5:          cmp.w    #7,d4
                    bne      BUSY6_4
                    move.w   #$500,d3
                    bra      SETSTATE

BUSY6_4:            clr.w    d3
                    bra      SETSTATE

BUSY7_0:            move.w   #$700,d3
                    bsr      SETSTATE
                    tst.w    d0
                    bne      BUSY7_1
                    move.w   JOY1TRIG,d1
                    bra      BUSY7_2

BUSY7_1:            move.w   JOY2TRIG,d1
BUSY7_2:            beq      BUSY7_3
                    rts

BUSY7_3:            clr.w    d3
                    bra      SETSTATE

SETSAFE:            tst.w    d0
                    bne      SETSAFE1
                    move.w   #4,S1SAFE
                    rts

SETSAFE1:           move.w   #4,S2SAFE
                    rts

KILLDOUBLE:         movem.l  d1,-(sp)
                    move.w   COUNTER,d1
                    sub.w    #20,d1
                    tst.w    d0
                    bne      lbC008B4A
                    move.w   d1,B1TIME
                    bra      lbC008B50

lbC008B4A:          move.w   d1,B2TIME
lbC008B50:          movem.l  (sp)+,d1
                    rts

GETPOS:             asr.w    #2,d1
                    divs     #10,d1
                    asr.w    #4,d2
GETPOS1:            lsl.w    #4,d1
                    lsl.w    #3,d2
                    add.w    #97,d1
                    add.w    d5,d2
                    move.w   d1,X
                    move.w   d2,Y
                    rts

BUSY9_0:            tst.w    d1
                    bne      BUSY9_4
                    tst.w    d0
                    bne      BUSY9_2
                    tst.w    S1DEAD
                    bne      BUSY6_4
                    moveq    #2,d7
                    jsr      NEW_SOUND
                    tst.w    S1HAND
                    beq      lbC008BA6
                    bsr      BUSY4_A
lbC008BA6:          subq.w   #3,S1ENERGY
                    move.w   #2,REFRESH
                    clr.w    S1F
                    move.w   S1MAPX,d1
                    sub.w    S2MAPX,d1
                    bgt      BUSY9_1
                    move.l   #BUF19,S1FADDR
                    move.w   #$901,d3
                    bra      SETSTATE

BUSY9_1:            move.l   #BUF1A,S1FADDR
                    move.w   #$901,d3
                    bra      SETSTATE

BUSY9_2:            tst.w    S2DEAD
                    bne      BUSY6_4
                    moveq    #2,d7
                    jsr      NEW_SOUND
                    tst.w    S2HAND
                    beq      lbC008C16
                    bsr      BUSY4_A
lbC008C16:          sub.w    #3,S2ENERGY
                    move.w   #2,REFRESH
                    clr.w    S2F
                    move.w   S2MAPX,d1
                    sub.w    S1MAPX,d1
                    bgt      BUSY9_3
                    move.l   #BUF29,S2FADDR
                    move.w   #$901,d3
                    bra      SETSTATE

BUSY9_3:            move.l   #BUF2A,S2FADDR
                    move.w   #$901,d3
                    bra      SETSTATE

BUSY9_4:            move.w   d1,d3
                    add.w    #$901,d3
                    cmp.w    #$903,d3
                    bne      SETSTATE
                    tst.w    d0
                    bne      BUSY9_5
                    move.l   S1FADDR,d1
                    cmp.l    #BUF19,d1
                    beq      BUSY9_4_0
                    move.w   #1,SPYDIR
                    move.l   #BUF12,S1FADDR
                    clr.w    S1F
                    bra      BUSY9_6

BUSY9_4_0:          move.w   #2,SPYDIR
                    move.l   #BUF11,S1FADDR
                    clr.w    S1F
                    bra      BUSY9_6

BUSY9_5:            move.l   S2FADDR,d1
                    cmp.l    #BUF29,d1
                    beq      BUSY9_5_0
                    move.w   #1,SPYDIR
                    move.l   #BUF22,S2FADDR
                    clr.w    S2F
                    bra      BUSY9_6

BUSY9_5_0:          move.w   #2,SPYDIR
                    move.l   #BUF21,S2FADDR
                    clr.w    S2F
BUSY9_6:            clr.w    d3
                    bra      SETSTATE

BUSY10_0:           tst.w    d0
                    bne      BUSY10_0_0
                    tst.w    S1DEAD
                    bne      BUSY6_4
                    move.l   #WLAUGH1,S1FADDR
                    lea      S1F,a0
                    bra      BUSY10_0_1

BUSY10_0_0:         tst.w    S2DEAD
                    bne      BUSY6_4
                    move.l   #BLAUGH1,S2FADDR
                    lea      S2F,a0
BUSY10_0_1:         cmp.w    #8,d1
                    beq      BUSY10_4
                    btst     #0,d1
                    beq      BUSY10_1
                    clr.w    (a0)
                    add.w    #$A01,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY10_1:           move.w   #1,(a0)
                    add.w    #$A01,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY10_4:           tst.w    d0
                    bne      BUSY10_5
                    move.l   #BUF11,S1FADDR
                    bra      BUSY10_6

BUSY10_5:           move.l   #BUF21,S2FADDR
BUSY10_6:           bra      BUSY7_0

BUSY20_0:           clr.w    S1RUN
                    clr.w    S2RUN
                    tst.w    d0
                    bne      lbC008E00
                    lea      S1FADDR,a1
                    lea      S1F,a2
                    lea      S1DEPTH,a3
                    move.w   #1,S1DEAD
                    lea      S1DROWN,a4
                    move.w   S1MAPX,d3
                    move.w   S1MAPY,d4
                    clr.w    S1SWAMP
                    tst.w    d1
                    bne      lbC008E4C
                    tst.w    S2CT
                    bne      lbC008E4C
                    move.w   #$A00,S2CT
                    bra      lbC008E4C

lbC008E00:          lea      S2FADDR,a1
                    lea      S2F,a2
                    lea      S2DEPTH,a3
                    move.w   #1,S2DEAD
                    lea      S2DROWN,a4
                    move.w   S2MAPX,d3
                    move.w   S2MAPY,d4
                    clr.w    S2SWAMP
                    tst.w    d1
                    bne      lbC008E4C
                    tst.w    S1CT
                    bne      lbC008E4C
                    move.w   #$A00,S1CT
lbC008E4C:          tst.w    d1
                    bne      lbC008E6E
                    move.w   #$1D,(a3)
                    move.l   #12,d7
                    jsr      NEW_SOUND
                    movem.l  d0-d7/a0-a6,-(sp)
                    bsr      BUSY4_A
                    movem.l  (sp)+,d0-d7/a0-a6
lbC008E6E:          clr.w    (a2)
                    move.l   #GRAVE,(a1)
                    subq.w   #1,(a3)
                    cmp.w    #5,(a3)
                    bgt      lbC008E84
                    bra      BUSY6_4

lbC008E84:          add.w    #$1401,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY21_0:           cmp.w    #2,d1
                    bne      BUSY21_1
                    tst.w    d0
                    bne      lbC008EB8
                    clr.w    S1ALTITUDE
                    move.l   #BUF14,S1FADDR
                    clr.w    S1F
                    bra      _BUSY6_4

lbC008EB8:          clr.w    S2ALTITUDE
                    move.l   #BUF24,S2FADDR
                    clr.w    S2F
_BUSY6_4:           bra      BUSY6_4

BUSY21_1:           tst.w    d0
                    bne      lbC008F0A
                    move.w   #-8,S1ALTITUDE
                    clr.w    S1DEPTH
                    lea      S1F,a0
                    lea      S1MAPX,a1
                    lea      S1MAPY,a2
                    move.l   #BUF1D,S1FADDR
                    bra      lbC008F36

lbC008F0A:          move.w   #-8,S2ALTITUDE
                    clr.w    S2DEPTH
                    lea      S2F,a0
                    lea      S2MAPX,a1
                    lea      S2MAPY,a2
                    move.l   #BUF2D,S2FADDR
lbC008F36:          move.w   #1,(a0)
                    moveq    #0,d3
                    move.w   (a2),d3
                    lsr.w    #2,d3
                    mulu     MAXMAPX,d3
                    move.w   (a1),d4
                    sub.w    #4,d4
                    lsr.w    #2,d4
                    add.w    d4,d3
                    add.w    d3,d3
                    add.l    #MAP,d3
                    move.l   d3,a3
                    cmp.w    #$A8,(a3)
                    beq      lbC008F6A
                    cmp.w    #$B0,(a3)
                    bne      lbC008F6E
lbC008F6A:          clr.w    (a0)
lbC008F6E:          add.w    #$1501,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY40_0:           tst.w    d0
                    bne      lbC008F8A
                    clr.w    S1F
                    bra      lbC008F92

lbC008F8A:          clr.w    S2F
lbC008F92:          add.w    #$4100,d1
                    move.w   d1,d3
                    bra      SETSTATE

BUSY41_0:           lsl.w    #8,d1
                    move.w   d1,d3
                    bra      SETSTATE

;                    rts

SETSTATE:           tst.w    d0
                    bne      SETSTATE2
                    move.w   d3,S1CT
                    bne      lbC008FBC
                    clr.w    S1FLASH
lbC008FBC:          rts

SETSTATE2:          move.w   d3,S2CT
                    bne      lbC008FCE
                    clr.w    S2FLASH
lbC008FCE:          rts

GETBTIME:           tst.w    d0
                    bne      GETBTIME2
                    move.w   B1TIME,d1
                    rts

GETBTIME2:          move.w   B2TIME,d1
                    rts

SHOWMAP:            move.w   #96,X
                    add.w    #16,d2
                    move.w   d2,Y
                    move.w   #6,WIDTH
                    move.l   SCREEN2,SCREEN
                    move.w   LEVEL,d4
                    subq.w   #1,d4
                    mulu     #1968,d4
                    add.l    #MAPS,d4
                    move.l   d4,BUFFER
                    movem.l  d0-d3/a0,-(sp)
                    bsr      SPRITER
                    movem.l  (sp)+,d0-d3/a0
                    rts

ABSD2:              tst.w    d2
                    bge      lbC00903A
                    neg.w    d2
lbC00903A:          rts

CLEANTRAIL:         movem.l  d0/a0/a1,-(sp)
                    lea      S1TRAIL,a0
                    lea      S2TRAIL,a1
                    move.w   #7-1,d0
lbC009054:          move.w   #$FFFF,(a0)+
                    move.w   #$FFFF,(a1)+
                    dbra     d0,lbC009054
                    movem.l  (sp)+,d0/a0/a1
                    rts

BUSY36:             tst.w    SPYWIN
                    bne      _BUSY6_40
                    tst.w    d0
                    bne      lbC0090B0
                    tst.w    S1DROWN
                    bne      _BUSY6_40
                    tst.w    S1SWAMP
                    bne      _BUSY6_40
                    tst.w    S1DEPTH
                    bne      _BUSY6_40
                    move.l   #BUF14,d5
                    lea      S1FADDR,a4
                    lea      S1F,a5
                    move.w   S1ENERGY,d4
                    bra      lbC0090E6

lbC0090B0:          tst.w    S2DROWN
                    bne      _BUSY6_40
                    tst.w    S2SWAMP
                    bne      _BUSY6_40
                    tst.w    S2DEPTH
                    bne      _BUSY6_40
                    move.l   #BUF24,d5
                    lea      S2FADDR,a4
                    lea      S2F,a5
                    move.w   S2ENERGY,d4
lbC0090E6:          cmp.w    #$32,d4
                    bhi      _BUSY6_40
                    move.l   d5,(a4)
                    clr.w    (a5)
                    move.w   #$2401,d3
                    bra      SETSTATE

_BUSY6_40:          bra      BUSY6_4

BUSY22:             tst.w    d0
                    bne      lbC00912E
                    lea      S1MENU,a2
                    lea      S1AIMMENU,a3
                    lea      S1HAND,a4
                    lea      S1PLUNGER,a5
                    lea      S1FLASH,a6
                    move.w   #$60,d3
                    move.w   #$30,d2
                    bra      BUSY22A

lbC00912E:          lea      S2MENU,a2
                    lea      S2AIMMENU,a3
                    lea      S2HAND,a4
                    lea      S2PLUNGER,a5
                    lea      S2FLASH,a6
                    move.w   #$58,d3
                    move.w   #$38,d2
BUSY22A:            tst.w    SPYWIN
                    bne      BUSY6_4
                    move.w   COUNTER,d4
                    and.w    #1,d4
                    bne      lbC00918C
                    move.w   (a2),d4
                    cmp.w    (a3),d4
                    beq      BUSY22B
                    blt      lbC00917E
                    subq.w   #1,(a2)
                    bra      lbC009180

lbC00917E:          addq.w   #1,(a2)
lbC009180:          move.l   #1,d7
                    jsr      NEW_SOUND
lbC00918C:          move.w   #$1600,d3
                    bra      SETSTATE

BUSY22B:            clr.w    (a6)
                    cmp.w    #1,d4
                    bne      lbC0091AC
                    tst.w    (a5)
                    beq      _BUSY6_41
                    subq.w   #1,(a5)
                    move.w   d3,(a4)
                    bra      _BUSY6_41

lbC0091AC:          cmp.w    #2,d4
                    bne      lbC0091C8
                    tst.w    2(a5)
                    beq      _BUSY6_41
                    subq.w   #1,2(a5)
                    move.w   #$28,(a4)
                    bra      _BUSY6_41

lbC0091C8:          cmp.w    #3,d4
                    bne      lbC0091E2
                    tst.w    4(a5)
                    beq      _BUSY6_41
                    subq.w   #1,4(a5)
                    move.w   d2,(a4)
                    bra      _BUSY6_41

lbC0091E2:          cmp.w    #4,d4
                    bne      lbC0091FE
                    tst.w    6(a5)
                    beq      _BUSY6_41
                    subq.w   #1,6(a5)
                    move.w   #$40,(a4)
                    bra      _BUSY6_41

lbC0091FE:          cmp.w    #5,d4
                    bne      lbC00921A
                    tst.w    8(a5)
                    beq      _BUSY6_41
                    subq.w   #1,8(a5)
                    move.w   #$48,(a4)
                    bra      _BUSY6_41

lbC00921A:          cmp.w    #6,d4
                    bne      lbC009236
                    tst.w    10(a5)
                    beq      _BUSY6_41
                    subq.w   #1,10(a5)
                    move.w   #$50,(a4)
                    bra      _BUSY6_41

lbC009236:          tst.w    d0
                    bne      lbC009246
                    clr.w    S1F
                    bra      lbC00924C

lbC009246:          clr.w    S2F
lbC00924C:          move.w   #$4005,d3
                    bra      SETSTATE

_BUSY6_41:          bra      BUSY6_4

BUSY50:             tst.w    d0
                    bne      lbC009274
                    lea      S1SAVE_ADD,a1
                    lea      S1SAVE_DIR,a2
                    lea      S1FADDR,a3
                    bra      BUSY50_1

lbC009274:          lea      S2SAVE_ADD,a1
                    lea      S2SAVE_DIR,a2
                    lea      S2FADDR,a3
BUSY50_1:           move.w   d1,d3
                    add.w    #$5001,d3
                    cmp.w    #$5004,d3
                    bne      BUSY50_2
                    add.l    #$1E0,(a3)
                    bra      SETSTATE

BUSY50_2:           cmp.w    #$5003,d3
                    bne      BUSY50_3
                    add.l    #$1E0,(a3)
                    move.w   #7-1,d7
                    lea      SNOW_LIST,a4
lbC0092B6:          tst.w    (a4)
                    beq      lbC0092C4
                    lea      10(a4),a4
                    dbra     d7,lbC0092B6
lbC0092C4:          move.l   (a1),(a4)
                    move.w   #$90,4(a4)
                    move.w   (a2),6(a4)
                    move.w   d0,8(a4)
                    bra      SETSTATE

BUSY50_3:           cmp.w    #$5008,d3
                    bne      SETSTATE
                    cmp.l    #BUFWL3,(a3)
                    beq      lbC009308
                    cmp.l    #BUFWR3,(a3)
                    beq      lbC009312
                    cmp.l    #BUFBL3,(a3)
                    beq      lbC00931C
                    move.l   #BUF21,(a3)
                    bra      _BUSY6_42

lbC009308:          move.l   #BUF12,(a3)
                    bra      _BUSY6_42

lbC009312:          move.l   #BUF11,(a3)
                    bra      _BUSY6_42

lbC00931C:          move.l   #BUF22,(a3)
_BUSY6_42:          bra      BUSY6_4

BUSY51:             bsr      BUSY4_A
                    tst.w    d0
                    bne      lbC009358
                    lea      S1FADDR,a1
                    lea      S1F,a2
                    lea      S1ENERGY,a3
                    move.l   S1DIG,a4
                    move.l   #BUF14,d5
                    move.l   #WSPYSAT,d6
                    bra      BUSY51_1

lbC009358:          lea      S2FADDR,a1
                    lea      S2F,a2
                    lea      S2ENERGY,a3
                    move.l   S2DIG,a4
                    move.l   #BUF24,d5
                    move.l   #BSPYSAT,d6
BUSY51_1:           move.w   d1,d3
                    add.w    #$5101,d3
                    cmp.w    #$5108,d3
                    bge      BUSY51_2
                    cmp.w    #$88,(a4)
                    bne      lbC009398
                    move.l   a4,a0
                    bsr      DELETE_TRAP
lbC009398:          and.w    #3,d1
                    move.w   d1,(a2)
                    bra      SETSTATE

BUSY51_2:           cmp.w    #$5108,d3
                    bne      BUSY51_3
                    subq.w   #4,(a3)
                    move.l   d6,(a1)
                    clr.w    (a2)
                    bra      SETSTATE

BUSY51_3:           cmp.w    #$5120,d3
                    bne      SETSTATE
                    move.l   d5,(a1)
                    clr.w    (a2)
                    bra      BUSY6_4

BUSY52:             bsr      SETUPA2
                    tst.w    d1
                    bne      C3
                    bsr      ADD_TRAP
                    bra      C99

C98:                clr.w    d3
                    bra      SETSTATE

C99:                bsr      SETUPA2
                    tst.w    d0
                    bne      C1
                    move.l   a0,S1DIG
                    tst.w    S1DEPTH
                    bne.b    C98
                    tst.w    S1SWAMP
                    bne.b    C98
                    bra      C2

C1:                 move.l   a0,S2DIG
                    tst.w    S2DEPTH
                    bne.b    C98
                    tst.w    S2SWAMP
                    bne.b    C98
C2:                 bsr      SETUPA2
                    clr.w    (a3)
                    cmp.l    (a2),d6
                    beq      lbC00942A
                    move.l   d4,(a2)
                    bra      _C4

lbC00942A:          move.l   d5,(a2)
_C4:                bra      C4

C3:                 tst.w    (a3)
                    bne      lbC00943C
                    addq.w   #1,(a3)
                    bra      C4

lbC00943C:          clr.w    (a3)
C4:                 cmp.w    #$14,d1
                    blt      C5
                    move.w   #$88,(a4)
                    move.l   d7,(a2)
                    clr.w    (a3)
                    bsr      SETSAFE
                    tst.w    d0
                    bne      lbC009460
                    move.w   #$30,(a5)
                    bra      lbC009464

lbC009460:          move.w   #$38,(a5)
lbC009464:          tst.w    d0
                    bne      lbC009484
                    tst.w    S1AUTO
                    beq      BUSY6_4
                    clr.w    S1HAND
                    addq.w   #1,S1BUCKET
                    bra      BUSY6_4

lbC009484:          tst.w    S2AUTO
                    beq      BUSY6_4
                    clr.w    S2HAND
                    addq.w   #1,S2BUCKET
                    bra      BUSY6_4

C5:                 move.w   d1,d3
                    add.w    #$5201,d3
                    bra      SETSTATE

SETUPA2:            tst.w    d0
                    bne      lbC0094E6
                    lea      S1FADDR,a2
                    lea      S1F,a3
                    move.l   S1DIG,a4
                    lea      S1HAND,a5
                    lea      S1SHCT,a6
                    move.l   #WPOURL1,d4
                    move.l   #WPOURR1,d5
                    move.l   #BUF11,d6
                    move.l   #BUF14,d7
                    rts

lbC0094E6:          lea      S2FADDR,a2
                    lea      S2F,a3
                    move.l   S2DIG,a4
                    lea      S2HAND,a5
                    lea      S2SHCT,a6
                    move.l   #BPOURL1,d4
                    move.l   #BPOURR1,d5
                    move.l   #BUF21,d6
                    move.l   #BUF24,d7
                    rts

BUSY53:             bsr      SETUPA2D
                    tst.w    d1
                    bne      D3_
                    moveq    #$12,d7
                    jsr      NEW_SOUND
                    bsr      ADD_TRAP
                    bra      D99

D98:                clr.w    d3
                    bra      SETSTATE

D99:                moveq    #$12,d7
                    jsr      NEW_SOUND
                    bsr      SETUPA2D
                    tst.w    d0
                    bne      D1_
                    move.l   a0,S1DIG
                    tst.w    S1DEPTH
                    bne.b    D98
                    tst.w    S1SWAMP
                    bne.b    D98
                    bra      D2_

D1_:                move.l   a0,S2DIG
                    tst.w    S2DEPTH
                    bne.b    D98
                    tst.w    S2SWAMP
                    bne.b    D98
D2_:                bsr      SETUPA2D
                    clr.w    (a3)
                    cmp.l    (a2),d6
                    beq      lbC009594
                    move.l   d4,(a2)
                    bra      _D4

lbC009594:          move.l   d5,(a2)
_D4:                bra      D4_

D3_:                tst.w    (a3)
                    bne      lbC0095A6
                    addq.w   #1,(a3)
                    bra      D4_

lbC0095A6:          clr.w    (a3)
D4_:                cmp.w    #$14,d1
                    blt      D5_
                    move.w   #$80,(a4)
                    move.l   d7,(a2)
                    clr.w    (a3)
                    bsr      SETSAFE
                    move.w   #$28,(a5)
                    tst.w    d0
                    bne      lbC0095E0
                    tst.w    S1AUTO
                    beq      BUSY6_4
                    clr.w    S1HAND
                    addq.w   #1,S1SAW
                    bra      BUSY6_4

lbC0095E0:          tst.w    S2AUTO
                    beq      BUSY6_4
                    clr.w    S2HAND
                    addq.w   #1,S2SAW
                    bra      BUSY6_4

D5_:                move.w   d1,d3
                    add.w    #$5301,d3
                    bra      SETSTATE

SETUPA2D:           tst.w    d0
                    bne      lbC009642
                    lea      S1FADDR,a2
                    lea      S1F,a3
                    move.l   S1DIG,a4
                    lea      S1HAND,a5
                    lea      S1SHCT,a6
                    move.l   #WSAWL1,d4
                    move.l   #WSAWR1,d5
                    move.l   #BUF11,d6
                    move.l   #BUF14,d7
                    rts

lbC009642:          lea      S2FADDR,a2
                    lea      S2F,a3
                    move.l   S2DIG,a4
                    lea      S2HAND,a5
                    lea      S2SHCT,a6
                    move.l   #BSAWL1,d4
                    move.l   #BSAWR1,d5
                    move.l   #BUF21,d6
                    move.l   #BUF24,d7
                    rts

BUSY54:             bsr      BUSY4_A
                    tst.w    d0
                    bne      lbC0096B2
                    lea      S1FADDR,a1
                    lea      S1F,a2
                    lea      S1ENERGY,a3
                    move.l   S1DIG,a4
                    lea      S2CT,a5
                    move.l   #BUF14,d5
                    move.l   #WHOLE1,d6
                    bra      BUSY54_1

lbC0096B2:          lea      S2FADDR,a1
                    lea      S2F,a2
                    lea      S2ENERGY,a3
                    move.l   S2DIG,a4
                    lea      S1CT,a5
                    move.l   #BUF24,d5
                    move.l   #BHOLE1,d6
BUSY54_1:           tst.w    d1
                    bne      lbC009712
                    tst.w    (a5)
                    bne      lbC0096EC
                    move.w   #$A00,(a5)
lbC0096EC:          move.l   #5,d7
                    jsr      NEW_SOUND
                    cmp.w    #$80,(a4)
                    bne      lbC009706
                    move.l   a4,a0
                    bsr      DELETE_TRAP
lbC009706:          move.l   d6,(a1)
                    clr.w    (a2)
                    move.w   #$5401,d3
                    bra      SETSTATE

lbC009712:          cmp.w    #1,d1
                    bne      lbC009728
                    move.l   #HOLE2,(a1)
                    move.w   #$5402,d3
                    bra      SETSTATE

lbC009728:          move.w   COUNTER,d3
                    and.w    #3,d3
                    bne      lbC009740
                    cmp.w    #3,(a2)
                    beq      lbC009740
                    addq.w   #1,(a2)
lbC009740:          move.w   d1,d3
                    add.w    #$5401,d3
BUSY54_2:           cmp.w    #$5404,d3
                    bne      BUSY54_3
                    subq.w   #4,(a3)
                    bra      SETSTATE

BUSY54_3:           cmp.w    #$5420,d3
                    bne      SETSTATE
                    move.l   d5,(a1)
                    clr.w    (a2)
                    bra      BUSY6_4

BUSY55:             bsr      SETUPA2E
                    tst.w    d1
                    bne      E3
                    moveq    #$11,d7
                    jsr      NEW_SOUND
                    bsr      ADD_TRAP
                    bra      E99

E98:                clr.w    d3
                    bra      SETSTATE

E99:                moveq    #$11,d7
                    jsr      NEW_SOUND
                    bsr      SETUPA2E
                    tst.w    d0
                    bne      E1
                    move.l   a0,S1DIG
                    tst.w    S1DEPTH
                    bne.b    E98
                    tst.w    S1SWAMP
                    bne.b    E98
                    bra      E2

E1:                 move.l   a0,S2DIG
                    tst.w    S2DEPTH
                    bne.b    E98
                    tst.w    S2SWAMP
                    bne.b    E98
E2:                 bsr      SETUPA2E
                    clr.w    (a3)
                    cmp.l    (a2),d6
                    beq      lbC0097DA
                    move.l   d4,(a2)
                    bra      _E4

lbC0097DA:          move.l   d5,(a2)
_E4:                bra      E4

E3:                 tst.w    (a3)
                    bne      lbC0097EC
                    addq.w   #1,(a3)
                    bra      E4

lbC0097EC:          clr.w    (a3)
E4:                 cmp.w    #$14,d1
                    blt      E5
                    move.w   #$98,(a4)
                    move.l   d7,(a2)
                    clr.w    (a3)
                    bsr      SETSAFE
                    move.w   #$40,(a5)
                    tst.w    d0
                    bne      lbC009826
                    tst.w    S1AUTO
                    beq      BUSY6_4
                    clr.w    S1HAND
                    addq.w   #1,S1PICK
                    bra      BUSY6_4

lbC009826:          tst.w    S2AUTO
                    beq      BUSY6_4
                    clr.w    S2HAND
                    addq.w   #1,S2PICK
                    bra      BUSY6_4

E5:                 move.w   d1,d3
                    add.w    #$5501,d3
                    bra      SETSTATE

SETUPA2E:           tst.w    d0
                    bne      lbC009888
                    lea      S1FADDR,a2
                    lea      S1F,a3
                    move.l   S1DIG,a4
                    lea      S1HAND,a5
                    lea      S1SHCT,a6
                    move.l   #WPICKL1,d4
                    move.l   #WPICKR1,d5
                    move.l   #BUF11,d6
                    move.l   #BUF14,d7
                    rts

lbC009888:          lea      S2FADDR,a2
                    lea      S2F,a3
                    move.l   S2DIG,a4
                    lea      S2HAND,a5
                    lea      S2SHCT,a6
                    move.l   #BPICKL1,d4
                    move.l   #BPICKR1,d5
                    move.l   #BUF21,d6
                    move.l   #BUF24,d7
                    rts

BUSY56:             bsr      BUSY4_A
                    tst.w    d0
                    bne      lbC0098F8
                    lea      S1FADDR,a1
                    lea      S1F,a2
                    lea      S1ENERGY,a3
                    move.l   S1DIG,a4
                    lea      S2CT,a5
                    move.l   #BUF14,d5
                    move.l   #WICICLED1,d6
                    bra      BUSY56_1

lbC0098F8:          lea      S2FADDR,a1
                    lea      S2F,a2
                    lea      S2ENERGY,a3
                    move.l   S2DIG,a4
                    lea      S1CT,a5
                    move.l   #BUF24,d5
                    move.l   #BICICLED1,d6
BUSY56_1:           tst.w    d1
                    bne      lbC00994A
                    moveq    #$13,d7
                    jsr      NEW_SOUND
                    tst.w    (a5)
                    bne      lbC00993A
                    move.w   #$A00,(a5)
lbC00993A:          move.w   #$198,(a4)
                    move.l   d5,(a1)
                    clr.w    (a2)
                    move.w   #$5601,d3
                    bra      SETSTATE

lbC00994A:          cmp.w    #1,d1
                    bne      lbC009966
                    move.w   #$1A0,(a4)
                    move.w   #$5602,d3
                    sub.w    #10,(a3)
                    bsr      SETSTATE
                    bra      BUSY4_A

lbC009966:          cmp.w    #$3C,d1
                    bgt      lbC00998A
                    move.l   d6,(a1)
                    addq.w   #1,(a2)
                    cmp.w    #3,(a2)
                    bne      lbC00997C
                    clr.w    (a2)
lbC00997C:          move.w   #$190,(a4)
                    move.w   d1,d3
                    add.w    #$5601,d3
                    bra      SETSTATE

lbC00998A:          clr.w    (a2)
                    move.l   d5,(a1)
                    bra      BUSY6_4

BUSY57:             tst.w    d0
                    bne      lbC0099F2
                    cmp.w    #3,S1WIN
                    beq      lbC0099A8
                    bsr      BUSY4_A
lbC0099A8:          and.w    #$FFFC,S1MAPX
                    and.w    #$FFFC,S1MAPY
                    lea      S1ENERGY,a1
                    lea      S1FADDR,a2
                    lea      S1F,a3
                    lea      S1DEPTH,a4
                    lea      S1ALTITUDE,a5
                    lea      S1SAFE,a6
                    move.l   S1DIG,a0
                    move.l   #BUF14,d6
                    move.l   #BUF12,d5
                    bra      BUSY57_0_5

lbC0099F2:          cmp.w    #3,S2WIN
                    beq      lbC009A02
                    bsr      BUSY4_A
lbC009A02:          and.w    #$FFFC,S2MAPX
                    and.w    #$FFFC,S2MAPY
                    lea      S2ENERGY,a1
                    lea      S2FADDR,a2
                    lea      S2F,a3
                    lea      S2DEPTH,a4
                    lea      S2ALTITUDE,a5
                    lea      S2SAFE,a6
                    move.l   S2DIG,a0
                    move.l   #BUF24,d6
                    move.l   #BUF22,d5
BUSY57_0_5:         tst.w    d1
                    bne      BUSY57_1
                    tst.w    d0
                    bne      lbC009A64
                    addq.w   #8,S1OFFSETX
                    addq.w   #2,S1OFFSETY
                    bra      lbC009A70

lbC009A64:          addq.w   #8,S2OFFSETX
                    addq.w   #2,S2OFFSETY
lbC009A70:          move.l   d6,(a2)
                    move.w   #$140,-2(a0)
                    move.w   #$148,(a0)
                    move.w   #$150,2(a0)
                    move.w   #$5701,d3
                    bra      SETSTATE

BUSY57_1:           cmp.w    #1,d1
                    bne      BUSY57_2
                    cmp.w    #$14,(a4)
                    bgt      BUSY57_1_5
                    addq.w   #2,(a4)
                    rts

BUSY57_1_5:         tst.w    d0
                    bne      lbC009AE2
                    tst.w    S1ROCKET
                    bne      lbC009AE0
                    cmp.w    #3,S1WIN
                    bne      lbC009B1E
                    move.l   #WROCKET1,RDATA
                    move.w   #1,S1ROCKET
                    move.w   #2,SOUNDCT
                    move.l   #$10009,d7
                    jmp      NEW_SOUND
lbC009AE0:          rts

lbC009AE2:          tst.w    S2ROCKET
                    bne.b    lbC009AE0
                    cmp.w    #3,S2WIN
                    bne      lbC009B1E
                    move.l   #BROCKET1,RDATA
                    move.w   #1,S2ROCKET
                    move.w   #2,SOUNDCT
                    move.l   #$10009,d7
                    jmp      NEW_SOUND
;                    rts

lbC009B1E:          move.l   d5,(a2)
                    move.w   #$5702,d3
                    bra      SETSTATE

BUSY57_2:           cmp.w    #2,d1
                    bne      BUSY57_3
                    subq.w   #1,(a1)
                    bpl      lbC009B3A
                    move.w   #1,(a1)
lbC009B3A:          addq.w   #1,(a3)
                    and.w    #3,(a3)
                    subq.w   #4,(a4)
                    bmi      BUSY57_2_5
                    rts

BUSY57_2_5:         clr.w    (a4)
                    move.w   #$158,-2(a0)
                    move.w   #$160,(a0)
                    move.w   #$168,2(a0)
                    move.w   #$5703,d3
                    bra      SETSTATE

BUSY57_3:           cmp.w    #3,d1
                    bne      BUSY57_4
                    addq.w   #1,(a3)
                    and.w    #3,(a3)
                    cmp.w    #15,(a5)
                    bgt      BUSY57_3_5
                    addq.w   #5,(a5)
                    rts

BUSY57_3_5:         move.w   #$128,-2(a0)
                    move.w   #$130,(a0)
                    move.w   #$138,2(a0)
                    move.w   #$5704,d3
                    bra      SETSTATE

BUSY57_4:           addq.w   #1,(a3)
                    and.w    #3,(a3)
                    subq.w   #3,(a5)
                    bmi      BUSY57_4_5
                    rts

BUSY57_4_5:         clr.w    (a5)
                    move.w   #4,(a6)
                    tst.w    d0
                    bne      lbC009BBE
                    subq.w   #8,S1OFFSETX
                    subq.w   #2,S1OFFSETY
                    bra      _BUSY6_43

lbC009BBE:          subq.w   #8,S2OFFSETX
                    subq.w   #2,S2OFFSETY
_BUSY6_43:          bra      BUSY6_4

BUSY58:             tst.w    d0
                    bne      lbC009C0C
                    clr.w    S2TNTREADY
                    lea      S1FADDR,a1
                    lea      S1F,a2
                    lea      S1HAND,a3
                    move.l   #BUF11,d3
                    move.l   #WPLUNGER1,d4
                    move.l   #WPLUNGEL1,d5
                    move.l   #BUF14,d6
                    move.w   #$60,d7
                    bra      BUSY58_1

lbC009C0C:          clr.w    S1TNTREADY
                    lea      S2FADDR,a1
                    lea      S2F,a2
                    lea      S2HAND,a3
                    move.l   #BUF21,d3
                    move.l   #BPLUNGER1,d4
                    move.l   #BPLUNGEL1,d5
                    move.l   #BUF24,d6
                    move.w   #$58,d7
BUSY58_1:           tst.w    d1
                    bne      BUSY58_2
                    cmp.w    (a1),d3
                    beq      lbC009C52
                    move.l   d5,(a1)
                    bra      lbC009C54

lbC009C52:          move.l   d4,(a1)
lbC009C54:          clr.w    (a2)
                    move.w   #$5801,d3
                    bra      SETSTATE

BUSY58_2:           move.w   d1,d3
                    add.w    #$5801,d3
                    cmp.w    #$5808,d3
                    bgt      BUSY58_3
                    bne      SETSTATE
                    move.w   #1,(a2)
                    bra      SETSTATE

BUSY58_3:           cmp.w    #$5810,d3
                    bgt      BUSY58_4
                    bne      SETSTATE
                    clr.w    (a2)
                    bra      SETSTATE

BUSY58_4:           cmp.w    #$5818,d3
                    blt      SETSTATE
                    move.l   d6,(a1)
                    move.w   d7,(a3)
                    tst.w    d0
                    bne      lbC009CB6
                    tst.w    S1AUTO
                    beq      BUSY6_4
                    clr.w    S1HAND
                    addq.w   #1,S1PLUNGER
                    bra      BUSY6_4

lbC009CB6:          tst.w    S2AUTO
                    beq      BUSY6_4
                    clr.w    S2HAND
                    addq.w   #1,S2PLUNGER
                    bra      BUSY6_4

BUSY59:             bsr      BUSY4_A
                    tst.w    d0
                    bne      lbC009D0E
                    lea      S1DIG,a0
                    lea      S1FADDR,a1
                    lea      S1F,a2
                    lea      S1ENERGY,a3
                    lea      S1ALTITUDE,a4
                    lea      S2CT,a5
                    move.l   #BUF14,d4
                    move.l   #WBLUP1,d5
                    bra      BUSY59_1

lbC009D0E:          lea      S2DIG,a0
                    lea      S2FADDR,a1
                    lea      S2F,a2
                    lea      S2ENERGY,a3
                    lea      S2ALTITUDE,a4
                    lea      S1CT,a5
                    move.l   #BUF24,d4
                    move.l   #BBLUP1,d5
BUSY59_1:           tst.w    d1
                    bne      BUSY59_2
                    tst.w    (a5)
                    bne      lbC009D4E
                    move.w   #$A00,(a5)
lbC009D4E:          moveq    #4,d7
                    jsr      NEW_SOUND
                    move.l   d5,(a1)
                    clr.w    (a2)
                    sub.w    #10,(a3)
                    move.w   #$5901,d3
                    bra      SETSTATE

BUSY59_2:           move.w   COUNTER,d3
                    and.w    #1,d3
                    addq.w   #1,d3
                    move.w   d3,(a2)
                    cmp.w    #1,d1
                    bne      BUSY59_3
                    addq.w   #1,(a4)
                    cmp.w    #6,(a4)
                    blt      BUSY59_9
                    move.w   #$5902,d3
                    bra      SETSTATE

BUSY59_3:           subq.w   #1,(a4)
                    bgt      BUSY59_9
                    move.l   d4,(a1)
                    clr.w    (a2)
                    move.l   #DUMMY_WORD,(a0)
                    move.w   #$5620,d3
                    bra      SETSTATE

BUSY59_9:           rts

DUMMY_WORD:         dc.w     0

GETMODE:            move.w   #2,BG_ONCE
                    move.w   #$1F4,DEMO_COUNT
GETM2:              bsr      TEST_OPTIONS
                    subq.w   #1,DEMO_COUNT
                    bne      lbC009E08
                    move.w   #$190,DEMO
                    jsr      PLAYINIT0
                    move.w   #1,S1AUTO
                    move.w   #1,S2AUTO
                    movem.l  d0-d7/a0-a6,-(sp)
                    bsr      CLEANTRAIL
                    bsr      DO_GAME
                    bsr      CLEANTRAIL
                    movem.l  (sp)+,d0-d7/a0-a6
                    clr.w    DEMO
                    bra.b    GETMODE

lbC009E08:          tst.w    BG_ONCE
                    beq      GETM2A
                    subq.w   #1,BG_ONCE
                    move.l   BACK,a0
                    move.l   SCREEN2,a1
                    move.w   #(200*40)-1,d0
lbC009E28:          move.l   (a0)+,(a1)+
                    dbra     d0,lbC009E28
                    move.w   #$40,d1
                    move.w   #10,d2
                    move.w   #$12,d6
                    move.w   #$3E,d7
                    move.l   SCREEN2,a0
                    jsr      RCLEARBLOCK
                    move.w   #$40,d1
                    move.w   #$6F,d2
                    move.w   #$12,d6
                    move.w   #$3E,d7
                    move.l   SCREEN2,a0
                    jsr      RCLEARBLOCK
                    move.w   #$6A,d1
                    move.w   #$15,d2
                    move.w   #7,d6
                    move.w   #$29,d7
                    lea      CONTROLS,a1
                    bsr      RSPRITER
                    move.w   #$6A,d1
                    move.w   #$74,d2
                    move.w   #7,d6
                    move.w   #$37,d7
                    lea      CONTROLS,a1
                    bsr      RSPRITER
                    move.w   #$40,d1
                    move.w   #$1B,d2
                    move.w   #2,d6
                    move.w   #$1E,d7
                    lea      lbL016EF0,a1
                    bsr      RSPRITER
                    move.w   #$40,d1
                    move.w   #$7E,d2
                    move.w   #2,d6
                    move.w   #$1E,d7
                    lea      lbL01A418,a1
                    bsr      RSPRITER
                    move.w   S1MODE,d1
                    move.w   S2MODE,d2
                    move.w   #6,d3
GETM2A:             bsr      DRAWITEMS
                    bsr      SWAPSCREEN
GETM3:              move.w   #$44,d0
                    jsr      INKEY
                    bne      GETM4
                    move.w   #$40,d0
                    jsr      INKEY
                    beq      GETM5
GETM4:              cmp.w    #6,d3
                    bne      lbC009F20
                    cmp.w    d2,d1
                    bne      lbC009F1E
                    tst.w    d1
                    bne      lbC009F1C
                    moveq    #3,d2
                    bra      lbC009F1E

lbC009F1C:          moveq    #4,d2
lbC009F1E:          rts

lbC009F20:          cmp.w    #2,d3
                    bhi      lbC009F3E
                    move.w   d3,d1
                    cmp.w    #2,d2
                    bne      _GETM2
                    cmp.w    d2,d1
                    bne      _GETM2
                    moveq    #0,d2
                    bra      _GETM2

lbC009F3E:          move.w   d3,d2
                    subq.w   #3,d2
                    cmp.w    #2,d2
                    bne      _GETM2
                    cmp.w    d2,d1
                    bne      _GETM2
                    moveq    #0,d1
_GETM2:             bra      GETM2

GETM5:              move.w   #$4C,d0
                    jsr      INKEY
                    beq      GETM6
lbC009F64:          move.w   #$4C,d0
                    jsr      INKEY
                    bne.b    lbC009F64
                    move.w   #500,DEMO_COUNT
                    tst.w    d3
                    beq      GETM2
                    subq.w   #1,d3
                    bra      GETM2

GETM6:              move.w   #$4D,d0
                    jsr      INKEY
                    beq      GETM2
lbC009F94:          move.w   #$4D,d0
                    jsr      INKEY
                    bne.b    lbC009F94
                    move.w   #500,DEMO_COUNT
                    cmp.w    #6,d3
                    beq      GETM2
                    addq.w   #1,d3
                    bra      GETM2

DRAWITEMS:          clr.w    d4
DRAWITEMS1:         move.w   #104,PX1
                    move.w   #136,PX2
                    cmp.w    #3,d4
                    bge      lbC009FEC
                    move.w   d4,d6
                    mulu     #15,d6
                    add.w    #20,d6
                    move.w   d6,PY1
                    move.w   d6,PY2
                    bra      lbC00A006

lbC009FEC:          move.w   d4,d6
                    subq.w   #3,d6
                    mulu     #15,d6
                    add.w    #115,d6
                    move.w   d6,PY1
                    move.w   d6,PY2
lbC00A006:          move.w   #1,d5
                    cmp.w    d3,d4
                    bne      _DRAWLINE
                    move.w   #14,d5
_DRAWLINE:          bsr      DRAWLINE
                    add.w    #12,PY1
                    add.w    #12,PY2
                    bsr      DRAWLINE
                    sub.w    #32,PX2
                    sub.w    #11,PY2
                    bsr      DRAWLINE
                    add.w    #32,PX1
                    add.w    #32,PX2
                    bsr      DRAWLINE
                    move.w   #1,d5
                    cmp.w    d1,d4
                    bne      lbC00A062
                    move.w   #7,d5
lbC00A062:          add.w    #3,d2
                    cmp.w    d2,d4
                    bne      lbC00A070
                    move.w   #7,d5
lbC00A070:          sub.w    #3,d2
                    move.w   #105,PX1
                    move.w   #135,PX2
                    cmp.w    #3,d4
                    bge      DRAWITEMS2
                    move.w   d4,d6
                    mulu     #15,d6
                    add.w    #21,d6
                    move.w   d6,PY1
                    move.w   d6,PY2
                    bra      DRAWITEMS3

DRAWITEMS2:         move.w   d4,d6
                    subq.w   #3,d6
                    mulu     #15,d6
                    add.w    #116,d6
                    move.w   d6,PY1
                    move.w   d6,PY2
DRAWITEMS3:         bsr      DRAWLINE
                    add.w    #10,PY1
                    add.w    #10,PY2
                    bsr      DRAWLINE
                    sub.w    #30,PX2
                    sub.w    #9,PY2
                    bsr      DRAWLINE
                    add.w    #30,PX1
                    add.w    #30,PX2
                    bsr      DRAWLINE
                    addq.w   #1,d4
                    cmp.w    #6,d4
                    ble      DRAWITEMS1
                    rts

SELECTITEM:         rts

DRAWLINE:           movem.l  d0-d7/a0-a6,-(sp)
                    move.w   d5,d7
                    move.w   PX1,d1
                    move.w   PY1,d2
                    move.w   PX2,d3
                    move.w   PY2,d4
                    move.l   SCREEN2,a0
                    bsr      DRAW_LINE
                    movem.l  (sp)+,d0-d7/a0-a6
                    rts

PX1:                dc.w     0
PY1:                dc.w     0
PX2:                dc.w     0
PY2:                dc.w     0
BG_ONCE:            dc.w     0

RCLEARBLOCK:        movem.l  d0-d3/d7/a0/a2,-(sp)
                    addq.w   #1,d7
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    move.w   d1,d0
                    and.w    #$FFF8,d1
                    lsr.w    #3,d1
                    add.w    d1,a0
lbC00A160:          move.w   d6,d3
                    move.l   a0,a2
lbC00A164:          move.b   #$FF,(a0)+
                    move.b   #0,(200*40)-1(a0)
                    move.b   #0,(200*2*40)-1(a0)
                    move.b   #0,(200*3*40)-1(a0)
                    dbra     d3,lbC00A164
                    lea      40(a2),a0
                    dbra     d7,lbC00A160
                    movem.l  (sp)+,d0-d3/d7/a0/a2
                    rts

BRAINMOVE:          clr.w    GOING_TO_KILL_YOU1
                    clr.w    GOING_TO_KILL_YOU2
                    clr.w    SPYDIR
                    clr.w    d1
                    clr.w    d2
                    tst.w    d0
                    bne      lbC00A21E
                    cmp.w    #3,S2WIN
                    beq      lbC00A1C6
                    cmp.w    #51,S1ENERGY
                    bls      lbC00A1CC
lbC00A1C6:          clr.w    IN_TROUBLE1
lbC00A1CC:          tst.w    S1NUDGE
                    beq      lbC00A1DC
                    subq.w   #1,S1NUDGE
lbC00A1DC:          move.w   S1MAPX,d3
                    move.w   S1MAPY,d4
                    move.w   S1HAND,d5
                    move.w   S1SAFE,d6
                    move.l   S1CHOICEX,a2
                    move.l   S1CHOICEY,a3
                    lea      S1BDIR,a4
                    lea      S1RUN,a6
                    lea      S1CT,a1
                    tst.w    S1DEAD
                    beq      lbC00A28E
                    rts

lbC00A21E:          cmp.w    #3,S1WIN
                    bne      lbC00A236
                    cmp.w    #51,S2ENERGY
                    bls      lbC00A23C
lbC00A236:          clr.w    IN_TROUBLE2
lbC00A23C:          tst.w    S2NUDGE
                    beq      lbC00A24C
                    subq.w   #1,S2NUDGE
lbC00A24C:          move.w   S2MAPX,d3
                    move.w   S2MAPY,d4
                    move.w   S2HAND,d5
                    move.w   S2SAFE,d6
                    move.l   S2CHOICEX,a2
                    move.l   S2CHOICEY,a3
                    lea      S2BDIR,a4
                    lea      S2RUN,a6
                    lea      S2CT,a1
                    tst.w    S2DEAD
                    beq      lbC00A28E
                    rts

lbC00A28E:          lsr.w    #2,d3
                    lsr.w    #2,d4
                    movem.l  d4,-(sp)
                    mulu     #96,d4
                    add.w    d3,d4
                    add.w    d4,d4
                    add.l    #MAP,d4
                    move.l   d4,a0
                    movem.l  (sp)+,d4
BRAINMOVE0:         tst.w    d0
                    bne      lbC00A2C8
                    cmp.w    #22,S1ENERGY
                    bhi      BMOVE1A
                    move.w   #60,IN_TROUBLE1
                    bra      BMOVE1A

lbC00A2C8:          cmp.w    #22,S2ENERGY
                    bhi      BMOVE1A
                    move.w   #60,IN_TROUBLE2
BMOVE1A:            tst.w    d0
                    bne      lbC00A2FC
                    tst.w    IN_TROUBLE1
                    beq      lbC00A316
                    clr.w    S1BASTARD_COUNT
                    subq.w   #1,IN_TROUBLE1
                    bra      lbC00A408

lbC00A2FC:          tst.w    IN_TROUBLE2
                    beq      lbC00A316
                    clr.w    S2BASTARD_COUNT
                    subq.w   #1,IN_TROUBLE2
                    bra      lbC00A408

lbC00A316:          tst.w    d0
                    bne      lbC00A37C
                    tst.w    S2DEAD
                    bne      lbC00A35C
                    tst.w    S2SWAMP
                    bne      lbC00A35C
                    tst.w    S2DEPTH
                    bne      lbC00A35C
                    cmp.b    #80,S2CT
                    beq      lbC00A368
                    cmp.b    #9,S2CT
                    beq      lbC00A368
                    tst.b    S2CT
                    beq      lbC00A368
lbC00A35C:          clr.w    S1BASTARD_COUNT
                    bra      lbC00A408

lbC00A368:          tst.w    S1BASTARD_COUNT
                    beq      lbC00A3DC
                    subq.w   #1,S1BASTARD_COUNT
                    bra      lbC00A56C

lbC00A37C:          tst.w    S1DEAD
                    bne      lbC00A3BC
                    tst.w    S1DEPTH
                    bne      lbC00A3BC
                    tst.w    S1SWAMP
                    bne      lbC00A3BC
                    cmp.b    #80,S1CT
                    beq      lbC00A3C8
                    cmp.b    #9,S1CT
                    beq      lbC00A3C8
                    tst.b    S1CT
                    beq      lbC00A3C8
lbC00A3BC:          clr.w    S2BASTARD_COUNT
                    bra      lbC00A408

lbC00A3C8:          tst.w    S2BASTARD_COUNT
                    beq      lbC00A3DC
                    subq.w   #1,S2BASTARD_COUNT
                    bra      lbC00A56C

lbC00A3DC:          tst.w    SPYWIN
                    bne      lbC00A3EA
                    bra      lbC00A408

lbC00A3EA:          tst.w    d0
                    bne      lbC00A3FC
                    move.w   #5,S1BASTARD_COUNT
                    bra      lbC00A56C

lbC00A3FC:          move.w   #5,S2BASTARD_COUNT
                    bra      lbC00A56C

lbC00A408:          tst.w    d0
                    bne      lbC00A442
                    lea      S1WIN,a5
                    tst.w    S1STILL
                    bne      BRAINMOVE1
                    tst.w    S1TRAPNEXT
                    bne      BRAINMOVE1
                    tst.w    IN_TROUBLE1
                    beq      lbC00A476
lbC00A432:          lea      XIGLOO1,a2
                    lea      YIGLOO1,a3
                    bra      lbC00A638

lbC00A442:          lea      S2WIN,a5
                    tst.w    S2TRAPNEXT
                    bne      BRAINMOVE1
                    tst.w    S2STILL
                    bne      BRAINMOVE1
                    tst.w    IN_TROUBLE2
                    beq      lbC00A476
                    lea      XIGLOO2,a2
                    lea      YIGLOO2,a3
                    bra      lbC00A638

lbC00A476:          cmp.w    #3,(a5)
                    bne      lbC00A48E
                    lea      XHATCH,a2
                    lea      YHATCH,a3
                    bra      lbC00A638

lbC00A48E:          cmp.w    #8,d5
                    beq      lbC00A51E
                    tst.w    d0
                    bne      lbC00A4D0
                    tst.w    XWPLUNG
                    beq      lbC00A4B6
                    lea      XWPLUNG,a2
                    lea      YWPLUNG,a3
                    bra      lbC00A5C8

lbC00A4B6:          tst.w    XWBUCK
                    beq      lbC00A504
                    lea      XWBUCK,a2
                    lea      YWBUCK,a3
                    bra      lbC00A5C8

lbC00A4D0:          tst.w    XBPLUNG
                    beq      lbC00A4EA
                    lea      XBPLUNG,a2
                    lea      YBPLUNG,a3
                    bra      lbC00A5C8

lbC00A4EA:          tst.w    XBBUCK
                    beq      lbC00A504
                    lea      XBBUCK,a2
                    lea      YBBUCK,a3
                    bra      lbC00A5C8

lbC00A504:          tst.w    XCASE
                    beq      lbC00A56C
                    lea      XCASE,a2
                    lea      YCASE,a3
                    bra      lbC00A5C8

lbC00A51E:          tst.w    XCARD
                    beq      lbC00A538
                    lea      XCARD,a2
                    lea      YCARD,a3
                    bra      lbC00A5C8

lbC00A538:          tst.w    XGYRO
                    beq      lbC00A552
                    lea      XGYRO,a2
                    lea      YGYRO,a3
                    bra      lbC00A5C8

lbC00A552:          tst.w    XJAR
                    beq      lbC00A56C
                    lea      XJAR,a2
                    lea      YJAR,a3
                    bra      lbC00A5C8

lbC00A56C:          tst.w    d0
                    bne      lbC00A5E8
                    tst.w    S2IGLOO
                    bne      lbC00A432
                    move.w   #-1,GOING_TO_KILL_YOU1
                    movem.l  d1/d2,-(sp)
                    move.w   S2CELLX,d1
                    move.w   S2CELLY,d2
                    addq.w   #1,d2
                    cmp.w    S1CELLX,d1
                    ble      lbC00A5A6
                    subq.w   #6,d1
                    bra      lbC00A5A8

lbC00A5A6:          addq.w   #8,d1
lbC00A5A8:          move.w   d1,XPLACE
                    move.w   d2,YPLACE
                    lea      XPLACE,a2
                    lea      YPLACE,a3
                    movem.l  (sp)+,d1/d2
                    bra      lbC00A638

lbC00A5C8:          move.w   (a2),XPLACE
                    move.w   (a3),YPLACE
                    lea      XPLACE,a2
                    lea      YPLACE,a3
                    bsr      FIND_A_MOUND
                    bra      lbC00A638

lbC00A5E8:          tst.w    S1IGLOO
                    bne      lbC00A432
                    move.w   #-1,GOING_TO_KILL_YOU2
                    movem.l  d1/d2,-(sp)
                    move.w   S1CELLX,d1
                    move.w   S1CELLY,d2
                    cmp.w    S2CELLX,d1
                    ble      lbC00A61A
                    subq.w   #6,d1
                    bra      lbC00A61C

lbC00A61A:          addq.w   #8,d1
lbC00A61C:          move.w   d1,XPLACE
                    move.w   d2,YPLACE
                    lea      XPLACE,a2
                    lea      YPLACE,a3
                    movem.l  (sp)+,d1/d2
lbC00A638:          tst.w    d0
                    bne      lbC00A64E
                    move.l   a2,S1CHOICEX
                    move.l   a3,S1CHOICEY
                    bra      BRAINMOVE1

lbC00A64E:          move.l   a2,S2CHOICEX
                    move.l   a3,S2CHOICEY
BRAINMOVE1:         movem.l  d0-d6/a0-a6,-(sp)
                    tst.w    d0
                    bne      lbC00A696
                    clr.w    S1STILL
                    tst.w    S1NUDGE
                    bne      BRAINMOVE1_1
                    tst.w    S1SWAMP
                    bne      BM9
                    tst.w    S1DEPTH
                    bne      BM9
                    tst.w    GOING_TO_KILL_YOU1
                    bne      lbC00A6C4
                    bra      BM9

lbC00A696:          clr.w    S2STILL
                    tst.w    S2NUDGE
                    bne      BRAINMOVE1_1
                    tst.w    S2SWAMP
                    bne      BM9
                    tst.w    S2DEPTH
                    bne      BM9
                    tst.w    GOING_TO_KILL_YOU2
                    beq      BM9
lbC00A6C4:          move.w   S1MAPY,d1
                    sub.w    S2MAPY,d1
                    bge      lbC00A6D6
                    neg.w    d1
lbC00A6D6:          cmp.w    #1,d1
                    bgt      BM9
                    move.w   S1MAPX,d1
                    sub.w    S2MAPX,d1
                    bge      lbC00A6F0
                    neg.w    d1
lbC00A6F0:          cmp.w    #7,d1
                    blt      BM9
                    cmp.w    #15,d1
                    blt      lbC00A712
                    bsr      RNDER2
                    and.w    #7,d1
                    cmp.w    IQ,d1
                    bgt      BM9
lbC00A712:          tst.w    d0
                    bne      BBUSY_SB
BBUSY_SW:           move.w   S1MAPX,d1
                    cmp.w    S2MAPX,d1
                    bgt      lbC00A73E
                    move.w   S1MAPX,d1
                    addq.w   #2,d1
                    lea      BUFWR1,a0
                    move.w   #1,d3
                    bra      lbC00A752

lbC00A73E:          move.w   S1MAPX,d1
                    ;sub.w    #0,d1
                    lea      BUFWL1,a0
                    move.w   #-1,d3
lbC00A752:          clr.w    S1F
                    move.l   a0,S1FADDR
                    move.w   S1MAPY,d2
                    move.w   d3,S1SAVE_DIR
                    lea      S1SAVE_ADD,a1
                    bra      BBUSY_S_SETUP

BBUSY_SB:           move.w   S2MAPX,d1
                    cmp.w    S1MAPX,d1
                    bgt      lbC00A79A
                    move.w   S2MAPX,d1
                    addq.w   #2,d1
                    lea      BUFBR1,a0
                    move.w   #1,d3
                    bra      lbC00A7AE

lbC00A79A:          move.w   S2MAPX,d1
                    ;sub.w    #0,d1
                    lea      BUFBL1,a0
                    move.w   #-1,d3
lbC00A7AE:          clr.w    S2F
                    move.l   a0,S2FADDR
                    move.w   S2MAPY,d2
                    move.w   d3,S2SAVE_DIR
                    lea      S2SAVE_ADD,a1
BBUSY_S_SETUP:      lsr.w    #2,d2
                    mulu     MAXMAPX,d2
                    lsr.w    #2,d1
                    add.w    d2,d1
                    add.w    d1,d1
                    lea      MAP,a0
                    add.w    d1,a0
                    move.l   a0,(a1)
                    move.w   #$5000,d3
                    bsr      SETSTATE
                    move.w   #85,DANGER
                    movem.l  (sp)+,d0-d6/a0-a6
                    clr.w    d1
                    clr.w    d2
                    clr.w    SPYDIR
                    rts

BM9:                bsr      BUSY6_4
BRAINMOVE1_0:       tst.w    SPYWIN
                    beq      BRAINMOVE1_1
                    movem.l  d0-d7/a0-a6,-(sp)
                    tst.w    d0
                    bne      lbC00A86E
                    tst.w    GOING_TO_KILL_YOU1
                    beq      lbC00A936
                    tst.w    S2DEAD
                    bne      lbC00A936
                    move.w   S1MAPX,d1
                    move.w   S1MAPY,d2
                    move.w   S2MAPX,d3
                    move.w   S2MAPY,d4
                    tst.w    S2SWAMP
                    beq      lbC00A8BA
                    tst.w    S2DEPTH
                    beq      lbC00A8BA
                    move.w   #1,S1RUN
                    bra      lbC00A936

lbC00A86E:          tst.w    GOING_TO_KILL_YOU2
                    beq      lbC00A936
                    tst.w    S1DEAD
                    bne      lbC00A936
                    move.w   S2MAPX,d1
                    move.w   S2MAPY,d2
                    move.w   S1MAPX,d3
                    move.w   S1MAPY,d4
                    tst.w    S1SWAMP
                    beq      lbC00A8BA
                    tst.w    S1DEPTH
                    beq      lbC00A8BA
                    move.w   #1,S2RUN
                    bra      lbC00A936

lbC00A8BA:          lsr.w    #2,d1
                    lsr.w    #2,d3
                    move.w   d2,d5
                    move.w   d4,d6
                    lsr.w    #4,d5
                    lsr.w    #4,d6
                    cmp.w    d5,d6
                    bne      lbC00A936
                    move.w   d1,d5
                    sub.w    d3,d5
                    move.w   d2,d6
                    sub.w    d4,d6
                    tst.w    d6
                    beq      lbC00A936
                    tst.w    d5
                    bpl      lbC00A8E2
                    neg.w    d5
lbC00A8E2:          cmp.w    #64,d5
                    bhi      lbC00A936
                    tst.w    d6
                    bpl      lbC00A904
                    clr.w    d1
                    move.w   #1,d2
                    move.w   #4,SPYDIR
                    bra      lbC00A914

lbC00A904:          clr.w    d1
                    move.w   #-1,d2
                    move.w   #3,SPYDIR
lbC00A914:          move.w   d1,TEMP1
                    move.w   d2,TEMP2
                    movem.l  (sp)+,d0-d7/a0-a6
                    movem.l  (sp)+,d0-d6/a0-a6
                    move.w   TEMP1,d1
                    move.w   TEMP2,d2
                    rts

lbC00A936:          movem.l  (sp)+,d0-d7/a0-a6
BRAINMOVE1_1:       movem.l  (sp)+,d0-d6/a0-a6
                    tst.w    d0
                    bne      lbC00A982
                    tst.w    S1NUDGE
                    bne      GO_MOVE
                    tst.w    S1IGLOO
                    beq      BRAINMOVE1_1A
                    cmp.w    #62,S1ENERGY
                    bge      lbC00A9C4
                    bsr      FIRE_IN_HERE
                    beq      lbC00A9C4
                    move.w   COUNTER,d7
                    and.w    #$FF,d7
                    cmp.w    #10,d7
                    beq      lbC00A9C4
                    bra      lbC00A9BC

lbC00A982:          tst.w    S2NUDGE
                    bne      GO_MOVE
                    tst.w    S2IGLOO
                    beq      BRAINMOVE1_1A
                    cmp.w    #62,S2ENERGY
                    bge      lbC00A9C4
                    bsr      FIRE_IN_HERE
                    beq      lbC00A9C4
                    move.w   COUNTER,d7
                    and.w    #$FF,d7
                    cmp.w    #$2C,d7
                    beq      lbC00A9C4
lbC00A9BC:          move.w   #1,(a4)
                    bra      GO_MOVE

lbC00A9C4:          cmp.w    #$F9,2(a0)
                    beq      lbC00A9F4
                    cmp.w    #$F9,4(a0)
                    beq      lbC00A9F4
                    cmp.w    #$F9,6(a0)
                    beq      lbC00A9F4
                    cmp.w    #$F9,8(a0)
                    beq      lbC00A9F4
                    move.w   #4,(a4)
                    bra      lbC00A9F8

lbC00A9F4:          move.w   #8,(a4)
lbC00A9F8:          tst.w    d0
                    bne      lbC00AA0A
                    move.w   #9,S1NUDGE
                    bra      GO_MOVE

lbC00AA0A:          move.w   #9,S2NUDGE
                    bra      GO_MOVE

BRAINMOVE1_1A:      tst.w    d0
                    bne      lbC00AA2A
                    tst.w    S1NUDGE
                    bne      GO_MOVE
                    bra      lbC00AA34

lbC00AA2A:          tst.w    S2NUDGE
                    bne      GO_MOVE
lbC00AA34:          move.w   d4,d6
                    move.w   (a3),d5
                    clr.w    d1
                    clr.w    d2
                    clr.w    SPYDIR
                    lsr.w    #2,d5
                    lsr.w    #2,d6
                    cmp.w    d5,d6
                    beq      BRAINMOVE2
                    cmp.w    #$20,(a4)
                    bne      lbC00AA5C
                    clr.w    (a4)
lbC00AA5C:          move.w   d4,d6
                    and.w    #$FFFC,d6
                    mulu     #96,d6
                    add.w    d3,d6
                    add.w    d6,d6
                    add.l    #MAP,d6
                    move.l   d6,a5
                    move.w   (a5),d6
                    cmp.w    #$98,d6
                    beq      lbC00AA84
                    cmp.w    #$190,d6
                    bne      lbC00AA92
lbC00AA84:          cmp.w    (a3),d4
                    ble      lbC00AA92
                    move.w   #1,(a4)
                    bra      lbC00AB34

lbC00AA92:          cmp.w    #$188,576(a5)
                    bne      lbC00AAAA
                    cmp.w    (a3),d4
                    bge      lbC00AAAA
                    move.w   #2,(a4)
                    bra      lbC00AB34

lbC00AAAA:          tst.w    d0
                    bne      lbC00AABE
                    tst.w    S1NUDGE
                    beq      _RNDER2
                    bra      lbC00AB10

lbC00AABE:          tst.w    S2NUDGE
                    bne      lbC00AB10
_RNDER2:            jsr      RNDER2
                    and.w    #3,d1
                    beq      lbC00AB10
                    move.l   a5,-(sp)
lbC00AAD8:          move.w   -(a5),d1
                    cmp.w    #$B1,d1
                    beq      lbC00AB0A
                    cmp.w    (a3),d4
                    ble      lbC00AB00
                    cmp.w    #$98,d1
                    beq      lbC00AAF6
                    cmp.w    #$190,d1
                    bne.b    lbC00AAD8
lbC00AAF6:          move.l   (sp)+,a5
                    move.w   #4,(a4)
                    bra      lbC00AB10

lbC00AB00:          cmp.w    #$188,576(a5)
                    bne.b    lbC00AAD8
                    bra.b    lbC00AAF6

lbC00AB0A:          move.l   (sp)+,a5
                    move.w   #8,(a4)
lbC00AB10:          moveq    #0,d1
                    tst.w    (a4)
                    bne      lbC00AB34
                    movem.l  d0-d2,-(sp)
                    jsr      RNDER
                    move.w   d0,d4
                    and.w    #3,d4
                    move.w   #1,d0
                    lsl.w    d4,d0
                    move.w   d0,(a4)
                    movem.l  (sp)+,d0-d2
lbC00AB34:          move.w   (a4),d4
                    bra      GETD0D1

BRAINMOVE2:         move.l   d0,-(sp)
                    bsr      RNDER
                    move.w   d0,d7
                    move.l   (sp)+,d0
                    and.w    #3,d7
                    beq      lbC00AB88
                    cmp.w    (a2),d3
                    beq      lbC00AB88
lbC00AB54:          tst.w    d0
                    bne      lbC00AB68
                    tst.w    S1NUDGE
                    bne      GO_MOVE
                    bra      lbC00AB72

lbC00AB68:          tst.w    S2NUDGE
                    bne      GO_MOVE
lbC00AB72:          cmp.w    (a2),d3
                    blt      lbC00AB80
                    move.w   #4,(a4)
                    bra      GO_MOVE

lbC00AB80:          move.w   #8,(a4)
                    bra      GO_MOVE

lbC00AB88:          cmp.w    (a3),d4
                    beq      lbC00ABA4
                    cmp.w    (a3),d4
                    blt      lbC00AB9C
                    move.w   #1,(a4)
                    bra      GO_MOVE

lbC00AB9C:          move.w   #2,(a4)
                    bra      GO_MOVE

lbC00ABA4:          cmp.w    (a2),d3
                    bne.b    lbC00AB54
                    move.w   S1HAND,d5
                    move.w   S1BADMOVE,d7
                    tst.w    d0
                    beq      lbC00ABC6
                    move.w   S2HAND,d5
                    move.w   S2BADMOVE,d7
lbC00ABC6:          tst.w    d5
                    beq      lbC00AC08
                    tst.w    d0
                    bne      lbC00ABDE
                    move.w   #1,S1STILL
                    bra      lbC00ABE6

lbC00ABDE:          move.w   #1,S2STILL
lbC00ABE6:          tst.w    d7
                    bne      lbC00ABFC
                    cmp.w    #$27,(a0)
                    bgt      lbC00ABFC
                    cmp.w    #8,d5
                    beq      lbC00AC08
lbC00ABFC:          move.w   #$300,d3
                    bsr      SETSTATE
                    bra      lbC00AC4E

lbC00AC08:          tst.w    d0
                    bne      lbC00AC2C
                    tst.w    GOING_TO_KILL_YOU1
                    bne      lbC00AC4E
                    tst.w    S1TRAPNEXT
                    bne      lbC00AC4E
                    clr.w    S1STILL
                    bra      lbC00AC46

lbC00AC2C:          tst.w    GOING_TO_KILL_YOU2
                    bne      lbC00AC4E
                    tst.w    S2TRAPNEXT
                    bne      lbC00AC4E
                    clr.w    S2STILL
lbC00AC46:          move.w   #$200,d3
                    bsr      SETSTATE
lbC00AC4E:          clr.w    (a4)
                    clr.w    d1
                    clr.w    d2
                    clr.w    SPYDIR
                    rts

GO_MOVE:            move.w   (a4),d4
                    ;bsr      GETD0D1
                    ;rts
                    ; no rts

GETD0D1:            lsr.w    #1,d4
                    bcc      lbC00AC80
                    move.w   #-1,d2
                    clr.w    d1
                    move.w   #3,SPYDIR
                    rts

lbC00AC80:          lsr.w    #1,d4
                    bcc      lbC00AC96
                    move.w   #1,d2
                    clr.w    d1
                    move.w   #4,SPYDIR
                    rts

lbC00AC96:          lsr.w    #1,d4
                    bcc      lbC00ACAC
                    move.w   #-1,d1
                    clr.w    d2
                    move.w   #1,SPYDIR
                    rts

lbC00ACAC:          lsr.w    #1,d4
                    bcc      lbC00ACC2
                    move.w   #1,d1
                    clr.w    d2
                    move.w   #2,SPYDIR
                    rts

lbC00ACC2:          clr.w    d1
                    clr.w    d2
                    clr.w    SPYDIR
                    rts

BTEMP:              dc.w     0

BRAINBUSY:          tst.w    d0
                    bne      lbC00AD58
                    tst.w    S1IGLOO
                    bne      lbC00ADD8
                    move.w   S2TNTREADY,BTEMP
                    lea      S1BRAIN,a1
                    lea      S1BDIR,a2
                    lea      S1CT,a3
                    move.w   S1F,d3
                    move.w   S1MAPX,d6
                    move.w   S1MAPY,d7
                    lea      S1HAND,a4
                    lea      S1FUEL,a6
                    tst.w    S1TRAPNEXT
                    bne      BRAINBUSY0_5
                    tst.w    S2DEAD
                    bne      lbC00ADD8
                    tst.w    S1DROWN
                    bne      lbC00ADD8
                    tst.w    S1SWAMP
                    bne      lbC00ADD8
                    tst.w    S1DEPTH
                    bne      lbC00ADD8
                    tst.w    S1DEAD
                    beq      lbC00ADDA
                    rts

lbC00AD58:          tst.w    S2IGLOO
                    bne      lbC00ADD8
                    move.w   S1TNTREADY,BTEMP
                    lea      S2BRAIN,a1
                    lea      S2BDIR,a2
                    lea      S2CT,a3
                    move.w   S2F,d3
                    move.w   S2MAPX,d6
                    move.w   S2MAPY,d7
                    lea      S2HAND,a4
                    lea      S2FUEL,a6
                    tst.w    S2TRAPNEXT
                    bne      BRAINBUSY0_5
                    tst.w    S1DEAD
                    bne      lbC00ADD8
                    tst.w    S2DROWN
                    bne      lbC00ADD8
                    tst.w    S2SWAMP
                    bne      lbC00ADD8
                    tst.w    S2DEPTH
                    bne      lbC00ADD8
                    tst.w    S2DEAD
                    beq      lbC00ADDA
lbC00ADD8:          rts

lbC00ADDA:          move.l   d0,-(sp)
                    bsr      RNDER
                    move.w   d0,d4
                    move.l   (sp)+,d0
                    movem.l  d4/d6/d7,-(sp)
                    tst.w    BTEMP
                    bne      BRAINBUSY0
                    tst.w    TENMINS
                    bne      lbC00AE08
                    cmp.w    #1,ONEMINS
                    ble      lbC00AE58
lbC00AE08:          and.w    #$FF,d4
                    move.w   #22,d6
                    sub.w    IQ,d6
                    sub.w    IQ,d6
                    move.w   S1ENERGY,d7
                    tst.w    d0
                    beq      lbC00AE2E
                    move.w   S2ENERGY,d7
lbC00AE2E:          cmp.w    #35,d7
                    bgt      lbC00AE46
                    move.w   #16,d6
                    sub.w    IQ,d6
                    sub.w    IQ,d6
lbC00AE46:          cmp.w    d6,d4
                    blt      BRAINBUSY0
                    cmp.w    #10,COUNTER
                    blt      BRAINBUSY0
lbC00AE58:          cmp.w    #40,(a4)
                    blt      lbC00AE6C
                    and.w    #7,d4
                    cmp.w    #1,d4
                    beq      BRAINBUSY0
lbC00AE6C:          movem.l  (sp)+,d4/d6/d7
                    rts

BRAINBUSY0:         movem.l  (sp)+,d4/d6/d7
BRAINBUSY0_5:       tst.w    SPYWIN
                    bne      FULL_HANDS
                    tst.w    (a4)
                    beq      BB_2
                    cmp.w    #39,(a4)
                    bgt      FULL_HANDS
                    tst.w    d0
                    bne      lbC00AEA0
                    move.w   #1,S1TRAPNEXT
                    bra      lbC00AEA8

lbC00AEA0:          move.w   #1,S2TRAPNEXT
lbC00AEA8:          move.w   #$300,d3
                    bra      SETSTATE

BB_2:               tst.w    BTEMP
                    beq      lbC00AEC2
                    move.w   #1,d4
                    bra      USED4

lbC00AEC2:          cmp.w    #10,COUNTER
                    blt      CHOOSE5
                    jsr      RNDER2
                    move.w   d1,d4
                    and.w    #7,d4
                    beq      CHOOSE5
                    cmp.w    #1,d4
                    beq      CHOOSE5
                    bra      USED4

CHOOSE5:            move.w   #7,d4
USED4:              movem.l  d4/a0,-(sp)
                    cmp.w    #7,d4
                    beq      ALLOW_D4
                    lea      S1SAVE_WINY,a0
                    tst.w    d0
                    beq      UD4A
                    lea      IGGY,a0
UD4A:               add.w    d4,d4
                    add.w    d4,a0
                    tst.w    (a0)
                    bne      ALLOW_D4
                    movem.l  (sp)+,d4/a0
                    addq.w   #1,d4
                    bra.b    USED4

ALLOW_D4:           movem.l  (sp)+,d4/a0
                    cmp.w    #5,d4
                    beq      BUSY6_4
                    cmp.w    #7,d4
                    bne      lbC00AF46
                    tst.w    MAP_TIME
                    beq      lbC00AF46
                    subq.w   #1,MAP_TIME
                    bra      BUSY6_4

lbC00AF46:          move.w   IQ,d3
                    addq.w   #1,d3
                    move.w   d3,MAP_TIME
                    tst.w    d0
                    bne      lbC00AF8C
                    clr.w    S1TRAPNEXT
                    tst.w    S1SWAMP
                    bne      FULL_HANDS
                    tst.w    S1DEPTH
                    bne      FULL_HANDS
                    move.w   d4,S1AIMMENU
                    move.w   #1,S1FLASH
                    clr.w    S1F
                    bra      lbC00AFBA

lbC00AF8C:          clr.w    S2TRAPNEXT
                    tst.w    S2SWAMP
                    bne      FULL_HANDS
                    tst.w    S2DEPTH
                    bne      FULL_HANDS
                    clr.w    S2F
                    move.w   d4,S2AIMMENU
                    move.w   #1,S2FLASH
lbC00AFBA:          move.w   #$1600,d3
                    bra      SETSTATE

FULL_HANDS:         move.w   (a4),d4
                    beq      lbC00AFD4
                    move.w   #$400,d3
                    bsr      SETSTATE
                    ;bra      lbC00AFD4

lbC00AFD4:          rts

BRAINBUSY1:         tst.w    (a3)
                    bne      lbC00AFFC
                    tst.w    d0
                    bne      lbC00AFEE
                    clr.w    S1F
                    bra      lbC00AFF6

lbC00AFEE:          clr.w    S2F
lbC00AFF6:          move.w   #$4005,d3
                    move.w   d3,(a3)
lbC00AFFC:          rts

RANDMOVE:           move.l   d0,-(sp)
                    tst.w    d0
                    bne      lbC00B014
                    tst.w    S1IGLOO
                    bne      lbC00B0F0
                    bra      _RNDER0

lbC00B014:          tst.w    S2IGLOO
                    bne      lbC00B0F0
_RNDER0:            jsr      RNDER
                    and.w    #$1F,d0
                    cmp.w    #12,d0
                    bne      lbC00B0F0
                    jsr      RNDER
                    clr.w    d1
                    btst     #6,d0
                    beq      lbC00B050
                    move.w   #1,d1
                    btst     #7,d0
                    beq      lbC00B050
                    neg.w    d1
lbC00B050:          clr.w    d2
                    tst.w    d1
                    bne      lbC00B068
                    move.w   #1,d2
                    btst     #9,d0
                    beq      lbC00B068
                    neg.w    d2
lbC00B068:          cmp.w    #-1,d1
                    bne      lbC00B07C
                    move.w   #1,SPYDIR
                    bra      lbC00B0C0

lbC00B07C:          cmp.w    #1,d1
                    bne      lbC00B090
                    move.w   #2,SPYDIR
                    bra      lbC00B0C0

lbC00B090:          cmp.w    #-1,d2
                    bne      lbC00B0A4
                    move.w   #3,SPYDIR
                    bra      lbC00B0C0

lbC00B0A4:          cmp.w    #1,d2
                    bne      lbC00B0B8
                    move.w   #4,SPYDIR
                    bra      lbC00B0C0

lbC00B0B8:          move.w   #0,SPYDIR
lbC00B0C0:          tst.w    d0
                    bne      _RNDER1
                    jsr      RNDER
                    and.w    #7,d0
                    move.w   d0,S1NUDGE
                    clr.w    d0
                    bra      lbC00B0F0

_RNDER1:            jsr      RNDER
                    and.w    #7,d0
                    move.w   d0,S2NUDGE
                    move.w   #1,d0
lbC00B0F0:          move.l   (sp)+,d0
                    rts

FIND_A_MOUND:       movem.l  d1-d7/a0/a1/a4/a5,-(sp)
                    clr.w    d7
                    move.w   (a2),d1
                    move.w   d1,a4
                    move.w   (a3),d2
                    move.w   d2,a5
                    add.w    d2,d2
                    mulu     MAXMAPX,d2
                    lea      MAP,a0
                    add.w    d2,a0
                    add.w    d1,d1
                    add.w    d1,a0
                    move.w   (a0),d5
                    move.w   a4,d1
                    move.w   a5,d2
                    and.w    #$1C,d2
                    and.w    #$70,d1
                    add.w    d2,d2
                    mulu     MAXMAPX,d2
                    lea      MAP,a0
                    add.w    d2,a0
                    add.w    d1,d1
                    add.w    d1,a0
                    move.w   a4,d1
                    move.w   a5,d2
                    and.w    #$1C,d2
                    and.w    #$70,d1
                    move.w   #4-1,d3
lbC00B148:          move.l   a0,a1
                    move.w   d1,d6
                    move.w   #16-1,d4
lbC00B150:          move.w   (a0)+,d5
                    beq      lbC00B182
                    cmp.w    d1,a4
                    bne      lbC00B162
                    cmp.w    d2,a5
                    beq      lbC00B19C
lbC00B162:          cmp.w    #$68,d5
                    bge      lbC00B182
                    btst     #1,d5
                    beq      lbC00B182
                    cmp.w    #$27,d5
                    blt      lbC00B182
                    btst     #2,d5
                    bne      lbC00B198
lbC00B182:          addq.w   #1,d1
                    dbra     d4,lbC00B150
                    lea      192(a1),a0
                    move.w   d6,d1
                    addq.w   #1,d2
                    dbra     d3,lbC00B148
                    bra      lbC00B1A0

lbC00B198:          move.w   #1,d7
lbC00B19C:          move.w   d1,(a2)
                    move.w   d2,(a3)
lbC00B1A0:          tst.w    d0
                    bne      lbC00B1B0
                    move.w   d7,S1BADMOVE
                    bra      lbC00B1B6

lbC00B1B0:          move.w   d7,S2BADMOVE
lbC00B1B6:          movem.l  (sp)+,d1-d7/a0/a1/a4/a5
                    rts

XPLACE:             dc.w     0
YPLACE:             dc.w     0
GOING_TO_KILL_YOU1: dc.w     0
GOING_TO_KILL_YOU2: dc.w     0
S1NUDGE:            dc.w     0
S2NUDGE:            dc.w     0
DANGER:             dc.w     85
S1BASTARD_COUNT:    dc.w     0
S2BASTARD_COUNT:    dc.w     0
IN_TROUBLE1:        dc.w     0
IN_TROUBLE2:        dc.w     0
OLDXSUB:            dc.w     0
OLDYSUB:            dc.w     0
SPECIAL_DELAY:      dc.w     0
MAP_TIME:           dc.w     0
DONE_MOVE:          dc.w     0
DEMO_COUNT:         dc.w     0
HATCH_RAND:         dc.w     0
HATCHAD:            dc.l     0
RDATA:              dc.l     0
RY:                 dc.w     0
RHT:                dc.w     0
RLEN:               dc.w     0
RYOFF:              dc.w     0
S1ROCKET:           dc.w     0
S2ROCKET:           dc.w     0
S1WIN:              dc.w     0
S2WIN:              dc.w     0
BRAINON:            dc.w     0
PATTERN:            dc.w     -1
TEMP1:              dc.w     0
TEMP2:              dc.w     0
ABORT:              dc.w     0
RIGHTSHIFT:         dc.w     0
SNOW_LINE:          dc.w     0
TEMPKEY:            dcb.w    2,0
OLDSTACK:           dcb.w    2,0
PRIV:               dc.w     0
VBAT:               dcb.w    2,0
PALETTE:            dcb.w    16,0
BACK:               dc.l     0
IN_CASE:            dc.b     0
lbB00B239:          dc.b     0
lbB00B23A:          dcb.b    2,0
DEMOCT:             dcb.b    2,0
DEMO:               dc.w     0
FILEPTR:            dc.w     0
SPYPIX:             dc.b     'gfx/spy1x.pi1',0
SPYPIX2:            dc.b     'gfx/spy2x.pi1',0
BACKPIX:            dc.b     'gfx/back.pi1',0
LANDPIX:            dc.b     'gfx/land.pi1',0
MAPPIX:             dc.b     'gfx/maps.pi1',0
                    even
S1TRAIL:            dcb.w    7,-1
S1OFFSETX:          dc.w     0
S1OFFSETY:          dc.w     0
S1SAVE_ADD:         dc.l     0
S1SAVE_DIR:         dc.w     0
S1MODE:             dc.w     2
S1RUN:              dc.w     0
S1AUTO:             dc.w     0
S1BRAIN:            dc.w     0
S1BDIR:             dc.w     0
S1DEAD:             dc.w     0
S1DROWN:            dc.w     0
S1F:                dc.w     0
S1DIR:              dc.w     0
S1FADDR:            dc.l     0
S1MAPX:             dc.w     0
S1MAPY:             dc.w     0
S1CELLX:            dc.w     0
S1CELLY:            dc.w     0
S1OLDX:             dc.w     0
S1OLDY:             dc.w     0
S1CT:               dc.w     0
S1WATERCT:          dc.w     0
S1ENERGY:           dc.w     0
S1FUEL:             dc.w     0
S1BUMP:             dc.w     0
S1SAFE:             dc.w     0
S1TEMPHAND:         dc.w     0
S1HAND:             dc.w     0
S1DIG:              dc.l     0
S1SWAMP:            dc.w     0
S1DEPTH:            dc.w     0
S1ALTITUDE:         dc.w     0
B1TIME:             dc.w     0
S1SHCT:             dc.w     0
S1FLASH:            dc.w     0
S1MENU:             dc.w     1
BUF1X:              dc.w     0
BUF1Y:              dc.w     -1
S1TREEX:            dc.w     0
S1TREEY:            dc.w     0
S1PLOTX:            dc.w     0
S1PLOTY:            dc.w     0
S1LINEX1:           dc.w     0
S1LINEY1:           dc.w     0
S1LINEX2:           dc.w     0
S1LINEY2:           dc.w     0
S1DRLINE:           dc.w     0
S1CHOICEX:          dc.l     0
S1CHOICEY:          dc.l     0
S1BASH:             dc.w     0
S1AIMMENU:          dc.w     0
S1TRAPNEXT:         dc.w     0
S1STILL:            dc.w     0
S1BADMOVE:          dc.w     0
S1IGLOO:            dc.w     0
S1SAVE_MAPX:        dc.w     0
S1SAVE_MAPY:        dc.w     0
S1SAVE_WINX:        dc.w     0
S1SAVE_WINY:        dc.w     0
S1PLUNGER:          dc.w     0
S1SAW:              dc.w     0
S1BUCKET:           dc.w     0
S1PICK:             dc.w     0
S1SNSH:             dc.w     0
S1TNT:              dc.w     0
S1TNTREADY:         dc.w     0
S2TRAIL:            dcb.w    7,-1
S2RUN:              dc.w     0
S2OFFSETX:          dc.w     0
S2OFFSETY:          dc.w     0
S2SAVE_ADD:         dc.l     0
S2SAVE_DIR:         dc.w     0
S2MODE:             dc.w     0
S2AUTO:             dc.w     0
S2BRAIN:            dc.w     0
S2BDIR:             dc.w     0
S2DEAD:             dc.w     0
S2DROWN:            dc.w     0
S2F:                dc.w     0
S2DIR:              dc.w     0
S2FADDR:            dc.l     0
S2MAPX:             dc.w     0
S2MAPY:             dc.w     0
S2CELLX:            dc.w     0
S2CELLY:            dc.w     0
S2OLDX:             dc.w     0
S2OLDY:             dc.w     0
S2CT:               dc.w     0
S2WATERCT:          dc.w     0
S2ENERGY:           dc.w     0
S2FUEL:             dc.w     0
S2BUMP:             dc.w     0
S2SAFE:             dc.w     0
S2TEMPHAND:         dc.w     0
S2HAND:             dc.w     0
S2DIG:              dc.l     0
S2SWAMP:            dc.w     0
S2DEPTH:            dc.w     0
S2ALTITUDE:         dc.w     0
B2TIME:             dc.w     0
S2SHCT:             dc.w     0
S2FLASH:            dc.w     0
S2MENU:             dc.w     1
BUF2X:              dc.w     0
BUF2Y:              dc.w     -1
S2TREEX:            dc.w     0
S2TREEY:            dc.w     0
S2PLOTX:            dc.w     0
S2PLOTY:            dc.w     0
S2LINEX1:           dc.w     0
S2LINEY1:           dc.w     0
S2LINEX2:           dc.w     0
S2LINEY2:           dc.w     0
S2DRLINE:           dc.w     0
S2CHOICEX:          dc.l     0
S2CHOICEY:          dc.l     0
S2BASH:             dc.w     0
S2AIMMENU:          dc.w     0
S2TRAPNEXT:         dc.w     0
S2STILL:            dc.w     0
S2BADMOVE:          dc.w     0
S2IGLOO:            dc.w     0
S2SAVE_MAPX:        dc.w     0
S2SAVE_MAPY:        dc.w     0
S2SAVE_WINX:        dc.w     0
S2SAVE_WINY:        dc.w     0
IGGY:               dc.w     0
S2PLUNGER:          dc.w     0
S2SAW:              dc.w     0
S2BUCKET:           dc.w     0
S2PICK:             dc.w     0
S2SNSH:             dc.w     0
S2TNT:              dc.w     0
S2TNTREADY:         dc.w     0
SOUNDNUM:           dc.w     0
SOUNDCT:            dc.w     0
SPYX:               dc.w     0
SPYY:               dc.w     0
SPYDIR:             dc.w     0
SPYWIN:             dc.w     0
SPYWX:              dc.w     0
SPYWY:              dc.w     0
WIN1X:              dc.w     0
WIN1Y:              dc.w     0
WIN2X:              dc.w     0
WIN2Y:              dc.w     0
CURMAXX:            dc.w     60
CURMAXY:            dc.w     32
REFRESH:            dc.w     2
BULLET:             dc.w     4
BUSYDIR:            dc.w     0
COUNTER:            dc.w     1
TENMINS:            dc.w     0
ONEMINS:            dc.w     0
TENSECS:            dc.w     0
ONESECS:            dc.w     0
XROCKET:            dc.w     0
YROCKET:            dc.w     0
XMIDNOSE:           dc.w     0
YMIDNOSE:           dc.w     0
XMIDTAIL:           dc.w     0
YMIDTAIL:           dc.w     0
XNOSE:              dc.w     0
YNOSE:              dc.w     0
XMID:               dc.w     0
YMID:               dc.w     0
XTAIL:              dc.w     0
YTAIL:              dc.w     0
XCARD:              dc.w     0
YCARD:              dc.w     0
XGYRO:              dc.w     0
YGYRO:              dc.w     0
XJAR:               dc.w     0
YJAR:               dc.w     0
XCASE:              dc.w     0
YCASE:              dc.w     0
XHATCH:             dc.w     0
YHATCH:             dc.w     0
XIGLOO1:            dc.w     0
YIGLOO1:            dc.w     0
XIGLOO2:            dc.w     0
YIGLOO2:            dc.w     0
XWPLUNG:            dc.w     0
YWPLUNG:            dc.w     0
XBPLUNG:            dc.w     0
YBPLUNG:            dc.w     0
XWBUCK:             dc.w     0
YWBUCK:             dc.w     0
XBBUCK:             dc.w     0
YBBUCK:             dc.w     0
LOOPTIME:           dc.w     0
SCREEN_P:           dc.l     0
CHPLACE_P:          dc.l     0
CHSRC_P:            dc.l     0
FOURBITS:           dc.w     0
L_COLOR:            dc.w     14
COUNT:              dc.w     0
COLOR:              dc.w     0
WINX:               dc.w     0
WINY:               dc.w     0
ULX:                dc.w     0
ULY:                dc.w     0
OFFSET:             dc.w     0
PLAYERS:            dc.w     1
LEVEL:              dc.w     1
IQ:                 dc.w     1
DRAWSUB:            dc.w     0
MAXMAPX:            dc.w     0
MAXMAPY:            dc.w     0
; 96*20*2 = 3840 bytes per level
MAP:                dcb.w    1920,0
MAP1:               dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,$1B1,$1B9,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,$1B1,$1B9,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,$F9,1,1,1,1,1,1,1
                    dc.w     1,1,$F9,0,0,0,0,0,1,1,1,1,1,1,1,1,$B1,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,$C9,$D1,$D9,$E1,$E9,0,0,0,0,0,$B1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0
                    dc.w     0,$188,0,0,0,0,0,0,0,0,0,0,0,$B1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,$B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,$190,0,0,0,0,1,1,1,1,1,0
                    dc.w     0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,$C9,$D1,$D9,$E1,$E9,0
                    dc.w     0,0,0,0,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     $B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1
MAP2:               dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,$1B1,$1B9,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,$1B1,$1B9,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,$F9,1,1,1,1,1,1,1
                    dc.w     1,1,$F9,0,0,0,0,0,1,1,1,1,1,1,1,1,$B1,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,0,0,0,0,0,0,0,0
                    dc.w     $C0,$C0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,0,0,0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,0,0
                    dc.w     $C9,$D1,$D9,$E1,$E9,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     $B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0
                    dc.w     0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,$1F0,$1F8
                    dc.w     0,0,0,0,$188,0,0,0,0,0,0,0,0,0,$B1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,$B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,$190,0,0,0,$B8
                    dc.w     $B8,$B8,$B8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,$101
                    dc.w     $109,$111,$119,$121,0,0,0,0,0,0,0,0,0,$B8,$B8,$B8
                    dc.w     $B8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0,$188,0,0,0
                    dc.w     0,0,0,$1D0,$1D8,$1E0,$1E8,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,0
                    dc.w     $190,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,0,0,0,0,0,0,0,$C9,$D1,$D9,$E1,$E9
                    dc.w     0,0,0,0,0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1
MAP3:               dc.w     $B1,$B0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,$C0
                    dc.w     $C0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,0,0,0,0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B1,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1,$B1,0,0,0,0,0,0,0
                    dc.w     $C9,$D1,$D9,$E1,$E9,0,0,0,0,0,0,$C0,$C0,0,0,0,0,0
                    dc.w     $C0,$C0,0,0,0,0,0,0,0,0,0,0,$B1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1
                    dc.w     $B1,$B1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$C0,$C0
                    dc.w     0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,0,0,$B1,$B1,$B1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,$1B1,$1B9,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$1B1
                    dc.w     $1B9,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1,$B1,0,0,$188,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,$1F0,$1F8,0,0,0,0,0,$1F0
                    dc.w     $1F8,0,0,0,$188,0,0,0,$B1,$B1,$B1,$B1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0
                    dc.w     0,$F9,1,1,1,1,1,1,1,1,1,$F9,0,0,0,0,0,1,1,1,1,1,1
                    dc.w     1,1,$B1,$B0,0,0,0,0,$190,0,0,0,0,$B8,$B8,$B8,$B8
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$190,0,0,0,1,1
                    dc.w     1,1,1,0,0,0,0,0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B1,$B1,0,0,0,0,0,0,0,0,0,$B8,$B8
                    dc.w     $B8,$B8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     $C9,$D1,$D9,$E1,$E9,0,0,0,0,0,0,0,0,$B1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1,0,0,0
                    dc.w     0,0,0,0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1
                    dc.w     $B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1
                    dc.w     $B1,$B1,$B1,0,0,0,0,0,0,0,$1D0,$1D8,$1E0,$1E8,0,0
                    dc.w     0,0,0,0,0,0,0,$188,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,$B1,$B1,$B1,$B1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,$B1,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,0,0,0,1,1,1,1,1,0,0,0,0,$190
                    dc.w     0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,0,0,$C0,$C0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,1,1,1,1,1,1,1,1,1
                    dc.w     1,$B1,$B1,0,0,0,$101,$109,$111,$119,$121,0,0,0,0
                    dc.w     0,0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,0,0,$C0,$C0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,0,0
                    dc.w     $C0,$C0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1
                    dc.w     $B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1
                    dc.w     $B1,$B1,$B1,0,0,0,0,0,0,0,0,0,0,0,0,0,$1D0,$1D8
                    dc.w     $1E0,$1E8,0,0,0,0,$188,0,0,$1F0,$1F8,0,0,0,0,0,0
                    dc.w     0,0,0,$188,0,0,0,0,0,0,$B1,$B1,$B1,$B1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,$B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,0,0,0,0,1,1,1,1,1,0,0,0,0,$190,0,0,0,$B8,$B8
                    dc.w     $B8,$B8,0,0,0,0,0,0,$190,0,0,0,0,0,0,0,0,0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,0,0
                    dc.w     0,0,$101,$109,$111,$119,$121,0,0,0,0,0,0,0,0,$B8
                    dc.w     $B8,$B8,$B8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     $B1,$B1,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1,$B1,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,$1D0,$1D8,$1E0,$1E8,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,$B1,$B1,$B1,$B1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1
MAP4:               dc.w     $B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,0,0,0,0,0
                    dc.w     0,1,1,1,1,1,0,0,0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,$B1,$B1,0,0,0,0,0,0,$101,$109,$111,$119,$121,0
                    dc.w     0,0,0,0,0,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,$B1,$B1,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,$1B1,$1B9,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,$1B1,$1B9,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1,$B1,0
                    dc.w     0,0,0,$188,0,0,0,0,0,0,0,$B1,$B1,$B1,$B1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0
                    dc.w     0,0,0,$F9,1,1,1,1,1,1,1,1,1,$F9,0,0,0,0,0,1,1,1,1
                    dc.w     1,1,1,1,$B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$190,0,1
                    dc.w     1,1,1,1,0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,1,1,1,1,1,1,1,1,1,1,$B1,$B1,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,$C9,$D1,$D9,$E1,$E9,0,0,0,0,$B1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1
                    dc.w     $B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1
                    dc.w     $B1,0,$188,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,$B1,$B1,$B1,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,$190,0,0,$C0,$C0,0,0,0,0,0,$C0,$C0
                    dc.w     0,0,0,0,$C0,$C0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1
                    dc.w     1,1,1,0,0,0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B1,$B1,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,$C0,$C0,0,0,0,0,0,$C0,$C0,0,0,0,0,$C0
                    dc.w     $C0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$C9,$D1,$D9,$E1
                    dc.w     $E9,0,0,0,0,0,0,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1
                    dc.w     $B1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$C0,$C0,0,0,0,0
                    dc.w     0,$C0,$C0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1,$B1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     $188,0,0,$1F0,$1F8,0,0,0,0,0,$1F0,$1F8,0,0,0,0
                    dc.w     $1F0,$1F8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$188,0,0
                    dc.w     0,0,0,0,0,$B1,$B1,$B1,$B1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     $B1,$B0,0,0,0,0,0,0,0,0,0,0,0,0,0,$190,0,$B8,$B8
                    dc.w     $B8,$B8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B8
                    dc.w     $B8,$B8,$B8,0,0,0,0,$190,0,0,0,0,0,0,0,0,0,0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B1,$B1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B8,$B8,$B8
                    dc.w     $B8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B8,$B8
                    dc.w     $B8,$B8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     $B1,$B1,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1,$B1
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,$1D0,$1D8,$1E0,$1E8,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,$188,0,0,0,0,0,0,$1D0,$1D8
                    dc.w     $1E0,$1E8,0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1,$B1,$B1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,$B1,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,0,0,0,1,1,1,1,1,0,0,0,$190,0,0,0,0,0
                    dc.w     $C0,$C0,0,0,0,0,0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,1,1,1,1,1,1,1,1,1,1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0
                    dc.w     $101,$109,$111,$119,$121,0,0,0,0,0,0,0,0,0,$C0
                    dc.w     $C0,0,0,0,0,0,0,0,0,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,$B1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     $1F0,$1F8,0,0,0,0,0,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1
MAP5:               dc.w     $B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,0
                    dc.w     0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,$B8,$B8,$B8,$B8
                    dc.w     0,0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,1,1,1
                    dc.w     1,1,1,1,1,1,1,$B1,$B1,0,0,0,0,0,$101,$109,$111
                    dc.w     $119,$121,0,0,0,0,0,0,0,0,$B8,$B8,$B8,$B8,0,0,0,0
                    dc.w     0,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B8,$B8,$B8,$B8
                    dc.w     0,0,0,$B1,$B1,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,$1B1,$1B9,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,$1B1,$1B9,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     $188,0,0,0,0,$1D0,$1D8,$1E0,$1E8,0,0,$B1,$B1,$B1
                    dc.w     $B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,0,0,0,0,0,$F9,1,1,1,1,1,1,1,1,1,$F9,0,0,0
                    dc.w     0,0,1,1,1,1,1,1,1,1,$B1,$B0,0,0,0,0,0,0,0,0,0,$C0
                    dc.w     $C0,0,0,0,0,0,0,0,0,0,0,0,0,$190,0,0,0,0,$B8,$B8
                    dc.w     $B8,$B8,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0
                    dc.w     0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B1,$B1,0,0,0,0,0,0,0,0,0,$C0,$C0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B8,$B8,$B8,$B8,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,$C9,$D1,$D9,$E1,$E9,0,0,0,0,0
                    dc.w     0,0,0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,$C0,$C0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B8,$B8,$B8,$B8,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,$1F0,$1F8,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,$1D0,$1D8,$1E0,$1E8,0
                    dc.w     0,0,0,0,0,0,0,0,0,$188,0,0,0,0,0,0,0,0,0,0,0,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B0,0,0,0,$190,0,0,0,0,0,1,1,1,1
                    dc.w     1,0,0,0,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8
                    dc.w     $A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8
                    dc.w     $A8,0,0,$190,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B1,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1
                    dc.w     $B1,0,0,0,0,0,0,0,0,0,$C9,$D1,$D9,$E1,$E9,0,0,0
                    dc.w     $A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9
                    dc.w     $A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,$A9,$A9,$A9,$A9,$A9,$A9,$A9
                    dc.w     $A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9
                    dc.w     $A9,$A9,$A9,$A9,$A9,$A9,$A9,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9
                    dc.w     $A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9
                    dc.w     $A9,$A9,$A9,$A9,$A9,0,0,0,$188,0,0,0,0,0,0,0,0
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B0,0,0,0,0,0,$B8,$B8,$B8,$B8
                    dc.w     0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0
                    dc.w     0,0,0,0,0,0,$B8,$B8,$B8,$B8,0,0,0,$190,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B1,$B1,0,0,0,0,0,$B8,$B8,$B8,$B8
                    dc.w     0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,0,$101,$109,$111
                    dc.w     $119,$121,0,0,0,0,0,0,0,0,0,$B8,$B8,$B8,$B8,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0
                    dc.w     $B8,$B8,$B8,$B8,0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B8,$B8,$B8,$B8,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0
                    dc.w     0,0,$1D0,$1D8,$1E0,$1E8,0,0,0,0,0,0,$1F0,$1F8,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$188,0,0,$1D0
                    dc.w     $1D8,$1E0,$1E8,0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,0
                    dc.w     0,0,0,0,0,0,0,0,$C0,$C0,0,0,0,0,$190,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0
                    dc.w     0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0
                    dc.w     0,0,0,$C0,$C0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,0,0,0,0,0,0,0,0,$1F0,$1F8,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
MAP6:               dc.w     $B1,$B0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B1,$B1,0,0,0,$101,$109,$111,$119
                    dc.w     $121,0,0,0,0,0,0,0,0,0,$B1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,$B1,$B1,$B1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,$1B1,$1B9,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,$1B1,$1B9,1,1,1,1,1,1,1,1,1,$B1
                    dc.w     $B1,$B1,$B1,0,0,0,0,0,0,0,0,0,$188,0,0,$B1,$B1
                    dc.w     $B1,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,0,0,0,0,0,$F9,1,1,1,1,1,1,1,1,1,$F9,0,0,0,0,0,1
                    dc.w     1,1,1,1,1,1,1,$B1,$B0,0,0,0,1,1,1,1,1,0,0,0,$190
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,$C0,$C0,0
                    dc.w     0,0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,0,0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B1,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1,$B1,0,0,0
                    dc.w     $101,$109,$111,$119,$121,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,$C0,$C0,0,0,0,0,0,$C0,$C0,0,0,0,0,$B8,$B8
                    dc.w     $B8,$B8,0,0,0,0,0,0,0,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,$C0,$C0,0
                    dc.w     0,0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     $1F0,$1F8,0,0,0,0,0,$1F0,$1F8,$188,0,0,0,$1D0
                    dc.w     $1D8,$1E0,$1E8,0,0,$188,0,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,1,1,1,1,1
                    dc.w     0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,0,$C0,$C0,0,0,$190
                    dc.w     0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B1,$B1,0,0,0,0,0,0,0,0,0,0,0,0,$B8,$B8,$B8
                    dc.w     $B8,0,0,0,0,0,$C9,$D1,$D9,$E1,$E9,0,0,$B8,$B8,$B8
                    dc.w     $B8,0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,0,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,0,$C0,$C0,0,0,0,0
                    dc.w     0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,$188,0,0,$1D0
                    dc.w     $1D8,$1E0,$1E8,0,0,0,0,0,0,0,0,0,0,0,0,$1D0,$1D8
                    dc.w     $1E0,$1E8,0,0,$188,0,0,0,$1F0,$1F8,0,0,0,0,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B0,0,0,0,0,0,0,0,0,0,$190,0,0,0,0,0,0,0
                    dc.w     $A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8
                    dc.w     $A8,0,0,0,0,$190,0,1,1,1,1,1,0,$C0,$C0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B1,$B1,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9
                    dc.w     $A9,$A9,$A9,$A9,0,0,0,0,0,0,$101,$109,$111,$119
                    dc.w     $121,0,$C0,$C0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$A9,$A9,$A9
                    dc.w     $A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9
                    dc.w     $A9,0,0,0,0,0,0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9
                    dc.w     $A9,$A9,$A9,$A9,$A9,$A9,$A9,0,0,0,0,0,0,0,0,0,0
                    dc.w     $1F0,$1F8,0,0,0,0,$188,0,0,0,0,0,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,0,0,0,0,0,0,0,0,$190,0,0
                    dc.w     0,0,0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1
MAP7:               dc.w     $B1,$B0,0,0,0,0,0,0,0,0,0,0,0,0,0,$C0,$C0,0,0,0,0
                    dc.w     0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,$C0,$C0,0,0,0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B1,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1,$B1,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,0,0,0,$C0,$C0
                    dc.w     0,0,0,0,0,0,$C0,$C0,0,0,0,$B1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1
                    dc.w     $B1,0,0,0,0,0,0,0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,0
                    dc.w     0,0,$C0,$C0,0,0,0,0,0,0,$C0,$C0,0,$B1,$B1,$B1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,$1B1,$1B9,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$1B1
                    dc.w     $1B9,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1,$B1,0,0,0,0,0
                    dc.w     0,0,$188,0,0,0,$1F0,$1F8,0,0,0,0,0,0,0,0,0,$1F0
                    dc.w     $1F8,0,0,0,0,0,0,$1F0,$1F8,$B1,$B1,$B1,$B1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
                    dc.w     0,0,0,0,$F9,1,1,1,1,1,1,1,1,1,$F9,0,0,0,0,0,1,1,1
                    dc.w     1,1,1,1,1,$B1,$B0,0,1,1,1,1,1,0,0,0,$190,0,0,0
                    dc.w     $B8,$B8,$B8,$B8,0,0,0,0,0,0,0,0,0,0,0,0,$C0,$C0,0
                    dc.w     0,0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1
                    dc.w     $B1,0,$101,$109,$111,$119,$121,0,0,0,0,0,0,0,$B8
                    dc.w     $B8,$B8,$B8,0,0,0,0,0,0,0,0,0,0,0,0,$C0,$C0,0,0,0
                    dc.w     0,0,0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,0,0,0,0,0,0,0,0,0,0,0,0,$B8,$B8,$B8,$B8,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,$C0,$C0,0,0,0,0,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,$1D0,$1D8,$1E0,$1E8,0,0,0,0,0,0,0
                    dc.w     $188,0,0,0,0,$1F0,$1F8,0,0,0,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,$C0,$C0,0,0,0,$190,0,0
                    dc.w     $C0,$C0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,$C0
                    dc.w     $C0,0,0,0,0,0,0,0,0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B1,$B1,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,$C0,$C0,0
                    dc.w     0,0,0,0,0,0,0,0,$C9,$D1,$D9,$E1,$E9,0,0,0,0,$C0
                    dc.w     $C0,0,0,0,0,0,0,0,0,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,$C0,$C0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$C0,$C0,0,0,0
                    dc.w     0,0,0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0
                    dc.w     0,$188,0,0,0,0,0,0,$1F0,$1F8,0,0,0,0,0,0,$1F0
                    dc.w     $1F8,0,0,0,0,0,$188,0,0,0,0,0,0,0,0,0,0,0,0,$1F0
                    dc.w     $1F8,0,0,0,0,0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,0,0,$190,0,1,1,1
                    dc.w     1,1,0,0,0,0,0,0,0,0,$B8,$B8,$B8,$B8,0,0,0,$190,0
                    dc.w     0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,0,0,0,0,$C9,$D1,$D9,$E1,$E9,0,0,0,0,0,0,0,0
                    dc.w     $B8,$B8,$B8,$B8,0,0,0,0,0,0,0,$B8,$B8,$B8,$B8,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,$B8,$B8,$B8,$B8,0,0,0,0,0,0,0,$B8
                    dc.w     $B8,$B8,$B8,0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$1D0,$1D8
                    dc.w     $1E0,$1E8,0,0,0,0,0,0,0,$1D0,$1D8,$1E0,$1E8,0,0,0
                    dc.w     0,0,0,0,$188,0,0,0,0,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,0,0,1,1,1,1,1,0,0,0,0,$C0,$C0
                    dc.w     0,0,0,0,0,0,$190,0,0,0,0,0,0,0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B1,$B0,$B0,$B0,$B0,$B0,$B0,$B0
                    dc.w     $B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B0,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,0,0,$101,$109,$111,$119,$121
                    dc.w     0,0,0,0,$C0,$C0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0,0,0
                    dc.w     0,0,0,0,0,$C0,$C0,0,0,0,0,0,0,0,0,0,0,0,0,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$B1,$B1,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,0,0,0
                    dc.w     0,0,0,0,0,0,$1F0,$1F8,0,0,0,0,0,0,0,0,0,0,0,$B1
                    dc.w     $B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1,$B1
                    dc.w     $B1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
                    dc.w     1,1,1,$FFFF,$FFFF,$FFFF
TERRAIN:            dc.l     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.l     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.l     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.l     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.l     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.l     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.l     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.l     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.l     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.l     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
TERRAIN1:           dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,$3C,$3C,$3C,$3D,$3E,$3F
                    dc.w     $40,$41,$42,$43,$3C,$3C,0,0,0,0,$3C,$3C,$3C,$44
                    dc.w     $45,$46,$47,$48,$49,$4A,$3C,$3C,0,0,0,0,0,$FFFF,0
                    dc.w     0,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13
                    dc.w     14,15,$10,$11,$12,$13,$32,$33,$34,$35,$36,$37,$38
                    dc.w     $39,$3A,$3B,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     $FFFF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,$FFFF,0,0,0,0,0,0,0,0
                    dc.w     0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,$10,$11
                    dc.w     $12,$13,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$FFFF,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
TERRAIN2:           dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,$3C,$3C,$3C,$3D,$3E,$3F
                    dc.w     $40,$41,$42,$43,$3C,$3C,0,0,0,0,$3C,$3C,$3C,$44
                    dc.w     $45,$46,$47,$48,$49,$4A,$3C,$3C,0,0,0,0,0,$FFFF,0
                    dc.w     0,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13
                    dc.w     14,15,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A
                    dc.w     $1B,$1C,$1D,$32,$33,$34,$35,$36,$37,$38,$39,$3A
                    dc.w     $3B,0,0,0,0,0,0,0,0,0,$FFFF,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     $FFFF,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11
                    dc.w     12,13,14,15,$10,$11,$12,$13,$14,$15,$16,$17,$18
                    dc.w     $19,$1A,$1B,$1C,$1D,$32,$33,$34,$35,$36,$37,$38
                    dc.w     $39,$3A,$3B,0,0,0,0,0,0,0,0,0,$FFFF,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,$FFFF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,1,2,3,4,5,6,7,8,9,$32,$33,$34,$35,$36,$37,$38
                    dc.w     $39,$3A,$3B,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     $FFFF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0
TERRAIN3:           dc.w     0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,$10,$11,$12
                    dc.w     $13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$32
                    dc.w     $33,$34,$35,$36,$37,$38,$39,$3A,$3B,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$3C,$3C,$3C,$3D
                    dc.w     $3E,$3F,$40,$41,$42,$43,$3C,$3C,0,0,0,0,$3C,$3C
                    dc.w     $3C,$44,$45,$46,$47,$48,$49,$4A,$3C,$3C,0,0,0,0,0
                    dc.w     0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,$10,$11,$12
                    dc.w     $13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E
                    dc.w     $1F,$20,$21,$22,$23,$24,$25,$26,$27,$32,$33,$34
                    dc.w     $35,$36,$37,$38,$39,$3A,$3B,0,0,0,0,0,0,0,0,0
                    dc.w     $FFFF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,$10,$11,$12
                    dc.w     $13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E
                    dc.w     $1F,$20,$21,$22,$23,$24,$25,$26,$27,$32,$33,$34
                    dc.w     $35,$36,$37,$38,$39,$3A,$3B,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4
                    dc.w     5,6,7,8,9,10,11,12,13,14,15,$10,$11,$12,$13,$14
                    dc.w     $15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$32,$33,$34
                    dc.w     $35,$36,$37,$38,$39,$3A,$3B,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
TERRAIN4:           dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4
                    dc.w     5,6,7,8,9,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$3C
                    dc.w     $3C,$3C,$3D,$3E,$3F,$40,$41,$42,$43,$3C,$3C,0,0,0
                    dc.w     0,$3C,$3C,$3C,$44,$45,$46,$47,$48,$49,$4A,$3C,$3C
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9
                    dc.w     10,11,12,13,14,15,$10,$11,$12,$13,$32,$33,$34,$35
                    dc.w     $36,$37,$38,$39,$3A,$3B,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,6
                    dc.w     7,8,9,10,11,12,13,14,15,$10,$11,$12,$13,$14,$15
                    dc.w     $16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21
                    dc.w     $22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D
                    dc.w     $2E,$2F,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39
                    dc.w     $3A,$3B,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9
                    dc.w     10,11,12,13,14,15,$10,$11,$12,$13,$14,$15,$16,$17
                    dc.w     $18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21,$22,$23
                    dc.w     $24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F
                    dc.w     $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
                    dc.w     $10,$11,$12,$13,$32,$33,$34,$35,$36,$37,$38,$39
                    dc.w     $3A,$3B,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
TERRAIN5:           dc.w     0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12
                    dc.w     13,14,15,$10,$11,$12,$13,$32,$33,$34,$35,$36,$37
                    dc.w     $38,$39,$3A,$3B,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,$3C,$3C,$3C,$3D,$3E,$3F,$40,$41,$42
                    dc.w     $43,$3C,$3C,0,0,0,0,$3C,$3C,$3C,$44,$45,$46,$47
                    dc.w     $48,$49,$4A,$3C,$3C,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9
                    dc.w     10,11,12,13,14,15,$10,$11,$12,$13,$14,$15,$16,$17
                    dc.w     $18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21,$22,$23
                    dc.w     $24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F
                    dc.w     $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,$32,$33
                    dc.w     $34,$35,$36,$37,$38,$39,$3A,$3B,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,$32,$33
                    dc.w     $34,$35,$36,$37,$38,$39,$3A,$3B,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,$10,$11
                    dc.w     $12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D
                    dc.w     $1E,$1F,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29
                    dc.w     $2A,$2B,$2C,$2D,$2E,$2F,$30,$31,$32,$33,$34,$35
                    dc.w     $36,$37,$38,$39,$3A,$3B,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,6
                    dc.w     7,8,9,10,11,12,13,14,15,$10,$11,$12,$13,$32,$33
                    dc.w     $34,$35,$36,$37,$38,$39,$3A,$3B,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0
TERRAIN6:           dc.w     0,1,2,3,4,5,6,7,8,9,$32,$33,$34,$35,$36,$37,$38
                    dc.w     $39,$3A,$3B,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     $3C,$3C,$3C,$3D,$3E,$3F,$40,$41,$42,$43,$3C,$3C,0
                    dc.w     0,0,0,$3C,$3C,$3C,$44,$45,$46,$47,$48,$49,$4A,$3C
                    dc.w     $3C,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
                    dc.w     15,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A
                    dc.w     $1B,$1C,$1D,$1E,$1F,$20,$21,$22,$23,$24,$25,$26
                    dc.w     $27,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,6
                    dc.w     7,8,9,10,11,12,13,14,15,$10,$11,$12,$13,$14,$15
                    dc.w     $16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20,$21
                    dc.w     $22,$23,$24,$25,$26,$27,$32,$33,$34,$35,$36,$37
                    dc.w     $38,$39,$3A,$3B,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,1,2,3,4,5,6,7,8,9,$32,$33,$34,$35,$36
                    dc.w     $37,$38,$39,$3A,$3B,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4
                    dc.w     5,6,7,8,9,10,11,12,13,14,15,$10,$11,$12,$13,$32
                    dc.w     $33,$34,$35,$36,$37,$38,$39,$3A,$3B,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5
                    dc.w     6,7,8,9,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0
TERRAIN7:           dc.w     0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,$10,$11,$12
                    dc.w     $13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$32
                    dc.w     $33,$34,$35,$36,$37,$38,$39,$3A,$3B,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$3C,$3C,$3C,$3D
                    dc.w     $3E,$3F,$40,$41,$42,$43,$3C,$3C,0,0,0,0,$3C,$3C
                    dc.w     $3C,$44,$45,$46,$47,$48,$49,$4A,$3C,$3C,0,0,0,0,0
                    dc.w     0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,$10,$11,$12
                    dc.w     $13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$32
                    dc.w     $33,$34,$35,$36,$37,$38,$39,$3A,$3B,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,$10,$11,$12
                    dc.w     $13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E
                    dc.w     $1F,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A
                    dc.w     $2B,$2C,$2D,$2E,$2F,$30,$31,$32,$33,$34,$35,$36
                    dc.w     $37,$38,$39,$3A,$3B,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
                    dc.w     $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B
                    dc.w     $1C,$1D,$1E,$1F,$20,$21,$22,$23,$24,$25,$26,$27
                    dc.w     $32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,8,9,10,11
                    dc.w     12,13,14,15,$10,$11,$12,$13,$32,$33,$34,$35,$36
                    dc.w     $37,$38,$39,$3A,$3B,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    dc.w     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; -------------------------------------------

                    section  uninit_dats,bss_c

STRENGTH_EMPTY:     ds.l     130
STRENGTH_FULL:      ds.l     130
SNOWSLAB:           ds.l     640
SLEETSLAB:          ds.l     640
DRYSLAB:            ds.l     640
BUF11:              ds.l     164
lbL016EF0:          ds.l     492
BUF12:              ds.l     656
BUF13:              ds.l     656
BUF14:              ds.l     656
BUF15:              ds.w     1
BUF16:              ds.l     120
BUF17:              ds.w     1
BUF18:              ds.w     1
BUF19:              ds.l     164
BUF1A:              ds.l     164
BUF1B:              ds.w     1
BUF1D:              ds.l     164
lbL019EF8:          ds.l     164
BUF21:              ds.l     164
lbL01A418:          ds.l     492
BUF22:              ds.l     656
BUF23:              ds.l     656
BUF24:              ds.l     656
BUF25:              ds.w     1
BUF26:              ds.l     120
BUF27:              ds.w     1
BUF28:              ds.w     1
BUF29:              ds.l     164
BUF2A:              ds.l     164
BUF2B:              ds.w     1
BUF2D:              ds.l     164
lbL01D420:          ds.l     164
GRAVE:              ds.l     164
LAND:               ds.l     9750
MAPS:               ds.l     3936
RTCOVER:            ds.l     256
MAPBOX:             ds.l     24
S1BACK:             ds.l     1408
S2BACK:             ds.l     1408
MAPSPOT:            ds.l     24
G_MOUND:            ds.l     14
G_CASE:             ds.l     20
G_CARD:             ds.l     20
G_URANIUM:          ds.l     20
G_GYRO:             ds.l     20
G_SAW:              ds.l     20
G_WHITE_BUCKET:     ds.l     20
G_BLACK_BUCKET:     ds.l     20
G_PICKAXE:          ds.l     22
G_SNOWSHOES:        ds.l     18
G_TNT:              ds.l     24
G_BLACK_PLUNGER:    ds.l     20
G_WHITE_PLUNGER:    ds.l     20
G_ICEHOLE:          ds.l     10
G_ICEPATCH:         ds.l     18
G_DOORWAY:          ds.l     58
G_IGLOO_LEFT1:      ds.l     70
G_IGLOO_LEFT2:      ds.l     70
G_IGLOO_LEFT3:      ds.l     70
G_IGLOO_LEFT4:      ds.l     70
G_IGLOO_LEFT5:      ds.l     70
G_IGLOO_RIGHT1:     ds.l     70
G_IGLOO_RIGHT2:     ds.l     70
G_IGLOO_RIGHT3:     ds.l     70
G_IGLOO_RIGHT4:     ds.l     70
G_IGLOO_RIGHT5:     ds.l     70
G_POLAR_BEARA1:     ds.l     22
G_POLAR_BEARA2:     ds.l     22
G_POLAR_BEARA3:     ds.l     22
G_POLAR_BEARB1:     ds.l     58
G_POLAR_BEARB2:     ds.l     58
G_POLAR_BEARB3:     ds.l     58
G_POLAR_BEARC1:     ds.l     62
G_POLAR_BEARC2:     ds.l     62
G_POLAR_BEARC3:     ds.l     62
G_EXIT_SOUTH:       ds.l     6
G_EXIT_NORTH1:      ds.l     56
G_EXIT_NORTH2:      ds.l     56
G_EXIT_NORTH3:      ds.l     56
G_FIREL1:           ds.l     28
G_FIRER1:           ds.l     28
G_FIREL2:           ds.l     28
G_FIRER2:           ds.l     28
G_SNOW1:            ds.l     64
G_SNOW2:            ds.l     64
G_SNOW3:            ds.l     64
G_SNOW4:            ds.l     64
G_SNOW5:            ds.l     64
G_ICE1:             ds.l     64
G_ICE2:             ds.l     64
G_CARDR:            ds.l     18
G_SAWR:             ds.l     14
G_PICKAXER:         ds.l     22
G_TNTR:             ds.l     24
G_EMPTY:            ds.l     6
G_FULL:             ds.l     6
G_HOLD_BACK:        ds.l     88
G_SNOWBALL:         ds.l     10
WSPYSAT:            ds.l     120
BSPYSAT:            ds.l     120
WPOURR1:            ds.l     164
WPOURR2:            ds.l     164
WPOURL1:            ds.l     164
WPOURL2:            ds.l     164
BPOURL1:            ds.l     164
BPOURL2:            ds.l     164
BPOURR1:            ds.l     164
BPOURR2:            ds.l     164
WPLUNGER1:          ds.l     164
WPLUNGER2:          ds.l     164
WPLUNGEL1:          ds.l     164
WPLUNGEL2:          ds.l     164
BPLUNGER1:          ds.l     164
BPLUNGER2:          ds.l     164
BPLUNGEL1:          ds.l     164
BPLUNGEL2:          ds.l     164
WLAUGH1:            ds.l     164
WLAUGH2:            ds.l     164
BLAUGH1:            ds.l     164
BLAUGH2:            ds.l     164
WBLUP1:             ds.l     164
WBLUP2:             ds.l     164
WBLUP3:             ds.l     164
BBLUP1:             ds.l     164
BBLUP2:             ds.l     164
BBLUP3:             ds.l     164
WPICKR1:            ds.l     164
WPICKR2:            ds.l     164
WPICKL1:            ds.l     164
WPICKL2:            ds.l     164
BPICKL1:            ds.l     164
BPICKL2:            ds.l     164
BPICKR1:            ds.l     164
BPICKR2:            ds.l     164
WSAWR1:             ds.l     164
WSAWR2:             ds.l     164
WSAWL1:             ds.l     164
WSAWL2:             ds.l     164
BSAWL1:             ds.l     164
BSAWL2:             ds.l     164
BSAWR1:             ds.l     164
BSAWR2:             ds.l     164
WHOLE1:             ds.l     164
HOLE2:              ds.l     164
HOLE3:              ds.l     164
HOLE4:              ds.l     164
HOLE5:              ds.l     164
BHOLE1:             ds.l     164
WICICLED1:          ds.l     164
WICICLED2:          ds.l     164
WICICLED3:          ds.l     164
BICICLED1:          ds.l     164
BICICLED2:          ds.l     164
BICICLED3:          ds.l     164
WROCKET1:           ds.l     296
WROCKET2:           ds.l     296
BROCKET1:           ds.l     296
BROCKET2:           ds.l     296
BUFWL1:             ds.l     120
BUFWL2:             ds.l     120
BUFWL3:             ds.l     120
BUFWR1:             ds.l     120
BUFWR2:             ds.l     120
BUFWR3:             ds.l     120
BUFBL1:             ds.l     120
BUFBL2:             ds.l     120
BUFBL3:             ds.l     120
BUFBR1:             ds.l     120
BUFBR2:             ds.l     120
BUFBR3:             ds.l     120
GO_H:               ds.l     126
GO_D:               ds.l     126
SHOW_H:             ds.l     42
SHOW_D:             ds.l     42
HIDE_H:             ds.l     42
HIDE_D:             ds.l     42
MISSILE_H:          ds.l     112
MISSILE_D:          ds.l     112
WSPY_D:             ds.l     116
BSPY_D:             ds.l     116
WSPY_H:             ds.l     116
BSPY_H:             ds.l     116
COMP_H:             ds.l     120
COMP_D:             ds.l     120
NUMS:               ds.l     60
SUBXW:              ds.w     1
SUBXB:              ds.w     1
SUBHTW:             ds.w     1
SUBHTB:             ds.w     1
SPLASH_BACK:        ds.w     1
SPLASH_COUNT:       ds.w     1
ALTER_PALETTE_FLAG: ds.w     1
FADE_FLAG:          ds.w     1
FADE_VALUE:         ds.w     1
TSAVE_INT:          ds.l     1
TINT_FLAG:          ds.w     1
TINT_REQ:           ds.w     1
TSCREEN1:           ds.l     1
TSCREEN2:           ds.l     1
TSCREEN3:           ds.l     1
TSCREEN4:           ds.l     1
TFILEPTR:           ds.w     1
TBACK:              ds.l     1
THANDLE:            ds.l     1
TLENGTH:            ds.l     1
TOLD_VAL_INT:       ds.l     1
TINT_VECTOR:        ds.l     1
TPALETTE:           ds.l     8
TCOUNTER:           ds.w     1
TFERDINAND:         ds.w     1
TSAVE_KEY:          ds.l     1
TSAVE_ADD:          ds.l     1
TSAVE_STACK:        ds.l     1
LOWER_LIMIT:        ds.w     1
CONTROLS:           ds.l     770
HANDLE:             ds.l     1
LENGTH:             ds.l     1
BUPHER:             ds.l     128
TRAPLIST:           ds.l     150
JOY1TRIG:           ds.w     1
JOY2TRIG:           ds.w     1
RANDOM_AREA:        ds.b     8192

                    end

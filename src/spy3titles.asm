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
_LVOExit            equ      -144

; -------------------------------------------

                    section  spy3titles,code_c

START_CODE:         bra      START

COPPER_LIST:
PLANES:             dc.w     $E2,0,$E0,0
                    dc.w     $E6,0,$E4,0
                    dc.w     $EA,0,$E8,0
                    dc.w     $EE,0,$EC,0
COPPER_SPRITE:      dc.w     $120,0,$122,0,$124,0,$126,0,$128,0,$12A,0,$12C,0,$12E,0
                    dc.w     $130,0,$132,0,$134,0,$136,0,$138,0,$13A,0,$13C,0,$13E,0
                    dc.w     $FFFF,$FFFE
END_COPPER_LIST:
DUMMY_SPRITE:       dc.w     0,0

WAIT_FOR_RASTER:    move.l   d1,d2
                    add.w    #$B00,d2
.WAIT:              move.l   $DFF004,d0
                    and.l    #$1FFFF,d0
                    cmp.l    d1,d0
                    bls.b    .WAIT
                    cmp.l    d2,d0
                    bhi.b    .WAIT
                    rts

ATARI_COPY:         move.w   #((200*40)/2)-1,d0
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
                    lea      DOSNAME,a1
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
                    move.w   #8-1,d0
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
                    move.w   #$83DF,$96(a6)
                    rts

WHICH_PLANES:       move.w   #4-1,d0
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

ALLOCATE_MEMORY:    move.l   #SCREENA,ONESCREEN
                    move.l   #SCREENB,TWOSCREEN
                    move.l   #SCREENC,BACK
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
                    lea      92(a1),a1
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
DOSNAME:            dc.b     'dos.library',0
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
E_HIGH_PING:        dc.w     1,32,0,5,0,1,32,-1
                    dc.w     0,-1
E_MEDIUM_PING:      dc.w     1,32,0,5,0,1,32,-1,0,-1
E_LOW_PING:         dc.w     1,44,0,100,0,0,1,-44,0,-1
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
E_SAW:              dc.w     1,30,0,20,0,0,1,-30,0,20,0,0,1,30,1000,20,0,0,1,-30,-1000,20,0,0,1,30,0,20,0,0,1,-30
                    dc.w     0,20,0,0,1,30,1000,20,0,0,1,-30,-1000,20,0,0,1,30,0,20,0,0,1,-30,0,20,0,0,1,30,1000
                    dc.w     20,0,0,1,-30,-1000,20,0,0,1,30,0,20,0,0,1,-30,0,$14,0,0,1,30,1000,20,0,0,1,-30,-1000
                    dc.w     20,0,0,1,30,0,20,0,0,1,-30,0,20,0,0,1,30,1000,20,0,0,1,-30,-1000,20,0,0,1,30,0,20,0
                    dc.w     0,1,-30,0,20,0,0,1,30,1000,20,0,0,1,-30,-1000,$14,0,0,-1
E_KISS:             dc.w     1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1
                    dc.w     0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2
                    dc.w     0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0
                    dc.w     1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1
                    dc.w     0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,$14,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1400,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0
                    dc.w     2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0
                    dc.w     0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1
                    dc.w     1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0
                    dc.w     2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,$14,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1400,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1
                    dc.w     0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2
                    dc.w     0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0
                    dc.w     1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1
                    dc.w     0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2
                    dc.w     0,0,20,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1400,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0
                    dc.w     1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1
                    dc.w     0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2
                    dc.w     0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0
                    dc.w     1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1,0,2,0,0,1,1
                    dc.w     0,2,0,0,1,1,0,2,0,0,20,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,1,-1
                    dc.w     0,2,0,0,-1
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
                    clr.w    14(a6)
                    bsr      INITMUSC
                    move.l   $78.w,SAVEINT6
                    move.l   #MYINT6,$78.w
                    lea      $BFD000,a0
                    move.b   #0,$600(a0)
                    move.b   #14,$700(a0)
                    move.b   #$11,$F00(a0)
                    move.b   #$82,$D00(a0)
                    move.w   #$A000,$DFF09A
                    clr.b    lbB002BAD
                    rts

GO_SOUND:           move.l   a1,(a5)
                    move.w   #$FF,$DFF09E
                    move.w   d0,4(a5)
                    move.w   d1,$14(a6)
                    move.w   d1,6(a5)
                    clr.w    6(a6)
                    clr.w    0(a6)
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

LOW_PING:           move.w   #128/2,d0
                    move.w   #200,d1
                    lea      E_LOW_PING,a0
                    lea      WAVEFORM128,a1
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

GRAVESOUND:         move.w   #598/2,d0
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
                    bne      lbC0023F0
                    lea      $DFF0B0,a5
                    lea      MUSINF_1,a6
                    bsr      HANDLE_REQUEST
                    bne      lbC0023F0
                    lea      $DFF0C0,a5
                    lea      MUSINF_2,a6
                    bsr      HANDLE_REQUEST
                    bne      lbC0023F0
                    lea      $DFF0D0,a5
                    lea      MUSINF_3,a6
                    bra      HANDLE_REQUEST
lbC0023F0:          rts

HANDLE_REQUEST:     lea      REQUESTS,a0
                    tst.w    14(a6)
                    bne      lbC002448
                    tst.w    (a0)+
                    bmi      lbC00240A
                    bne      lbC002428
lbC00240A:          tst.w    (a0)+
                    bmi      lbC002414
                    bne      lbC002428
lbC002414:          tst.w    (a0)+
                    bmi      lbC00241E
                    bne      lbC002428
lbC00241E:          tst.w    (a0)+
                    bmi      lbC00244C
                    beq      lbC00244C
lbC002428:          move.w   -(a0),d0
                    and.w    #$FF,d0
                    or.w     #$8000,(a0)
                    and.w    #$9FFF,(a0)
                    move.l   a0,22(a6)
                    add.w    d0,d0
                    add.w    d0,d0
                    lea      SOUND_ROUTINES,a0
                    move.l   (a0,d0.w),a0
                    jsr      (a0)
lbC002448:          moveq    #0,d0
                    rts

lbC00244C:          moveq    #-1,d0
                    rts

NEW_SOUND:          movem.l  d0-d2/a0,-(sp)
                    move.w   d7,d0
                    move.w   d0,d2
                    and.w    #$3FF,d0
                    btst     #13,d2
                    beq      lbC00247A
                    tst.w    BSND_FLAG
                    bne      NEW_RET
                    move.w   #1,BSND_FLAG
                    bra      NO_MATCH

lbC00247A:          lea      REQUESTS,a0
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
                    beq      lbC0024E8
                    tst.w    (a0)+
                    beq      lbC0024E8
                    tst.w    (a0)+
                    beq      lbC0024E8
                    tst.w    (a0)+
                    beq      lbC0024E8
                    btst     #14,d2
                    bne      lbC0024E8
                    bra      NEW_RET

lbC0024E8:          move.w   d0,-(a0)
NEW_RET:            movem.l  (sp)+,d0-d2/a0
                    rts

REQUESTS:           dcb.l    2,0
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
                    tst.w    MASTER_ENABLE
                    beq      MYINT6_RET
                    movem.l  d0-d7/a0-a6,-(sp)
                    tst.w    MUSIC_DELAY
                    beq      lbC002570
                    subq.w   #1,MUSIC_DELAY
                    bra      ENVS

lbC002570:          move.w   #3,MUSIC_DELAY
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
                    beq      _HANDLE_SOUNDS
                    bsr      CHANGE_ENVELOPE
_HANDLE_SOUNDS:     bsr      HANDLE_SOUNDS
                    movem.l  (sp)+,d0-d7/a0-a6
MYINT6_RET:         move.w   #$2000,$DFF09C
                    rte

CHANGE_ENVELOPE:    tst.w    (a6)
                    bne      SAME_STEP
                    or.w     #$8000,8(a6)
                    tst.w    14(a6)
                    bmi      lbC002616
                    clr.w    14(a6)
lbC002616:          move.l   10(a6),a0
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
                    bne      lbC002688
                    move.l   22(a6),a1
                    move.w   (a1),d0
                    btst     #14,d0
                    beq      lbC002684
                    bclr     #14,d0
                    move.w   d0,(a1)
                    move.w   2(a0),d0
                    sub.w    d0,a0
                    bra.b    CE_1

lbC002684:          addq.w   #4,a0
                    bra.b    CE_1

lbC002688:          tst.w    6(a6)
                    bne      lbC002696
                    and.w    #$7FFF,8(a6)
lbC002696:          move.l   22(a6),a0
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
                    move.w   #$1000,4(a5)
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
                    clr.w    d1
                    bsr.b    PSGW
                    move.w   #9,d0
                    clr.w    d1
                    bsr.b    PSGW
                    move.l   #NOTES1,POINTERA
                    move.l   #NOTES2,POINTERB
                    clr.w    DELAYA
                    clr.w    DELAYB
                    clr.w    FLAGA
                    clr.w    FLAGB
                    rts

PLAYMUS:            tst.w    MUSICON
                    beq      lbC002940
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

lbC002940:          move.w   #8,d0
                    clr.w    d1
                    bsr      PSGW
                    move.w   #9,d0
                    clr.w    d1
                    bra      PSGW

PLAY_CHANNEL:       tst.w    d7
                    beq      PLAY2
                    subq.w   #1,d7
                    tst.w    d5
                    bne      lbC002984
                    tst.w    FLAGA
                    beq      lbC0029A0
                    cmp.w    #9,d7
                    bgt      lbC0029A0
                    move.w   d7,d1
                    move.w   #8,d0
                    bsr      PSGW
lbC002984:          tst.w    FLAGB
                    beq      lbC0029A0
                    cmp.w    #10,d7
                    bgt      lbC0029A0
                    move.w   d7,d1
                    move.w   #9,d0
                    bra      PSGW
lbC0029A0:          rts

PLAY2:              tst.w    (a4)
                    bpl      lbC0029AC
                    move.l   2(a4),a4
lbC0029AC:          move.w   (a4)+,d2
                    move.w   (a4)+,d3
                    move.w   (a4)+,d7
                    tst.w    d3
                    bmi      lbC002A18
                    tst.w    d5
                    bne      lbC0029EC
                    subq.w   #1,d2
                    move.w   #-1,FLAGA
                    move.w   #8,d0
                    move.w   #9,d1
                    bsr      PSGW
                    clr.w    d0
                    move.w   d2,d1
                    bsr      PSGW
                    move.w   #1,d0
                    move.w   d3,d1
                    bsr      PSGW
                    bra      lbC002A42

lbC0029EC:          move.w   #-1,FLAGB
                    move.w   #9,d0
                    move.w   #10,d1
                    bsr      PSGW
                    move.w   #2,d0
                    move.w   d2,d1
                    bsr      PSGW
                    move.w   #3,d0
                    move.w   d3,d1
                    bsr      PSGW
                    bra      lbC002A42

lbC002A18:          tst.w    d5
                    bne      lbC002A30
                    move.w   #8,d0
                    clr.w    d1
                    bsr      PSGW
                    clr.w    FLAGA
lbC002A30:          move.w   #9,d0
                    clr.w    d1
                    bsr      PSGW
                    clr.w    FLAGB
lbC002A42:          rts

NOTES1:             dc.w     0,-1,352
NOTES1A:            dc.w     0,-1,704,5,7,88,0,-1,88,5,6,88,0,-1
                    dc.w     88,5,2,88,0,-1,88,5,0,88,0,-1,88,4,7
                    dc.w     88,0,-1,88,4,6,88,0,-1,88,4,2,88,0
                    dc.w     -1,88,4,0,88,0,-1,88,3,7,88,0,-1,88
                    dc.w     3,6,88,0,-1,88,3,2,88,0,-1,88,3,0,88,0
                    dc.w     -1,88,-1
                    dc.l     NOTES1A
NOTES2:             dc.w     1,2,11,1,2,11,1,2,22,0,-1,44,0,-1,88,1,2
                    dc.w     11,1,2,11,1,2,22,0,-1,44,0,-1,88
NOTES2A:            dc.w     1,2,11,1,2,11,2,9,11,1,2,11,2,0,11,1,2,11,2,9,11
                    dc.w     2,7,$16,1,2,11,2,6,11,1,2,11,2,4,11,1,2,11,2,0,11
                    dc.w     1,9,11,-1
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
SAVE_INT2:          dcb.w    2,0
TEMP_MUSIC:         dc.w     0
REGS:               dcb.b    13,0
lbB002BAD:          dc.b     0
REG7:               dcb.b    2,0
SAVEINT6:           dc.l     0
MUSINF_0:           dcb.w    13,0
MUSINF_1:           dcb.w    13,0
MUSINF_2:           dcb.w    13,0
MUSINF_3:           dcb.w    13,0
MUSIC_POINTER:      dc.w     0
MUSIC_DELAY:        dc.w     0
FRED:               dc.w     0
MASTER_ENABLE:      dc.w     0
RANDOM_AREA:        dcb.b    8192,0
BSND_FLAG:          dc.w     0
MUSIC_DELAY2:       dc.w     0
RND1:               dc.l     $81281233
RND2:               dc.l     $12871332
RND3:               dc.l     $1111FFED

START:              jsr      ALLOCATE_MEMORY
                    jsr      START_SOUNDS
                    jsr      SETUP_SCREEN
                    move.l   TWOSCREEN,SCREEN2
                    move.l   ONESCREEN,SCREEN1
                    bsr      READALL
                    move.l   #1245184,d0
.WAIT:              subq.l   #1,d0
                    bne.b    .WAIT
                    move.l   $6C.w,-(sp)
                    move.l   #MYINT3,$6C.w
                    jsr      TITLES
                    move.w   #$A0,$DFF096
                    move.l   (sp)+,$6C.w
                    move.l   SAVEINT6,$78.w
                    moveq    #0,d1
                    move.l   DOS_BASE,a6
                    moveq    #0,d0
                    jsr      _LVOExit(a6)
                    moveq    #0,d0
                    rts

READALL:            lea      OBJNAME1,a0
                    bsr      READPIX
                    move.l   BACK,a0
                    moveq    #0,d1
                    moveq    #0,d2
                    moveq    #4,d6
                    moveq    #$1B,d7
                    lea      BLACK_SUB,a1
                    bsr      RSTUFF_BUFF
                    moveq    #4,d1
                    lea      WHITE_SUB,a1
                    bsr      RSTUFF_BUFF
                    moveq    #8,d1
                    moveq    #4,d2
                    moveq    #3,d6
                    moveq    #$1D,d7
                    lea      ROCK1,a1
                    bsr      RSTUFF_BUFF
                    moveq    #12,d1
                    moveq    #0,d2
                    moveq    #4,d6
                    moveq    #$16,d7
                    lea      ROCK2,a1
                    bsr      RSTUFF_BUFF
                    moveq    #16,d1
                    moveq    #1,d2
                    moveq    #4,d6
                    moveq    #$1C,d7
                    lea      ROCK3,a1
                    bsr      RSTUFF_BUFF
                    moveq    #12,d1
                    moveq    #$20,d2
                    moveq    #2,d6
                    moveq    #$11,d7
                    lea      ROCK4,a1
                    bsr      RSTUFF_BUFF
                    moveq    #14,d1
                    moveq    #$34,d2
                    moveq    #2,d6
                    moveq    #$1E,d7
                    lea      PENGY_L,a1
                    bsr      RSTUFF_BUFF
                    moveq    #$10,d1
                    lea      PENGY_F,a1
                    bsr      RSTUFF_BUFF
                    moveq    #$12,d1
                    lea      PENGY_R,a1
                    bsr      RSTUFF_BUFF
                    moveq    #0,d1
                    moveq    #$22,d2
                    moveq    #12,d6
                    moveq    #$30,d7
                    lea      SPYVSPY,a1
                    bsr      RSTUFF_BUFF
                    moveq    #$5D,d2
                    moveq    #$10,d6
                    moveq    #$1C,d7
                    lea      MAD_MAG,a1
                    bsr      RSTUFF_BUFF
                    move.w   #$86,d2
                    move.w   #$12,d6
                    move.w   #$42,d7
                    lea      ARCTIC_ANTS,a1
                    bsr      RSTUFF_BUFF
                    move.l   #OBJNAME2,a0
                    bsr      READPIX
                    move.l   BACK,a0
                    moveq    #0,d1
                    moveq    #0,d2
                    moveq    #5,d6
                    moveq    #14,d7
                    lea      SPLASH1,a1
                    bsr      RSTUFF_BUFF
                    moveq    #14,d2
                    lea      SPLASH2,a1
                    bsr      RSTUFF_BUFF
                    moveq    #$21,d2
                    lea      SPLASH3,a1
                    bsr      RSTUFF_BUFF
                    moveq    #$36,d2
                    lea      SPLASH4,a1
                    bsr      RSTUFF_BUFF
                    moveq    #12,d1
                    moveq    #0,d2
                    moveq    #4,d6
                    moveq    #$38,d7
                    lea      OVERLAY,a1
                    bsr      RSTUFF_BUFF
                    moveq    #5,d1
                    moveq    #0,d2
                    moveq    #7,d6
                    moveq    #$22,d7
                    lea      BLACK_CAVE,a1
                    bsr      RSTUFF_BUFF
                    move.w   #$27,d2
                    lea      RED_CAVE,a1
                    bsr      RSTUFF_BUFF
                    moveq    #0,d1
                    moveq    #$65,d2
                    moveq    #$14,d6
                    moveq    #$17,d7
                    lea      FIRSTSTAR,a1
                    bsr      RSTUFF_BUFF
                    lea      BGNAME,a0
                    bra      READPIX

MYINT3:             jsr      TINTERRUPT
                    clr.w    INT_REQ
                    move.w   #$70,$DFF09C
                    rte

INT_REQ:            dc.w     0
INT_FLAG:           dc.w     0
MY_VERY_OWN_STACK:  dc.l     0

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

SWAPSCREEN:         jmp      SWAP_SCREEN

BGNAME:             dc.b     'gfx/backgnd.pi1',0
OBJNAME1:           dc.b     'gfx/objects.pi1',0
OBJNAME2:           dc.b     'gfx/object2.pi1',0
                    even

RSPRITER:           movem.l  d0-d7/a0-a2,-(sp)
                    subq.w   #1,d6
                    subq.w   #1,d7
                    move.w   d1,d4
                    and.w    #15,d4
                    lsl.w    #3,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    and.w    #$FFF0,d1
                    asr.w    #3,d1
                    add.w    d1,a0
lbC0054A8:          move.l   a0,a2
                    move.w   d6,d0
lbC0054AC:          moveq    #0,d2
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
                    beq      lbC005526
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
                    bra      lbC00553C

lbC005526:          move.w   (a1)+,d2
                    or.w     d2,(a0)+
                    move.w   (a1)+,d2
                    or.w     d2,(200*40)-2(a0)
                    move.w   (a1)+,d2
                    or.w     d2,(200*2*40)-2(a0)
                    move.w   (a1)+,d2
                    or.w     d2,(200*3*40)-2(a0)
lbC00553C:          dbra     d0,lbC0054AC
                    lea      40(a2),a0
                    dbra     d7,lbC0054A8
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
lbC005562:          move.l   a0,a2
                    move.w   d6,d0
lbC005566:          move.w   (a0)+,(a1)+
                    move.w   (200*40)-2(a0),(a1)+
                    move.w   (200*2*40)-2(a0),(a1)+
                    move.w   (200*3*40)-2(a0),(a1)+
                    dbra     d0,lbC005566
                    lea      40(a2),a0
                    dbra     d7,lbC005562
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
lbC00559A:          move.l   a0,a2
                    move.w   d6,d0
lbC00559E:          move.w   (a1)+,(a0)+
                    move.w   (a1)+,(200*40)-2(a0)
                    move.w   (a1)+,(200*2*40)-2(a0)
                    move.w   (a1)+,(200*3*40)-2(a0)
                    dbra     d0,lbC00559E
                    lea      40(a2),a0
                    dbra     d7,lbC00559A
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

RSTUFF_BUFF:        movem.l  d0-d7/a0-a2,-(sp)
                    addq.w   #1,d6
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
lbC0055E0:          move.l   a0,a2
                    move.w   d6,d0
lbC0055E4:          move.w   (a0),d1
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
                    dbra     d0,lbC0055E4
                    clr.w    (a1)+
                    lea      40(a2),a0
                    dbra     d7,lbC0055E0
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

RSTUFF_BUFF_ST:     movem.l  d0-d7/a0-a2,-(sp)
                    addq.w   #1,d6
                    move.w   d6,d3
                    mulu     d7,d3
                    add.w    d3,d3
                    move.l   d3,(a1)+
                    move.w   d6,(a1)+
                    move.w   d7,(a1)+
                    subq.w   #2,d6
                    subq.w   #1,d7
                    lsl.w    #5,d2
                    add.w    d2,a0
                    add.w    d2,d2
                    add.w    d2,d2
                    add.w    d2,a0
                    asl.w    #3,d1
                    add.w    d1,a0
lbC00564C:          move.l   a0,a2
                    move.w   d6,d0
lbC005650:          move.w   (a0),d1
                    or.w     2(a0),d1
                    or.w     4(a0),d1
                    or.w     6(a0),d1
                    move.w   d1,(a1)
                    move.w   d3,d2
                    move.w   (a0)+,(a1,d2.w)
                    add.w    d3,d2
                    move.w   (a0)+,(a1,d2.w)
                    add.w    d3,d2
                    move.w   (a0)+,(a1,d2.w)
                    add.w    d3,d2
                    move.w   (a0)+,(a1,d2.w)
                    addq.w   #2,a1
                    dbra     d0,lbC005650
                    clr.w    (a1)+
                    lea      160(a2),a0
                    dbra     d7,lbC00564C
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
lbC0056AE:          move.l   a0,a2
                    move.w   d6,d0
lbC0056B2:          move.w   d3,d2
                    move.w   (a0),(a1)
                    move.w   (200*40)(a0),(a1,d2.w)
                    add.w    d3,d2
                    move.w   (200*2*40)(a0),(a1,d2.w)
                    add.w    d3,d2
                    move.w   (200*3*40)(a0),(a1,d2.w)
                    addq.w   #2,a1
                    addq.w   #2,a0
                    dbra     d0,lbC0056B2
                    lea      40(a2),a0
                    dbra     d7,lbC0056AE
                    movem.l  (sp)+,d0-d7/a0-a2
                    rts

RSPRITER_AM:        movem.l  d0-d7/a0-a4,-(sp)
                    move.w   MINTERMS,d5
                    lea      $DFF000,a2
                    move.w   #$8440,$96(a2)
                    move.w   4(a1),d6
                    cmp.w    #$FE2,d5
                    beq      lbC005706
                    subq.w   #1,d6
lbC005706:          lsl.w    #3,d2
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
                    beq      lbC005748
                    move.w   #2,$64(a2)
lbC005748:          move.w   #0,$62(a2)
                    move.w   #$28,d3
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

X:                  dc.w     0
Y:                  dc.w     0
WIDTH:              dc.w     0
HEIGHT:             dc.w     0
BUFFER:             dc.l     0
SCREEN:             dc.l     0
MINTERMS:           dc.w     $FE2

TITLES:             move.w   #0,d0
                    bsr      MAKE_PALETTE_D0
                    move.w   #6,TPALETTE
                    clr.w    FADE_FLAG
INIT_CL:            move.l   SCREEN1,a0
                    move.l   SCREEN2,a1
                    move.w   #(200*40)-1,d0
lbC005818:          clr.l    (a0)+
                    clr.l    (a1)+
                    dbra     d0,lbC005818
                    bsr      SWAPSCREEN
                    bsr      FADE_IN
                    move.w   #-1,FADE_VALUE
                    clr.w    ALTER_PALETTE_FLAG
                    bsr      INTRO_SEQUENCE
                    clr.w    TPALETTE
                    move.w   #-1,FADE_FLAG
lbC005848:          tst.w    FADE_FLAG
                    bne.b    lbC005848
                    rts

TINTERRUPT:         addq.w   #1,TFERDINAND
                    tst.w    ALTER_PALETTE_FLAG
                    beq      lbC00586C
                    subq.w   #1,ALTER_PALETTE_FLAG
                    bra      lbC005878

lbC00586C:          move.w   #4,ALTER_PALETTE_FLAG
                    bra      ALTER_PALETTE
lbC005878:          rts

MAKE_PALETTE_D0:    movem.l  a0/a1,-(sp)
                    move.w   d0,FADE_VALUE
                    lsl.w    #5,d0
                    lea      PA,a0
                    add.w    d0,a0
                    move.w   #16-1,d0
                    lea      $DFF180,a1
lbC005898:          move.w   (a0)+,d2
                    add.w    d2,d2
                    add.w    #$111,d2
                    move.w   d2,(a1)+
                    dbra     d0,lbC005898
                    movem.l  (sp)+,a0/a1
                    rts

ALTER_PALETTE:      movem.l  d1/d2,-(sp)
                    tst.w    FADE_FLAG
                    beq      lbC005904
                    bpl      lbC0058DE
                    subq.w   #1,FADE_VALUE
                    move.w   FADE_VALUE,d1
                    cmp.w    TPALETTE,d1
                    bne      lbC0058F6
                    clr.w    FADE_FLAG
                    bra      lbC0058F6

lbC0058DE:          addq.w   #1,FADE_VALUE
                    cmp.w    #21,FADE_VALUE
                    bne      lbC0058F6
                    clr.w    FADE_FLAG
lbC0058F6:          move.l   d0,-(sp)
                    move.w   FADE_VALUE,d0
                    bsr      MAKE_PALETTE_D0
                    move.l   (sp)+,d0
lbC005904:          movem.l  (sp)+,d1/d2
                    rts

FADE_IN:            move.w   #((200*40)/4)-1,d0
                    move.l   BACK,a0
                    move.l   SCREEN2,a1
.COPY:              move.l   (a0)+,(a1)+
                    move.l   (a0)+,(a1)+
                    move.l   (a0)+,(a1)+
                    move.l   (a0)+,(a1)+
                    dbra     d0,.COPY
                    bsr      SWAPSCREEN
                    rts

INTRO_SEQUENCE:     clr.w    TCOUNTER
                    clr.w    SUBHTW
                    clr.w    SUBHTB
                    move.w   #4,SUBXW
                    move.w   #256,SUBXB
                    moveq    #13,d7
                    bsr      NEW_SOUND
IS_1:               eor.w    #1,NEW_COUNTER
                    tst.w    NEW_COUNTER
                    bne      lbC00596C
                    addq.w   #1,TCOUNTER
lbC00596C:          move.w   TCOUNTER,d4
                    move.l   BACK,a0
                    btst     #0,d4
                    bne      lbC005994
                    cmp.w    #320,d4
                    blt      lbC005994
                    cmp.w    #336,d4
                    bgt      lbC005994
                    lea      80(a0),a0
lbC005994:          move.l   SCREEN2,a1
                    move.w   #((200*40)/4)-1,d0
lbC00599E:          move.l   (a0)+,(a1)+
                    move.l   (a0)+,(a1)+
                    move.l   (a0)+,(a1)+
                    move.l   (a0)+,(a1)+
                    dbra     d0,lbC00599E
                    cmp.w    #256,d4
                    bge      IS_5
                    cmp.w    #64,d4
                    bgt      lbC0059DC
                    lea      FIRSTSTAR,a1
                    moveq    #0,d1
                    moveq    #5,d2
                    moveq    #20,d6
                    moveq    #23,d7
                    bra      lbC005A4A

lbC0059DC:          cmp.w    #128,d4
                    bgt      lbC005A06
                    lea      MAD_MAG,a1
                    moveq    #32,d1
                    moveq    #5,d2
                    moveq    #16,d6
                    moveq    #28,d7
                    bra      lbC005A4A

lbC005A06:          cmp.w    #192,d4
                    bgt      lbC005A30
                    lea      SPYVSPY,a1
                    moveq    #74,d1
                    moveq    #3,d2
                    moveq    #12,d6
                    moveq    #48,d7
                    bra      lbC005A4A

lbC005A30:          lea      ARCTIC_ANTS,a1
                    moveq    #34,d1
                    moveq    #0,d2
                    moveq    #18,d6
                    moveq    #66,d7
lbC005A4A:          move.l   SCREEN2,a0
                    bsr      RSPRITER_AM
                    move.w   d4,d0
                    and.w    #$3F,d0
                    cmp.w    #1,d0
                    bne      lbC005A6E
                    move.w   #1,FADE_FLAG
                    bra      _IS_9

lbC005A6E:          cmp.w    #40,d0
                    bne      _IS_9
                    move.w   #-1,FADE_FLAG
_IS_9:              bra      IS_9

IS_5:               cmp.w    #260,d4
                    bne      lbC005A9A
                    tst.w    NEW_COUNTER
                    bne      lbC005A9A
                    moveq    #5,d7
                    bsr      NEW_SOUND
lbC005A9A:          cmp.w    #284,d4
                    beq      lbC005AAA
                    cmp.w    #300,d4
                    bne      lbC005ABE
lbC005AAA:          tst.w    NEW_COUNTER
                    bne      lbC005ABE
                    moveq    #7,d7
                    bsr      NEW_SOUND
                    bra      lbC005ABE

lbC005ABE:          cmp.w    #320,d4
                    bge      IS_8
                    move.l   SCREEN2,a0
                    move.w   SUBXW,d1
                    move.w   SUBHTW,d7
                    lea      WHITE_SUB,a1
                    moveq    #1,d4
                    bsr      MOVE_SUB
                    move.w   d7,SUBHTW
                    move.w   d1,SUBXW
                    move.w   SUBXB,d1
                    move.w   SUBHTB,d7
                    lea      BLACK_SUB,a1
                    moveq    #-1,d4
                    bsr      MOVE_SUB
                    move.w   d7,SUBHTB
                    move.w   d1,SUBXB
                    move.w   #128,d1
                    move.w   #100,d2
                    move.w   #4,d6
                    move.w   #56,d7
                    lea      OVERLAY,a1
                    move.l   SCREEN2,a0
                    bsr      RSPRITER_AM
                    bra      IS_9

IS_8:               cmp.w    #320,d4
                    bne      lbC005B50
                    tst.w    NEW_COUNTER
                    bne      lbC005B50
                    moveq    #4,d7
                    bsr      NEW_SOUND
lbC005B50:          cmp.w    #360,d4
                    bge      IS_10
                    move.w   d4,d0
                    and.w    #1,d0
                    add.w    d0,d0
                    add.w    d0,d0
                    lea      CAVES,a1
                    move.l   (a1,d0.w),a1
                    move.w   #$60,d1
                    move.w   #$61,d2
                    move.w   #$22,d7
                    move.w   #7,d6
                    move.l   SCREEN2,a0
                    bsr      RSPRITER_AM
IS_9:               bsr      DO_PENGUIN
lbC005B88:          cmp.w    #2,TFERDINAND
                    blt.b    lbC005B88
                    bsr      SWAPSCREEN
                    clr.w    TFERDINAND
                    bra      IS_1

IS_10:              rts

SPLASHES:           dc.l     SPLASH1
                    dc.l     SPLASH2
                    dc.l     SPLASH3
                    dc.l     SPLASH4
CAVES:              dc.l     RED_CAVE
                    dc.l     BLACK_CAVE

MOVE_SUB:           cmp.w    #$1B,d7
                    beq      lbC005BC8
                    addq.w   #1,d7
                    bra      lbC005BCA

lbC005BC8:          add.w    d4,d1
lbC005BCA:          move.w   #$7F,d2
                    sub.w    d7,d2
                    move.w   #4,d6
                    bsr      RSPRITER_AM
                    move.w   d7,d4
                    move.w   d1,d3
                    move.w   #$7F,d2
                    subq.w   #4,d1
                    move.w   TCOUNTER,d0
                    and.w    #3,d0
                    add.w    d0,d0
                    add.w    d0,d0
                    lea      SPLASHES,a1
                    move.l   (a1,d0.w),a1
                    move.w   #5,d6
                    move.w   #14,d7
                    bsr      RSPRITER_AM
                    move.w   d3,d1
                    move.w   d4,d7
                    rts

DO_PENGUIN:         lea      ROCKDATA1,a3
                    bsr      ONE_PENGY
                    lea      ROCKDATA2,a3
                    bsr      ONE_PENGY
                    lea      ROCKDATA3,a3
                    bsr      ONE_PENGY
                    lea      ROCKDATA4,a3
                    bra      ONE_PENGY

WHICH_PENGUIN:      dc.l     PENGY_L
                    dc.l     PENGY_F
                    dc.l     PENGY_R

ONE_PENGY:          move.w   (a3),d1
                    move.w   2(a3),d2
                    move.w   20(a3),d3
                    bpl      lbC005C64
                    add.w    d3,d2
                    cmp.w    #$A8,d2
                    bne      lbC005C74
                    move.w   #1,20(a3)
                    bra      lbC005C74

lbC005C64:          add.w    d3,d2
                    cmp.w    #$C1,d2
                    bne      lbC005C74
                    move.w   #-1,20(a3)
lbC005C74:          move.w   d2,2(a3)
                    move.l   8(a3),a1
                    move.w   6(a3),d6
                    move.w   4(a3),d7
                    move.l   SCREEN2,a0
                    bsr      RSPRITER_LIMITED
                    add.w    12(a3),d1
                    add.w    14(a3),d2
                    move.w   #$1E,d7
                    move.w   #2,d6
                    tst.w    18(a3)
                    beq      lbC005CAE
                    subq.w   #1,18(a3)
                    bra      lbC005CC6

lbC005CAE:          move.w   #$14,18(a3)
                    addq.w   #1,16(a3)
                    cmp.w    #3,16(a3)
                    bne      lbC005CC6
                    clr.w    16(a3)
lbC005CC6:          move.w   16(a3),d0
                    add.w    d0,d0
                    add.w    d0,d0
                    lea      WHICH_PENGUIN,a1
                    move.l   (a1,d0.w),a1
                    ;bsr      RSPRITER_LIMITED
                    ;rts
                    ; no rts

RSPRITER_LIMITED:   move.w   d0,-(sp)
                    move.w   d2,d0
                    add.w    d7,d0
                    cmp.w    #200,d0
                    ble      _RSPRITER_AM
                    move.w   #200,d7
                    sub.w    d2,d7
_RSPRITER_AM:       bsr      RSPRITER_AM
                    move.w   (sp)+,d0
                    rts

;MASK_TABLE:         dc.w     0,$4000,$2000,$10,$8010,$4100,$8200,$8010,$4210
;                    dc.w     $8124,$4217,$8127,$4213,$971E,$8818,$6666,$9999
;                    dc.w     $5555,$9999,$5555,$9999,$5555,$9999,$5555,$AAAA
;                    dc.w     $5555,$AAAA,$5555,$AAAA,$5555,$AAAA,$5555,$AAAA
;                    dc.w     $5555,$AAAA,$5555,$AAAA,$5555,$AAAA,$5555,$AAAA
;                    dc.w     $5555,$AAAA,$5555,$AAAA,$5555,$AAAA,$5555,$AAAA
;                    dc.w     $5555,$AAAA,$5555,$AAAA,$5555,$AAAA,$5555,$AAAA
;                    dc.w     $5555,$AAAA,$5555,$AAAA,$5555,$AAAA,$5555
ROCKDATA1:          dc.w     20,185,29,3
                    dc.l     ROCK1
                    dc.w     8,-18,0,6,1
ROCKDATA2:          dc.w     80,170,22,4
                    dc.l     ROCK2
                    dc.w     16,-15,1,18,1
ROCKDATA3:          dc.w     160,180,28,4
                    dc.l     ROCK3
                    dc.w     12,-15,2,14,1
ROCKDATA4:          dc.w     240,190,17,2
                    dc.l     ROCK4
                    dc.w     4,-20,0,9,1
PA:                 dc.w     $357,$357,$357,$357,$357,$357,$357,$357,$357,$357,$357,$357,$357,$357,$357,$357
PB:                 dc.w     $357,$357,$357,$357,$347,$346,$356,$457,$357,$357,$347,$456,$357,$357,$357,$357
PC:                 dc.w     $357,$357,$456,$357,$247,$234,$356,$557,$357,$357,$247,$445,$347,$357,$357,$357
PD:                 dc.w     $357,$357,$456,$357,$237,$233,$355,$567,$357,$357,$236,$544,$347,$357,$367,$357
PE:                 dc.w     $357,$357,$555,$357,$127,$122,$445,$667,$357,$357,$126,$533,$337,$357,$367,$357
PF:                 dc.w     $357,$357,$555,$357,$117,$011,$445,$667,$357,$357,$116,$631,$337,$357,$367,$357
P0:                 dc.w     $357,$357,$555,$357,$007,$000,$444,$777,$357,$357,$006,$630,$337,$357,$377,$357
P1:                 dc.w     $357,$357,$555,$357,$007,$000,$444,$777,$357,$357,$006,$630,$337,$357,$377,$357
P2:                 dc.w     $357,$356,$555,$456,$007,$000,$444,$777,$457,$357,$006,$630,$337,$357,$377,$346
P3:                 dc.w     $357,$356,$555,$456,$007,$000,$444,$777,$457,$357,$006,$630,$337,$357,$377,$246
P4:                 dc.w     $357,$455,$555,$455,$007,$000,$444,$777,$457,$357,$006,$630,$337,$357,$377,$245
P5:                 dc.w     $357,$445,$555,$455,$007,$000,$444,$777,$457,$357,$006,$630,$337,$357,$377,$235
P6:                 dc.w     $357,$444,$555,$554,$007,$000,$444,$777,$557,$357,$006,$630,$337,$357,$377,$234
P7:                 dc.w     $357,$444,$555,$564,$007,$000,$444,$777,$567,$456,$006,$630,$337,$357,$377,$234
P8:                 dc.w     $357,$543,$555,$563,$007,$000,$444,$777,$567,$456,$006,$630,$337,$357,$377,$133
P9:                 dc.w     $357,$543,$555,$563,$007,$000,$444,$777,$567,$456,$006,$630,$337,$357,$377,$123
P10:                dc.w     $357,$543,$555,$663,$007,$000,$444,$777,$667,$456,$006,$630,$337,$357,$377,$123
P11:                dc.w     $357,$542,$555,$662,$007,$000,$444,$777,$667,$456,$006,$630,$337,$357,$377,$122
P12:                dc.w     $357,$642,$555,$662,$007,$000,$444,$777,$667,$456,$006,$630,$337,$357,$377,$112
P13:                dc.w     $357,$631,$555,$671,$007,$000,$444,$777,$677,$555,$006,$630,$337,$357,$377,$111
P14:                dc.w     $357,$631,$555,$771,$007,$000,$444,$777,$777,$555,$006,$630,$337,$357,$377,$011
P15:                dc.w     $357,$720,$555,$770,$007,$000,$444,$777,$777,$555,$006,$630,$337,$357,$377,$000
NEW_COUNTER:        dc.l     0

; -------------------------------------------

                    section  uninit_dats,bss_c

WHITE_SUB:          ds.w     679
BLACK_SUB:          ds.b     1358
ROCK1:              ds.l     292
ROCK2:              ds.l     277
ROCK3:              ds.l     352
ROCK4:              ds.w     259
PENGY_L:            ds.l     227
PENGY_F:            ds.l     227
PENGY_R:            ds.l     227
SPYVSPY:            ds.l     1562
MAD_MAG:            ds.l     1192
ARCTIC_ANTS:        ds.l     3137
SPLASH1:            ds.l     212
SPLASH2:            ds.l     212
SPLASH3:            ds.l     212
SPLASH4:            ds.l     212
OVERLAY:            ds.l     702
BLACK_CAVE:         ds.l     682
RED_CAVE:           ds.l     682
FIRSTSTAR:          ds.w     2419
SUBXW:              ds.w     1
SUBXB:              ds.w     1
SUBHTW:             ds.w     1
SUBHTB:             ds.w     1
SPLASH_BACK:        ds.w     1
SPLASH_COUNT:       ds.w     1
ALTER_PALETTE_FLAG: ds.w     1
FADE_FLAG:          ds.w     1
FADE_VALUE:         ds.w     1
SCREENA:            ds.l     8192
SCREENB:            ds.l     8192
SCREENC:            ds.l     8192
BACK:               ds.l     1
TPALETTE:           ds.w     16
TCOUNTER:           ds.w     1
TFERDINAND:         ds.w     1
TSAVE_KEY:          ds.w     2
TSAVE_ADD:          ds.w     2
TSAVE_STACK:        ds.w     3

                    end

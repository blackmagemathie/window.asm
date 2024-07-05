namespace append

empty_force:
    ; ----------------
    ; appends blank space to window table.
    ; ----------------
    ; A (2)   -> height.
    ; !gy (2) -> position, y.
    ; !ti (2) -> table index.
    ; ----------------
    ; !ti (2)   <- table index, updated.
    ; $310d (2) <- (garbage)
    ; ----------------
    php
    rep #$30
    ldx.w !ti
    sta.w !t0
    lda.w !gy
    cmp #$00e0
    bcc +
    dec
    clc
    adc.w !t0
    bcc .end
    inc
    bra .append
    +
    lda.w !t0
    
    .append:
        jsr empty_common
    .end:
        stx.w !ti
        plp
        rtl

empty_pad:
    ; ----------------
    ; appends blank space to window table.
    ; suited for padding before drawing shapes.
    ; ----------------
    ; !gy (2) -> position, y.
    ; !ti (2) -> table index.
    ; ----------------
    ; !ti (2) <- table index, updated.
    ; ----------------
    php
    rep #$30
    ldx.w !ti
    lda.w !gy
    beq +
    cmp #$00e0
    bcs +
    jsr empty_common
    +
    stx.w !ti
    plp
    rtl

empty_common:
    cmp #$0081
    bcc +
    pha
    lda #$0080
    sta.l !wl+0,x
    lda #$00ff
    sta.l !wl+1,x
    inx #3
    pla
    sec
    sbc #$0080
    +
    sta.l !wl+0,x
    lda #$00ff
    sta.l !wl+1,x
    inx #3
    rts

shape:
    ; ----------------
    ; appends shape to window table.
    ; ----------------
    ; $3100 (3) -> data pointer, rect height.
    ; $3103 (3) ->                    left.
    ; $3106 (3) ->                    width.
    ; $3109 (2) ->      length.
    ; !gx (2)   -> position, x.
    ; !gy (2)   ->           y.
    ; !ti (2)   -> table index.
    ; ----------------
    ; !ti (2)   <- table index, updated.
    ; $310d (2) <- (garbage)
    ; ----------------
    !ph = $3100
    !pl = $3103
    !pw = $3106
    !l  = $3109
    
    lda.b #!wwp
    sta $318f
    sta $2225
    phb
    phk
    plb
    rep #$30
    lda #$3100
    tcd
    
    ldx.b !ti
    ldy #$0000
    lda.b !gy
    sta.b !t0
    cmp #$00e0
    bcc .read
    
    .find:
        dec
        -
        clc
        adc.b [!ph],y
        bcs +
        iny #2
        cpy.b !l
        bcc -
        bra .end
        +
        stz !t0
        inc
        bra +
        
    .read:
        lda.b [!ph],y
        +
        sta.b !rh
        lda.b [!pl],y
        clc
        adc.b !gx
        sta.b !rl
        dec
        clc
        adc.b [!pw],y
        sta.b !rr
        sep #$20
        jsr util_rect_2
        rep #$20
        lda.b !rh
        clc
        adc.b !t0
        sta.b !t0
        cmp #$00e0
        bcs .end
        iny #2
        cpy.b !l
        bcc .read
        
    .end:
        stx.b !ti
        lda #$3000
        tcd
        sep #$30
        stz $318f
        stz $2225
        plb
        rtl
    
namespace off
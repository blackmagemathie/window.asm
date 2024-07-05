namespace append

empty_force:
    ; ----------------
    ; appends blank space to window table.
    ; ----------------
    ; A (2)                    -> height.
    ; !window_global_y (2)     -> position, y.
    ; !window_global_index (2) -> table index.
    ; ----------------
    ; !window_global_index (2) <- table index, updated.
    ; $310d (2)                <- (garbage)
    ; ----------------
    !t0 = $310d
    
    php
    rep #$30
    ldx.w !window_global_index
    sta.w !t0
    lda.w !window_global_y
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
        stx.w !window_global_index
        plp
        rtl

empty_pad:
    ; ----------------
    ; appends blank space to window table.
    ; suited for padding before drawing shapes.
    ; ----------------
    ; !window_global_y (2)     -> position, y.
    ; !window_global_index (2) -> table index.
    ; ----------------
    ; !window_global_index (2) <- table index, updated.
    ; ----------------
    php
    rep #$30
    ldx.w !window_global_index
    lda.w !window_global_y
    beq +
    cmp #$00e0
    bcs +
    jsr empty_common
    +
    stx.w !window_global_index
    plp
    rtl

empty_common:
    cmp #$0081
    bcc +
    pha
    lda #$0080
    sta.l !window_data+0,x
    lda #$00ff
    sta.l !window_data+1,x
    inx #3
    pla
    sec
    sbc #$0080
    +
    sta.l !window_data+0,x
    lda #$00ff
    sta.l !window_data+1,x
    inx #3
    rts

shape:
    ; ----------------
    ; appends shape to window table.
    ; ----------------
    ; $3100 (3)                -> data pointer, rect height.
    ; $3103 (3)                ->                    left.
    ; $3106 (3)                ->                    width.
    ; $3109 (2)                ->      length.
    ; !window_global_x (2)     -> position, x.
    ; !window_global_y (2)     ->           y.
    ; !window_global_index (2) -> table index.
    ; ----------------
    ; !window_global_index (2) <- table index, updated.
    ; $310d (2)                <- (garbage)
    ; ----------------
    !ph = $3100
    !pl = $3103
    !pw = $3106
    !l  = $3109
    
    lda.b #!window_page
    sta $318f
    sta $2225
    phb
    phk
    plb
    rep #$30
    lda #$3100
    tcd
    
    ldx.b !window_global_index
    ldy #$0000
    lda.b !window_global_y
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
        adc.b !window_global_x
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
        stx.b !window_global_index
        lda #$3000
        tcd
        sep #$30
        stz $318f
        stz $2225
        plb
        rtl
    
namespace off
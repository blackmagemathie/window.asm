namespace circle
    
prepare:
    ; prepares values for circle drawing.
    ; no need to call if radius unchanged.
    ; ----------------
    ; $00 (11) -> returned bresenham values.
    ; ----------------
    ; $3104 (2) <- radius, unsigned, ×1.
    ; $3106 (2) <-                   ×2.
    ; $3108 (2) <- octant data size.
    ; $310a (2) <-        diagonal size.
    ; $310c (3) <-        data pointer.
    ; ----------------
    !1r = $3104
    !2r = $3106
    !bs = $3108
    !bd = $310a
    !bp = $310c
    
    rep #$20
    
    ; 1r, 2r
    lda $00
    sta.w !1r
    asl
    sta.w !2r
    
    ; bs, bd
    lda $04
    sta.w !bs
    lda $02
    sta.w !bd
    
    ; bp
    lda $08
    sta.w !bp+0
    sep #$20
    lda $0a
    sta.w !bp+2
        
    rtl

draw:
    ; creates hdma table from octant.
    ; ----------------
    ; !gx (2)    -> top left corner pos x.
    ; !gy (2)    ->                     y.
    ; $3104 (11) -> (prepared values)
    ; carry      -> table to use. clear = 1; set = 2.
    ; ----------------
    lda.b #!wwp
    sta $318f
    sta $2225
    phb
    phk
    plb
    rep #$30
    lda #$3100
    tcd
    
    bcs +
    ldx.w #!window_index_1
    bra ++
    +
    ldx.w #!window_index_2
    ++
    
    .test_bounds:
        lda.b !gx
        cmp #$0100
        bcc +
        dec
        clc
        adc.b !2r
        bcs +
        jmp .clear
        +
        
        lda.b !gy
        cmp #$00e0
        bcc +
        dec
        clc
        adc.b !2r
        bcs +
        jmp .clear
        +
        
    .pad_blank:
        lda.b !gy
        beq .test_small
        cmp #$00e0
        bcs .test_small
        sep #$20
        cmp #$81
        bcc +
        lda #$80
        sta.w !ww+0,x
        lda #$ff
        sta.w !ww+1,x
        stz.w !ww+2,x
        inx #3
        lda.b !gy+0
        and #$7f
        +
        sta.w !ww+0,x
        lda #$ff
        sta.w !ww+1,x
        stz.w !ww+2,x
        inx #3
        
    .test_small:
        rep #$20
        lda.b !1r
        cmp #$0003
        bcs .draw
        lda.b !gx
        sta.b !rl
        clc
        adc.b !2r
        dec
        sta.b !rr
        lda.b !gy
        cmp #$00e0
        sep #$20
        lda.b !2r
        bcc +
        clc
        adc.b !gy
        +
        sta.b !rh
        jsr util_rect_2
        jmp .clear
        
    .draw:
        sep #$20
        jsr .top_h
        lda.b !bd
        beq +
        clc
        jsr .diag
        +
        jsr .top_v
        jsr .bot_v
        lda.b !bd
        beq +
        sec
        jsr .diag
        +
        jsr .bot_h
        
    .clear:
        sep #$20
        jsr util_clear_2
        
    .end:
        lda #$3000
        tcd
        sep #$20
        stz.w !ww+0,x
        sep #$10
        stz $318f
        stz $2225
        plb
        rtl
        
    .top_h:
        ldy #$0000
        rep #$20
        lda.b !gy
        cmp #$00e0
        bcs +
        tya
        bra ..draw
        +
        dec
        clc
        adc.b !bs
        bcs +
        sep #$20
        rts
        +
        sta.b !t1
        lda.b !bs
        clc
        sbc.b !t1
        sta.b !t1
        
        ..find:
            sep #$20
            stz.b !t0+1
            lda #$00
            -
            clc
            adc.b [!bp],y
            bcc +
            inc.b !t0+1
            +
            iny
            cpy.b !t1
            bcc -
            sta.b !t0+0
            rep #$20
            lda.b !t0
        
        ..draw:
            pha
            lda.b !gx
            clc
            adc.b !1r
            sec
            sbc $01,s
            sta.b !rl
            pla
            asl
            clc
            adc.b !rl
            dec
            sta.b !rr
            sep #$20
            lda #$01
            sta.b !rh
            -
            rep #$20
            lda.b [!bp],y
            and #$00ff
            sta.b !t1
            clc
            adc.b !rr
            sta.b !rr
            lda.b !rl
            sec
            sbc.b !t1
            sta.b !rl
            sep #$20
            jsr util_rect_2
            iny
            cpy.b !bs
            bcc -
            rts
            
    .bot_h:
        rep #$20
        lda.b !gy
        clc
        adc.b !2r
        sec
        sbc.b !bs
        cmp #$00e0
        bcs +
        lda.b !bs
        dec
        bra ..find
        +
        dec
        clc
        adc.b !bs
        bcs +
        sep #$20
        rts
        +
        
        ..find:
            sta.b !t1
            lda.b !bs
            tay
            
            sep #$20
            stz.b !t0+1
            lda #$00
            bra +
            
            -
            clc
            adc.b [!bp],y
            bcc +
            inc.b !t0+1
            +
            dey
            cpy.b !t1
            bne -
            
            sta.b !t0+0
            rep #$20
            lda.b !bs
            clc
            adc.b !bd
            clc
            adc.b !t0
            sta.b !t1
            clc
            adc.b !gx
            sta.b !rl
            
            lda.b !gx
            clc
            adc.b !2r
            clc
            sbc.b !t1
            sta.b !rr
            
            sep #$20
            lda #$01
            sta.b !rh
            
        ..draw:
            -
            jsr util_rect_2
            rep #$20
            lda.b [!bp],y
            and #$00ff
            sta.b !t1
            clc
            adc.b !rl
            sta.b !rl
            lda.b !rr
            sec
            sbc.b !t1
            sta.b !rr
            +
            sep #$20
            dey
            bpl -
            rts
        
    .top_v:
        rep #$20
        
        ; get full height
        lda.b !1r
        sec
        sbc.b !bd
        sec
        sbc.b !bs
        sta.b !t1
        
        ; get starting y pos
        lda.b !gy
        clc
        adc.b !bs
        clc
        adc.b !bd
        sta.b !t0
        
        ; test full offscreen
        cmp #$00e0
        bcc +
        dec
        clc
        adc.b !t1
        bcs +
        sep #$20
        rts
        +
        
        ; init edge left
        lda.b !bs
        dec
        tay
        sta.b !t1
        clc
        adc.b !gx
        sta.b !rl
        
        ; init edge right
        lda.b !2r
        clc
        adc.b !gx
        clc
        sbc.b !t1
        sta.b !rr
        
        ..draw:
            -
            lda.b [!bp],y
            and #$00ff
            pha
            sta.b !rh
            lda.b !t0
            cmp #$00e0
            bcc ...ok
            dec
            clc
            adc.b !rh
            bcc ...no
            inc
            sta.b !rh
            ...ok:
            sep #$20
            jsr util_rect_2
            rep #$20
            ...no:
            dec.b !rl
            inc.b !rr
            pla
            clc
            adc.b !t0
            sta.b !t0
            dey
            bpl -
            sep #$20
            rts
            
    .bot_v:
        rep #$20
        
        ; get full height
        lda.b !1r
        sec
        sbc.b !bd
        sec
        sbc.b !bs
        sta.b !t1
        
        ; get starting y pos
        lda.b !gy
        clc
        adc.b !1r
        sta.b !t0
        
        ; test full offscreen
        cmp #$00e0
        bcc +
        dec
        clc
        adc.b !t1
        bcs +
        sep #$20
        rts
        +
        
        ; init edges
        lda.b !gx
        sta.b !rl
        dec
        clc
        adc.b !2r
        sta.b !rr
        
        ..draw:
            ldy #$0000
            -
            lda.b [!bp],y
            and #$00ff
            pha
            sta.b !rh
            lda.b !t0
            cmp #$00e0
            bcc ...ok
            dec
            clc
            adc.b !rh
            bcc ...no
            inc
            sta.b !rh
            ...ok:
            sep #$20
            jsr util_rect_2
            rep #$20
            ...no:
            inc.b !rl
            dec.b !rr
            pla
            clc
            adc.b !t0
            sta.b !t0
            iny
            cpy.b !bs
            bcc -
            sep #$20
            rts
        
    .diag:
        rep #$20
        
        lda.b !bd
        sta.b !rh
        
        lda.b !gy
        bcs +
        clc
        adc.b !bs
        bra ++
        +
        clc
        adc.b !2r
        sec
        sbc.b !bs
        sec
        sbc.b !bd
        ++
        cmp #$00e0
        bcc ..draw
        dec
        clc
        adc.b !rh
        bcs +
        sep #$20
        rts
        +
        inc
        sta.b !rh
        
        ..draw:
            lda.b !gx
            clc
            adc.b !bs
            sta.b !rl
            lda.b !gx
            clc
            adc.b !2r
            clc
            sbc.b !bs
            sta.b !rr
            sep #$20
            jmp util_rect_2

namespace off
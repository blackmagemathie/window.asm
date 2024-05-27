namespace circle

from_bresenham:
    ; creates hdma table from octant.
    ; ----------------
    ; $3000 (2) -> radius, unsigned.
    ; [$3008]   -> octant data.
    ; $3002 (2) -> $0001 = ends on diagonal.
    ; $3004 (2) -> octant data size.
    ; $3100 (2) -> top left corner pos x.
    ; $3102 (2) ->                     y.
    ; carry     -> table to use. clear = 1; set = 2. (wip)
    ; ----------------
    !cx = $00
    !cy = $02
    !1r = $04
    !2r = $06
    !b  = $08
    
    lda.b #!window_page
    sta $318f
    sta $2225
    phb
    phk
    plb
    rep #$30
    lda #$3100
    tcd
    ldx.w #!window_index_1
    
    .test_bounds:
        lda $3000
        sta !1r
        asl
        sta !2r
        
        lda !cx
        cmp #$0100
        bcc +
        dec
        clc
        adc !2r
        bcs +
        jmp .clear
        +
        
        lda !cy
        cmp #$00e0
        bcc +
        dec
        clc
        adc !2r
        bcs +
        jmp .clear
        +
        
    .init_v:
        sep #$20
        
        lda $3008 : sta !b+0
        lda $3009 : sta !b+1
        lda $300a : sta !b+2
        
        lda !cy+1
        bne .find_v
        lda !cy+0
        bne +
        lda #$e0
        sta $300b
        jmp .draw_parts
        +
        cmp #$e0
        bcs .find_v
        cmp #$80
        beq +
        bcc +
        lda #$80
        sta.w !window_abs+0,x
        lda #$ff
        sta.w !window_abs+1,x
        stz.w !window_abs+2,x
        inx #3
        lda !cy+0
        and #$7f
        +
        sta.w !window_abs+0,x
        lda #$ff
        sta.w !window_abs+1,x
        stz.w !window_abs+2,x
        inx #3
        lda #$e0
        sec
        sbc !cy+0
        sta $300b
        jmp .draw_parts
        
    .find_v:
        bra .clear
        
    .draw_parts:
        ; if small, simplify drawing
        lda !1r+1
        bne +
        lda !1r+0
        cmp #$03
        bcs +
        asl
        sta !window_rect_height
        stz $3105
        rep #$20
        lda !cx
        sta !window_rect_edge_l_1_lo
        clc
        adc !window_rect_height
        dec
        sta !window_rect_edge_r_1_lo
        sep #$20
        jsr util_rect_2
        bra .clear
        +
        ; else, split into parts
        jsr .top_h
        lda $3002
        beq +
        jsr .diag
        +
        jsr .top_v
        
    .clear:
        sep #$20
        jsr util_clear_2
        
    .end:
        rep #$20
        lda #$3000
        tcd
        sep #$20
        stz.w !window_abs+0,x
        sep #$10
        stz $318f
        stz $2225
        plb
        rtl
        
    .top_h:
        ; seg values
        lda #$01
        sta !window_rect_height
        ldy #$0000
        lda [!b],y
        rep #$20
        and #$00ff
        pha
        lda !cx
        clc
        adc !1r
        sec
        sbc $01,s
        sta !window_rect_edge_l_1_lo
        pla
        asl
        clc
        adc !window_rect_edge_l_1_lo
        dec
        sta !window_rect_edge_r_1_lo
        ; loop counter
        lda $3004
        sec
        sbc $3002
        sta $3006
        ; loop
        sep #$20
        -
        jsr util_rect_2
        iny
        cpy $3006
        bcs ++
        lda [!b],y
        clc
        adc !window_rect_edge_r_1_lo
        sta !window_rect_edge_r_1_lo
        bcc +
        inc !window_rect_edge_r_1_hi
        +
        lda !window_rect_edge_l_1_lo
        sec
        sbc [!b],y
        sta !window_rect_edge_l_1_lo
        bcs +
        dec !window_rect_edge_l_1_hi
        +
        bra -
        ++
        rts
        
    .top_v:
        rep #$20
        lda $3004
        clc
        sbc $3002
        tay
        sta $3006
        clc
        adc !cx
        sta !window_rect_edge_l_1_lo
        lda !2r
        clc
        adc !cx
        clc
        sbc $3006
        sta !window_rect_edge_r_1_lo
        sep #$20
        -
        lda [!b],y
        sta !window_rect_height
        jsr util_rect_2
        dey
        bmi +
        rep #$20
        dec !window_rect_edge_l_1_lo
        inc !window_rect_edge_r_1_lo
        sep #$20
        bra -
        +
        rts
        
    .diag:
        rep #$20
        lda $3004
        dec
        tay
        clc
        adc !cx
        sta !window_rect_edge_l_1_lo
        lda !2r
        sec
        adc !cx
        clc
        sbc $3004
        sta !window_rect_edge_r_1_lo
        sep #$20
        lda [!b],y
        sta !window_rect_height
        jmp util_rect_2
        
    undef "cx"
    undef "cy"
    undef "1r"
    undef "2r"
    undef "b"

namespace off
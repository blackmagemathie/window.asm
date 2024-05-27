namespace util

rect_2:
    ; ----------------
    ; appends rect to window table.
    ; ----------------
    ; !window_rect_edge_l_1 (2) -> edge pos, left.
    ; !window_rect_edge_r_1 (2) ->           right.
    ; !window_rect_height (1)   -> height.
    ; ----------------
    lda !window_rect_height
    sta.w !window_abs+0,x
    
    lda !window_rect_edge_l_1_hi
    beq .some_in
    lda !window_rect_edge_r_1_hi
    beq .some_in
    rep #$20
    lda !window_rect_edge_l_1_lo
    cmp !window_rect_edge_r_1_lo
    sep #$20
    lda #$ff
    bcs .both_out
    
    .invalid:
        sta.w !window_abs+1,x
        stz.w !window_abs+2,x
        bra .end
        
    .both_out:
        sta.w !window_abs+2,x
        stz.w !window_abs+1,x
        bra .end
        
    .some_in:
        sep #$20
        ..left:
            lda !window_rect_edge_l_1_hi
            beq +
            lda #$00
            bra ++
            +
            lda !window_rect_edge_l_1_lo
            ++
            sta.w !window_abs+1,x
        ..right:
            lda !window_rect_edge_r_1_hi
            beq +
            lda #$ff
            bra ++
            +
            lda !window_rect_edge_r_1_lo
            ++
            sta.w !window_abs+2,x
            
    .end:
        inx #3
        rts
    
clear_2:
    ; ----------------
    ; ends window table.
    ; ----------------
    lda #$01
    sta.w !window_abs+0,x
    sta.w !window_abs+1,x
    stz.w !window_abs+2,x
    inx #3
    rts
    
namespace off
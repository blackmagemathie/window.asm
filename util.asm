namespace util

rect_2:
    ; ----------------
    ; appends rect to window table.
    ; ----------------
    ; !rl (2) -> edge pos, left.
    ; !rr (2) ->           right.
    ; !rh (1) -> height.
    ; ----------------
    lda.b !rh
    sta.w !ww+0,x
    
    lda.b !rl+1
    beq .some_in
    lda.b !rr+1
    beq .some_in
    rep #$20
    lda.b !rl+0
    cmp.b !rr+0
    sep #$20
    lda #$ff
    bcs .both_out
    
    .invalid:
        sta.w !ww+1,x
        stz.w !ww+2,x
        bra .end
        
    .both_out:
        sta.w !ww+2,x
        stz.w !ww+1,x
        bra .end
        
    .some_in:
        sep #$20
        ..left:
            lda.b !rl+1
            beq +
            lda #$00
            bra ++
            +
            lda.b !rl+0
            ++
            sta.w !ww+1,x
        ..right:
            lda.b !rr+1
            beq +
            lda #$ff
            bra ++
            +
            lda.b !rr+0
            ++
            sta.w !ww+2,x
            
    .end:
        inx #3
        rts
    
clear_2:
    ; ----------------
    ; ends window table.
    ; ----------------
    lda #$01
    sta.w !ww+0,x
    sta.w !ww+1,x
    stz.w !ww+2,x
    inx #3
    rts
    
namespace off
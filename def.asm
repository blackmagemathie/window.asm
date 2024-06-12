; tables
    !window_data = $40aa80 ; ($580 bytes)
    !window_page = (!window_data&$01e000)/$2000
    !window_abs  = $6000+(!window_data&$001fff)
    !window_index_1 = $0000
    !window_index_2 = $02c0
    
; rect
    !rh = $313e
    !rl = $313c
    !rr = $313a
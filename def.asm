; tables
    !window_data = $40aa80 ; ($580 bytes)
    !window_page = (!window_data&$01e000)/$2000
    !window_abs  = $6000+(!window_data&$001fff)
    !window_index_1 = $0000
    !window_index_2 = $02c0
    
; rect
    !window_rect_height      = $3136
    !window_rect_edge_l_1_lo = $3138
    !window_rect_edge_l_1_hi = $3139
    !window_rect_edge_l_2_lo = $313a
    !window_rect_edge_l_2_hi = $313b
    !window_rect_edge_r_1_lo = $313c
    !window_rect_edge_r_1_hi = $313d
    !window_rect_edge_r_2_lo = $313e
    !window_rect_edge_r_2_hi = $313f
    
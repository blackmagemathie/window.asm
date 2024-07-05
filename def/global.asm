; tables
    !window_data = $40aa00 ; ($600 bytes)
    !window_page = (!window_data&$01e000)/$2000
    !window_abs  = $6000+(!window_data&$001fff)
    !window_index_1 = $0000
    !window_index_2 = $0300
    
; global
    !window_table_index = $3138
    !window_pos_y = $3136
    !window_pos_x = $3134
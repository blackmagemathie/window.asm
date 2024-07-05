from PIL import Image

def indent(n:int=0):
    return " "*4*n

if __name__ == "__main__":
    
    print("image path >",end=" ")
    pic_path = input()
    pic = Image.open(pic_path)
    pic_w,pic_h = pic.size
    if pic.mode!="P" or pic.palette.mode!="RGB" or len(pic.getpalette())/3!=2:
        raise Exception("invalid image format.")
    
    print("frame width ["+str(pic_w)+"] >",end=" ")
    frame_w = int(input() or str(pic_w))
    if pic_w%frame_w!=0 :
        raise Exception("invalid frame width")
    frame_q_x = pic_w//frame_w
    
    print("frame height ["+str(pic_h)+"] >",end=" ")
    frame_h = int(input() or str(pic_h))
    if pic_h%frame_h!=0 :
        raise Exception("invalid frame height")
    frame_q_y = pic_h//frame_h
    
    print("window quantity [1] >",end=" ")
    option_window_q = int(input() or "1")
    if option_window_q<1 or option_window_q>2:
        raise Exception("invalid window quantity")
    
    option_merge_lines = True
    option_format_mode = "hdma"
    
    frame_q = frame_q_x*frame_q_y
    data = []
    
    for frame_id in range(0,frame_q):
        
        frame_pos_x = (frame_id%frame_q_x)*frame_w
        frame_pos_y = (frame_id//frame_q_x)*frame_h
        frame_edge = []
        
        for line in range(0,frame_h):
            
            color_prev = 0
            edge_i = 0
            edge = [0xff,0]*option_window_q
            edge_len = len(edge)
            
            for col in range(0,frame_w):
                
                sub_pos_x = frame_pos_x+col
                sub_pos_y = frame_pos_y+line
                color = pic.getpixel((sub_pos_x,sub_pos_y))
                if color!=color_prev:
                    if edge_i>=edge_len:
                        raise Exception("too many edges (frame #"+str(frame_id)+", x="+str(sub_pos_x)+", y="+str(sub_pos_y)+")")
                    edge[edge_i] = col-(edge_i%2)
                    edge_i+=1
                color_prev=color
            
            # finish odd edges
            if edge_i%2!=0:
                edge[edge_i] = frame_w-1
            
            if option_merge_lines and line>0 and frame_edge[-1][0]<0x80 and (frame_edge[-1][1:]==edge):
                frame_edge[-1][0] += 1
            else:
                frame_edge.append([1]+edge)
        
        data.append(frame_edge)
    
    with open("output.asm","w") as f:
        
        # header
        f.write("; total frames : ${:02x}\n".format(frame_q))
        f.write("; frame width  : ${:04x}\n".format(frame_w))
        f.write("; frame height : ${:04x}\n".format(frame_h))
        f.write("\n")
        
        # frame pointers
        f.write("frame_pointer:\n")
        for frame_id in range(0,len(data)):
            f.write(indent(1)+"dw frame_{:02x}\n".format(frame_id))
        f.write("\n")
        
        # frame size
        f.write("frame_size:\n")
        for frame_id in range(0,len(data)):
            f.write(indent(1)+"dw {:04x}\n".format(len(data[frame_id])))
        f.write("\n")
        
        # frame data
        for frame_id in range(0,len(data)):
            f.write("frame_{:02x}:\n".format(frame_id))
            
            match option_format_mode:
                case "hdma":
                    for rect in data[frame_id]:
                        f.write(indent(1)+"db "+",".join("${:02x}".format(v) for v in rect)+"\n")
                    f.write(indent(1)+"db $00\n\n")
                case _:
                    raise Exception("invalid output format")
        
    print("processed "+str(frame_q)+" frames.")
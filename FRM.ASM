.model tiny
.code
locals $$
org 100h

;===========================================
; Exit Program
;===========================================
; Entry:     None
; Exit:      None
; Expects:   None
; Destroys:  AX
;===========================================
EXIT macro
     nop
                
     mov ax, 4c00h ; exit (0)
     int 21h
                
     nop
     endm
;===========================================


;===========================================
; Clear video memory
;===========================================
; Entry:     None
; Exit:      None
; Expects:   None
; Destroys:  None
;===========================================
CLEAR_VIDEO macro
            nop
                 
	    push bx cx
            
	    mov  bx, 0b800h                      
	    mov  es, bx                                                   

	    mov  cx, 2001
	    $$clear_byte: mov bx, cx
			  add bx, bx
                        
			  mov byte ptr es:[bx], 20h
			  loop $$clear_byte
	     pop bx cx
            
	     nop
	     endm
;===========================================


;===========================================
; Recording to video memory
;===========================================
; Entry:     None
; Exit:      SI = SI + 1
; Expects:   ES = 0b800h
;            BL = symbol
;            AH = color
; Destroys:  None
;===========================================
REC_VIDEO macro
          nop
	  
	  mov byte ptr es:[si], bl
	  inc si
	  mov byte ptr es:[si], ah
	  
	  nop
	  endm
;===========================================


Start:  push 40  ; x
        push 7   ; y
        push 10   ; height
        push 4eh ; color
        push 1   ; style
        
        call draw_frame

        EXIT

	
;============================================
; Draw frame 
;============================================
; Entry:     p1 = X-COORDINATE upper left corner
;	     p2 = Y-COORDINATE upper left corner
;            p3 = HEIGTH frame
;            p4 = COLOR  frame
;            p6 = STYLE  frame
; Exit:      None
; Expects:   Screen size equals 25*80
;            ES = 0b800h
;            There is the mass "frame_styles"
;            There is the mass "message"
; Destroys:  AX, BX, CX, SI, DI, BP
;============================================
draw_frame  proc
            CLEAR_VIDEO  
            
            push bp               
            mov  bp, sp
	    
	    mov si, [bp + 4] ; si = style
	    cmp si, 3
	    je  $$call_user_style
	    jmp $$not_user_style
	    
	    $$call_user_style: call user_style
	    $$not_user_style:  call scanf_msg
	                       lea bx, message
			       call strlen
			       add cx, 4 ; cx = width
			       
	    mov bh, [bp + 10] ; bh = y
            mov bl, [bp + 12] ; bl = x
	    
            call calc_crd    
	    
	    mov  ax, 0
	    call draw_corner ; Draw upper left corner
	
            push cx
            sub  cx, 2   
            add  bx, cx
            add  bx, cx 
            mov  ax, 1
	    mov  di, 3
	    call draw_line ; Draw heigth line
	    pop  cx
 
            push cx
            sub  cx, 1  
            add  bx, cx
            add  bx, cx   
	    mov  ax, 2 
	    call draw_corner ; Draw upper rigth corner

            mov  cx, [bp + 8] ; cx = height
            sub  cx, 2 
            add  bx, 160
	    mov  ax, 5 
	    mov  di, 159  
	    call draw_line ; Draw rigth line

	    mov  ax, 8
	    call draw_corner ; Draw lower rigth corner
	    pop cx
	    
            push cx
            sub  cx, 2      
            sub  bx, 2  
	    mov  ax, 7
	    mov  di, 3  
	    call draw_line ; Draw lower line
            
	    mov  ax, 6 
	    call draw_corner ; Draw lower left corner

	    sub  bx, 160
            mov  cx, [bp + 8] ; cx = height
            sub  cx, 2  
	    mov  ax, 3
	    mov  di, 161
	    call draw_line ; Draw left line
	    pop cx
	    ;===============================
	    ; Draw inside frame
	    ;===============================
	    add  bx, 160
            mov  di, [bp + 8]  ; di = height
            push cx
            
            sub di, 2
            sub cx, 2
            add bx, 2
	    
	    mov  ax, 4
	    
	    mov  si, [bp + 4] ; si = style  
	    call style_elem    
	    mov  ah, [bp + 6] ; ah = color
            
            $$draw_inside:       cmp di, 0
                                 jne $$draw_line_inside
                                 jmp $$end_draw_inside
                           
            $$draw_inside_after: dec di
                                 add si, 160
                                 pop cx
				 push cx
                                 sub cx, 2
                                 sub si, cx
                                 sub si, cx
                                 
                                 jmp $$draw_inside
                                             
            $$draw_line_inside:  REC_VIDEO
                                 inc si
                         
                                 loop $$draw_line_inside
                                 jmp  $$draw_inside_after
            
            $$end_draw_inside:
	    pop cx	    
            ;===============================
	    mov bh, [bp + 10] ; bh = y
            mov bl, [bp + 12] ; bl = x
	    mov al, [bp + 8]  ; al = heigth
	    
            call video_prnt_msg
	    
            ret
draw_frame  endp
;============================================


;============================================
; Draw line
;============================================
; Entry:     
; Exit:      
; Expects:   
; Destroys: 
;============================================
draw_line proc 
          mov  si, [bp + 4] ; si = style
	  call style_elem  
	  mov  dx, ax
	  mov  ah, [bp + 6] ; ah = color
	    
	  $$draw_line: REC_VIDEO                
		       cmp dx, 5
		       je  $$add_si
		       jmp $$sub_si
		       
		       $$add_si:         add  si, di
		                         jmp  $$end_add_or_sub
	               $$sub_si:         sub  si, di
		       $$end_add_or_sub: loop $$draw_line
	
	  mov bx, si
          ret
draw_line endp
;============================================


;============================================
; Draw corner
;============================================
; Entry:     None
; Exit:      None
; Expects:   None
; Destroys:  None
;============================================
draw_corner proc 
            mov  si, [bp + 4] ; si = style
	    call style_elem 	    
	    mov  ah, [bp + 6] ; ah = color
	    
            REC_VIDEO
	    
            dec si 
	    mov bx, si
            ret
draw_corner endp
;============================================

;============================================
; Calculate screen coordinates
;============================================
; Entry:     BH = Y, BL = X
; Exit:      BX = screen coordinates
; Expects:   None
; Destroys:  None
;============================================
calc_crd proc 
         push ax
	 
	 mov al, bh              
	 mov ah, 00h            
	 mov bh, 80d
	 mul bh                  ; a = 80*a (symbol in string)
	 mov bh, 00h             ; bh = null
	 add bx, ax
	 shl bx, 1               ; bx = 2*bx (x = 2*x)
         
         pop ax
         ret
calc_crd endp
;============================================

include style.asm
include msg.asm
include str.asm
include math.asm

frame_styles      db 0Dah, 0C4h, 0Bfh ;== style 0 ==;
	          db 0B3h, 020h, 0B3h ;    line     ;
	          db 0C0h, 0C4h, 0D9h ;=============;

	          db 03h, 03h,  03h   ;== style 1 ==;
	          db 03h, 020h, 03h   ;    heart    ;
	          db 03h, 03h,  03h   ;=============;
		
	          db 0C9h, 0CDh, 0BBh ;== style 2 ==;
	          db 0BAh, 020h, 0BAh ; double line ;
	          db 0C8h, 0CDh, 0BCh ;=============;
	     
		  db 9 dup ('$')      ; memory for user style (style 3)
	     
consol_prnt_msg   db "Enter text for the frame: $"
message           db 100 dup ('$')  ; message for frame

consol_prnt_style db "Enter frame style: $"
user_style_var    db 10 dup ('$')
		
end Start
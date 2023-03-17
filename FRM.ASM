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
                
     mov ax, 4c00h ; exit (0)
     int 21h
                
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
                 
	        push bx cx
            
	    	mov  bx, 0b800h                      
	    	mov  es, bx                                                   

	    	mov  cx, 2001
	    	$$clear_byte: 	mov bx, cx
			  		  		add bx, bx
                        
			          		mov byte ptr es:[bx], 20h
							inc bx
							mov byte ptr es:[bx], 07h
			          		loop $$clear_byte
	     	pop bx cx
            
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
REC_VIDEO 	macro
	  
	      	mov byte ptr es:[si], bl
	      	inc si
	      	mov byte ptr es:[si], ah

	      	endm
;===========================================


Start:	push 30  ; x
        push 7   ; y
        push 10  ; height
        push 4fh ; color
        push 2   ; style  
        
        call draw_frame

        EXIT

;============================================
; Draw frame 
;============================================
; Entry:     p1 = X-COORDINATE upper left corner
;	         p2 = Y-COORDINATE upper left corner
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
	    
	    	$$call_user_style: 	call user_style
	    	$$not_user_style:  	call scanf_msg
	                       		lea  bx, message
			       				call strlen
			       				add  cx, 4 ; cx = width
			       
	   		mov bh, [bp + 10] ; bh = y
            mov bl, [bp + 12] ; bl = x
	    
            call calc_crd ; bx = begin coordinate	       
		    ;=================================		
			mov di, bx ; di = begin coordinate

			mov si, [bp + 4]; si = style
			call style_pointer

			mov bx, cx ; bx = width
			mov cx, 1

			call draw_line
            ;=================================
			mov si, [bp + 4]; si = style
			call style_pointer
			add si, 3

			mov cx, [bp + 8]
			sub cx, 2

			call draw_line
			;=================================
			mov si, [bp + 4]; si = style
			call style_pointer
			add si, 6

			mov cx, 1

			call draw_line
			;=================================
	    	mov bh, [bp + 10] ; bh = y
            mov bl, [bp + 12] ; bl = x
	    	mov al, [bp + 8]  ; al = heigth
	    
            call video_prnt_msg
	    
	    	pop bp
            ret
draw_frame  endp
;============================================


;============================================
; Draw line (left, middle, rigth symbol)
;============================================
; Entry:    BX = width
;           CX = number of line
;           SI = number first element 
;           DI = begin coordinate
; Exit:     DI = new begin coordinate
; Expects:  ES = 0b800h  
; Destroys: CX, SI
;============================================
draw_line	proc
            push bx

			sub bx, 2  ; bx = width - 2
            mov ax, offset frame_styles
			add si, ax ; pointer to style first symbol - corner

$$draw_all: push bx si 

			lodsb           ;<-- draw left corner
			stosb           ;
							;
            mov al, [bp + 6];
			stosb		;<--;

			$$draw_line: 	push si				;<-- draw line
			                lodsb				;
			             	stosb           	;
					        pop  si				;
												;
                        	mov al, [bp + 6]    ;
			            	stosb				;
												;
						    dec bx				;
							cmp bx, 0			;
							jne $$draw_line ;<--;

            inc si          ;<-- draw rigth corner
			lodsb           ;
			stosb           ;
							;
            mov al, [bp + 6];
			stosb		;<--;

            pop si bx
			
			add di, 156  ;<--;
			sub di, bx       ;
			sub di, bx       ;<-- new line on video memory

loop $$draw_all	

            pop bx
			ret
draw_line   endp 
;============================================


;============================================
; Calculate screen coordinates
;============================================
; Entry:     BH = Y, BL = X
; Exit:      BX = screen coordinates
; Expects:   None
; Destroys:  None
;============================================
calc_crd 	proc 
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
calc_crd 	endp
;============================================

include style.asm
include msg.asm
include str.asm
include math.asm

;============================================

frame_styles  	db 0Dah, 0C4h, 0Bfh ;== style 0 ==;
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
user_style_var    db 10 dup ('$')   ; variable for return hex numbers in a string

;============================================

end Start
;============================================
; Style pointer
;============================================
; Entry:     SI = style frame
; Exit:      SI = style pointer
; Expects:   None
; Destroys:  None
;============================================
style_pointer   proc 
	      		push ax
	      
	      		mov  ax, 9  ;==================;
	      		mul  si     ;   si = 9*style   ;
              	mov  si, ax ;==================;
	      
	      		pop  ax
              	ret
style_pointer 	endp
;============================================


;============================================
; Style element
;============================================
; Entry:     AX = element number whose style is needed
;            SI = style frame
; Exit:      SI = old BX
;            BX = style element
; Expects:   There is the mass "frame_styles"
; Destroys:  None
;============================================
style_elem 	proc
	   		push bx
	   
	   		call style_pointer
	   
	   		mov bx, si
	   		add bx, ax   
	   		lea bx, frame_styles + bx ; bx = frame_styles + bx ;
	   		mov bx, [bx]              ; bx = value in bx       ;
	   
	   		pop si ; si = old bx         
	   		ret
style_elem 	endp
;============================================


;============================================
; User frame style
;============================================
; Entry:     SI = begin adress for reading user style
; Exit:      
; Expects:   There is the mass "frame_styles"
;            There is the mass "consol_prnt"
;            There is the mass "user_style_var"
; Destroys:  AX, BX, DX, SI
;============================================
user_style 	proc
		    
			push si
			mov si, 3
           	call style_pointer ; si = style_pointer
			mov di, si
			pop si
	   
	   		mov cx, 9
	   		$$element_frame_prnt:   call scanf_hex
				 					mov  frame_styles + di, bl									
									add  di, 1
				 					loop $$element_frame_prnt
           	ret
user_style 	endp
;============================================

;============================================
; Scanf, while did not enter a space or enter
;============================================
; Entry:     None
; Exit:      BX = hex value
; Expects:   SI = begin adress for reading user style
; Destroys:  None
;============================================
scanf_hex 	proc
			push ax

            xor bx, bx

      	    $$scanf_hex: 	xor ax, ax
	                     	lodsb
						
	       				 	cmp al, 2Ch
	       				 	je  $$end_scanf

						 	cmp al, 68h
						 	je  $$scanf_hex

						 	STR_SYMBOL_TO_HEX
						
	       				 	push ax

                		 	mov ax, bx  ;<--;
                		 	mov bl, 16d     ;
                		 	mul bl          ;<-- ax = 16*ax
                		 	mov bx, ax

                		 	pop ax
                		 	add bx, ax
						 
	       				 	jmp $$scanf_hex			
			$$end_scanf: 
			
			pop ax
			ret
scanf_hex 	endp
;============================================  

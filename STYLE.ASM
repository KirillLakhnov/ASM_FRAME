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
; Entry:     SI = style frame
; Exit:      
; Expects:   There is the mass "frame_styles"
;            There is the mass "consol_prnt"
;            There is the mass "user_style_var"
; Destroys:  AX, BX, DX, SI
;============================================
user_style 	proc

           	mov ah, 09h
	   		mov dx, offset consol_prnt_style
	   		int 21h
		
           	call style_pointer ; si = style_pointer
	   
	   		mov cx, 9
	   		$$element_frame_prnt: 	lea  bx, user_style_var
	                         		call scanf
				 					lea  bx, user_style_var
				 					call string_to_hex
				 					mov  frame_styles + si, al
				 					inc  si
				 					loop $$element_frame_prnt
				 
           	ret
user_style 	endp
;============================================

;============================================
; Scanf, while did not enter a space or enter
;============================================
; Entry:     BX = pointer to string
; Exit:      None
; Expects:   None
; Destroys:  AX
;============================================
scanf 	proc
      	$$scanf: 	mov ah, 01h
               		int 21h
	      
	       			cmp al, 0dh
	       			je  $$end_scanf     
	       			cmp al, 20h
	       			je  $$end_scanf
	      
	       			mov [bx], al
	       			inc bx
	       			jmp $$scanf
       
      	$$end_scanf: ret
scanf 	endp
;============================================ 


;============================================
; Сonverts the hex number written in the string to a number
;============================================
; Entry:     BX = pointer to string
; Exit:      AL = hex number
; Expects:   None
; Destroys:  None
;============================================
string_to_hex 	proc
              	push cx si bx
	      
	      		mov cx, 0
	      		mov ax, 0
              	$$loop_string_to_hex: 	push bx	                     
	                            		mov bx, [bx]				    
				    					xor bh, bh
				    
				    					cmp bl, 68h
				    					je $$end_loop
				    
	                            		cmp bl, 39h
				    					jle $$if_bx_jle_39h
				    					jmp $$else_bx_jle_39h 
	      
	      		$$if_bx_jle_39h: 		sub bl, 30h
				    					jmp $$end_if_bx_jle_39h
                                              
	      		$$else_bx_jle_39h:    	sub bl, 37h
				    					jmp $$end_if_bx_jle_39h
                                              
	      		$$end_if_bx_jle_39h: 
	      
	     		mov  si, 16 ; si = 16
	      		call pow    ; si = 16^cx	      
	      		mul  si     ; ax = ax*(16^cx)
	      		add  ax, bx ; ax = bx + ax*(16^cx) 
	      
	      		pop bx
	      		inc bx
	      		inc cx
	      		jmp $$loop_string_to_hex
	      
	      		$$end_loop: pop bx
	      
	      		pop bx si cx	      
              	ret
string_to_hex 	endp
;============================================ 

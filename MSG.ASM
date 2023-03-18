;============================================
; Scanf message for frame
;============================================
; Entry:     None
; Exit:      None
; Expects:   There is the mass "message"
;            SI =  begin adress for message from cmd line
; Destroys:  None
;============================================
scanf_msg 	proc
          	push ax bx dx
	  
	        xor ax, ax
	        lodsb
			cmp al, 27h
			jne $$end_scanf_msg

	  		lea bx, message

	  		$$scanf_msg: 	xor ax, ax
	                        lodsb
							cmp al, 27h
	               			je  $$end_scanf_msg
	       
	               			mov [bx], al
	               			inc bx
	               			jmp $$scanf_msg
       
          	$$end_scanf_msg: 

	  		pop dx bx ax
	  
	  		ret
scanf_msg 	endp
;============================================


;============================================
; Print message to video memory
;============================================
; Entry:     BH = Y, BL = X
;            AL = height
;            AH = color
; Exit:      None
; Expects:   There is the mass "message"
;            ES = 0b800h
; Destroys:  BX
;============================================
video_prnt_msg 	proc
               	push bx  
               	lea  bx, message	       
	       		call strlen
	       		pop  bx
	       
	       		call call_cord_msg
	       
	       		mov si, bx ; si = begin massege coordinate
	       		lea bx, message
	       
	       		$$video_prnt_msg_loop: 	push bx
	       
	                              		mov bx, [bx]

										cmp bl, 5Ch
										je $$is_it_new_line_msg

				$$after_check_new_line: cmp bl, 24h
				      					je $$end_video_prnt_msg_loop
				                        
				      					mov byte ptr es:[si], bl
										inc si
										mov byte ptr es:[si], ah
				      					inc si
				      
				      					pop bx
				      					inc bx 
				      					jmp $$video_prnt_msg_loop

	       		$$is_it_new_line_msg:   pop bx
				                        inc bx
										push bx
										mov bx, [bx]
										cmp bl, 6eh
										je $$new_line_msg

				$$is_it_new_color:      pop bx
				                        call is_new_color
										cmp al, 0
										je  $$old_color
										jmp $$new_color

				$$old_color:			dec bx
										push bx
										mov bx, [bx]
										jmp $$after_check_new_line

				$$new_color:		    jmp $$video_prnt_msg_loop

				$$new_line_msg:         add si, 160
										pop bx
										inc bx
										jmp $$video_prnt_msg_loop

	       		$$end_video_prnt_msg_loop: pop bx 
               	ret
video_prnt_msg 	endp
;============================================


;============================================
; Is it new color message
;============================================
; Entry:     BX = pointer to message
; Exit:      AL = 1 => new color    and AH = new color
;            AL = 0 => no new color and AH = old color
; Expects:   
; Destroys:  
;============================================
is_new_color proc
			 add bx, 2
			 push bx
			 mov bx, [bx]
			 cmp bl, 2Fh
			 jne $$it_is_not_new_color
			 jmp $$it_is_new_color

			 $$it_is_new_color:		pop  bx
			 						sub  bx, 2
									push bx
									
									xor dx, dx
									xor ax, ax
									mov cx, 2
						
			 $$loop_new_color:		mov al, [bx]
									STR_SYMBOL_TO_HEX

									push ax

                		 			mov ax, dx  ;<--;
                		 			mov dl, 16d     ;
                		 			mul dl         ;<-- ax = 16*ax
                		 			mov dx, ax

                		 			pop ax
									add dx, ax

									pop  bx
									inc  bx
									push bx

									loop $$loop_new_color

                                    pop bx
									inc bx
									mov ah, dl
			 						mov al, 1
			 						jmp $$end_is_new_color						

			 $$it_is_not_new_color: mov al, 0
									pop bx
									sub bx, 2

			 $$end_is_new_color:    ret
			 

is_new_color endp
;============================================

;============================================
; Calculate begin message recording to video
;============================================
; Entry:     BH = Y, BL = X
;            AL = height
; Exit:      BX = coordinate begin msg
; Expects:   None
; Destroys:  CX, DX, SI
;============================================
call_cord_msg 	proc 
	            push ax

              	call calc_crd
	      
	      		sub al, 2
	      		xor ah, ah
	      		mov cx, 80
	      		mul cx
	      		add bx, ax
	      
	      		add bx, 3
	
	      		mov si, bx ; si = coordinate begin msg
	      		mov ax, bx ; ax = coordinate begin msg
	      		mov bx, 2  
	      		div bx     ; ax = ax/2
	      		cmp dx, 1  ; compare the remainder of the division with 1
	      
	      		je  $$plus_coord_msg
	      		jmp $$not_plus_coord_msg
	      
	      		$$plus_coord_msg:     	inc si     ; si = si + 1
	      		$$not_plus_coord_msg: 	mov bx, si ; bx = new coordinate begin msg
	         
			    pop ax
              	ret
call_cord_msg 	endp
;============================================
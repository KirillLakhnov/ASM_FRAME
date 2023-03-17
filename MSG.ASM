;============================================
; Scanf message for frame
;============================================
; Entry:     None
; Exit:      None
; Expects:   There is the mass "message"
; Destroys:  None
;============================================
scanf_msg proc
          push ax bx dx

          mov ah, 09h
	  mov dx, offset consol_prnt_msg
	  int 21h
	  
	  lea bx, message
	  $$scanf_msg: mov ah, 01h
                       int 21h
	      
	               cmp al, 0dh
	               je  $$end_scanf_msg
	       
	               mov [bx], al
	               inc bx
	               jmp $$scanf_msg
       
          $$end_scanf_msg:	
	  
	  pop dx bx ax
	  
	  ret
scanf_msg endp
;============================================


;============================================
; Print message to video memory
;============================================
; Entry:     BH = Y, BL = X
;            AL = height
; Exit:      None
; Expects:   There is the mass "message"
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
				      					cmp bl, 24h
				      					je $$end_video_prnt_msg_loop
				      
				      					mov byte ptr es:[si], bl
				      					add si, 2
				      
				      					pop bx
				      					add bx, 1
				      					jmp $$video_prnt_msg_loop
	       
	       		$$end_video_prnt_msg_loop: pop bx 
               	ret
video_prnt_msg 	endp
;============================================


;============================================
; Calculate begin massege recording to video
;============================================
; Entry:     BH = Y, BL = X
;            AL = height
; Exit:      BX = coordinate begin msg
; Expects:   None
; Destroys:  AX, CX, DX, SI
;============================================
call_cord_msg 	proc 
	    
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
	         
              	ret
call_cord_msg 	endp
;============================================
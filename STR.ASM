;============================================
; String length
;============================================
; Entry:     BX = pointer to begin string
; Exit:      CX = string length
; Expects:   None
; Destroys:  BX
;============================================
strlen proc
       mov cx, 0
       
       $$strlen_loop: push bx
       
                      mov bx, [bx]
		      
		      cmp bl, 24h
		      je  $$end_strlen_loop
		      
                      inc cx
                      pop bx
		      inc bx
		      
		      jmp $$strlen_loop
		      
		      
       $$end_strlen_loop: pop bx
       
       ret
strlen endp
;============================================


;===========================================
; String compare
;===========================================
; Entry:     BX = pointer to begin 1th string
;            SI = pointer to begin 2th string
; Exit:      CL = rezult of compare 
;            (1th string == 2th string, if cx == 0)
; Expects:   None
; Destroys:  SI, BX
;===========================================
strcmp proc

       dec  bx
       dec  si
       push bx si
       $$strcmp_loop: pop  si bx
                      inc  bx
		      inc  si
                      push bx si
                      
                      mov bx, [bx]
		      mov cx, [si]
		      
		      cmp cl, 24h
		      je $$end_strcmp_loop
		      
		      cmp bl, 24h
		      je $$end_strcmp_loop
		      
		      cmp bl, cl
		      je  $$strcmp_loop
		      jmp $$end_strcmp_loop
		      
       $$end_strcmp_loop: sub cl, bl
       
       pop si bx
       
       ret
strcmp endp
;===========================================
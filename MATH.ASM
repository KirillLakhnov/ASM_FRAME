;============================================ 
; Pow
;============================================ 
; Entry:     SI = foundation
;            CX = index
; Exit:      SI = rezult
; Expects:   None
; Destroys:  None
;============================================
pow proc
    push cx ax
    
    cmp cx, 0
    je  $$pow_loop_exception
    
    cmp cx, 1
    je  $$end_pow_loop
    
    dec cx
    
    $$pow_loop: mov ax, si
                mul si
		mov si, ax
		
		loop $$pow_loop
		jmp  $$end_pow_loop
    
    $$pow_loop_exception: mov si, 1
    
    $$end_pow_loop:
    
    pop ax cx  
    ret
pow endp
;============================================

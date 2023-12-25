global Sharpen_asm

pixel_negro dd 0xff000000, 0xff000000
pixel_color dd 0xff000000, 0x00000000
mul_neg dq 0x0001000100010001, 0x0001000100010001
val_9 dq 0x0009000900090009, 0x0009000900090009

;void Sharpen_c(uint8_t *src, uint8_t *dst, int width, int height,
;    int src_row_size,
;    int dst_row_size)
; rdi <- src, rsi <- dst,
; rdx <- width, rcx <- height,
; r8 <- src_row_size, byte
; r9 <- dst_row_size  byte para que??????
Sharpen_asm:

; matriz de sharpen preseteada
; Los 2 pixeles son traidos extendidos
; trabajamos con 2 pixeles para no perder precision en la multiplicacion
; Para alojarlos en destino, lo compactamos saturados
	push rbp
	mov rbp, rsp
	push r15
    push r14
    push r13
    push r12
    mov r15, rsi
    mov r14, rdi
    mov r13, rdx
	mov rax, rdx
    mov r12, rcx
    ; r15 <- dst
    ; r14 <- src
    ; r13 <- src_row_size
    ; r12 <- height

    ; pixel negro
    movq xmm8, [pixel_negro] ; parte baja
    movlhps xmm8, xmm8 

	; borde superior
    ; cuantos pixeles escribimos
    mov rcx, rdx  ; rcx = width 
    shr rcx, 2    ; div por 4 = 1(filas) / 4(pixels)
    .borde_sup:
        movdqu [rsi], xmm8
        add rsi, 16
    loop .borde_sup

	;mov [rsi], dword 0xff000000
	;add rsi, 4 ; destination en el [1][1]


	;topes
	mov rcx, r12
	sub rcx, 2  ; cantidad de iteraciones de .fila
	shr r13, 1
	sub r13, 1
	mov rdx, r13
	;mov rdx, rdi 
	;add rdx, r8
	;sub rdx, 12 ; cantidad de iteraciones de .columna ?

	pcmpeqd xmm1, xmm1 ; xmm register con todos 1s
	movdqu xmm9, [val_9]
	pxor xmm7, xmm7


	.fila:
		mov [rsi], dword 0xff000000
		add rsi, 4 
		.columna:
			pxor xmm0, xmm0 ; result

			;pmovzxbw xmm2, [rdi] ; me traigo 2 pixeles extendido a 128
			; 1ra Fila Matriz:
 			movdqu xmm4, [rdi]		; 4 Pixels
			movdqa xmm3, xmm4
			punpcklbw xmm3, xmm7	; Pixel 1,0
			;pmovzxbw xmm3, xmm4
			punpckhbw xmm4, xmm7	; Pixel 3,2

			movdqa xmm5, xmm3
			psrldq xmm5, 8
			movdqa xmm6, xmm4
			pslldq xmm6, 8
			por xmm5, xmm6			; Pixel 2,1
			

			;pxor xmm2, xmm1 ;niego
			;paddw xmm2, [mul_neg]

			;niego
			vpsignw xmm3, xmm1		; neg Pixel 1,0
			vpsignw xmm4, xmm1		; neg Pixel 3,2
			vpsignw xmm5, xmm1		; neg Pixel 2,1

			; sumo a result
			paddw xmm0, xmm3	; sum Pixel 1,0
			paddw xmm0, xmm4	; sum Pixel 3,2
			paddw xmm0, xmm5	; sum Pixel 2,1
			

			; 2da Fila Matriz:
 			movdqu xmm4, [rdi+r8]		; 4 Pixels Fila siguiente 
			movdqa xmm3, xmm4
			punpcklbw xmm3, xmm7	; Pixel 1,0
			;pmovzxbw xmm3, xmm4
			punpckhbw xmm4, xmm7	; Pixel 3,2

			movdqa xmm5, xmm3
			psrldq xmm5, 8
			movdqa xmm6, xmm4
			pslldq xmm6, 8
			por xmm5, xmm6			; Pixel 2,1

			;niego
			vpsignw xmm3, xmm1		; neg Pixel 1,0
			vpsignw xmm4, xmm1		; neg Pixel 3,2

			; multiplico por 9
			pmullw xmm5,xmm9 		; mul 9 Pixel 2,1

			; sumo a result
			paddw xmm0, xmm3	; sum Pixel 1,0
			paddw xmm0, xmm4	; sum Pixel 3,2
			paddw xmm0, xmm5	; sum Pixel 2,1

			; 3ra Fila Matriz:
 			movdqu xmm4, [rdi+2*r8]; 4 Pixels
			movdqa xmm3, xmm4
			punpcklbw xmm3, xmm7	; Pixel 1,0
			;pmovzxbw xmm3, xmm4
			punpckhbw xmm4, xmm7	; Pixel 3,2

			movdqa xmm5, xmm3
			psrldq xmm5, 8
			movdqa xmm6, xmm4
			pslldq xmm6, 8
			por xmm5, xmm6			; Pixel 2,1
			

			;pxor xmm2, xmm1 ;niego
			;paddw xmm2, [mul_neg]

			;niego
			vpsignw xmm3, xmm1		; neg Pixel 1,0
			vpsignw xmm4, xmm1		; neg Pixel 3,2
			vpsignw xmm5, xmm1		; neg Pixel 2,1

			; sumo a result
			paddw xmm0, xmm3	; sum Pixel 1,0
			paddw xmm0, xmm4	; sum Pixel 3,2
			paddw xmm0, xmm5	; sum Pixel 2,1

			; escrbir a mem:
			packuswb xmm0, xmm0
			movq qword [rsi], xmm0

	
			add rdi, 8
			add rsi, 8
			dec rdx
			cmp rdx, 0
			jne .columna
		; Ultimo pixel black:
		;add rsi, 8 
		mov [rsi], dword 0xff000000
		add rsi, 4 
		add rdi, 8 
		
		mov rdx, r13
		dec rcx
		cmp rcx, 0
		jne .fila

    mov rcx, rax  ; rcx = width 
    shr rcx, 2    ; div por 4 = 1(filas) / 4(pixels)
    .borde_inf:
        movdqu [rsi], xmm8
        add rsi, 16
    loop .borde_inf

    pop r12
    pop r13
    pop r14
    pop r15
	pop rbp
	ret

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
    mov r15, rsi ; r15 <- dst
    mov r14, rdi ; r14 <- src
    mov r13, rdx ; r13 <- width
	mov rax, rdx ; rax <- width
    mov r12, rcx ; r12 <- height

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


	;topes
	mov rcx, r12
	sub rcx, 2  ; cantidad de iteraciones de .fila
	shr r13, 1	; width / 2 (vamos de a dos)
	sub r13, 1	; restamos 1 (dos extremos)
	mov rdx, r13

	pcmpeqd xmm1, xmm1   ; xmm1 register con todos 1s
	movdqu xmm9, [val_9] ; xmm9 = 9
	pxor xmm7, xmm7		 ; xmm7 = 0


	.fila:
		mov [rsi], dword 0xff000000
		add rsi, 4 
		.columna:
			pxor xmm0, xmm0 ; result

			; 1ra Fila Matriz:
 			movdqu xmm4, [rdi]		; 4 Pixels Fila 1
			call procesar_neg_filas

			; 3ra Fila Matriz:
 			movdqu xmm4, [rdi+2*r8]	; 4 Pixels Fila 3
			call procesar_neg_filas

			; 2da Fila Matriz:
 			movdqu xmm4, [rdi+r8]	; 4 Pixels Fila 2
			movdqa xmm3, xmm4		; xmm3 = xmm4
			punpcklbw xmm3, xmm7	; Pixel 1,0
			punpckhbw xmm4, xmm7	; Pixel 3,2

			movhlps xmm5, xmm3		; Pixel x,1
			movlhps xmm5, xmm4		; Pixel 2,1

			; multiplico por 9
			pmullw xmm5, xmm9 		; mul 9 Pixel 2,1

			; sumo a result
			paddw xmm0, xmm3	; sum Pixel 1,0
			paddw xmm0, xmm4	; sum Pixel 3,2
			vpsignw xmm0, xmm1	; neg result
			paddw xmm0, xmm5	; sum 9*Pixel 2,1

			; escrbir a mem:
			packuswb xmm0, xmm0
			movq qword [rsi], xmm0

			add rdi, 8			; siguiente 2 pixels
			add rsi, 8			; idem
			dec rdx				; end?
			jne .columna
		; Ultimo pixel black:
		mov [rsi], dword 0xff000000
		add rsi, 4 				; siguiente pixels
		add rdi, 8 				; sum 2 pixels al estar -2 del final
		
		mov rdx, r13			; reset width
		dec rcx					; fila--
		cmp rcx, 0				; end?
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

procesar_neg_filas:
	movdqa xmm3, xmm4
	punpcklbw xmm3, xmm7	; Pixel 1,0
	punpckhbw xmm4, xmm7	; Pixel 3,2

	movhlps xmm5, xmm3		; Pixel x,1
	movlhps xmm5, xmm4		; Pixel 2,1

	paddw xmm0, xmm3		; sum Pixel 1,0
	paddw xmm0, xmm4		; sum Pixel 3,2
	paddw xmm0, xmm5		; sum Pixel 2,1

	ret

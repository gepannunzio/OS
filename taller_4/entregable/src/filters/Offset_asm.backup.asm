section .data
color_mask dd 0xff000000, 0xff000000

section .text
global Offset_asm

; void Offset_asm (uint8_t *src, uint8_t *dst, int width, int height,
;                      int src_row_size, int dst_row_size);
; rdi <- src, rsi <- dst,
; rdx <- width, rcx <- height,
; r8 <- src_row_size, byte
; r9 <- dst_row_size  byte para que??????

Offset_asm:
    push rbp
    mov rbp, rsp
    push r15
    push r14
    push r13
    push r12
    mov r15, rsi
    mov r14, rdi
    mov r13, r8
    mov r12, rcx
    mov r11, rdx
    ; r15 <- dst
    ; r14 <- src
    ; r13 <- src_row_size
    ; r12 <- height
    ; r11 <- width

    ; Procesamos 4 pixeles en simultaneo

    ; pixel negro
    movq xmm3, [color_mask] ; parte baja
    movlhps xmm3, xmm3  

    movdqa xmm0, xmm3 ; copio mascara
    psrldq xmm0, 3  ; mascara azul

    ; borde superior
    ; cuantos pixeles escribimos
    mov rcx, rdx  ; rcx = width 
    shl rcx, 1    ; mul por 2 = 8(filas) / 4(pixels)
    .borde_sup:
        movdqu [rsi], xmm3
        add rsi, 16
    loop .borde_sup

    ; nos movemos al comienzo del destino que no es negro
	movdqu [rsi], xmm3
	movdqu [rsi + 16], xmm3
	add rsi, 32

    shl r8, 3 ; r8 * 8 
    add rdi, r8 ; bajo 8 filas
    add rdi, 32 ; pos fuente

    ; topes
    mov rdx, rdi ; rdi tiene el inicio color esta 8 adelante
    add rdx, r13 ; bajo a la fila
    sub rdx, 64  ; tengo que restar 16 pixels adicionales

	mov rcx, r12 ; rcx = height
    sub rcx, 16  ; pixeles
    ; rsi tiene posicion de destino

    ; Filtrar solo parte de adentro de la imagen
    .fila:
        .columna:
            pxor xmm1, xmm1 ; resultado

            ; parte azul
            ; calcular posicion de fuente
            movdqa xmm2, [rdi + r8]
            pand xmm2, xmm0
            ; xmm2 <- azules fuente
            por xmm1, xmm2

            ; shiftear mascara a der 1 byte
            pslldq xmm0, 1

            ; parte roja
            ; xmm2 <- rojos fuente
			movdqu xmm2, [rdi + 32]				
			pand xmm2, xmm0
			por xmm1, xmm2

            ; shiftear mascara a der 1 byte
            pslldq xmm0, 1

			; parte verde
            ; xmm2 <- verdes fuente
			movdqu xmm2, [rdi + 32 + r8]
			pand xmm2, xmm0
			por xmm1, xmm2

			; mascara negro alpha = 255
			por xmm1, xmm3

            psrldq xmm0, 2 ; resetea mascara

            ; escribir a destino
            movdqu [rsi], xmm1

            ; siguientes 4 pixeles
            add rsi, 16 
            add rdi, 16 
            ; fin de columna?
            cmp rdi, rdx
            jne .columna 
        ; poner pixeles negros
        movdqu [rsi], xmm3
        movdqu [rsi + 16], xmm3
        movdqu [rsi + 32], xmm3
        movdqu [rsi + 48], xmm3
        
        add rdx, r13 ; siguiente fila
        add rsi, 64
        add rdi, 64
        ; fin de fila?
        loop .fila

    ; borde inferior
    ; cuantos pixeles escribimos
    mov rcx, r11 ; rcx = height
    shl rcx, 1   ; mul por 2 = 8(filas) / 4(pixels)
    sub rsi, 8*4 ; pixeles x byte, begin row
    .borde_inferior:
        movdqu [rsi], xmm3
        add rsi, 16 
    loop .borde_inferior

    pop r12
    pop r13
    pop r14
    pop r15
    pop rbp
	ret

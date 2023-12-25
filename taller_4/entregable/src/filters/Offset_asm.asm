%define pixel_size          4 ; bytes
%define pixeles_procesados  4
%define offset              8
%define bytes_procesados    pixel_size*pixeles_procesados
%define columna_negra       offset*pixel_size 
%define dos_columna_negra   2*columna_negra

section .data
color_mask db 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00
pixel_negro db 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff

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
    push r11
    mov r15, rsi
    mov r14, rdi
    mov r13, r8
    mov r11, rdx
    ; r15 <- dst
    ; r14 <- src
    ; r13 <- src_row_size
    ; r11 <- width

    ; pixel negro
    mov     r11,    color_mask
    movq    xmm3,   [r11]    ;parte baja
    movlhps xmm3,   xmm3  ;parte alto
    pslld   xmm3,   24


    ; nos movemos al comienzo del destino que no es negro
    shl r8, 3   ; r8 = src_row_size * offset, bytes de 8 filas
    add rsi, r8

    ; primer cachito de columna izquierda
    sub rsi, 16
    movdqa [rsi + bytes_procesados], xmm3
    movdqa [rsi + 2 * bytes_procesados], xmm3
    movdqa [rsi + 3 * bytes_procesados], xmm3
    add rsi, 16
    ; -----

    add rsi, pixel_size * offset ; columna izquierda en negro 

    add rdi, r8
    add rdi, pixel_size * offset ; idem

    mov     r11,    color_mask
    movq    xmm0,   [r11]       ; parte baja
    movlhps xmm0,   xmm0        ; parte alta

    ; Limites superiores del ciclo
    mov rdx, r14 ; columna, rdx <- *src
    add rdx, r8 ; suma 8 filas negras
    add rdx, r13 ; suma 1 fila mas
    sub rdx, columna_negra; resta un cacho de pixels, ahi comienza columna negra derecha

    ; rdx, es la direccion de la matriz fuente donde cambiamos de fila

    sub rcx, 16 ; primeras 8 y ultimas 8 filas no cuentan

    ; rsi <- posicion actual de matriz de destino
    ; rdi <- posicion actual de matriz de origen
    ; Filtrar solo parte de adentro de la imagen
    .fila:
        .columna:
            ; azul
            pxor xmm1, xmm1
            movdqa xmm2, [rdi + r8] ; 8 filas abajo, misma columna
            pblendvb xmm1, xmm2

            ; roja
            ; shiftear double words 8 bits a la izq?
            pslld xmm0, 8
            movdqa xmm2, [rdi + columna_negra] ; 8 pixeles a la derecha
            pblendvb xmm1, xmm2

            ; verde
            ; shiftear mascara a der 1 byte
            pslld xmm0, 8
            movdqa xmm2, [rdi + columna_negra + r8] ; 8 derecha, 8 abajo
            pblendvb xmm1, xmm2 ; mascara implicia XMM0

            ; alpha
            por xmm1, xmm3

            psrld xmm0, 16; reset mascara

            ; escribir resultado a destino
            movdqa [rsi], xmm1

            ; siguientes 4 pixeles
            add rsi, bytes_procesados
            add rdi, bytes_procesados

            ; fin de columna?
            cmp rdi, rdx
            jne .columna 
        ; rdi == rdx
        ; poner pixeles negros
        
        movdqa [rsi],        xmm3
        movdqa [rsi + bytes_procesados],        xmm3
        movdqa [rsi + 1 * bytes_procesados],    xmm3
        movdqa [rsi + 2 * bytes_procesados],    xmm3
        movdqa [rsi + 3 * bytes_procesados],    xmm3
        
        add rdx, r13 ; siguiente fila
        add rsi, dos_columna_negra
        add rdi, dos_columna_negra
        ; fin de fila?
        dec rcx
        cmp rcx, 0
        jne .fila
        ;loop .fila

    ; bordes
    
    ; borde inferior
    ; cuantos pixeles escribimos
    mov rcx, r8; 
    shr rcx, 4 ; dividir por 32
    sub rsi, 8*4 ; pixeles x byte
    .borde_inferior:
        movdqa [rsi], xmm3
        add rsi, bytes_procesados
    loop .borde_inferior

    ; borde superior
    mov rsi, r15 ; rsi <- *dst
    ; cuantos pixeles escribimos
    mov rcx, r8 ; 
    shr rcx, 4 ; dividir por 32
    .borde_sup:
        movdqa [rsi], xmm3
        add rsi, bytes_procesados
    loop .borde_sup

    pop r11
    pop r13
    pop r14
    pop r15
    ;mov rsp, rbp
    pop rbp
	ret

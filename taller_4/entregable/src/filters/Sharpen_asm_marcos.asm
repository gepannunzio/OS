;align 16
%define pixel_size  4

segment .data
pixel_negro         db 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff
;                       0       1   2       3   4      5    6    7     8     9     a     b     c     d     e     f 
; entrada:             |azul1     | rojo1    |  azul2    | rojo2     |  azul3    | rojo3     | azul4     | rojo4
; salida:              |azul1     | azul2    |  azul3    | azul4     |  rojo1    | rojo2     | rojo3     | rojo4
shuffle_god         db 0x00, 0x01, 0x04, 0x05, 0x08, 0x09, 0x0c, 0x0d, 0x02, 0x03, 0x06, 0x07, 0x0a, 0x0b, 0x0e, 0x0f
pixel_azul_rojo     db 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00
pixel_verde_alpha   db 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff, 0x00, 0xff
solo_izq            db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00
solo_der            db 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
menos9_izq          db 0x01, 0x00, 0x01, 0x00, 0xf7, 0xff, 0xf7, 0xff, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00 ;tiene un 1 en el resto de lugares para la multiplicacion
menos9_der          db 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0xf7, 0xff, 0xf7, 0xff, 0x01, 0x00, 0x01, 0x00 ;idem

borrar_otros        db 0xff, 0xff, 0xff, 0xff, 0x04, 0x05, 0x06, 0x07, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff

segment .text
global Sharpen_asm
;void Sharpen_c(uint8_t *src, uint8_t *dst, int width, int height,
;    int src_row_size,
;    int dst_row_size)
; rdi <- src, rsi <- dst,
; rdx <- width, rcx <- height,
; r8 <- src_row_size, byte
; r9 <- dst_row_size  byte
Sharpen_asm:
; matriz de sharpen preseteada
; Los 2 pixeles son traidos extendidos
; trabajamos con 2 pixeles para no perder precision en la multiplicacion
; Para alojarlos en destino, lo compactamos saturados
; recordar que hay 16 registros xmm. Van de xmm0 hasta xmm15
	push rbp
	mov rbp, rsp
    PUSH R12
    PUSH R13
    PUSH R14
    PUSH R15

    MOV R13, RDI
    MOV R14, RSI

;test !!
    movdqu xmm13, [borrar_otros]
    ;; pixel negro
    ;movq xmm3, [pixel_negro] ; parte baja
    ;movlhps xmm3, xmm3 

	;; borde superior
    ;; cuantos pixeles escribimos

    ;mov rcx, rdx  ; rcx = width 
    ;shr rcx, 2    ; mul por 2 = 1(filas) / 4(pixels)
    ;.borde_sup:
    ;    movdqu [rsi], xmm3
    ;    add rsi, 16
    ;loop .borde_sup

	;mov [rsi], dword 0xff000000
	;add rsi, 4 ; destination en el [1][1]

	;;topes
	;sub rcx, 3 ;cantidad de iteraciones de .fila
	;mov rdx, rdi 
	;add rdx, r8
    ;sub rdx, 8 ; cantidad de iteraciones de .columna ?

    PCMPEQB XMM15,  XMM15 ;XMM15 <- 1
    
    MOVDQU  XMM8,   [solo_izq]
    MOVDQU  XMM9,   [solo_der]

    MOVDQA  XMM0,   [pixel_verde_alpha]
    MOVDQA  XMM1,   [pixel_azul_rojo]
    ; XMM0 <- mascara color verde y alpha
    ; XMM1 <- mascara color azul y rojo
    
    MOVDQA  XMM10,  [menos9_izq]
    MOVDQA  XMM11,  [menos9_der]

    MOVDQA  XMM14,  [shuffle_god]

    ; xmm2,3,4 <- van a tener partes azules y rojas
    ; xmm5,6,7 <- van a tener partes verdes y alpha

    ; RDI es el la posicion actual de la matriz fuente
    ; RSI es el la posicion actual de la matriz destino
    ; este loop esta CASI**** bien. Por ahora recorre toda la imagen leyendo y escribiendo sin SEGFAULTS
    ; advertir que dentro del loop utilizo RAX y RBX para escribir el pixel
    ; tope
    MOV RDX, RCX
    DEC RDX
    DEC RDX ; dos filas menos

    MOV R12, R13
    ADD R12, R8
    SUB R12, pixel_size
    SUB R12, pixel_size
    SUB R12, pixel_size

    ADD RSI, R8 ;+ src_row_size
    ADD RSI, pixel_size
    MOV R15, RSI
    ; DEBUG ver original
    ;ADD RDI, R8
    ;ADD RDI, pixel_size
	.fila:
        CMP RDX, 0
        JZ .termino
		.columna:
            CMP RDI, R12 ;final de columna?
            JZ .finCol
        ; PRIMERA FILA
            ;MOVDQU  XMM13,  [R15]

            MOVDQU  XMM2,   [RDI] ;copiar pixeles
            MOVDQU  XMM5,   XMM2  ;otra copia (no entran todas las words en uno xmm)
            PAND    XMM2,   XMM1  ;guardar azules y rojos
            PAND    XMM5,   XMM0  ;guardar verdes y alpha, quedan en words al dejar lo otro en 0
            PSRLW   XMM5,   8     ;acomodar verdes/alpha para que queden en words

        ; SEGUNDA FILA
            MOVDQU  XMM3,   [RDI + R8]  ;copiar pixeles                                              
            MOVDQU  XMM6,   XMM3        ;otra copia (no entran todas las words en uno xmm)
            PAND    XMM3,   XMM1        ;guardar azules y rojos
            PAND    XMM6,   XMM0        ;guardar verdes y alpha, quedan en words al dejar lo otro en 0
            PSRLW   XMM6,   8           ;acomodar verdes/alpha para que queden en words

        ; TERCERA FILA
            MOVDQU  XMM4,   [RDI + 2*R8] ;copiar pixeles
            MOVDQU  XMM7,   XMM4         ;otra copia (no entran todas las words en uno xmm)
            PAND    XMM4,   XMM1         ;guardar azules y rojos
            PAND    XMM7,   XMM0         ;guardar verdes y alpha, quedan en words al dejar lo otro en 0
            PSRLW   XMM7,   8            ;acomodar verdes/alpha para que queden en words

        ; MULTIPLICAR POR -9 AL DEL MEDIO "IZQ Y DER" PARA AZ/RO Y VER/ALF
            ; XMM10 <- -9 izq XMM11 <- -9 der
            ; hace lo mismo que el de abajo pero lo almacena en el primero registro
            ;MOVDQU XMM12, XMM3
            ;MOVDQU XMM13, XMM6
            ;PMULLW XMM12, XMM11
            ;PMULLW XMM13, XMM11

            ;movdqu xmm12, xmm3
            ;psignw xmm12, xmm15
            ;pshufb xmm12, xmm13
            ;paddw xmm3, xmm12
            ;paddw xmm3, xmm12
            ;psllw  xmm12, 3
            ;paddw xmm3, xmm12

            ;movdqu xmm12, xmm6
            ;psignw xmm12, xmm15
            ;pshufb xmm12, xmm13
            ;paddw xmm6, xmm12
            ;paddw xmm6, xmm12
            ;psllw  xmm12, 3
            ;paddw xmm6, xmm12
            ; SIGUE TENIENDO EL MISMO ERROR!!!! NO PERDIA PRECISION CON PMULLW

            PMULLW  XMM3, XMM10
            PMULLW  XMM6, XMM10

            ; xmm3  <- IZQUIERDA: word azu/roj, con el del medio * (-9)
            ; xmm6  <- IZQUIERDA: word ver, con el del medio * (-9)
            ; xmm12 <- DERECHA: word azu/ro, con el del medio * (-9)
            ; xmm13 <- DERECHA: word ver, con el del medio * (-9)
        ; SUMAS
            ; Reordenar words con un shuffle, asi me quedan de un lado azules y del otro rojas. Idem verde.
            ; azul/rojo
            PSHUFB  XMM2, XMM14
            PSHUFB  XMM3, XMM14 ; izquierdo fila 2
            PSHUFB  XMM4, XMM14
            ; verde
            PSHUFB  XMM5, XMM14
            PSHUFB  XMM6, XMM14 ; izquierdo fila 2
            PSHUFB  XMM7, XMM14
            ; derecho fila 2
;            PSHUFB  XMM10, XMM14 ; a/r ERROR: XMM10 era una mascara
;            PSHUFB  XMM11, XMM14 ; v

            ; sumar primera y tercera fila
            PADDW   XMM2,  XMM4 ; AZ/RO Filas 1 + 3
            PADDW   XMM5,  XMM7 ; V/AL Filas 1 + 3

            PSIGNW  XMM2,   XMM15 ; negarlos
            PSIGNW  XMM5,   XMM15 ; negarlos
            PSIGNW  XMM3,   XMM15 ; negarlos
            PSIGNW  XMM6,   XMM15 ; negarlos

            ; Packed Horizontal Add Words
            ; https://www.officedaytime.com/simd512e/simdimg/phaddw_1.png

            ; izq, azu/roj
            MOVDQU  XMM4,   XMM3 ; aprovecho que esta libre ahora
            MOVDQU  XMM7,   XMM2 ; idem
            PAND    XMM4,   XMM8 ; filtro ultima word en ambos colores
            PAND    XMM7,   XMM8 ; idem
            PHADDW  XMM4,   XMM7
            PHADDW  XMM4,   XMM15
            PSHUFLW XMM4,   XMM4, 216; swapear de lugar la 2 y 3 words; Shuffle Packed Low Words
            PHADDW  XMM4,   XMM15
            PACKUSWB XMM4,  XMM15 ; Pack Unsigned Saturation Word -> Byte
            ; quedan los dos bytes mas significativos con parte azul / roja del pixel izquierdo
            
            ; izq, ver
            MOVDQU  XMM2,   XMM5 ; aprovecho que esta libre ahora
            MOVDQU  XMM3,   XMM6 ; idem
            PAND    XMM2,   XMM8 ; filtro ultima word en ambos colores
            PAND    XMM3,   XMM8 ; idem
            PHADDW  XMM2,   XMM3
            PHADDW  XMM2,   XMM15 ;+0
            PSHUFLW XMM2,   XMM2, 216;swapear de lugar la 2 y 3 words 
            PHADDW  XMM2,   XMM15 ;+0 
            PACKUSWB XMM2,  XMM15 ; Pack Unsigned Saturation Word -> Byte
            ; quedan los dos bytes mas significativos con parte verde / alpha del pixel izquierdo

            ;queda extraerlos a un registro, recordar Azul - Verde - Rojo - Alpha, por ser little endian los coloco alrevez
            XOR RAX, RAX

            PEXTRB RBX, XMM2, 1 ; alpha
            MOV AL, BL
            SHL RAX, 8

            PEXTRB RBX, XMM4, 1 ; rojo
            MOV AL, BL
            SHL RAX, 8

            PEXTRB RBX, XMM2, 0 ; verde 
            MOV AL, BL
            SHL RAX, 8

            PEXTRB RBX, XMM4, 0 ; azul
            MOV AL, BL

            MOV [RSI], eax ; escribir en destino; ESTABA USANDO AX(16bits)
            ADD RDI, pixel_size ;avanzo 2 pixeles
            ADD RSI, pixel_size
            JMP .columna
        .finCol:
            ADD RDI, pixel_size*3
            ADD RSI, pixel_size*3
            ADD R12, R8
            DEC RDX
            JMP .fila

    .termino:
            
    pop r15
    pop r14
    pop r13
    pop r12
	pop rbp
	ret

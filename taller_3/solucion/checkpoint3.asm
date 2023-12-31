
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global complex_sum_z
global packed_complex_sum_z
global product_9_f

%define offset_z 24
;########### DEFINICION DE FUNCIONES
;extern uint32_t complex_sum_z(complex_item *arr, uint32_t arr_length);
;registros: arr[rdi], arr_length[rsi]
complex_sum_z:
	;prologo

	mov rcx, rsi ; carga la cantidad de iteraciones a hacer al contador de vueltas
	xor rax, rax 
	.cycle:     ; etiqueta a donde retorna el ciclo que itera sobre arr
		add rax, [rdi + offset_z]
		add rdi, 32
	loop .cycle ; decrementa ecx y si es distinto de 0 salta a .cycle

	;epilogo
	ret

;extern uint32_t packed_complex_sum_z(packed_complex_item *arr, uint32_t arr_length);
;registros: arr[?], arr_length[?]
packed_complex_sum_z:

	;prologo

	mov rcx, rsi ; carga la cantidad de iteraciones a hacer al contador de vueltas
	sub rax, rax 
	mov rdx, 20
	.cycle:     ; etiqueta a donde retorna el ciclo que itera sobre arr
		add rax, [rdi + rdx]
		add rdx, 24
	loop .cycle ; decrementa ecx y si es distinto de 0 salta a .cycle

	;epilogo
	ret


;extern void product_9_f(double* destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[rsi], f1[xmm0], x2[rdx], f2[xmm1], x3[rcx], f3[xmm2], x4[r8], f4[xmm3]
;	, x5[r9], f5[xmm4], x6[rbp + 0x10], f6[xmm5], x7[rbp + 0x18], f7[xmm6], x8[rbp + 0x20], f8[xmm7],
;	, x9[rbp + 0x28], f9[rbp + 0x30]
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles
	; COMPLETAR
	sub rax, rax
	cvtss2sd xmm0, xmm0
	cvtss2sd xmm1, xmm1
	cvtss2sd xmm2, xmm2
	cvtss2sd xmm3, xmm3
	cvtss2sd xmm4, xmm4
	cvtss2sd xmm5, xmm5
	cvtss2sd xmm6, xmm6
	cvtss2sd xmm7, xmm7


	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	; COMPLETAR

	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	mulsd xmm0, xmm5
	mulsd xmm0, xmm6
	mulsd xmm0, xmm7

	cvtss2sd xmm1, [rbp + 48]

	mulsd xmm0, xmm1


	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	; COMPLETAR

	cvtsi2sd xmm1, rsi
	cvtsi2sd xmm2, rdx
	cvtsi2sd xmm3, rcx
	cvtsi2sd xmm4, r8
	cvtsi2sd xmm5, r9

	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	mulsd xmm0, xmm5

	cvtsi2sd xmm1, [rbp + 16]
	cvtsi2sd xmm2, [rbp + 24]
	cvtsi2sd xmm3, [rbp + 32]
	cvtsi2sd xmm4, [rbp + 40]

	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4

	movq [rdi], xmm0

	; epilogo
	pop rbp
	ret


extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global alternate_sum_4_using_c

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4:
	;prologo
	; COMPLETAR
	push rbp
	mov rbp, rsp
	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx

	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	;epilogo
	; COMPLETAR

	pop rbp
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	push r15
	push r14
	push r13
	push r12

	mov r15, rdi
	mov r14, rsi
	mov r13, rdx
	mov r12, rcx

	mov rbp,rsp
	; COMPLETAR

	CALL restar_c
	mov rdi, r13
	mov rsi, r12
	mov r15, rax
; x1 - x2
	CALL restar_c
	mov rdi, r15
	mov rsi, rax
	CALL sumar_c

	;epilogo
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbp
	ret



; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_simplified:

	sub rsp, 0x08 ;Innecesario
	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx
	add rsp, 0x08 ;Innecesario
	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9], x7[rbp + 0x10], x8[rbp + 0x18]
alternate_sum_8:
	;prologo

	push rbp
	mov rbp, rsp


	; COMPLETAR

	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx
	add rax, r8
	sub rax, r9
	add rax, [rbp + 0x10]
	sub rax, [rbp + 0x18]


	;epilogo

	pop rbp

	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[rsi], f1[xmm0]
product_2_f:
	sub rsp, 0x08
	cvtsi2sd xmm1, rsi
	cvtss2sd xmm0, xmm0
	mulsd xmm0, xmm1
	cvttsd2si rsi, xmm0
	mov [rdi], esi
	add rsp, 0x08
	ret



section .text

global checksum_asm

; uint8_t checksum_asm(void* array, uint32_t n)

checksum_asm:

	push rbp
	mov rbp, rsp
	mov ecx, esi
	.cycle:
		pmovzxwd xmm0, [rdi]
		add rdi, 8
		pmovzxwd xmm1, [rdi]
		add rdi, 8
		pmovzxwd xmm2, [rdi]
		add rdi, 8
		pmovzxwd xmm3, [rdi]
		add rdi, 8
		movdqu xmm4, [rdi]
		add rdi, 16
		movdqu xmm5, [rdi]
		add rdi, 16
		; aij : xmm0 xmm1; bij : xmm2, xmm3 ; cij, xmm4, xmm5

		paddd xmm0, xmm2
		paddd xmm1, xmm3
		; sumamos ambas mitades

		psllw xmm0, 3
		psllw xmm1, 3

		; multiplicacion por 8

		pcmpeqd xmm0, xmm4
		pcmpeqd xmm1, xmm5
		; comparacion con c

		andpd xmm0, xmm1
		pextrq r8, xmm0, 1
		movq r9, xmm0
		; separar xmm en 2 r64
		and r8, r9
		; comparas high con low dword
		not r8
		cmp r8, 0
		; comparacion con 0 para flags

		jne  .diff		; si al menos 1 byte es distinto de 0 entonces hubo discrepancia
		
		loop .cycle

	mov rax, 1
	jmp .exit

	.diff:
		mov rax, 0 

	.exit:
	
	pop rbp
	ret


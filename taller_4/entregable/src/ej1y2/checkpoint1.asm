section .text 

global invertirBytes_asm

; void invertirBytes_asm(uint8_t* p, uint8_t n, uint8_t m)
invertirBytes_asm:
	push rbp
	mov rbp, rsp

	movdqu xmm0, [rdi]
	xorpd xmm3, xmm3
	xorpd xmm2, xmm2
	mov rcx, 16
	mov r8, 15
	.cycle:
		cmp r8b, sil
		jz .indice_n
		cmp r8b, dl
		jz .indice_m

		vmovq xmm2, r8
		pslldq xmm3, 1
		paddusb xmm3, xmm2
		jmp .continue		

		.indice_n:
		vmovq xmm2, rdx
		pslldq xmm3, 1
		paddusb xmm3, xmm2

		jmp .continue

		.indice_m:
		vmovq xmm2, rsi
		pslldq xmm3, 1
		paddusb xmm3, xmm2

	.continue:
	dec r8
	loop .cycle			
	pshufb xmm0, xmm3

	movdqu [rdi], xmm0

	pop rbp
	ret


invertirBytes_asm2:
	push rbp
	mov rbp, rsp

	movdqu xmm0, [rdi]

	mov rax, rdx ; rax := m
	mov r8, 0xff ; r8 := 0x0000..ff
	mov cl, sil  ; cl := n
	cmp sil, 8   ; if (cl > 8)
	jl .skip_mod_n
	sub cl, 8    ; then take mod 8
 .skip_mod_n:	     ; else skip
	shl cl, 3    ; cl := cl * 8 (shift bytes)
	shl rax, cl  ; shift rax n times
	shl r8, cl   ; idem r8
	movq xmm1, rax ; xmm1 := mask with idx
	movq xmm2, r8  ; xmm2 := mask with 0xff

	cmp sil, 8     ; if (cl > 8)
	jl .skip_shift_n
	pslldq xmm1, 8 ; shift to low part the result
	pslldq xmm2, 8 ; idem
 .skip_shift_n:

	mov rax, rsi ; rax := n
	mov r8, 0xff
	mov cl, dl ; cl := m
	cmp dl, 8
	jl .skip_mod_m
	sub cl, 8
 .skip_mod_m:
	shl cl, 3
	shl rax, cl ; shift rax m times
	shl r8, cl
	movq xmm3, rax ; xmm3 := mask with idx
	movq xmm4, r8  ; xmm4 := mask with 0xff

	cmp dl, 8
	jl .skip_shift_m
	pslldq xmm3, 8
	pslldq xmm4, 8
 .skip_shift_m:
	por xmm1, xmm3 ; xmm1 has both indexes to swap
	por xmm2, xmm4 ; xmm2 has mask with 0xff of values
	movdqa xmm4, xmm2 ; copy of xmm2

	pandn xmm2, xmm0  ; clear values of idx n and m from xmm0

	pshufb xmm0, xmm1 ; use mask idx in xmm0 (swap(n,m))
	pand xmm0, xmm4   ; use mask 0xff to remove trash

	por xmm0, xmm2    ; xmm2 has xmm0 without idx n and m

	movdqu [rdi], xmm0 ; copy xmm0 in mem

	pop rbp
	ret

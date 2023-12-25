section .text
	global _start
_start:
	mov rax, [x]
	mov rdx, [y] ; OF
	call add
	mov rax, [a] ; ZF, CF
	mov rdx, [b]
	call add

	mov eax, 1
	int 0x80

add:
	add rax, rdx
	ret

section .data
	x dq 0x7EDCBA9876543211
	y dq 0x7EDCBA9876543211
	a dq 0x0123456789ABCDEF
	b dq 0xFEDCBA9876543211

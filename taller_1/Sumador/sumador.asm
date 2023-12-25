extern print_uint64

section	.data
	over db "Overflow",0x0A
	y dq 0x7EDCBA9876543211 
section	.text
	global _start
_start:                

	mov rdi, 0x7EDCBA9876543211 
	add rdi, [y] 
	jno _no_overflow
	mov eax, 4
	mov ebx, 1
	mov ecx, over
	mov edx, 9
	int 0x80
_no_overflow:
	call print_uint64

	mov eax, 1	    
	int 0x80 



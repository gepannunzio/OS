section .text
	global _start
_start:
	mov al, [x] 
	mov dl, [y] 
	add al, dl ; Si supera los 8 bits se prende el CF

	mov eax, 1
	int 0x80

section .data
	x db 0xF4
	y db 0x14	


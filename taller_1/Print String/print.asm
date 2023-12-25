section	.text
	global _start
_start:
	mov edx, len1 ; length del mensaje
	mov ecx, msg1 ; msg tiene la dir del mensaje
	call print    ; llamo a subrutina print	
	mov edx, len2 
	mov ecx, msg2 
	call print

	mov eax, 1 ; system call for exit
	int 0x80 ; nueva interrupcion para realizar el exit
print:
	mov ebx, 1 ; file descriptor standard output console 
	mov eax, 4 ; system call for write
	int 0x80 ; interrupcion que toma los argumentos previos
	ret      ; retorno a _start
	
section .data
	msg1 db 'Hello, world!', 0xa ; El simbolo /n en ascii es 0xa
	len1 equ $ - msg1 ; $ representa la direccion actual
	msg2 db 'Andres Galeota, 626/21', 0xa 
	len2 equ $ - msg2 

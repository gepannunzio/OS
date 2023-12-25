
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

extern task


BITS 32
section .data
    prueba db 0x1 

section .text

_start:
	call task
	; Si corremos un ret acá va a fallar porque no tenemos a dónde retornar
	;
	; Lo que deberíamos hacer es tener una syscall que nos permita avisar
	; el fin de nuestra ejecución al sistema.
    ;int 14 no llega nunca a esta instruccion
    int 99
    
	jmp _start

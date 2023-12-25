extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
    push rbp
    mov rbp, rsp
    push r15
    push r14
    push r13

    mov r15, rdi
    mov r14, rsi ;desalineado
    sub rsp, 8 ;alineado

    call strLen

    mov r13, rax ; rdx = len(A)
    mov rdi, r14 ; 
    call strLen  ; rax = len(B)
    cmp r13d, eax ; flags(rdx - rax)
    jg .Amenor
    ; A <= B
    mov rax, r13
    .Amenor:
   
    ; rax <- min(len(A), len(B)) + 1
    xor rcx, rcx
    inc rax
    xor r8, r8
    xor r9, r9
    .loop:
        mov r8b, byte [r15 + rcx] ; r8 <- A[]
        mov r9b, byte [r14 + rcx]
    
        ; Comparar lexicograficamente
        cmp r8b, r9b ; comparamos los bytes mas bajos solamente.
        
        jl .r8Menor
        jg .r8Mayor

        inc rcx

        cmp rcx, rax ; si son iguales: fin del menor string
        je .iguales

        jmp .loop

    ; Todos iguales
    .iguales:
    mov rax, 0
    jmp .exit

    .r8Menor:
    mov rax, 1
    jmp .exit

    .r8Mayor:
    mov rax, -1

    .exit:
    add rsp, 8
    pop r13
    pop r14
    pop r15
    pop rbp
	ret

; char* strClone(char* a)
strClone:

    push rbp ;alineado
    mov rbp, rsp 

    push r15 ;desalineado
    push r14 ;alineado

    mov r15, rdi

	call strLen

    inc rax
    mov r14, rax

	mov rdi, r14   ; rdi = strLen (arg de malloc)
	call malloc wrt ..plt
    mov r14, rax
 	.cycle:
		mov dl, byte [r15]
		mov byte [r14], dl
		inc r14
		inc r15
		loop .cycle
	

    pop r14
    pop r15
    pop rbp
	ret

; void strDelete(char* a)
strDelete:
	; Esto no funciona porque copia el puntero al string
	; pero no el string en sí mismo
    push rbp
    mov rbp, rsp
    call free wrt ..plt
    pop rbp
	ret

; void strPrint(char* a, FILE* pFile)
; Falta null
strPrint:
    push rbp
    mov rbp,rsp
	mov rdx, rdi
    mov rdi, rsi
    mov rsi, rdx
    ; mov r13, fprintf
    ; jmp r13
    call fprintf wrt ..plt ; ???
	pop rbp
	ret

; uint32_t strLen(char* a)
strLen:
	xor rax,rax
	.cycle:
		cmp byte[rdi], 0
		jz .exit
		inc rdi
		inc rax
		jmp .cycle
	.exit:
	ret



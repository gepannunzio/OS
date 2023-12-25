; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "print.mac"

global start



; COMPLETAR - Agreguen declaraciones extern según vayan necesitando
extern A20_enable
extern A20_disable
extern GDT_DESC
extern screen_draw_layout
extern IDT_DESC
extern idt_init
extern pic_reset
extern pic_enable
extern mmu_init_kernel_dir
extern copy_page
extern mmu_init_task_dir
extern tss_init
extern tasks_screen_draw
extern sched_init
extern tasks_init
; COMPLETAR - Definan correctamente estas constantes cuando las necesiten
; GDT_CODE_0_SEL
%define CS_RING_0_SEL 0x8 
; GDT_DATA_0_SEL
%define DS_RING_0_SEL 0x18
%define SEL_TASK_IDLE (12 << 3)

BITS 16
;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg
start_pm_msg_task db 'Terminada tarea solicitada        '

gdtr DW 0 ; For limit storage
     DD 0 ; For base storage


;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; COMPLETAR - Deshabilitar interrupciones
    cli

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font
    mov ax, 0100h
    mov cx, 2020h
    int 10h ; make invisible cursor

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO REAL
    ; (revisar las funciones definidas en print.mac y los mensajes se encuentran en la
    ; sección de datos)

    print_text_rm start_rm_msg, start_rm_len, 0x2, 0x10, 0x18 ; color verde, revisar fila columna 

    ; COMPLETAR - Habilitar A20
    ; (revisar las funciones definidas en a20.asm)
    call A20_enable

    ; COMPLETAR - Cargar la GDT
    lgdt [GDT_DESC]

    ; COMPLETAR - Setear el bit PE del registro CR0
    mov eax, cr0 
    or al, 1       ; set PE (Protection Enable) bit in CR0 (Control Register 0)
    mov cr0, eax

    ; COMPLETAR - Saltar a modo protegido (far jump)
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo
    jmp CS_RING_0_SEL:modo_protegido

BITS 32
modo_protegido:
    ; COMPLETAR - A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo
    mov ax, DS_RING_0_SEL
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax
    mov ss, ax

    ; COMPLETAR - Establecer el tope y la base de la pila
    mov ebp, 0x25000
    mov esp, ebp

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO PROTEGIDO
    print_text_pm start_pm_msg, start_pm_len, 0x4, 0x0A, 0x0B

    ; COMPLETAR - Inicializar pantalla
    call screen_draw_layout

    ; Inicializar paginacion
    call mmu_init_kernel_dir
    mov cr3, eax

    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    ; COMPLETAR - Inicializar IDT
    call idt_init
    lidt [IDT_DESC]

    ; OPTATIVO -Aumentar freq reloj
    ; 65536 / 4 = 16384 = 0x4000
    mov al, 0x00
    out 0x40, al
    mov al, 0x40
    out 0x40, al

    ; COMPLETAR - Inicializar PIC
    call pic_reset
    call pic_enable

    call sched_init
    call tss_init
    call tasks_init

    ; COMPLETAR - Inicializar TSS
    
    ;call tasks_screen_draw
    mov ax, 11 << 3 ; GDT_IDX_TASK_INITIAL
    ltr ax
    sti

    jmp SEL_TASK_IDLE:0

    int 88
    int 98

    push 0x000000
    push 0x101000
    call copy_page
    mov eax, cr3
    push eax
    push 0x18000
    call mmu_init_task_dir
    mov cr3, eax
    print_text_pm start_pm_msg_task, start_pm_len, 0x3, 0x0A, 0x0B
    pop ecx
    pop eax
    mov cr3, eax

    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    .halt:
    hlt
    jmp .halt

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"

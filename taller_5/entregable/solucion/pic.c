/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Rutinas del controlador de interrupciones.
*/
#include "pic.h"

#define PIC1_PORT 0x20
#define PIC2_PORT 0xA0

#define ICW1 0x11
#define ICW2_PIC1 0x20
#define ICW3_PIC1 0x4
#define ICW4_PIC1 0x1
#define IMR_CLEAR 0xFF

#define ICW2_PIC2 0x28
#define ICW3_PIC2 0x2
#define ICW4_PIC2 0x1

static __inline __attribute__((always_inline)) void outb(uint32_t port,
                                                         uint8_t data) {
  __asm __volatile("outb %0,%w1" : : "a"(data), "d"(port));
}
void pic_finish1(void) { outb(PIC1_PORT, 0x20); }
void pic_finish2(void) {
  outb(PIC1_PORT, 0x20);
  outb(PIC2_PORT, 0x20);
}

// COMPLETAR: implementar pic_reset()
void pic_reset() {
  // Inicializacion PIC1
  outb(PIC1_PORT, ICW1);          // ICW1: IRQs activas por flanco, Modo cascada, ICW4 Si.
  outb(PIC1_PORT + 1, ICW2_PIC1); // PIC1_PORT + 1 = 0x21, ICW2: INT base para el PIC1 tipo 0x20
  outb(PIC1_PORT + 1, ICW3_PIC1); // ICW3: PIC1 Master, tiene un Slave conectado a IRQ2
  outb(PIC1_PORT + 1, ICW4_PIC1); // ICW4: Modo No Buffered, Fin de Interrupcion Normal 
  // Deshabilitamos las Interrupciones del PIC1
  outb(PIC1_PORT + 1, IMR_CLEAR); // OCW1: Set o Clear el IMR
  // Inicializacion PIC2
  outb(PIC2_PORT, ICW1);          // ICW1: IRQs activas por flanco, Modo cascada, ICW4 Si.
  outb(PIC2_PORT + 1, ICW2_PIC2); // PIC2_PORT + 1 = 0xA1, ICW2: INT base para el PIC2 tipo 0x28
  outb(PIC2_PORT + 1, ICW3_PIC2); // ICW3: PIC2 Slave, IRQ2 es la linea que envia al Master
  outb(PIC2_PORT + 1, ICW4_PIC2); // ICW4: Modo No Buffered, Fin de Interrupcion Normal
}

void pic_enable() {
  outb(PIC1_PORT + 1, 0x00);
  outb(PIC2_PORT + 1, 0x00);
}

void pic_disable() {
  outb(PIC1_PORT + 1, 0xFF);
  outb(PIC2_PORT + 1, 0xFF);
}

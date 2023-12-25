#include "student.h"
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>


void printStudent(student_t *stud)
{
    /* Imprime por consola una estructura de tipo student_t
    */
   printf("Nombre: %s\n", stud->name);
   printf("dni: %d\n", stud->dni);
   printf("calificaciones: %d, %d, %d\n", stud->califications[0], stud->califications[1], stud->califications[2]);
   printf("concepto: %d\n", stud->concept);
   printf("----------\n");
}

void printStudentp(studentp_t *stud)
{
    /* Imprime por consola una estructura de tipo studentp_t
    */
    printf("Nombre: %s\n", stud->name);
    printf("dni: %d\n", stud->dni);
    printf("calificaciones: %d, %d, %d\n", stud->califications[0], stud->califications[1], stud->califications[2]);
    printf("concepto: %d\n", stud->concept);
    printf("----------\n");
}

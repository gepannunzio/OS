#include "task_lib.h"
#include "../i386.h"

#define WIDTH TASK_VIEWPORT_WIDTH
#define HEIGHT TASK_VIEWPORT_HEIGHT

typedef struct {
	uint32_t x;
} player;

// un misil no fue lanzado si tiene X = -1
typedef struct {
    uint32_t x;
    uint32_t y;
} misil;

typedef misil alien;

typedef struct {
    player nave;
    misil projectiles[10];
    alien enemigos[10];
    uint32_t puntaje;
    bool perdio;
} juego;

void space_invader_draw(juego* partida, screen pantalla) {
	// Pintamos todo de negro
	task_draw_box(pantalla, 0, 0, WIDTH, HEIGHT, ' ', C_BG_BLACK);
	// Pintamos la nave
	task_draw_box(pantalla, partida->nave.x+2, HEIGHT-2, 5, 1, 219, C_FG_GREEN);
	task_draw_box(pantalla, partida->nave.x, HEIGHT-1, 9, 1, 219, C_FG_GREEN);
    task_print_dec(pantalla, partida->puntaje, 5, 3, 3, C_FG_GREEN);
    // Imprimir misiles y aliens
    for (int i=0; i < 10; i++) {
        if (partida->projectiles[i].x != -1) {
    	    task_draw_box(pantalla, partida->projectiles[i].x, partida->projectiles[i].y, 1, 1, '|', C_FG_WHITE);
        }
        if (partida->enemigos[i].x != -1) {
    	    task_draw_box(pantalla, partida->enemigos[i].x, partida->enemigos[i].y, 1, 1, '*', C_FG_WHITE);
        }
    }
	// Le pedimos al sistema operativo que muestre nuesta pantalla

	syscall_draw(pantalla);
    /*
	syscaif (partida->projectiles[i].x != -1) {
            for (int i=0; i < 10; i++) {
                if (partida->projectiles[i].x == partida->enemigos[i].x && partida->projectiles[i].y == partida->enemigos[i].y) {
                    partida->enemigos[i].x = -1;
                }
            }
        }ll_draw(panif (partida->projectiles[i].x != -1) {
            for (int i=0; i < 10; i++) {
                if (partida->projectiles[i].x == partida->enemigos[i].x && partida->projectiles[i].y == partida->enemigos[i].y) {
                    partida->enemigos[i].x = -1;
                }
            }
        }enemigo disponible
    
    }*/
}

void spawn_invader(juego* partida) {
    for (int i=0; i < 10; i++) {
        if (partida->enemigos[i].x == -1) {
	        uint32_t random_state = ENVIRONMENT->tick_count;
            partida->enemigos[i].x = task_random(&random_state) % WIDTH;
            partida->enemigos[i].y = 1;
            return;
        }
    }
}

void shoot(juego* partida) {
    for (int i=0; i < 10; i++) {
        if (partida->projectiles[i].x == -1) {
            partida->projectiles[i].x = partida->nave.x+4;
            partida->projectiles[i].y = HEIGHT-2;
            return;
        }
    }
}

void player_left(player* nave) {
    nave->x -= 1;
} 

void player_right(player* nave) {
    nave->x += 1;
}

void space_tick(juego* partida) {
    for (int i=0; i < 10; i++) {
        if (partida->projectiles[i].x != -1) {
            for (int j=0; j < 10; j++) {
                if ((partida->projectiles[i].x == partida->enemigos[j].x) & (partida->projectiles[i].y <= partida->enemigos[j].y+2)) {
                    partida->enemigos[j].x = -1;
                    partida->projectiles[i].x = -1;
                    partida->puntaje++;
                }
            }
        }
        if (partida->projectiles[i].x != -1) {
            partida->projectiles[i].y -= 1;
            if (partida->projectiles[i].y == 0)
                partida->projectiles[i].x = -1;
        }
        if ((ENVIRONMENT->tick_count % 250) && partida->enemigos[i].x != -1) { // CHEQUEAR
        //if (partida->enemigos[i].x != -1) {
            partida->enemigos[i].y += 1;
            // PERDER
            if (partida->enemigos[i].y >= HEIGHT-1) {
                partida->perdio = true;
            }
        }
    }
}

void partida(screen pantalla) {
	// Estado inicial de la partida
    juego partida = { .nave = { .x = 10 }, .puntaje = 0 , .perdio = false};
    for (int i=0; i < 10; i++) {
        partida.projectiles[i].x = -1;
        partida.projectiles[i].y = 0;
        partida.enemigos[i].x = -1;
        partida.enemigos[i].y = 0;
    }
    uint32_t ultimoDisparo = 0;    
	// Si se aprieta escape se termina la partida
	// Si sólo le queda la cola a la serpiente se termina la partida
	while (!ENVIRONMENT->keyboard.escape) {
        if (ENVIRONMENT->keyboard.a || ENVIRONMENT->keyboard.left) player_left(&partida.nave);
		if (ENVIRONMENT->keyboard.d || ENVIRONMENT->keyboard.right) player_right(&partida.nave);
		if (ENVIRONMENT->keyboard.spacebar || ENVIRONMENT->keyboard.up && ENVIRONMENT->tick_count - ultimoDisparo > 30) {
            shoot(&partida);
            ultimoDisparo = ENVIRONMENT->tick_count;
        }
        if (ENVIRONMENT->tick_count % 25 == 0) spawn_invader(&partida);
		space_tick(&partida);
		space_invader_draw(&partida, pantalla);

        if (partida.perdio) break;
		// Espero un ratito para que el juego no sea súper rápido
		task_sleep(5);
	}

    task_print(pantalla, "GAME OVER", WIDTH/2, HEIGHT/2, C_FG_RED);
}

void task(void) {
	while (true) {
		screen pantalla;

		// Imprimimos las instrucciones
		task_print(pantalla, "ESC: Terminar partida", 8, 11, C_FG_LIGHT_GREY);
		task_print(pantalla, "Presione enter para jugar", 6, 12, C_FG_WHITE);

		// Dibujamos las instrucciones en la pantalla
		syscall_draw(pantalla);

		// Espero a que se apriete enter
		while (!ENVIRONMENT->keyboard.enter);

		// Arranco una partida
		partida(pantalla);
	}
}
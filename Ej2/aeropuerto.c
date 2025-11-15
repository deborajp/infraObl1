#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <semaphore.h>

#define PASAJEROS 100
#define OFICINISTAS 5

sem_t mutex_lectores;
sem_t cartel;
sem_t mutex_print;

int leyendo = 0;

void *pasajeros_thread(void *arg) {
    for (int i = 1; i <= PASAJEROS; i++) {

        sem_wait(&mutex_lectores);
        leyendo++;
        if (leyendo == 1) {
            sem_wait(&cartel);
        }
        sem_post(&mutex_lectores);

        sem_wait(&mutex_print);
        printf("Pasajero %d está mirando el cartel\n", i);
        sem_post(&mutex_print);

        sleep(rand() % 4);

        sem_wait(&mutex_lectores);
        leyendo--;
        if (leyendo == 0) {
            sem_post(&cartel);
        }
        sem_post(&mutex_lectores);

        usleep(30000);
    }
    return NULL;
}

void *oficinistas_thread(void *arg) {
    for (int i = 1; i <= OFICINISTAS; i++) {
        for (int j = 1; j <= 3; j++) {

            sem_wait(&cartel);

            sem_wait(&mutex_print);
            printf("Oficinista %d está modificando el cartel (cambio %d)\n", i, j);
            sem_post(&mutex_print);

            sleep(rand() % 6);

            sem_post(&cartel);

            usleep(50000);
        }
    }
    return NULL;
}

int main() {
    srand(time(NULL));

    pthread_t hilo_pasajeros, hilo_oficinistas;

    sem_init(&mutex_lectores, 0, 1);
    sem_init(&cartel, 0, 1);
    sem_init(&mutex_print, 0, 1);

    pthread_create(&hilo_pasajeros, NULL, pasajeros_thread, NULL);
    pthread_create(&hilo_oficinistas, NULL, oficinistas_thread, NULL);

    pthread_join(hilo_pasajeros, NULL);
    pthread_join(hilo_oficinistas, NULL);

    return 0;
}
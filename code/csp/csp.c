#include <pthread.h>
#include <stdio.h>

typedef struct {
    void (*fn)();
    pthread_t self;
} actor;


void print(pthread_t pid) {
    printf("From ID: %lu\n", pid);
}

void *wiring(void *argument) {
    actor a;
    a = *((actor *)argument);
    a.self = pthread_self();
    a.fn(a.self);
}

int main() {
    int NUM_THREADS = 5;
    pthread_t threads[NUM_THREADS];

    for ( int i = 0; i < NUM_THREADS; i++ ) {
        actor a;
        a.fn = print;

        int s = pthread_create(&threads[i], NULL, wiring, &a);
    }

    for ( int i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }

    return 0;
}

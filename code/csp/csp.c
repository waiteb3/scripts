#include <pthread.h>
#include <stdio.h>

typedef struct {
    void (*fn)();
} actor;


void print() {
    printf("test\n");
}

int main() {
    actor a;

    a.fn = print;

    a.fn();

    return 0;
}

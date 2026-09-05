#include <stdio.h>
#include <stdlib.h>

int main() {
    int *ptr = malloc(5 * sizeof(int));

    if (ptr == NULL) {
        printf("Memory allocation failed\n");
        return 1;
    }

    for (int i = 0; i < 5; i++) {
        ptr[i] = i + 1+64;
    }

    for (int i = 0; i < 5; i++) {
        printf("%c ", (char)ptr[i]);
    }

    printf("sizeof int %ld\n", sizeof(int));

    // REALLOC (resize allocated memory)
    int newSize = 10;
    ptr = realloc(ptr, newSize * sizeof(int));

    for (int i = 0; i < newSize; i++){
        printf("%d ", ptr[i]);
    }


    free(ptr);

    return 0;
}
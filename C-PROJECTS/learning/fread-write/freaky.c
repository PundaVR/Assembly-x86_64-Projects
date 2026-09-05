#include <stdio.h>
#include <string.h>
int main() {
    FILE *fptr = fopen("gfg.bin", "wb");
    
    // Create a string for write into the file
    char s[] = "1234567890";//char s[] = "Hello, sigma 12345678";
    
// DO BOOLS WITH SINGLE BITS?
    int guitar = 1, manager = 0, appliance = 1, channel = 1;
    unsigned char in_flags = 0;
    in_flags |= (guitar    & 1) << 1;
    in_flags |= (manager   & 1) << 3;
    in_flags |= (appliance & 1) << 5;
    in_flags |= (channel   & 1) << 6;

    fwrite(in_flags, sizeof(char), 4, fptr);

    // Wrtie the string into the file using fwrite
    int n = fwrite(s, sizeof(char), strlen(s), fptr);
    
    // Here we check whole file is written into file
    if(strlen(s) == n){
        printf("String written successfully\n");
    }
  
    fclose(fptr);

    // OPEN FILE
    FILE *fr = fopen("gfg.bin", "rb");
    #define BUFFER_SIZE 11
    char buffer[BUFFER_SIZE];
    size_t sizeOfRead = fread(buffer, sizeof(char), BUFFER_SIZE, fr);

    printf("Size of read file: %ld\n", sizeOfRead);
    buffer[10] = '\0';

    for (int i = 0; i < BUFFER_SIZE; i++){
        printf("%c ", buffer[i]);
    }
    fclose(fr);


    printf("\nsizeof char = %ld\n", sizeof(char));
    return 0;
}


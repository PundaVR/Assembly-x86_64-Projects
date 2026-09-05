#include <stdio.h>
#include <stdlib.h>

#define CENT_LEN 11
#define STRUCT_SIZE 56
typedef struct
{                            // total bytes = 56
    long purpose;            // 8 bytes
    double power;            // 8 bytes
    unsigned int cracker;    // 4 bytes
    short grandfather;       // 2 bytes
    unsigned char guitar;    // 1 byte
    unsigned char appliance; // 1 byte
    unsigned char channel;   // 1 byte
    unsigned short manager;  // 2 bytes
    char cent[CENT_LEN];     // 11 bytes
    unsigned char drain;     // 1 byte
    char spiders;            // 1 byte
    float clover;            // 4 bytes
    unsigned char lamp;      // 1 byte
    float food;              // 4 bytes
    float help;              // 4 bytes
    unsigned short badge;    // 2 bytes
    char flowers;            // 1 byte
} Record;

// hideSpecialChar set to 1 to replace shit with '.'
void PrintFileData(FILE *f)
{
    fseek(f, 0L, SEEK_END);       // seek to front
    int inputFileSize = ftell(f); // get position in stream for pointer?
    rewind(f);                    // rewind to start

    unsigned char buffer[inputFileSize];
    size_t sizeOfRead = fread(buffer, sizeof(char), inputFileSize, f);

    printf("Input File:\n");
    for (int i = 0; i < inputFileSize; i++)
    {
        unsigned char c = buffer[i]; // < 65 ? '.' : buffer[i];
        printf("%c ", c < 65 || c > 122 ? '.' : c);
    }
    printf("\nInput Size: %d\n", inputFileSize);
}

void ReadData(FILE *f, Record *records)
{
    rewind(f); // make sure to rewind f incase its been moved
    unsigned char buffer[STRUCT_SIZE];
    size_t sizeOfRead = fread(buffer, sizeof(char), STRUCT_SIZE, f);

    printf("Input File:\n");
    for (int i = 0; i < STRUCT_SIZE; i++)
    {
        unsigned char byte = buffer[i]; // < 65 ? '.' : buffer[i];

        /*
        look at each byte
        insert ZERO at 3,5,21,31
        byte 19 holds bitpacked flag
        more bullshit
        */

        // set the zero bytes
        if (i == 3 || i == 5 || i == 21 || i == 31)
        {
            unsigned char *byte_ptr = (unsigned char *)records;

            // Move to the offset and assign the new value
            *(byte_ptr + i) = 0;
        }

        printf("%c ", byte < 65 || byte > 122 ? '.' : byte);
    }

    printf("\nInput Size: %d\n", 696969);
}

int main(int argc, char **argv)
{
    printf("hello\n\n");

    // if (argc != 3) {
    //     fprintf(stderr, "Usage: %s inputfile.bin outputfile.bin\n", argv[0]);
    //     exit(EXIT_FAILURE);
    // }

    FILE *in_fp = fopen("input-1.bin", "rb"); // FILE *in_fp = fopen(argv[1], "rb");
    if (in_fp == NULL)
    {
        fprintf(stderr, "%s: cannot open input file '%s'\n", argv[0], argv[1]);
        exit(EXIT_FAILURE);
    }

    //// Must open output file in binary write mode ("wb")
    FILE *out_fp = fopen("test1.bin", "wb"); // FILE *out_fp = fopen(argv[2], "wb");
    if (out_fp == NULL)
    {
        fprintf(stderr, "%s: cannot open output file '%s'\n", argv[0], argv[2]);
        fclose(in_fp);
        exit(EXIT_FAILURE);
    }

    size_t capacity = STRUCT_SIZE;
    Record *records = calloc(sizeof(Record), 1);//malloc(sizeof(Record));

    PrintFileData(in_fp);

    ReadData(in_fp, records);

    // remember to always clean up!
    free(records);
    fclose(in_fp);
    fclose(out_fp);
    printf("\nProgram End\n");
    return 0;
}

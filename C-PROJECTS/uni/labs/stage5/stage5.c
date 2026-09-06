#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CENT_LEN 11
#define STRUCT_SIZE 56
#pragma pack(push, 1) // fuck the padding ig
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
#pragma pack(pop)
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



void ANOTHER_DOGSHIT_ReadData(FILE *f, Record *records)
{
    rewind(f); // make sure to rewind f incase its been moved
    unsigned char buffer[STRUCT_SIZE];
    size_t sizeOfRead = fread(buffer, sizeof(char), STRUCT_SIZE, f);

    printf("ReadData():\n");

    rewind(f); // this does not work
    unsigned char *bytePtr = (unsigned char *)records;

    for (int i = 0; i < STRUCT_SIZE; i++) {
        // Read 1 byte from file into the i-th byte offset of the struct
        if (i == 3 || i == 5 || i == 21 || i == 31) 
        {
            fgetc(f);
            continue; // ignore zero bytes
        }
        if (i == 19) {
            //unsigned char byte = *(bytePtr+i);//(unsigned char *)(bytePtr+i); 
            unsigned char bitByte;
            fread(&bitByte, 1, 1, f);
            
            //printf("Bit 1: %d\n",(bitByte >> 0) & 1); // 1
            //printf("Bit 2: %d\n",(bitByte >> 1) & 1); // 0
            //printf("Bit 3: %d\n",(bitByte >> 2) & 1); // 0
            //printf("Bit 4: %d\n",(bitByte >> 3) & 1); // 0
            //printf("Bit 5: %d\n",(bitByte >> 4) & 1); // 0
            //printf("Bit 6: %d\n",(bitByte >> 5) & 1); // 0
            //printf("Bit 7: %d\n",(bitByte >> 6) & 1); // 0
            //printf("Bit 8: %d\n",(bitByte >> 7) & 1); // 0

            //bytePtr[i] = (bitByte >> 0) & 1;
            //i++;
            //bytePtr[i] = (bitByte >> 1) & 1;
            //i++;
            //bytePtr[i] = (bitByte >> 2) & 1;
            //i++;
            //bytePtr[i] = (bitByte >> 3) & 1;
            //i++;
            //bytePtr[i] = (bitByte >> 4) & 1;
            records->guitar    = (bitByte >> 0) & 1; // Bit 0 -> guitar (offset 18)
            records->appliance = (bitByte >> 1) & 1; // Bit 1 -> appliance (offset 19)
            records->channel   = (bitByte >> 2) & 1; // Bit 2 -> channel (offset 20)
            records->manager   = (bitByte >> 3) & 1;
            i+=3;
            continue;
        }
        
        size_t readCount = fread(bytePtr + i, 1, 1, f);
        
        if (readCount == 1) {
            printf("Byte %2d updated: 0x%02x\n", i, bytePtr[i]);
        }
    }
    
    
    printf("\nInput Size: %d\n", 696969);
}


void ReadData(FILE *f, Record *records)
{
    rewind(f); // make sure to rewind f incase its been moved
    unsigned char b[STRUCT_SIZE];
    size_t sizeOfRead = fread(b, sizeof(char), STRUCT_SIZE, f);

    printf("ReadData():\n");
    
    rewind(f); // this does not work
    unsigned char flags = b[19];
    
    float  power_f32;
    double clover_f64, food_f64, help_f64;

    memcpy(&power_f32,  b +  6, 4);
    memcpy(&clover_f64, b + 10, 8);
    memcpy(&help_f64,   b + 22, 8);
    memcpy(&food_f64,   b + 32, 8);


    records->purpose     = (signed char)b[18];
    records->power       = power_f32;
    records->cracker     = (unsigned int)(b[40] | (b[41] << 8));
    records->grandfather = (signed char)b[1];
    records->guitar      = (flags & 0x02) ? 1 : 0;
    records->appliance   = (flags & 0x80) ? 1 : 0;
    records->channel     = (flags & 0x08) ? 1 : 0;
    records->manager     = (flags & 0x40) ? 1 : 0;
    memcpy(records->cent, b + 42, CENT_LEN);
    records->cent[CENT_LEN - 1] = '\0';
    records->drain       = b[30] & 1;
    records->spiders     = (char)b[2];
    records->clover      = (float)clover_f64;
    records->lamp        = b[4];
    records->food        = (float)food_f64;
    records->help        = (float)help_f64;
    records->badge       = b[0] & 1;
    records->flowers     = (char)b[20];

}

void PrintRecords(Record *records){
    printf("\npurpose: %ld", records->purpose);
    printf("\npower: %f", records->power);
    printf("\ncracker: %u", records->cracker);
    printf("\ngrandfather: %d", records->grandfather);
    printf("\nguitar: %u", records->guitar);
    printf("\nappliance: %u", records->appliance);
    printf("\nchannel: %u", records->channel);
    printf("\nmanager: %hu", records->manager);
    printf("\ncent: %s", records->cent);
    printf("\ndrain: %u", records->drain);
    printf("\nspiders: %c", records->spiders);
    printf("\nclover: %f", records->clover);
    printf("\nlamp: %u", records->lamp);
    printf("\nfood: %f", records->food);
    printf("\nhelp: %f", records->help);
    printf("\nbadge: %hu", records->badge);
    printf("\nflowers: %c", records->flowers);
}

void WriteRecordsToFile(FILE *f, Record *records){
    fwrite(records, STRUCT_SIZE, 1, f); 
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
    Record *records = calloc(sizeof(Record), 1);// calloc zeros out memory (better than malloc?) //malloc(sizeof(Record));

    PrintFileData(in_fp);

    ReadData(in_fp, records);


    PrintRecords(records);

    WriteRecordsToFile(out_fp, records);

    // remember to always clean up!
    free(records);
    fclose(in_fp);
    fclose(out_fp);
    printf("\nProgram End\n");
    return 0;
}

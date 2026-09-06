#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CENT_LEN 11
#define STRUCT_SIZE 56
#define INPUT_FILE_STRUCT_SIZE 53

/*
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
*/

#pragma pack(push, 1) // fuck the padding ig
struct Record
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
};
#pragma pack(pop)

// hideSpecialChar set to 1 to replace shit with '.'
// returns filesize
int PrintFileData(FILE *f)
{
    rewind(f);
    fseek(f, 0L, SEEK_END);       // seek to end
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
    rewind(f);
    return inputFileSize;
}

void ReadData(FILE *f, struct Record *records, int index)
{
    unsigned char b[INPUT_FILE_STRUCT_SIZE];
    fread(b, sizeof(char), INPUT_FILE_STRUCT_SIZE, f);

    printf("ReadData():\n");

    unsigned char flags = b[19];

    float power_f32;
    double clover_f64, food_f64, help_f64;

    memcpy(&power_f32, b + 6, 4);
    memcpy(&clover_f64, b + 10, 8);
    memcpy(&help_f64, b + 22, 8);
    memcpy(&food_f64, b + 32, 8);

    records[index].purpose = (signed char)b[18];
    records[index].power = power_f32;
    records[index].cracker = (unsigned int)(b[40] | (b[41] << 8));
    records[index].grandfather = (signed char)b[1];
    records[index].guitar = (flags & 0x02) ? 1 : 0;
    records[index].appliance = (flags & 0x80) ? 1 : 0;
    records[index].channel = (flags & 0x08) ? 1 : 0;
    records[index].manager = (flags & 0x40) ? 1 : 0;

    memcpy(records[index].cent, b + 42, CENT_LEN);
    records[index].cent[CENT_LEN - 1] = '\0';

    records[index].drain = b[30] & 1;
    records[index].spiders = (char)b[2];
    records[index].clover = (float)clover_f64;
    records[index].lamp = b[4];
    records[index].food = (float)food_f64;
    records[index].help = (float)help_f64;
    records[index].badge = b[0] & 1;
    records[index].flowers = (char)b[20];
}

void PrintRecords(struct Record *records, int index)
{
    printf("\npurpose: %ld", records[index].purpose);
    printf("\npower: %f", records[index].power);
    printf("\ncracker: %u", records[index].cracker);
    printf("\ngrandfather: %d", records[index].grandfather);
    printf("\nguitar: %u", records[index].guitar);
    printf("\nappliance: %u", records[index].appliance);
    printf("\nchannel: %u", records[index].channel);
    printf("\nmanager: %hu", records[index].manager);
    printf("\ncent: %s", records[index].cent);
    printf("\ndrain: %u", records[index].drain);
    printf("\nspiders: %c", records[index].spiders);
    printf("\nclover: %f", records[index].clover);
    printf("\nlamp: %u", records[index].lamp);
    printf("\nfood: %f", records[index].food);
    printf("\nhelp: %f", records[index].help);
    printf("\nbadge: %hu", records[index].badge);
    printf("\nflowers: %c", records[index].flowers);
}

void WriteRecordsToFile(FILE *f, struct Record *records, int expectedRecords)
{
    fwrite(records, sizeof(struct Record), expectedRecords, f);
}

int CompareStrings(const void *a, const void *b)
{
    // Cast the generic pointers to actual string pointers (char **)

    return strncmp(*(const char **)&a, *(const char **)&b, CENT_LEN);
}

void ReorderRecords(struct Record *records, int expectedRecord)
{
    printf("\n========================\nRecorderRecords() Going through %d records\n", expectedRecord);

    char cents[CENT_LEN * expectedRecord];
    int order[expectedRecord];

    for (int i = 0; i < expectedRecord; i++)
    {
        // print the original order of cent
        printf("\n\n%d Record: %s\n", i, records[i].cent);

        char word[CENT_LEN]; // = records[i].cent;
        memcpy(&word, &records[i].cent, CENT_LEN);
        for (int j = 0; j < CENT_LEN; j++)
        {

            printf("%c", word[j]);
        }

        memcpy(&cents[i * CENT_LEN], &word, CENT_LEN);
    }

    printf("Confirming 'cents' holds all strings:\n");
    for (int x = 0; x < expectedRecord; x++)
    {
        for (int y = 0; y < CENT_LEN; y++)
        {
            char c = cents[x * CENT_LEN + y];
            printf("%c", c < 65 ? '.' : c);
        }
    }

    // now we need to reorder!

    printf("\nREORDERING STRINGS!!\n");

    for (int a = 0; a < expectedRecord; a++)
    {
        int cmp = strncmp(&cents[a * CENT_LEN], &cents[1 * CENT_LEN], CENT_LEN);
        printf("Compare %d = %d\n", a, cmp);

        qsort(cents, expectedRecord, CENT_LEN, CompareStrings);

    }

    // printing reorderd strings
    for (int b = 0; b < expectedRecord; b++)
    {
        for (int y = 0; y < CENT_LEN; y++)
        {
            char c = cents[b * CENT_LEN + y];
            printf("%c", c < 65 ? '.' : c);
        }
    }


    
    //
    // now reorder struct lol
    //
    printf("Reordering struct!\n");
    for (int z = 0; z < expectedRecord; z++){
        // create temp 
        
        // find index of struct with matching cent
        printf("Comparing ordered index %d\n", z);
        int matchingIndex = -1;
        for (int m = 0; m < expectedRecord; m++){

            if (strncmp(records[m].cent, &cents[z*CENT_LEN], CENT_LEN) == 0) {
                // STRING IS EQUAL
                printf("index %d IS MATCHING\n", m);
                matchingIndex = m;

            }
            else printf("index %d not matching\n", m);
        }

        if (matchingIndex == -1) printf("NO MATCHING INDEX FOUND FOR %d\n", z);

        struct Record temp; // we need to move temp in z (temp will be m)
        memcpy(&temp, &records[matchingIndex], sizeof(struct Record));
        memcpy(&records[matchingIndex], &records[z], sizeof(struct Record));
        memcpy(&records[z], &temp, sizeof(struct Record));

    }


    // print the reorgansied order
    for (int i = 0; i < expectedRecord; i++) {
        printf("\n------------\n");
        PrintRecords(records, i);
    
    }
    ///////ppp
    // unsigned char block[expectedRecord*sizeof(struct Record)];

    // struct Record temp;
    // memcpy(&temp, &block[0], sizeof(struct Record));
    // memcpy(&block[0], &block[1], sizeof(struct Record));
    // memcpy(&block[1], &temp, sizeof(struct Record));
}

int main(int argc, char **argv)
{
    printf("hello\n\n");

     if (argc != 3) {
         fprintf(stderr, "Usage: %s inputfile.bin outputfile.bin\n", argv[0]);
         exit(EXIT_FAILURE);
     }

    //FILE *in_fp = fopen("input-5.bin", "rb"); 
    FILE *in_fp = fopen(argv[1], "rb");
    if (in_fp == NULL)
    {
        fprintf(stderr, "%s: cannot open input file '%s'\n", argv[0], argv[1]);
        exit(EXIT_FAILURE);
    }

    //// Must open output file in binary write mode ("wb")
    //FILE *out_fp = fopen("test1.bin", "wb"); 
    FILE *out_fp = fopen(argv[2], "wb");
    if (out_fp == NULL)
    {
        fprintf(stderr, "%s: cannot open output file '%s'\n", argv[0], argv[2]);
        fclose(in_fp);
        exit(EXIT_FAILURE);
    }

    int fileSize = PrintFileData(in_fp);
    int expectedRecords = (int)(fileSize / INPUT_FILE_STRUCT_SIZE);
    printf("INPUT_FILE_STRUCT_SIZE %d\n", INPUT_FILE_STRUCT_SIZE);
    printf("Expected records = %d\n", expectedRecords);

    size_t capacity = expectedRecords * sizeof(struct Record);

    // Record *records = calloc(sizeof(Record), expectedRecords); // calloc zeros out memory (better than malloc?) //malloc(sizeof(Record));

    struct Record *records = (struct Record *)calloc(sizeof(struct Record), expectedRecords);

    for (int i = 0; i < expectedRecords; i++)
    {
        printf("\n=====================\nREADING STRUCT %d\n", i);
        ReadData(in_fp, records, i);
        PrintRecords(records, i);
    }

    ReorderRecords(records, expectedRecords);

    // ReadData(in_fp, records);

    WriteRecordsToFile(out_fp, records, expectedRecords);

    // remember to always clean up!
    free(records);
    fclose(in_fp);
    fclose(out_fp);
    printf("\nProgram End\n");
    return 0;
}

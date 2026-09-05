#include <stdio.h>
#include <stdlib.h>

#define CENT_LEN 11

typedef struct {
    long            purpose;        // int - 8 bytes
    double          power;          // float - 8 bytes
    unsigned int    cracker;        // u_int - 4 bytes
    short           grandfather;    // int - 2 bytes
    unsigned char   guitar;         // bool - 1 byte
    unsigned char   appliance;      // bool - 1 byte
    unsigned char   channel;        // bool - 1 byte
    unsigned short  manager;        // bool - 2 bytes
    char            cent[CENT_LEN]; // 11 bytes
    unsigned char   drain;          // bool - 1 byte
    char            spiders;        // char - 1 byte
    float           clover;         // float - 4 bytes
    unsigned char   lamp;           // u_int - 1 byte
    float           food;           // float - 4 bytes
    float           help;           // float - 4 bytes
    unsigned short  badge;          // bool - 2 bytes
    char            flowers;        // char - 1 byte
} record_t;


// Returns 1 on success, 0 if EOF.
static int ReadRecord(FILE *fp, record_t *r)
{
    if (fread(&r->purpose, 8, 1, fp) != 1) {    // first read detects EOF  
        return 0;
    }

    fread(&r->power, 8, 1, fp);
    fread(&r->cracker, 4, 1, fp);
    fread(&r->grandfather, 2, 1, fp);
    fread(&r->guitar, 1, 1, fp);
    fread(&r->appliance, 1, 1, fp);
    fread(&r->channel, 1, 1, fp);
    fread(&r->manager, 2, 1, fp);
    fread(r->cent, 1, CENT_LEN, fp);
    fread(&r->drain, 1, 1, fp);
    fread(&r->spiders, 1, 1, fp);
    fread(&r->clover, 4, 1, fp);
    fread(&r->lamp, 1, 1, fp);
    fread(&r->food, 4, 1, fp);
    fread(&r->help, 4, 1, fp);
    fread(&r->badge, 2, 1, fp);
    fread(&r->flowers, 1, 1, fp);

    return 1;
}



static void PrintRecord(const record_t *r)
{
    char cent[CENT_LEN + 1];    // new char array (with null string)
    int  i;

    for (i = 0; i < CENT_LEN; i++) {
        cent[i] = r->cent[i];
    }
    cent[CENT_LEN] = '\0'; // add null string to end of cent

    printf("%ld, ", r->purpose);
    printf("%f, ",  r->power);
    printf("%u, ",  r->cracker);
    printf("%x, ",  (unsigned short)r->grandfather);
    printf("%d, ",  (int)r->guitar);
    printf("%d, ",  (int)r->appliance);
    printf("%d, ",  (int)r->channel);
    printf("%d, ",  (int)r->manager);
    printf("%s, ",  cent);
    printf("%d, ",  (int)r->drain);
    printf("%c, ",  r->spiders);
    printf("%f, ",  (double)r->clover);
    printf("%u, ",  (unsigned int)r->lamp);
    printf("%f, ",  (double)r->food);
    printf("%f, ",  (double)r->help);
    printf("%d, ",  (int)r->badge);
    printf("%c\n",  r->flowers);
}


static void PrintHeader(void)
{
    printf("purpose, power, cracker, grandfather, guitar, appliance, "
           "channel, manager, cent, drain, spiders, clover, lamp, food, "
           "help, badge, flowers\n");
}


int main(int argc, char **argv)
{
    record_t    r;
    int         a;
    int         header_done = 0;

    if (argc < 2) {
        fprintf(stderr, "Usage: %s datafile ...\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    for (a = 1; a < argc; a++) {
        FILE *fp = fopen(argv[a], "rb");

        if (fp == NULL) {
            fprintf(stderr, "%s: cannot open file '%s'\n", argv[0], argv[a]);
            exit(EXIT_FAILURE);
        }

        if (!header_done) {
            PrintHeader();
            header_done = 1;
        }

        while (ReadRecord(fp, &r)) {
            PrintRecord(&r);
        }

        fclose(fp);
    }

    return 0;
}
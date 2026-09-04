#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CENT_LEN 11

typedef struct {
    long            purpose;        // 8 bytes
    double          power;          // 8 bytes
    unsigned int    cracker;        // 4 bytes
    short           grandfather;    // 2 bytes
    unsigned char   guitar;         // 1 byte
    unsigned char   appliance;      // 1 byte
    unsigned char   channel;        // 1 byte
    unsigned short  manager;        // 2 bytes
    char            cent[CENT_LEN]; // 11 bytes
    unsigned char   drain;          // 1 byte
    char            spiders;        // 1 byte
    float           clover;         // 4 bytes
    unsigned char   lamp;           // 1 byte
    float           food;           // 4 bytes
    float           help;           // 4 bytes
    unsigned short  badge;          // 2 bytes
    char            flowers;        // 1 byte
} record_t;

// Reads one raw binary record field-by-field.
// Fields are stored on disk in the same types as the struct, but the
// struct itself is padded, so it cannot be read in one go.
// Returns 1 only if EVERY field was successfully read.
static int ReadRecord(FILE *fp, record_t *r)
{
    if (fread(&r->purpose, 8, 1, fp) != 1) return 0;
    if (fread(&r->power, 8, 1, fp) != 1) return 0;
    if (fread(&r->cracker, 4, 1, fp) != 1) return 0;
    if (fread(&r->grandfather, 2, 1, fp) != 1) return 0;
    if (fread(&r->guitar, 1, 1, fp) != 1) return 0;
    if (fread(&r->appliance, 1, 1, fp) != 1) return 0;
    if (fread(&r->channel, 1, 1, fp) != 1) return 0;
    if (fread(&r->manager, 2, 1, fp) != 1) return 0;
    if (fread(r->cent, 1, CENT_LEN, fp) != CENT_LEN) return 0;
    if (fread(&r->drain, 1, 1, fp) != 1) return 0;
    if (fread(&r->spiders, 1, 1, fp) != 1) return 0;
    if (fread(&r->clover, 4, 1, fp) != 1) return 0;
    if (fread(&r->lamp, 1, 1, fp) != 1) return 0;
    if (fread(&r->food, 4, 1, fp) != 1) return 0;
    if (fread(&r->help, 4, 1, fp) != 1) return 0;
    if (fread(&r->badge, 2, 1, fp) != 1) return 0;
    if (fread(&r->flowers, 1, 1, fp) != 1) return 0;

    return 1;
}

// Writes one record back to the output stream in raw binary format
static void WriteRecord(FILE *out_fp, const record_t *r)
{
    fwrite(&r->purpose, 8, 1, out_fp);
    fwrite(&r->power, 8, 1, out_fp);
    fwrite(&r->cracker, 4, 1, out_fp);
    fwrite(&r->grandfather, 2, 1, out_fp);
    fwrite(&r->guitar, 1, 1, out_fp);
    fwrite(&r->appliance, 1, 1, out_fp);
    fwrite(&r->channel, 1, 1, out_fp);
    fwrite(&r->manager, 2, 1, out_fp);
    fwrite(r->cent, 1, CENT_LEN, out_fp);
    fwrite(&r->drain, 1, 1, out_fp);
    fwrite(&r->spiders, 1, 1, out_fp);
    fwrite(&r->clover, 4, 1, out_fp);
    fwrite(&r->lamp, 1, 1, out_fp);
    fwrite(&r->food, 4, 1, out_fp);
    fwrite(&r->help, 4, 1, out_fp);
    fwrite(&r->badge, 2, 1, out_fp);
    fwrite(&r->flowers, 1, 1, out_fp);
}

// qsort comparison function.
// Operates on an array of POINTERS to records, so only pointers get moved.
// Fields are in the order given in filestruct-sort.txt.
static int CompareRecords(const void *a, const void *b)
{
    const record_t *r1 = *(const record_t **)a;
    const record_t *r2 = *(const record_t **)b;
    int cmp;

    // cent ascending
    cmp = strncmp(r1->cent, r2->cent, CENT_LEN);
    if (cmp != 0) return cmp;

    // lamp descending
    if (r1->lamp != r2->lamp) return (r1->lamp > r2->lamp) ? -1 : 1;

    // appliance ascending
    if (r1->appliance != r2->appliance) return (r1->appliance < r2->appliance) ? -1 : 1;

    // food descending
    if (r1->food != r2->food) return (r1->food > r2->food) ? -1 : 1;

    // grandfather descending
    if (r1->grandfather != r2->grandfather) return (r1->grandfather > r2->grandfather) ? -1 : 1;

    // help ascending
    if (r1->help != r2->help) return (r1->help < r2->help) ? -1 : 1;

    // drain ascending
    if (r1->drain != r2->drain) return (r1->drain < r2->drain) ? -1 : 1;

    // clover descending
    if (r1->clover != r2->clover) return (r1->clover > r2->clover) ? -1 : 1;

    // spiders descending
    if (r1->spiders != r2->spiders) return (r1->spiders > r2->spiders) ? -1 : 1;

    // channel descending
    if (r1->channel != r2->channel) return (r1->channel > r2->channel) ? -1 : 1;

    // cracker descending
    if (r1->cracker != r2->cracker) return (r1->cracker > r2->cracker) ? -1 : 1;

    // purpose ascending
    if (r1->purpose != r2->purpose) return (r1->purpose < r2->purpose) ? -1 : 1;

    // badge ascending
    if (r1->badge != r2->badge) return (r1->badge < r2->badge) ? -1 : 1;

    // flowers ascending
    if (r1->flowers != r2->flowers) return (r1->flowers < r2->flowers) ? -1 : 1;

    // manager ascending
    if (r1->manager != r2->manager) return (r1->manager < r2->manager) ? -1 : 1;

    // power descending
    if (r1->power != r2->power) return (r1->power > r2->power) ? -1 : 1;

    // guitar ascending
    if (r1->guitar != r2->guitar) return (r1->guitar < r2->guitar) ? -1 : 1;

    return 0;
}

int main(int argc, char **argv)
{
    if (argc != 3) {
        fprintf(stderr, "Usage: %s inputfile.bin outputfile.bin\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    FILE *in_fp = fopen(argv[1], "rb");
    if (in_fp == NULL) {
        fprintf(stderr, "%s: cannot open input file '%s'\n", argv[0], argv[1]);
        exit(EXIT_FAILURE);
    }

    // Must open output file in binary write mode ("wb")
    FILE *out_fp = fopen(argv[2], "wb");
    if (out_fp == NULL) {
        fprintf(stderr, "%s: cannot open output file '%s'\n", argv[0], argv[2]);
        fclose(in_fp);
        exit(EXIT_FAILURE);
    }

    // Dynamic Array Allocation
    size_t capacity = 10;
    size_t count = 0;
    record_t *records = malloc(capacity * sizeof(record_t));

    if (records == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        fclose(in_fp);
        fclose(out_fp);
        exit(EXIT_FAILURE);
    }

    // Read records into the dynamic array.
    // Capacity is ensured BEFORE each read so records[count] is always valid.
    for (;;) {
        if (count == capacity) {
            capacity *= 2;
            record_t *temp = realloc(records, capacity * sizeof(record_t));
            if (temp == NULL) {
                fprintf(stderr, "Memory reallocation failed\n");
                free(records);
                fclose(in_fp);
                fclose(out_fp);
                exit(EXIT_FAILURE);
            }
            records = temp;
        }
        if (!ReadRecord(in_fp, &records[count])) break;
        count++;
    }

    // Build an array of pointers so qsort only swaps pointers
    record_t **sorted = malloc(count * sizeof(record_t *));
    if (sorted == NULL && count > 0) {
        fprintf(stderr, "Memory allocation failed\n");
        free(records);
        fclose(in_fp);
        fclose(out_fp);
        exit(EXIT_FAILURE);
    }

    for (size_t i = 0; i < count; i++) {
        sorted[i] = &records[i];
    }

    qsort(sorted, count, sizeof(record_t *), CompareRecords);

    // Write binary records to output file
    for (size_t i = 0; i < count; i++) {
        WriteRecord(out_fp, sorted[i]);
    }

    // cleanup!!
    free(sorted);
    free(records);
    fclose(in_fp);
    fclose(out_fp);

    return 0;
}
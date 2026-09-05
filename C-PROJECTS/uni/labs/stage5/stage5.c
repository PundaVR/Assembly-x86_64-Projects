#include <stdio.h>
#include <stdlib.h>

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
// The input file stores fields in narrower/wider types than the struct,
// so each field is read into a temporary of the on-disk type and converted.
// Returns 1 only if EVERY field was successfully read.
static int ReadRecord(FILE *fp, record_t *r)
{
    int            in_purpose;
    float          in_power;
    float          in_cracker;
    float          in_grandfather;
    unsigned char  in_flags;
    int            in_drain;
    double         in_clover;
    unsigned short in_lamp;
    double         in_food;
    double         in_help;
    int            in_badge;

    if (fread(&in_purpose, 4, 1, fp) != 1) return 0;
    if (fread(&in_power, 4, 1, fp) != 1) return 0;
    if (fread(&in_cracker, 4, 1, fp) != 1) return 0;
    if (fread(&in_grandfather, 4, 1, fp) != 1) return 0;
    if (fread(&in_flags, 1, 1, fp) != 1) return 0;
    if (fread(r->cent, 1, CENT_LEN, fp) != CENT_LEN) return 0;
    if (fread(&in_drain, 4, 1, fp) != 1) return 0;
    if (fread(&r->spiders, 1, 1, fp) != 1) return 0;
    if (fread(&in_clover, 8, 1, fp) != 1) return 0;
    if (fread(&in_lamp, 2, 1, fp) != 1) return 0;
    if (fread(&in_food, 8, 1, fp) != 1) return 0;
    if (fread(&in_help, 8, 1, fp) != 1) return 0;
    if (fread(&in_badge, 4, 1, fp) != 1) return 0;
    if (fread(&r->flowers, 1, 1, fp) != 1) return 0;

    r->purpose     = in_purpose;
    r->power       = in_power;
    r->cracker     = (unsigned int)in_cracker;
    r->grandfather = (short)in_grandfather;

    r->guitar    = (in_flags >> 1) & 1;
    r->manager   = (in_flags >> 3) & 1;
    r->appliance = (in_flags >> 5) & 1;
    r->channel   = (in_flags >> 6) & 1;

    r->drain  = in_drain ? 1 : 0;
    r->clover = (float)in_clover;
    r->lamp   = (unsigned char)in_lamp;
    r->food   = (float)in_food;
    r->help   = (float)in_help;
    r->badge  = in_badge ? 1 : 0;

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

    // Write binary records to output file
    for (size_t i = 0; i < count; i++) {
        WriteRecord(out_fp, &records[i]);
    }

    // cleanup!!
    free(records);
    fclose(in_fp);
    fclose(out_fp);

    return 0;
}
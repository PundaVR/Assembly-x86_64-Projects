#include <stdio.h>

struct record {
    long purpose;        // int - 8 bytes
    double power;             // float - 8 bytes
    unsigned int cracker;     // unsigned int - 4 bytes
    short grandfather;        // int - 2 bytes
    char guitar;              // bool - 1 byte
    char appliance;           // bool - 1 byte
    char channel;             // bool - 1 byte
    short manager;            // bool - 2 bytes
    char cent[11];            // fixed-length string holding at most 11 characters
    char drain;               // bool - 1 byte
    char spiders;             // char - 1 byte
    float clover;             // float - 4 bytes
    unsigned char lamp;       // unsigned int - 1 byte
    float food;               // float - 4 bytes
    float help;               // float - 4 bytes
    short badge;              // bool - 2 bytes
    char flowers;             // char - 1 byte
};

int main(int argc, char **argv)
{
    struct record a = {
        .purpose = 0223,           // 147 in octal notation
        .power = 7188.429688,
        .cracker = 0xB47,          // 2887 in hexadecimal notation
        .grandfather = -468,
        .guitar = 0,
        .appliance = 1,
        .channel = 1,
        .manager = 0,
        .cent = "noise",
        .drain = 1,
        .spiders = 't',
        .clover = 15006.412109f,
        .lamp = 3,
        .food = -0.000317f,
        .help = -0.084473f,
        .badge = 1,
        .flowers = '='
    };

    printf("purpose, power, cracker, grandfather, guitar, appliance, channel, manager, cent, drain, spiders, clover, lamp, food, help, badge, flowers\n");
    printf("%lld, %f, %u, %hx, %d, %d, %d, %d, %s, %d, %c, %f, %u, %f, %f, %d, %c\n",
           a.purpose,
           a.power,
           a.cracker,
           (unsigned short)a.grandfather,
           a.guitar,
           a.appliance,
           a.channel,
           a.manager,
           a.cent,
           a.drain,
           a.spiders,
           a.clover,
           a.lamp,
           a.food,
           a.help,
           a.badge,
           a.flowers);

    return 0;
}

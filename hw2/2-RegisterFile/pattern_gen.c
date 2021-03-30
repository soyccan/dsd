#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>

#define PATTERN_NUM 50

struct bin {
    char s[9]; // 8-bit binary string
};

// convert integer to N-bit binary string, big endian
#define binbe1(x) ((char*)&(struct bin){ .s = {'0' + (x & 1)} })

#define binbe2(x) ((char*)&(struct bin){ .s = {'0' + ((x >> 1) & 1), \
                                               '0' + (x & 1)} })

#define binbe3(x) ((char*)&(struct bin){ .s = {'0' + ((x >> 2) & 1), \
                                               '0' + ((x >> 1) & 1), \
                                               '0' + (x & 1)} })

#define binbe4(x) ((char*)&(struct bin){ .s = {'0' + ((x >> 3) & 1), \
                                               '0' + ((x >> 2) & 1), \
                                               '0' + ((x >> 1) & 1), \
                                               '0' + (x & 1)} })

#define binbe5(x) ((char*)&(struct bin){ .s = {'0' + ((x >> 4) & 1), \
                                               '0' + ((x >> 3) & 1), \
                                               '0' + ((x >> 2) & 1), \
                                               '0' + ((x >> 1) & 1), \
                                               '0' + (x & 1)} })

#define binbe6(x) ((char*)&(struct bin){ .s = {'0' + ((x >> 5) & 1), \
                                               '0' + ((x >> 4) & 1), \
                                               '0' + ((x >> 3) & 1), \
                                               '0' + ((x >> 2) & 1), \
                                               '0' + ((x >> 1) & 1), \
                                               '0' + (x & 1)} })

#define binbe7(x) ((char*)&(struct bin){ .s = {'0' + ((x >> 6) & 1), \
                                               '0' + ((x >> 5) & 1), \
                                               '0' + ((x >> 4) & 1), \
                                               '0' + ((x >> 3) & 1), \
                                               '0' + ((x >> 2) & 1), \
                                               '0' + ((x >> 1) & 1), \
                                               '0' + (x & 1)} })

#define binbe8(x) ((char*)&(struct bin){ .s = {'0' + ((x >> 7) & 1), \
                                               '0' + ((x >> 6) & 1), \
                                               '0' + ((x >> 5) & 1), \
                                               '0' + ((x >> 4) & 1), \
                                               '0' + ((x >> 3) & 1), \
                                               '0' + ((x >> 2) & 1), \
                                               '0' + ((x >> 1) & 1), \
                                               '0' + (x & 1)} })

// uint64_t bin(uint8_t x) {
//     if (x == 0)
//         return (uint64_t)('0' + (x & 1));
//     return (bin(x >> 1) << 8) | (uint64_t)('0' + (x & 1));
// }

int main() {
    uint8_t WEN, RW, RX, RY, busW;
    uint8_t busX_gold, busY_gold;
    uint8_t reg[8] = {0, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff};

    srand(time(0));

    for (int i = 0; i < PATTERN_NUM; i++) {
        // generate input
        WEN = rand() & 1;
        RW = rand() & 7;
        RX = rand() & 7;
        RY = rand() & 7;
        busW = rand() & 0xff;

        // simulate register read
        busX_gold = reg[RX];
        busY_gold = reg[RY];

        // simulate register write
        if (WEN && RW != 0) {
            reg[RW] = busW;
        }

        printf("%s_%s_%s_%s_%s // %hhx%hhx%hhx%hhx%02hhx\n", 
               binbe1(WEN), binbe3(RW), binbe3(RX), binbe3(RY), binbe8(busW),
               WEN, RW, RX, RY, busW);
        fprintf(stderr, "%02hhx%02hhx\n", busX_gold, busY_gold);
    }

    return 0;
}

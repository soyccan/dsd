#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>

#define PATTERN_NUM 50

int main() {
    uint8_t ctrl;
    uint8_t x, y;
    uint16_t out;

    srand(time(0));

    for (int i = 0; i < PATTERN_NUM; i++) {
        ctrl = rand() % 13;
        x = rand() & 0xff;
        y = rand() % 0xff;

        switch (ctrl) {
            case  0: out = (int16_t)(int8_t)x + (int16_t)(int8_t)y; break;
            case  1: out = (int16_t)(int8_t)x - (int16_t)(int8_t)y; break;
            case  2: out = x & y; break;
            case  3: out = x | y; break;
            case  4: out = ~x; break;
            case  5: out = x ^ y; break;
            case  6: out = ~(x | y); break;
            case  7: out = y << (x & 7); break;
            case  8: out = y >> (x & 7); break;
            case  9: out = (int8_t)x >> 1; break;
            case 10: out = (x << 1) | (x >> 7); break;
            case 11: out = (x << 7) | (x >> 1); break;
            case 12: out = x == y; break;
            default: exit(1);
        }

        printf("%01hhx%02hhx%02hhx\n", ctrl, x, y);
        fprintf(stderr, "%01hhx%02hhx\n", (out >> 8) & 1, (uint8_t)out);
    }

    return 0;
}

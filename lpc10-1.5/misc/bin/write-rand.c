#include "machine.h"

main()
{
    INT16 r;
    UINT8 msb, lsb;
    int	i;

    for (i = 0; i < 180; i++) {
        r = (INT16) rand();
	msb = (r >> 8) & 0xFF;
	lsb = r & 0xFF;
	printf("%c", msb);
	printf("%c", lsb);
    }
}

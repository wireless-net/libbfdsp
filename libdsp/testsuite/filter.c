
#include <stdio.h>
#include <filter.h>

int convolve_fr16_tst()
{
	int i;
	fract16 cin1[] = {0x7000, 0x6000, 0x5000, 0x4000};
	int clen1 = 4;
	fract16 cin2[] = {0x6000, 0x7000, 0x8000};
	int clen2 = 3;
	fract16 cout[6]; /* clen1 + clen2 - 1 */
	
	printf("convolve_fr16\n");
	convolve_fr16(cin1, clen1, cin2, clen2, cout);
	
	for (i = 0; i < 5; i++)
	printf ("0x%hx, ",cout[i]);
	printf ("0x%hx\n",cout[5]);

	printf ("should be 0x5400, 0x7fff, 0x2000, 0x1600, 0xe800, 0xc000\n");

	return 0;	
}

int main()
{
	convolve_fr16_tst();

	printf("Finished\n");
	return 0;
}



#include <stdio.h>
#include <vector.h>

int main()
{
	complex_float a[] = {{0.1, 0.2}, {0.3, 0.4}};
	complex_float b[] = {{0.5, 0.6}, {0.7, 0.8}};
	complex_float c;
	int n = 2;

	float a_f[] = {0, 0.5, 1.5, 2.0};
	float b_f[] = {2.0, 1.5, 0.5, 0};
	float c_f[4];
	int n_f = 4;
	int i;
	
	
	printf("cvecdotf\n");
	c = cvecdotf(a, b, n);
	printf ("(%f, %f) should be (-0.180000, 0.680000)\n", c.re, c.im);

	// cvecdotd - not supported

	printf("vecvaddf\n");
	vecvaddf(a_f, b_f, c_f, n_f);
	for (i = 0; i < 3; i++)
		printf ("%f, ", c_f[i]);
	printf ("%f (should be 2.000000, 2.000000, 2.000000, 2.000000)\n", c_f[3]);
	
	printf("vecvsubf\n");
	vecvsubf(a_f, b_f, c_f, n_f);
	for (i = 0; i < 3; i++)
		printf ("%f, ", c_f[i]);
	printf ("%f (should be -2.000000, -1.000000, 1.000000, 2.000000\n", c_f[3]);
	
	printf("vecvmltf\n");
	vecvmltf(a_f, b_f, c_f, n_f);
	for (i = 0; i < 3; i++)
		printf ("%f, ", c_f[i]);
	printf ("%f should be 0.000000, 0.750000, 0.750000, 0.000000\n", c_f[3]);
	
	printf("Finished\n");
	return 0;
}


/* Compute IFFT( CFFT( X ) ) = X */
/*	ifft.c
 *
 *	Example of the inverse FFT routine from the Blackfin DSP library.
 *
 *	Compare results in the output buffer "out" to the
 * 	desired output (files "out_re.ans" and out_im.ans")
 *
 *	See the documentation for more info on the DSP routines
 *
 */



#include <stdio.h>
#include <stdlib.h>
#include <filter.h>
#include <cycle_count.h>

#define N_FFT 64

complex_fract16    in[N_FFT];
complex_fract16    out_cfft[N_FFT];
complex_fract16    out_ifft[N_FFT];
complex_fract16    twiddle[N_FFT/2];
int                blk_exp;

void ifft_fr16_example(void)
{
  int i;

  /* Generate DC signal */
  for( i = 0; i < N_FFT; i++ )
    {
      in[i].re = 0x100;
      in[i].im = 0x0;
    }

  /* Populate twiddle table */
  twidfftrad2_fr16(twiddle, N_FFT);

  /* Compute Fast Fourier Transform */
  cfft_fr16(in, out_cfft, twiddle, 1, N_FFT, &blk_exp, 0);

  /* Reverse static scaling applied by cfft_fr16() function
     Apply the shift operation before the call to the
     ifft_fr16() function only if all the values in out_cfft
     = 0x100. Otherwise, perform the shift operation after the
     ifft_fr16() function has been computed.
  */
  for( i = 0; i < N_FFT; i++ )
    {
      out_cfft[i].re = out_cfft[i].re << 6; /* log2(N_FFT) = 6 */
      out_cfft[i].im = out_cfft[i].im << 6;
    }

  /* Compute Inverse Fast Fourier Transform
     The output signal from the ifft function will be the same
     as the DC signal of magnitude 0x100 which was passed into
     the cfft function.
  */
  ifft_fr16(out_cfft, out_ifft, twiddle, 1, N_FFT, &blk_exp, 0);
}

int main ()
{
  int i;
  FILE * outf = NULL;
  cycle_t start_count; 
  cycle_t final_count; 

  START_CYCLE_COUNT(start_count);

  ifft_fr16_example ();

  STOP_CYCLE_COUNT(final_count,start_count);
  PRINT_CYCLES("Number of cycles: ",final_count);

  for( i = 0; i < N_FFT; i++ )
    if (out_ifft[i].re != 0x100 || out_ifft[i].im != 0)
      abort ();

  printf ("Finished\n");

  return 0;
}

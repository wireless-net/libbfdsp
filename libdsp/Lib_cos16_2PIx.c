/*************************************************************************
 *
 * Lib_cos16_2PIx.c
 *
 * Copyright (C) 2000-2002 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ************************************************************************/

/*
   Fract16 Cosine function that works across the range 0 to 2pi

   Input:  0.0 .. 1.0
   Output  0x8000 .. 0x7fff

   The function has been designed specifically for the case:

   float   pi = 3.14...;
   fract16 x16;
   ..
   for( i=0; i<n; i++)
     x16 = ( cosf(2*pi*(i/n)) ) * 32768;
   ...

   The expression can now be rewriten as:
     x16 = __cos16_2PIx( i/n ); 
*/

#pragma file_attr("libFunc  =__cos16_2PIx")
#pragma file_attr("libFunc  =___cos16_2PIx")
/* called by gen_blackman_fr16 */
#pragma file_attr("libGroup =window.h")
#pragma file_attr("libFunc  =gen_blackman_fr16")
#pragma file_attr("libFunc  =__gen_blackman_fr16")
/* called by gen_hamming_fr16 */
#pragma file_attr("libFunc  =gen_hamming_fr16")
#pragma file_attr("libFunc  =__gen_hamming_fr16")
/* called by gen_hanning_fr16 */
#pragma file_attr("libFunc  =gen_hanning_fr16")
#pragma file_attr("libFunc  =__gen_hanning_fr16")
/* called by gen_harris_fr16 */
#pragma file_attr("libFunc  =gen_harris_fr16")
#pragma file_attr("libFunc  =__gen_harris_fr16")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =any")
#pragma file_attr("prefersMemNum =50")

#include <math_bf.h>
#include <fract_typedef.h>
#include "Lib_cos16_2PIx.h"


fract16 __cos16_2PIx(float x)
{
   fract16  x16;

   // get absolute value
   if( x < 0.0 )
     x = -x;

   // reduce input to fit into one period
   while( x >= 1.0 )
     x -= 1.0;

   // convert floating point value x [0..1) to fract16: x16 = [0x0..0x7fff)
   x16 = x * 32768;

   // The fractional cosine function is limited in their input and output
   // range:
   // cos_fr16():
   //       0x8000 (=-pi/2) = 0x0,
   //       0x0000 (=0)     = 0x7fff,
   //       0x7fff (=pi/2)  = 0x0
   //
   // To compute the cosine across the entire range of the phase, it is
   // necessary to modify the phase. This can be done by taking advantage
   // of the symmetrical nature of the cosine function:
   //   Q1: [  0   .. 1/2pi) :  cos_fr16(x), x=[0x0..0x7fff)
   //   Q2: [1/2pi ..    pi) : -cos_fr16(x), x=[0x8000..0x0)
   //   Q3: [   pi .. 3/2pi) : -cos_fr16(x), x=[0x0..0x7fff)
   //   Q4: [3/2pi ..   2pi) :  cos_fr16(x), x=[0x8000..0x0)
   //
   // To match the phase [0..1.0) to x requires at most two transformations.
   // Firstly, the range for the phase in each quarter Q1 to Q4 is 0.25
   // while the range for x is 1.0. Therefore the phase has to be multiplied
   // by four. For example:
   //   Q1: x=[0x0..0x7fff), phase=[0..0.25)    => phase_m = phase * 4
   //
   // Secondly for Q2, Q3 and Q4 it is also necessary to modify the phase
   // in such a way that it falls into the desired input range for x:
   //   Q2: x=[0x8000..0x0), phase=[0.25..0.50) => phase_m = (-0.5+phase)*4
   //   Q3: x=[0x0..0x7fff), phase=[0.50..0.75) => phase_m = ( phase-0.5)*4
   //   Q4: x=[0x8000..0x0), phase=[0.75..1.00) => phase_m = (-1.0+phase)*4
   //  
   if (x16 < 0x2000)       // < 0.25
   {
     // first quarter [0..pi/2):
     //   cos_fr16([0x0..0x7ff]) = [0x7ff..0)
     x16 = x16 * 4;
     return cos_fr16( x16 );
   }
   else if (x16 < 0x6000)  // < 0.75
   {
     // second quarter [pi/2..pi):
     //   -cos_fr16([0x8000..0x0)) = [0..0x8000)
     //
     // third quarter [pi..3/2pi):
     //   -cos_fr16([0x0..0x7ff]) = [0x8000..0)
     x16 = (x16 - 0x4000) * 4;
     return -cos_fr16( x16 );
   }
   else
   {
     // fourth quarter [3/2pi..pi):
     //   cos_fr16([0x8000..0x0)) = [0..0x7fff)
     x16 = (0x8000 + x16) * 4 ;
     return cos_fr16( x16 );
   }
}


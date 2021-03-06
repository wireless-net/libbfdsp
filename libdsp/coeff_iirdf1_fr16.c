/************************************************************************
 *
 * coeff_iirdf1_fr16.c
 *
 * Copyright (C) 2004 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ************************************************************************/
#include <fract.h>
#include <fract_math.h>
#include <math.h>
#include <filter.h>
#include <libetsi.h>

#pragma file_attr("libGroup =filter.h")
#pragma file_attr("libFunc  =coeff_iirdf1_fr16")
#pragma file_attr("libFunc  =__coeff_iirdf1_fr16")
#pragma file_attr("libFunc  =conj")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =any")       // we'll only normally call this
#pragma file_attr("prefersMemNum =50")     // fn a couple of times

#define  ETSI_SOURCE

/* Utility function to convert A and B filter coefficients from
 * 32-bit floating point format to fract16. Scaling is performed
 * if required. The function is designed to be used in conjunction 
 * with the iirdf1_fr16() IIR function. The iir function reverts any 
 * scaling applied to the coefficients, thus eliminating the need to 
 * scale the output generated by the iir.
 *
 * Order of Coefficients (using nstages = 1 as example): 
 *
 *   acoeff[2] = {A1, A2}      (A0 assumed to be 1.0) 
 *   bcoeff[3] = {B0, B1, B2}
 *   coeff[6]  = {B0, A1, B1, A2, B2, Scaling Factor}  
 *
 */

#pragma optimize_for_space
void
_coeff_iirdf1_fr16 
    (const float  acoeff[],   /* A-Coefficients in float format  */
     const float  bcoeff[],   /* B-Coefficients in float format  */
     fract16      coeff[],    /* Coefficients in fract16 format  */
     int          nstages     /* Number of biquad stages         */
    )
{
  int    i, indx ;
  int    max_val; 
  short  scale_adj;           /* Variable must be word sized     */   
  float  max_coeff, convflt2f32;


  /* Need to scale coefficients if 
   * acoeff[i] or bcoeff[i] > (float)0x7FFF   [~0.999969]
   */
  
  /* Find coefficient with largest absolute value */
  max_coeff = fabsf(bcoeff[0]);
  for (i = 0; i < (nstages*2); i++)
  {
     max_coeff = fmaxf(max_coeff,fmaxf(fabsf(acoeff[i]),fabsf(bcoeff[i+1])));
  }

  /* Find scale_adj: ( (int)max_val / 2^scale_adj ) < 1 */
  scale_adj = 0;
  max_val = (int)max_coeff;
  while( max_val >= 1)
  {
     max_val = max_val >> 1;
     scale_adj++;
  }


  /* Convert coefficients to fixed-point, 
   * scale by scale_adj and negate a cofficients
   *
   * Order coeff:  b[0], a[0], 
   *               ..., 
   *               b[2*nstages], a[2*nstages], b[2*nstages+1], scale_adj
   */
  convflt2f32 = (float) (32768 >> scale_adj);
  indx = 0;
  for (i = 0; i < ((nstages*4)+1); i += 2)
  {
     coeff[i] = sat_fr1x32((fract32)(convflt2f32 * bcoeff[indx++]));
  }
  
  indx = 0;
  for (i = 1; i < (nstages*4); i += 4)
  {
     coeff[i]   = negate_fr1x16(sat_fr1x32((fract32)(convflt2f32 * acoeff[indx++])));
     coeff[i+2] = negate_fr1x16(sat_fr1x32((fract32)(convflt2f32 * acoeff[indx++])));
  }
  coeff[i] = scale_adj;
	
}

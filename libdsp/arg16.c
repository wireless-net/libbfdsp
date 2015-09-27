// Copyright (C) 2000, 2001 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/**************************************************************************
   File: arg16.c
 
   This function calculates the phase of the complex number a.
    
***************************************************************************/

#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =__arg_fr16")
#pragma file_attr("libFunc  =arg_fr16")
/* Called by cartesian_fr16 */
#pragma file_attr("libFunc  =__cartesian_fr16")
#pragma file_attr("libFunc  =cartesian_fr16")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")


#include <math_bf.h>
#include <fract.h>
#include <fract_complex.h>

fract16 arg_fr16 ( complex_fract16 a )
{
  // Phase = atan( a.imaginary / a.real) / 2*pi,    phase = [0..1.0)

  fract16  phase;

  phase = atan2_fr16(a.im, a.re);

  if( phase > 0 )
  {
    // atan2_fr16( [0..0.5) ) = [0x0..0x7fff]
    // Expected phase :         [0..0.5)
    // => Need to divide output from atan2_fr16 by 2

    phase = multr_fr1x16(phase,0x4000);

  }
  else if( phase < 0 )
  {
    // atan2_fr16( [0.5..1.0) ) = [0x8000..0x0)
    // Expected phase :           [0.5..1.0)
    // => Need to scale by:       (2.0 + output atan2_fr16) / 2
    //                  = 1.0 + output/2
    //                  = (1.0 - max fract16 + max fract16) + output/2
    //                  = (max fract16 + output/2) + (1.0 - max fract16)

    phase = (0x7fff + multr_fr1x16(phase,0x4000)) + 0x1;

  }

  return( phase );

}

/* end of file */


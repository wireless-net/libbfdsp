// Copyright (C) 2000 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/*______________________________________________________________________

  Func name   : frexpf

  ----------------------------------------------------------------------------

  Purpose     : This function splits a 32-bit float input into its mantissa
                and exponent.
  Description : This function calculates the mantissa and exponent
                of input number x.
   _____________________________________________________________________
*/

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =frexpf")
#pragma file_attr("libFunc  =__frexpf")
#pragma file_attr("libFunc  =frexp")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <float.h>
#include <math.h>
#include "util.h"
#include <math_const.h>


FLOAT                      /* ret - mantissa of x */
_frexpf(
    FLOAT x,               /* (i) - value for which to compute frexpf */
    int *e                 /* (o) - address to which exponent is written */
)
{
    /* lPtr = (LONG *)&x */

    float m;
    FLOAT *fPtr = &x;
    LONG *lPtr = (LONG *)fPtr;

    /* if x == 0.0 */
    if (x == (FLOAT)0.0)
    {
        /*{ e = 0.0 }*/
        *e = (int)0;

        /* return 0.0 */
        return (int)0;
    }

    /* e = exponent part of x */
  
    /* e = *lPtr >> numBitsInMantissa */
    *e = (int)((*lPtr >> 23) & 0xff);       /* isolate exponent */

    /* e = e - exponentOffset */
    *e = *e - 126;                          /* subtract offset */
 
    /* m = mantissa of x -- done by setting exponent to exponentOffset */
    *lPtr = (*lPtr & 0x807fffff) | (126 << 23);
    m = *fPtr;
    
    /* return m */
    return m;
}

/*end of file*/

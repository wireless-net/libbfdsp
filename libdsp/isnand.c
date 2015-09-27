/************************************************************************
 *
 * isnand.c
 *
 * Copyright (C) 2004 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ************************************************************************/

/*
 * Description :   Test 64-bit floating point numbers for a NaN
 *                 Return 1 if input x is +/-NaN, 0 otherwise
 *
 *                 Domain      : Full Range
 *                 Accuracy    : 0 bits in error.
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libGroup =math_bf.h")
#pragma file_attr("libFunc  =_isnand")
#pragma file_attr("libFunc  =isnand")
#pragma file_attr("libFunc  =isnan")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "util.h"


int                               /*{ ret - isnand(x,y)   }*/
isnand
(
  DOUBLE x                        /*{ (i) - Input value x }*/
)
{
  unsigned int            xexp;
  unsigned long long int  mant;

  /* Extract exponent and mantissa of x */
  xexp=( ( *(unsigned long long *)(&x) ) >> (52) ) & 0x7ff;
  mant=( ( *(unsigned long long *)(&x) ) & 0xFFFFFFFFFFFFF);

  return ( (xexp==2047) && (mant!=0) );
}

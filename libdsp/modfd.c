/************************************************************************
 *
 * modfd.c
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
 * Description :  This file contains the 64-bit implementation of modf().
 *                This function calculates the fractional part and integer 
 *                part of the input number x.
 *
 *                Domain      : Full Range
 *                Accuracy    : 0 bits in error
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =__modfd")
#pragma file_attr("libFunc  =modfd")     // from math.h
#pragma file_attr("libFunc  =modf")      // from math.h

/* Called by powd */
#pragma file_attr("libFunc  =powd")
#pragma file_attr("libFunc  =__powd")     //from math_bf.h
#pragma file_attr("libFunc  =powl")       //from math_bf.h
#pragma file_attr("libFunc  =pow")        //from math_bf.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "util.h"


DOUBLE                            /*{ ret - fractional part of x          }*/
modfd
(
  DOUBLE x,                       /*{ (i) - input value x                 }*/
  DOUBLE *i                       /*{ (o) - pointer to integral part of x }*/
)
{
    DOUBLE y;
    DOUBLE fract;
    DOUBLE abs_x;
    LONG exp;
    LONG bitsToClear;
    LONG *yPtr = (LONG *)&y;

    /*{ y = |x| }*/
    y = x;
    if (x < 0.0L)
    {
        y = -y;
    }
    abs_x = y;

    /*{ exp = exponent of y }*/
    exp = (yPtr[1] & 0x7ff00000) >> 20;
    exp = exp - 1023;
    /*{ if exponent is negative, then |x| < 1 }*/
    if (exp < 0)
    {
        /*{ int = 0 }*/
        /*{ return fract = x }*/
        *i = 0.0L;
        fract = x;
        return fract;
    }

    /*{ if exponent > 52, there is no fractional part }*/
    if (exp > 52)
    {
        /*{ int = x }*/
        /*{ return fract = 0.0 }*/
        *i = x;
        return 0.0L;
    }

    /*{ bitsToClear = 52 - exp }*/
    bitsToClear = 52 - exp;

    /*{ if bitsToClear > 32 then }*/
    if (bitsToClear > 31)
    {
        /*{ clear all 32 bits of lower word of y }*/
        /*{ bitsToClear = bitsToClear - 32 }*/
        /*{ clear bitsToClear bits from upper word of y }*/
        bitsToClear = bitsToClear - 32;
        yPtr[0] = 0;   /* clear all lower bits */
        yPtr[1] = yPtr[1] & (0xffffffff << bitsToClear);
    }
    /*{ else }*/
    else
    {
        /*{ clear bitsToClear bits from lower word of y }*/
        yPtr[0] = yPtr[0] & (0xffffffff << bitsToClear);
    }

    /*{ fract = |x| - y }*/
    fract = SUBD(abs_x, y);

    /*{ if x < 0 then }*/
    if (x < 0.0L)
    {
        /*{ y = -y }*/
        y = -y;
        /*{ fract = -fract }*/
        fract = -fract;
    }

    /*{ *i = y }*/
    *i = y;

    /*{ return fract }*/
    return fract;
}

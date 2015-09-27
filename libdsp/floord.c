/************************************************************************
 *
 * floord.c
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
 * Description    : This file contains the 64-bit implementation of floor().
 *                  This function rounds down to the next lowest whole number 
 *                  that is less than or equal to x.
 *
 *                  Domain      : Full Range
 *                  Accuracy    : 0 bits in error
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =__floord")
#pragma file_attr("libFunc  =floord")     // from math.h
#pragma file_attr("libFunc  =floor")      // from math.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "util.h"


DOUBLE                            /*{ ret - floord(x)     }*/
floord
(
  DOUBLE x                        /*{ (i) - input value x }*/
)
{
    DOUBLE y;
    LONG exp;
    LONG bitsToClear;
    LONG *yPtr = (LONG *)&y;

    /*{ y = |x| }*/
    y = x;
    if (x < 0.0)
    {
        y = -y;
    }

    /*{ exp = exponent of y }*/
    exp = (yPtr[1] & 0x7ff00000) >> 20;
    exp = exp - 1023;

    /*{ if exponent is negative }*/
    if (exp < 0)
    {
        /*{ if x < 0, return -1 }*/
        /*{ else x >= 0, return 0 }*/
        y = (x < 0.0) ? -1.0 : 0.0;
        return y;
    }

    /*{ if exp > 52 then there are no bits to clear, return x}*/
    if (exp > 52)
    {
        return x;
    }

    /*{ bitsToClear = 52 - exp }*/
    bitsToClear = 52 - exp;

    /*{ if bitsToClear > 32 then }*/
    if (bitsToClear > 31)
    {
        /*{ clear all 32 bits in lower word of y }*/
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

    /*{ if x < 0.0 then }*/
    if (x < 0.0)
    {
        /*{ y = -y }*/
        y = -y;
        /*{ if y != x, y = y - 1 }*/
        if (y != x)
        {
            y = SUBD(y, 1.0);
        }
    }

    /*{ return y }*/
    return y;
}


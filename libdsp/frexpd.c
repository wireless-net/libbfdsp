/************************************************************************
 *
 * frexpd.c
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
 * Description    : This file contains the 64-bit implementation of frexp().
 *                  This function splits a 64-bit float into its exponent
 *                  and mantissa.
 *
 *                  Domain      : Full Range
 *                  Accuracy    : Relative error: 0 bits in error
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =frexpd")
#pragma file_attr("libFunc  =__frexpd")
#pragma file_attr("libFunc  =frexp")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "util.h"


DOUBLE                            /*{ ret - mantissa of x            }*/
frexpd
(
  DOUBLE x,                       /*{ (i) - input value x            }*/
  INT *e                          /*{ (o) - pointer to exponent of x }*/
)
{
    /*{ lPtr = (LONG *)&x }*/
    INT *lPtr = (INT *)&x;

    /*{ if x == 0.0 }*/
    if (x == 0.0)
    {
        /*{ e = 0 }*/
        *e = 0;
        /*{ return 0.0 }*/
        return 0.0;
    }

    /*{ e = exponent part of x }*/
    /*{!INDENT}*/
    /*{ e = (interpret as int)x >> numBitsInMantissa }*/
    *e = (lPtr[1] >> 20) & 0x7ff;       /* isolate exponent */
    /*{ e = e - exponentOffset }*/
    *e = *e - 1022;                     /* subtract offset */
    /*{!OUTDENT}*/

    /*{ m = mantissa of x -- done by setting exponent to exponentOffset }*/
    lPtr[1] = (lPtr[1] & 0x800fffff) | (1022 << 20);
      
    /*{ return m }*/
    return x;
}

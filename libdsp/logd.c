/************************************************************************
 *
 * logd.c
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
 * Description :  This file contains the 64-bit implementation of log().
 *                The algorithm used to implement this function is adapted 
 *                from Cody & Waite, "Software Manual for the Elementary
 *                Functions", Prentice-Hall, New Jersey, 1980.
 *
 *                Domain      : x = [0 ... 1.7e308]
 *                                For x outside the domain, this function
 *                                returns -1.7e308 
 *                Accuracy    : 3 bits of error or less over entire range
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =__logd")
#pragma file_attr("libFunc  =logd")
#pragma file_attr("libFunc  =log")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "math_const.h"
#include "util.h"


DOUBLE                            /*{ ret - logd(x)       }*/
logd
(
  DOUBLE x                        /*{ (i) - input value x }*/
)
{
    DOUBLE result;
    DOUBLE f, w, z, a, b, r;
    DOUBLE znum, zden;
    LONG n;
    DOUBLE xn;
    LONG *xPtr = (LONG *)&x;
    DOUBLE *fPtr = &x;

    /*{ if x < 0.0, return -1.7e308 }*/
    if (x <= 0.0)
    {
        result = -LDBL_MAX;
        return result;
    }

    /*{ n = exponent part of x }*/
    n = (xPtr[1] >> 20);
    n = n - 1022;

    /*{ f = fractional part of x }*/
    /* f = setxp(x, 0) -- done by setting exponent to 1022 */
    xPtr[1] = (xPtr[1] & 0x800fffff) | (1022 << 20);
    f = *fPtr;

    /*{ if f > sqrt(0.5) }*/
    if (f > ROOT_HALF)
    {
        /*{ znum = f - 1 }*/
        znum = SUBD(f, 0.5);
        znum = SUBD(znum, 0.5);
        /*{ zden = f * 0.5 + 0.5 }*/
        zden = MPYD(f, 0.5);
        zden = ADDD(zden, 0.5);
    }
    /*{ else }*/
    else
    {
        /*{ n = n - 1 }*/
        n = n - 1;
        /*{ znum = f - 0.5 }*/
        znum = SUBD(f, 0.5);
        /*{ zden = f * 0.5 + 0.5 }*/
        zden = MPYD(znum, 0.5);
        zden = ADDD(zden, 0.5);
    }
    xn = (DOUBLE)n;

    /*{ z = znum/zden }*/
    z = DIVD(znum, zden);

    /*{ w = z * z }*/
    w = MPYD(z, z);

    /*{ R(z) = z + z * r(w) }*/
    /*{!INDENT}*/
    /*{ r(w) = w * A(w)/B(w) }*/
    /*{ A(w) = (a2 * w + a1) * w + a0 }*/
    a = MPYD(LOGDA_COEF2, w);
    a = ADDD(a, LOGDA_COEF1);
    a = MPYD(a, w);
    a = ADDD(a, LOGDA_COEF0);

    /*{ B(w) = ((w + b2) * w + b1) * w + b0 }*/
    b = ADDD(w, LOGDB_COEF2);
    b = MPYD(b, w);
    b = ADDD(b, LOGDB_COEF1);
    b = MPYD(b, w);
    b = ADDD(b, LOGDB_COEF0);

    r = DIVD(a, b);
    r = MPYD(r, w);
    r = MPYD(r, z);
    r = ADDD(r, z);
    /*{!OUTDENT}*/

    /*{ result = n *c + R(z) }*/
    /* using higher precision calculation */
    result = MPYD(xn, LN2_DC1);
    result = ADDD(result, r);
    r = MPYD(xn, LN2_DC2);
    result = ADDD(result, r);
    r = MPYD(xn, LN2_DC3);
    result = ADDD(result, r);

    /*{ return result }*/
    return result;
}

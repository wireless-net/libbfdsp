/************************************************************************
 *
 * tanhd.c
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
 * Description :  This file contains the 64-bit implementation of tanh().
 *                The algorithm used to implement this function is adapted
 *                from Cody & Waite, "Software Manual for the Elementary
 *                Functions", Prentice-Hall, New Jersey, 1980.
 *
 *                Domain      : x = [-709.7 ... 709.7]
 *                                For x outside the domain, this function 
 *                                returns +-1.0.
 *                Accuracy    : 1 bits of error or less
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =tanhd")
#pragma file_attr("libFunc  =__tanhd")    //from math.h
#pragma file_attr("libFunc  =tanh")       //from math.h
#pragma file_attr("libFunc  =tanhl")      //from math.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "math_const.h"
#include "util.h"


DOUBLE                            /*{ ret - tanhd(x)      }*/
tanhd
(
  DOUBLE x                        /*{ (i) - input value x }*/
)
{
    DOUBLE f, g, xnum, xden;
    DOUBLE result;
    DOUBLE sign = 1.0;

    /*{ f = |x| }*/
    f = x;
    /*{ sign = 1 }*/
    /*{ if x < 0, sign = -sign }*/
    if (x < (DOUBLE)0.0)
    {
        f = -f;
        sign = -sign;
    }

    /*{ if f > TANHDOUBLE_BIGNUM, return sign }*/
    if (f > TANHDOUBLE_BIGNUM)
    {
        return sign;
    }

    /*{ if f > ln(3)/2 }*/
    if (f > LN3_2)
    {
        /*{ result = 1 - 2/(exp(2f) + 1) }*/
        result = ADDD(f, f);
        result = expd(result);
        result = ADDD(1.0, result);
        result = DIVD(2.0, result);
        result = SUBD(1.0, result);
    }
    /*{ else f <= ln(3)/2 }*/
    else
    {
        /*{ if f < EPS, return x }*/
        if (f < LDBL_EPSILON)
        {
            result = x;
            return result;
        }

        /*{ g = f * f }*/
        g = MPYD(f, f);

        /*{ R(g) = g * P(g)/Q(g) }*/
        /*{!INDENT}*/
        /*{ P(g) = (p2 * g + p1) * g + p0 }*/
        xnum = MPYD(TANHDP_COEF2, g);
        xnum = ADDD(xnum, TANHDP_COEF1);
        xnum = MPYD(xnum, g);
        xnum = ADDD(xnum, TANHDP_COEF0);

        /*{ Q(g) = ((g + q2) * g + q1) * g + q0 }*/
        xden = ADDD(TANHDQ_COEF2, g);
        xden = MPYD(xden, g);
        xden = ADDD(xden, TANHDQ_COEF1);
        xden = MPYD(xden, g);
        xden = ADDD(xden, TANHDQ_COEF0);
        /*{!OUTDENT}*/

        /*{ result = f + f * R(g) }*/
        result = DIVD(xnum, xden);
        result = MPYD(result, g);
        result = MPYD(result, f);
        result = ADDD(result, f);

    }

    /*{ if sign < 0, result = -result }*/
    if (sign < (DOUBLE)0.0)
    {
        result = -result;
    }

    /*{ return result }*/
    return result;
}

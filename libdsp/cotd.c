/************************************************************************
 *
 * cotd.c
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
 * Description    : This file contains the 64-bit implementation of cot().
 *                  The algorithm used to implement this function is adapted
 *                  from Cody & Waite, "Software Manual for the Elementary
 *                  Functions", Prentice-Hall, New Jersey, 1980.
 *
 *                  Domain      : x = [-298,156,826 ... 298,156,826]
 *                                  For x outside the domain, this function
 *                                  returns 0.
 *                                For cot(0), the function returns 0.
 *                  Accuracy    : Primary range (-PI/4 to PI/4)
 *                                  2 bits of error or less
 *                                Outside primary range
 *                                  3 bits of error or less
 *                                Error near singularities is indeterminate.
 */

#pragma file_attr("libGroup =math_bf.h")
#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =cotd")
#pragma file_attr("libFunc  =__cotd")
#pragma file_attr("libFunc  =cot")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "math_const.h"
#include "util.h"


DOUBLE                            /*{ ret - cotd(x)       }*/
cotd
(
  DOUBLE x                        /*{ (i) - input value x }*/
)
{
    LONG n;
    DOUBLE xn;
    DOUBLE f, g;
    DOUBLE x_int, x_fract;
    DOUBLE result;
    DOUBLE xnum, xden;

    /*{ If x is outside the domain or zero, return 0.0 }*/
    if ((x > COT64_X_MAX) || (x < -COT64_X_MAX) || (x == 0.0L))
    {
        return 0.0L;
    }

    /*{ split x into x_int and x_fract for better argument reduction }*/
    x_int = TO_DOUBLE(TO_LONG(x));
    x_fract = SUBD(x, x_int);

    /*{ Reduce the input to range between -PI/4, PI/4 }*/
    /*{!INDENT}*/
    /*{ n = Rounded long x/(PI/2) }*/
    if (x > 0.0)
    {
        n = TO_LONG(ADDD(MPYD(x, INV_PI_2), 0.5));
    }
    else
    {
        n = TO_LONG(ADDD(MPYD(x, INV_PI_2), -0.5));
    }

    /*{ xn = (double)n }*/
    xn = TO_DOUBLE(n);

    /*{ f = x - xn*PI  }*/
    /* (using higher precision computation) */
    f = SUBD(x_int, MPYD(xn, PI_2_DC1));
    f = ADDD(f, x_fract);
    f = SUBD(f, MPYD(xn, PI_2_DC2));
    f = SUBD(f, MPYD(xn, PI_2_DC3));
    /*{!OUTDENT}*/

    if (f < 0.0L)
    {
        g = -f;
    }
    else
    {
        g = f;
    }
    /*{ If |f| < eps }*/
    if (g < EPS_DOUBLE)
    {
        /*{ if n is odd, return -f }*/
        if (n & 0x0001)
        {
            result = -f;
        }
        /*{ if n is even, return 1/f }*/
        else
        {
            result = DIVD(1.0L, f);
        }            
        return result;
    }

    /*{ g = f * f }*/
    g = MPYD(f, f);

    /*{ Compute sin approximation on reduced argument }*/
    /*{!INDENT}*/
    /*{ xnum = (((g * p3 + p2) * g + p1) * g * f + f }*/
    xnum = MPYD(g, TANDP_COEF3);
    xnum = ADDD(xnum, TANDP_COEF2);
    xnum = MPYD(xnum, g);
    xnum = ADDD(xnum, TANDP_COEF1);
    xnum = MPYD(xnum, g);
    xnum = MPYD(xnum, f);
    xnum = ADDD(xnum, f);

    /*{ xden = (((g * q4 + q3) * g + q2) * g +q1) * g + q0 }*/
    xden = MPYD(g, TANDQ_COEF4);
    xden = ADDD(xden, TANDQ_COEF3);
    xden = MPYD(xden, g);
    xden = ADDD(xden, TANDQ_COEF2);
    xden = MPYD(xden, g);
    xden = ADDD(xden, TANDQ_COEF1);
    xden = MPYD(xden, g);
    xden = ADDD(xden, TANDQ_COEF0);
    /*{!OUTDENT}*/

    /*{ if n is odd, result = -xnum/xden }*/
    if (n & 0x0001)
    {
        xnum = -xnum;
    }
    /*{ else n is even, result = xden/xnum }*/
    else
    {
        result = xden;
        xden = xnum;
        xnum = result;
    }            
    result = DIVD(xnum, xden);

    /*{ return result }*/
    return result;
}

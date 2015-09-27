/************************************************************************
 *
 * expd.c
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
 * Description    : This file contains the 64-bit implementation of exp().
 *                  The algorithm used to implement this function is adapted 
 *                  from Cody & Waite, "Software Manual for the Elementary 
 *                  Functions", Prentice-Hall, New Jersey, 1980.
 *
 *                  Domain      : x = [-708.3 ... 709.7]
 *                                  For x = -|x| outside the domain,
 *                                               this function returns 0.0
 *                                  For x =  |x| outside the domain,
 *                                               this function returns 1.7e+308
 *                  Accuracy    : Primary range (-ln(2)/2 to ln(2)/2)
 *                                  1 bits of error or less
 *                                Outside primary range
 *                                  3 bits of error or less
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =__expd")
#pragma file_attr("libFunc  =expd")
#pragma file_attr("libFunc  =exp")

/* Called by alog10d */
#pragma file_attr("libGroup =math_bf.h")
#pragma file_attr("libFunc  =__alog10d")
#pragma file_attr("libFunc  =alog10d")
#pragma file_attr("libFunc  =alog10")
/* Called by alogd */
#pragma file_attr("libFunc  =__alogd")
#pragma file_attr("libFunc  =alogd")
#pragma file_attr("libFunc  =alog")
/* Called by coshd */
#pragma file_attr("libFunc  =coshd")
#pragma file_attr("libFunc  =__coshd")
#pragma file_attr("libFunc  =cosh")
#pragma file_attr("libFunc  =coshl")
/* Called by sinhd */
#pragma file_attr("libFunc  =sinhd")
#pragma file_attr("libFunc  =__sinhd")
#pragma file_attr("libFunc  =sinh")
/* Called by tanhd */
#pragma file_attr("libFunc  =tanhd")
#pragma file_attr("libFunc  =__tanhd")
#pragma file_attr("libFunc  =tanh")
#pragma file_attr("libFunc  =tanhl")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "math_const.h"
#include "util.h"


DOUBLE                            /*{ ret - expd(x)       }*/
expd
(
  DOUBLE x                        /*{ (i) - input value x }*/
)
{
    DOUBLE y;
    LONG n;
    DOUBLE xn, x_int, x_fract;
    DOUBLE g, z, xnum, xden;
    DOUBLE result;
    LONG *resultlp = (LONG *)&result;

    /*{ if x > 709.7, return 1.7e308 }*/
    if (x > XDOUBLE_MAX_EXP)
    {
        return LDBL_MAX;
    }

    /*{ if x < -708.3, return 0.0 }*/
    if (x < XDOUBLE_MIN_EXP)
    {
        return 0.0;
    }

    y = x;
    if (y < (DOUBLE)0.0)
    {
        y = -y;
    }

    /*{ if |x| < eps, return 1.0 }*/
    if (y < LDBL_EPSILON)
    {
        return 1.0;
    }

    /*{ n = intrnd(x / ln(c)) }*/
    g = 0.5;
    if (x <= (DOUBLE)0.0)
    {
        g = -g;
    }
    n = TO_LONG(ADDD(MPYD(x, INV_LN2), g));

    /*{ xn = (double)n }*/
    xn = TO_DOUBLE(n);

    /*{ split x into x_int and x_fract for better argument reduction }*/
    x_int = TO_DOUBLE(TO_LONG(x));
    x_fract = SUBD(x, x_int);

    /*{ g = x - xn*ln2 }*/
    /* (using higher precision computation) */
    g = SUBD(x_int, MPYD(xn, LN2_DC1));
    g = ADDD(g, x_fract);
    g = SUBD(g, MPYD(xn, LN2_DC2));
    g = SUBD(g, MPYD(xn, LN2_DC3));

    /*{ z = g * g }*/
    z = MPYD(g, g);

    /*{ Compute exp approximation on reduced argument }*/
    /*{!INDENT}*/
    /*{ xnum = ((z * p2 + p1) * z + p0) * g }*/
    xnum = MPYD(z, EXPDP_COEF2);
    xnum = ADDD(xnum, EXPDP_COEF1);
    xnum = MPYD(xnum, z);
    xnum = ADDD(xnum, EXPDP_COEF0);
    xnum = MPYD(xnum, g);

    /*{ xden = ((q3 * z + q2) * z + q1) * z + q0 }*/
    xden = MPYD(EXPDQ_COEF3, z);
    xden = ADDD(xden, EXPDQ_COEF2);
    xden = MPYD(xden, z);
    xden = ADDD(xden, EXPDQ_COEF1);
    xden = MPYD(xden, z);
    xden = ADDD(xden, EXPDQ_COEF0);

    /*{ result = 0.5 + xnum/[xden - xnum] }*/
    result = SUBD(xden, xnum);
    result = DIVD(xnum, result);
    result = ADDD(0.5, result);
    /*{!OUTDENT}*/

    /*{ n = n + 1 to take the scaling of result into account }*/
    n = n + 1;

    /*{ add n to the exponent of result }*/
    n = n << 20;                           /* shift n into exponent position */
    resultlp[1] = n + resultlp[1];         /* add exponent to result */

    /*{ return result }*/
    return result;
}

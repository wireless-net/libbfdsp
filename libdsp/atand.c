/************************************************************************
 *
 * atand.c
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
 * Description    : This file contains the 64-bit implementation of atan().
 *                  The algorithm used to implement this function is adapted
 *                  from Cody & Waite, "Software Manual for the Elementary
 *                  Functions", Prentice-Hall, New Jersey, 1980.
 *
 *                  Domain      : Full Range
 *                  Accuracy    : 3 bits or less for entire range
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =__atand")
#pragma file_attr("libFunc  =atand")
#pragma file_attr("libFunc  =atanl")
#pragma file_attr("libFunc  =atan")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "math_const.h"
#include "util.h"


DOUBLE                            /*{ ret - atand(x)       }*/
atand
(
  DOUBLE x                        /*{ (i) - input value x  }*/
)
{
    DOUBLE f, g;
    DOUBLE num, den;
    DOUBLE result;
    static const DOUBLE a[4] = {0, (DOUBLE)PI_6, (DOUBLE)PI_2, (DOUBLE)PI_3};

    /*{ n = 0 }*/
    int n = 0;

    /*{ f = |x| }*/
    f = x;
    if (f < 0.0)
    {
        f = -f;
    }

    /*{ if f > 1.0 }*/
    if (f > 1.0)
    {
        /*{ f = 1/f }*/
        f = DIVD(1.0, f);
        /*{ n = 2 }*/
        n = 2;
    }

    /*{ if f > 2 - sqrt(3) }*/
    if (f > TWO_MINUS_ROOT3)
    {
        /*{ f = [f * sqrt(3) - 1] / [sqrt(3) + f] }*/
        num = MPYD(SQRT3_MINUS_1, f);
        num = SUBD(num, 0.5);
        num = SUBD(num, 0.5);
        num = ADDD(num, f);
        den = ADDD(SQRT3, f);
        f = DIVD(num, den);

        /*{ n = n + 1 }*/
        n = n + 1;
    }

    g = f;
    if (g < 0.0)
    {
        g = -g;
    }

    /*{ if |f| < eps }*/
    if (g < EPS_DOUBLE)
    {
        /*{ result = f }*/
        result = f;
    }
    /*{ else |f| >= eps }*/
    else
    {
        /*{ g = f * f }*/
        g = MPYD(f, f);
    
        /*{ result = R(g) = g * P(g) / Q(g) }*/
        /*{!INDENT}*/
        /*{ P(g) = ((p3 * g + p2) * g + p1) * g + p0 }*/
        num = MPYD(ATANDP_COEF3, g);
        num = ADDD(num, ATANDP_COEF2);
        num = MPYD(num, g);
        num = ADDD(num, ATANDP_COEF1);
        num = MPYD(num, g);
        num = ADDD(num, ATANDP_COEF0);
        num = MPYD(num, g);
    
        /*{ Q(g) = (((g + q3) * g + q2) * g + q1) * g + q0 }*/
        den = ADDD(g, ATANDQ_COEF3);
        den = MPYD(den, g);
        den = ADDD(den, ATANDQ_COEF2);
        den = MPYD(den, g);
        den = ADDD(den, ATANDQ_COEF1);
        den = MPYD(den, g);
        den = ADDD(den, ATANDQ_COEF0);
    
        result = DIVD(num, den);
        /*{!OUTDENT}*/
    
        /*{ result = result * f + f }*/
        result = MPYD(result, f);
        result = ADDD(result, f);
    }
    
    /*{ n > 1, result = -result }*/
    if (n > 1)
    {
        result = -result;
    }
    
    /*{ result = result + a[n] }*/
    result = ADDD(a[n], result);

    /*{ if x < 0, result = -result }*/
    if (x < 0.0)
    {
        result = -result;
    }

    /*{ return result }*/
    return result;
}

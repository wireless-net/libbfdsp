/************************************************************************
 *
 * cosd.c
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
 * Description    : This file contains the 64-bit implementation of cos().
 *                  The algorithm used to implement this function is adapted
 *                  from Cody & Waite, "Software Manual for the Elementary 
 *                  Functions", Prentice-Hall, New Jersey, 1980.
 *
 *                  Domain      : x = [-298,156,826 ... 298,156,826]
 *                                  For x outside the domain, this function
 *                                  returns 0.0.
 *                  Accuracy    : Primary range (-PI_2 to PI_2) 
 *                                  2 bits of error or less
 *                                Outside primary range
 *                                  3 bits of error or less
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =cosd")
#pragma file_attr("libFunc  =__cosd")
#pragma file_attr("libFunc  =cosl")
#pragma file_attr("libFunc  =cos")
/* Called by polard */
#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =polard")
#pragma file_attr("libFunc  =__polard")
#pragma file_attr("libFunc  =polar")
/* Called by cexpd */
#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =cexpd") 
#pragma file_attr("libFunc  =__cexpd")
#pragma file_attr("libFunc  =cexp")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "math_const.h"
#include "util.h"
                

DOUBLE                            /*{ ret - cosd(x)       }*/
cosd
(
  DOUBLE x                        /*{ (i) - input value x }*/
)
{
    LONG n;
    DOUBLE y;
    DOUBLE xn;
    DOUBLE x_int, x_fract;
    DOUBLE f, g, result;
    int sign = 1;

    /*{ x = |x| (since cos(-x) == cos(x)) }*/
    if (x < 0.0L)
    {
        x = -x;
    }

    /*{ y = |x| + PI/2 }*/
    y = ADDD(x, PI_2);

    /*{ If x is outside domain, return 0.0 }*/
    if (y > COS64_X_MAX)
    {
        return 0.0L;
    }

    /*{ Reduce the input to range between -PI/2, PI/2 }*/
    /*{!INDENT}*/
    /*{ split x into x_int and x_fract for better argument reduction }*/
    x_int = TO_DOUBLE(TO_LONG(x));
    x_fract = SUBD(x, x_int);

    /*{ xn = Rounded long y/PI }*/
    n = TO_LONG(ADDD(MPYD(y, INV_PI), 0.5));
    xn = TO_DOUBLE(n);

    /*{ subtract 0.5 from xn  }*/
    /* (more accurate than adding PI/2 to input argument) */
    xn = SUBD(xn, 0.5L);


    /*{ f = x - xn*PI  }*/
    /* (using higher precision computation) */
    f = SUBD(x_int, MPYD(xn, PI_DC1));
    f = ADDD(f, x_fract);
    f = SUBD(f, MPYD(xn, PI_DC2));
    f = SUBD(f, MPYD(xn, PI_DC3));
    /*{!OUTDENT}*/

    /*{ sign = 1 }*/
    /*{ If n is odd, sign = -1 }*/
    if (n & 0x0001)
    {
        sign = -sign;
    }

    /*{ If |f| < eps, return f }*/
    if (f < 0.0L)
    {
        g = -f;
    }
    else
    {
        g = f;
    }

    if (g < EPS_DOUBLE)
    {
        result = f;
        if (sign < 0)
        {
            result = -result;
        }
        return result;
    }

    /*{ g = f * f }*/
    g = MPYD(f, f);

    /*{ Compute sin approximation }*/
    /*{!INDENT}*/
    /*{ result = ((((((((g * C8 + C7) * g + C6) * g + C5) * g + 
                      C4) * g + C3) * g + C2) * g + C1) * g) * f + f }*/
    result = MPYD(g, SIND_COEF8);
    result = ADDD(result, SIND_COEF7);
    result = MPYD(result, g);
    result = ADDD(result, SIND_COEF6);
    result = MPYD(result, g);
    result = ADDD(result, SIND_COEF5);
    result = MPYD(result, g);
    result = ADDD(result, SIND_COEF4);
    result = MPYD(result, g);
    result = ADDD(result, SIND_COEF3);
    result = MPYD(result, g);
    result = ADDD(result, SIND_COEF2);
    result = MPYD(result, g);
    result = ADDD(result, SIND_COEF1);
    result = MPYD(result, g);

    result = MPYD(result, f);
    result = ADDD(result, f);
    /*{!OUTDENT}*/

    /*{ if sign < 0, result = -result }*/
    if (sign < 0)
    {
        result = -result;
    }
    /* make sure -1.0 <= result <= 1.0 */
    if (result > 1.0L) {
      result = 1.0L;
    }
    else if (result < -1.0L) {
      result = -1.0L;
    }
    /*{ return result }*/
    return (result);
}

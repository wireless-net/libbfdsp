/************************************************************************
 *
 * sind.c
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
 * Description :  This file contains the 64-bit implementation of sin().
 *                The algorithm used to implement this function is adapted
 *                from Cody & Waite, "Software Manual for the Elementary
 *                Functions", Prentice-Hall, New Jersey, 1980.
 *         
 *                Domain      : x = [-298,156,826 ... 298,156,826]
 *                                For x outside the domain, this function
 *                                returns 0.0.
 *                Accuracy    : Primary range (-PI/2 to PI/2)
 *                                2 bits of error or less
 *                              Outside primary range
 *                                3 bits of error or less
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =sind")        //from math.h
#pragma file_attr("libFunc  =__sind")
#pragma file_attr("libFunc  =sinl")        //from math.h
#pragma file_attr("libFunc  =sin")         //from math.h

/* Called by polard */
#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =polard")  
#pragma file_attr("libFunc  =__polard")     //from complex_fns.h
#pragma file_attr("libFunc  =polar")        //from complex_fns.h

/* Called by cexpd */
#pragma file_attr("libFunc  =cexpd")  
#pragma file_attr("libFunc  =__cexpd")      //from complex_fns.h
#pragma file_attr("libFunc  =cexp")         //from complex_fns.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "math_const.h"
#include "util.h"


DOUBLE                            /*{ ret - sind(x)       }*/
sind
(
  DOUBLE x                        /*{ (i) - input value x }*/
)
{
    LONG n;
    DOUBLE xn;
    DOUBLE x_int, x_fract;
    DOUBLE f, g, result;
    DOUBLE sign = 1.0L;

    /*{ sign = 1 }*/

    /*{ if x < 0 }*/
    if (x < 0.0L)
    {
        /*{ sign = -sign }*/
        sign = -sign;
        /*{ x = -x }*/
        x = -x;
    }

    /*{ If x is outside the domain, return 0.0 }*/
    if (x > SIN64_X_MAX)
    {
        return 0.0L;
    }

    /*{ split val into x_int and x_fract for better argument reduction }*/
    x_int = TO_DOUBLE(TO_LONG(x));
    x_fract = SUBD(x, x_int);

    /*{ Reduce the input to range between -PI/2, PI/2 }*/
    /*{!INDENT}*/
    /*{ n = Rounded long x/PI }*/
    n = TO_LONG(ADDD(MPYD(x, INV_PI), 0.5));

    /*{ xn = (double)n }*/
    xn = TO_DOUBLE(n);
 
    /*{ f = x - xn*PI }*/
    /* (using higher precision computation) */
    f = SUBD(x_int, MPYD(xn, PI_DC1));
    f = ADDD(f, x_fract);
    f = SUBD(f, MPYD(xn, PI_DC2));
    f = SUBD(f, MPYD(xn, PI_DC3));

    /*{ If n is odd, sign = -sign }*/
    if (n & 0x0001)
    {
        sign = -sign;
    }
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
        /*{ result = f }*/
        result = f;
        /*{ if sign < 0, result = -result }*/
        if (sign < 0.0L)
        {
            result = -result;
        }
        /*{return result }*/
        return result;
    }

    /*{ g = f * f }*/
    g = MPYD(f, f);

    /*{ Compute sin approximation }*/
    /*{!INDENT}*/
    /*{ result = (((((((g * C8 + C7) * g + C6) * g + C5) * g + 
                     C4) * g + C3) * g + C2) * g + C1) * g * f + f }*/
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
    if (sign < 0.0L)
    {
        result = -result;
    }

    /*{ return result }*/
    return (result);
}

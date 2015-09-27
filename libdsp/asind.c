/************************************************************************
 *
 * asind.c
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
 * Description    : This file contains the 64-bit implementation of asin().
 *                  The algorithm used to implement this function is adapted 
 *                  from Cody & Waite, "Software Manual for the Elementary 
 *                  Functions", Prentice-Hall, New Jersey, 1980.
 * 
 *                  Domain      : x = [-1.0 ... 1.0]
 *                                  For x outside the domain, this function
 *                                  returns 0.0.
 *                  Accuracy    : 3 bits or less for entire range
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =asind")
#pragma file_attr("libFunc  =__asind")     //from math.h
#pragma file_attr("libFunc  =asin")        //from math.h
#pragma file_attr("libFunc  =asinl")        //from math.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "math_const.h"
#include "util.h"


DOUBLE                            /*{ ret - asind(x)       }*/
asind
(
  DOUBLE x                        /*{ (i) - input value x  }*/
)
{
    DOUBLE y, g;
    DOUBLE num, den, result;
    LONG i;
    DOUBLE sign = 1.0;

    /*{ y = |x| }*/
    y = x;
    if (y < (DOUBLE)0.0)
    {
        y = -y;
        sign = -sign;
    }

    /*{ if y > 0.5 }*/
    if (y > (DOUBLE)0.5)
    {
        /*{ set i = 1 }*/
        i = 1;

        /*{ if y > 0, return error }*/
        if (y > (DOUBLE)1.0)
        {
            result = 0.0;
            return result;
        }    

        /*{ g = (1 - y)/2 }*/
        g = MPYD(0.5, y);
        g = SUBD(0.5, g);

        /*{ y = -2/sqrt(g) }*/
        y = sqrtd(g);
        y = MPYD(y, -2.0);
    }
    /*{ else y <= 0.5 }*/
    else
    {
        /*{ set i = 0 }*/
        i = 0;

        /*{ if y < eps }*/
        if (y < EPS_DOUBLE)
        {
            /*{ result = y }*/
            result = y;

            /*{ if sign < 0, result = -result }*/
            if (sign < (DOUBLE)0.0)
            {
                result = -result;
            }
            /*{ return result }*/
            return result;
        }

        /*{ g = y * y }*/
        g = MPYD(y, y);
    }

    /*{ result = y + y*R(g) }*/
    /*{!INDENT}*/
    /*{ R(g) = g*P(g)/Q(g) }*/
    /*{ P(g) = (((p5 * g + p4) * g + p3) * g + p2) * g + p1 }*/
    num = MPYD(ASINDP_COEF5, g);
    num = ADDD(num, ASINDP_COEF4);
    num = MPYD(num, g);
    num = ADDD(num, ASINDP_COEF3);
    num = MPYD(num, g);
    num = ADDD(num, ASINDP_COEF2);
    num = MPYD(num, g);
    num = ADDD(num, ASINDP_COEF1);
    num = MPYD(num, g);

    /*{ Q(g) = ((((g + q4) * g + q3) * g + q2) * g + q1) * g + q0 }*/
    den = ADDD(g, ASINDQ_COEF4);
    den = MPYD(den, g);
    den = ADDD(den, ASINDQ_COEF3);
    den = MPYD(den, g);
    den = ADDD(den, ASINDQ_COEF2);
    den = MPYD(den, g);
    den = ADDD(den, ASINDQ_COEF1);
    den = MPYD(den, g);
    den = ADDD(den, ASINDQ_COEF0);

    result = DIVD(num, den);
    result = MPYD(result, y);
    result = ADDD(result, y);
    /*{!OUTDENT}*/

    /*{ if i == 1, result = PI/2 + result }*/
    /* (but more mathematically stable) */
    if (i == 1)
    {
        result = ADDD(result, PI_4);
        result = ADDD(result, PI_4);
    }

    /*{ if x < 0, result = -result }*/
    if (sign < (DOUBLE)0.0)
    {
        result = -result;
    }

    /*{ return result }*/
    return result;
}

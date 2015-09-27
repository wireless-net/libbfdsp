/************************************************************************
 *
 * acosd.c
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
 * Description    : This file contains the 64-bit implementation of acos(). 
 *                  The algorithm used to implement this function is adapted 
 *                  from Cody & Waite, "Software Manual for the Elementary 
 *                  Functions", Prentice-Hall, New Jersey, 1980.
 *   
 *                  Domain      : x = [-1.0 ... 1.0],
 *                                   For x outside the domain, this function 
 *                                   returns 0.0.
 *                  Accuracy    :  3 bits or less for entire range
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =acosd")
#pragma file_attr("libFunc  =__acosd")     //from math.h
#pragma file_attr("libFunc  =acos")        //from math.h
#pragma file_attr("libFunc  =acosl")        //from math.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "math_const.h"
#include "util.h"


DOUBLE                            /*{ ret - acosd(x)       }*/
acosd
(
  DOUBLE x                        /*{ (i) - input value x  }*/
)
{
    DOUBLE y, g;
    DOUBLE num, den, result;
    LONG i;

    /*{ y = |x| }*/
    y = x;
    if (y < (DOUBLE)0.0)
    {
        y = -y;
    }

    /*{ if y > 0.5 }*/
    if (y > (DOUBLE)0.5)
    {
        /*{ set i = 0 }*/
        i = 0;

        /*{ if y > 0, return error }*/
        if (y > (DOUBLE)1.0)
        {
            result = 0.0;
            return result;
        }    

        /*{ g = (1 - y)/2 }*/
        g = SUBD(1.0, y);
        g = MPYD(0.5, g);

        /*{ y = -2/sqrt(g) }*/
        y = sqrtd(g);
        y = MPYD(y, -2.0);
    }
    /*{ else y <= 0.5 }*/
    else
    {
        /*{ set i = 1 }*/
        i = 1;

        /*{ if y < eps }*/
        if (y < EPS_DOUBLE)
        {
            result = y;

            /*{ if x < 0, result = PI/2 + result }*/
            /* (but more mathematically stable) */
            if (x < (DOUBLE)0.0)
            {
                result = ADDD(PI_4, result);
                result = ADDD(result, PI_4);
            }
            /*{ else x >=0, result = PI/2 - result }*/
            /* (but more mathematically stable) */
            else
            {
                result = SUBD(PI_4, result);
                result = ADDD(result, PI_4);
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

    /*{ if x < 0 }*/
    if (x < (DOUBLE)0.0)
    {
        /*{ if i == 0, result = PI + result }*/
        /* (but more mathematically stable) */
        if (i == 0)
        {
            result = ADDD(result, PI_2);
            result = ADDD(result, PI_2);
        }
        /*{ if i == 1, result = PI/2 + result }*/
        /* (but more mathematically stable) */
        else
        {
            result = ADDD(PI_4, result);
            result = ADDD(result, PI_4);
        }
    }
    /*{ else x >= 0 }*/
    else
    {
        /*{ if i == 1, result = PI/2 - result }*/
        /* (but more mathematically stable) */
        if (i == 1)
        {
            result = SUBD(PI_4, result);
            result = ADDD(result, PI_4);
        }
        /*{ if i == 0, result = -result }*/
        else
        {
            result = -result;
        }
    }

    /*{ return result }*/
    return result;
}

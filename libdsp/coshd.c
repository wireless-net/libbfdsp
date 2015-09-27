/************************************************************************
 *
 * coshd.c
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
 * Description    : This file contains the 64-bit implementation of cosh().
 *                  The algorithm used to implement this function is adapted
 *                  from Cody & Waite, "Software Manual for the Elementary 
 *                  Functions", Prentice-Hall, New Jersey, 1980.
 *
 *                  Domain      : x = [-709.7 ... 709.7]
 *                                  For x outside the domain, this function
 *                                  returns 1.7e308.
 *                  Accuracy    : Primary range (-1 to 1)
 *                                  1 bits of error or less
 *                                Outside primary range
 *                                  3 bits of error or less
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =coshd")
#pragma file_attr("libFunc  =__coshd")
#pragma file_attr("libFunc  =cosh")
#pragma file_attr("libFunc  =coshl")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "math_const.h"
#include "util.h"


DOUBLE                            /*{ ret - coshd(x)      }*/
coshd
(
  DOUBLE x                        /*{ (i) - input value x }*/
)
{
    DOUBLE y, w, z;
    DOUBLE result;

    /*{ y = |x| }*/
    y = x;
    if (x < (DOUBLE)0.0)
    {
        y = -y;
    }

    /*{ if (y > XDOUBLE_MAX_EXP) }*/
    if (y > XDOUBLE_MAX_EXP)
    {
        /*{ w = y - ln(v) }*/
        w = SUBD(y, LN_V);

        /*{ if w > XDOUBLE_MAX_EXP, return 1.7e308 }*/
        if (w > XDOUBLE_MAX_EXP)
        {
            result = LDBL_MAX;
            return result;
        }

        /*{ z = exp(w) }*/
        z = expd(w);

        /*{ result = (v/2) * z }*/
        /* using higher precision computation */
        result = MPYD(V_2_MINUS1, z);
        result = ADDD(result, z);
    }
    /*{ else y <= XDOUBLE_MAX_EXP }*/
    else
    {
        /*{ z = exp(y) }*/
        z = expd(y);

        /*{ result = ((z + 1 / z) / 2 }*/
        result = DIVD(0.5, z);
        z = MPYD(0.5, z);
        result = ADDD(z, result);
    }

    /*{ return result }*/
    return result;
}


// Copyright (C) 2000 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/*_____________________________________________________________________
  Purpose     : This function computes cosh(x) using 32-bit float precision.
  Description : The algorithm used to implement this function is adapted from
                Cody & Waite, "Software Manual for the Elementary Functions",
                Prentice-Hall, New Jersey, 1980.

  Domain      : x = [-88.7 ... 88.7]

  Accuracy    : ~ Relative error:
                ~ * Primary range (-1 to 1) - 1 bits of error or less
                ~ * Outside primary range   - 3 bits of error or less
                ~ Assumption: there is no error in the input value

  Data Memory : ~   0
  Prog Memory : ~  59
  Cycles      : ~ 165 - max
                ~  28 - min

  Notes       : For x outside the domain, this function returns 3.4e38.
  _____________________________________________________________________
*/

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =coshf")
#pragma file_attr("libFunc  =__coshf")
#pragma file_attr("libFunc  =cosh")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <float.h>
#include <math.h>
#include "util.h"
#include <math_const.h>

FLOAT                                /*{ ret - cosh(x) }*/
_coshf(
    FLOAT x                          /*{ (i) - value to do coshf on }*/
)
{
    FLOAT y, w, z;
    FLOAT result;

    /*{ y = |x| }*/
    y = x;
    if (x < (FLOAT)0.0)
    {
        y = -y;
    }

    /*{ if (y > X_MAX_EXP) }*/
    if (y > (FLOAT)X_MAX_EXP)
    {
        /*{ w = y - ln(v) }*/
        w = SUB(y, (float)LN_V);

        /*{ if w > X_MAX_EXP, return 3.4e38 }*/
        if (w > (FLOAT)X_MAX_EXP)
        {
            result = (FLOAT)FLT_MAX;
            return result;
        }

        /*{ z = exp(w) }*/
        z = expf(w);

        /*{ result = (v/2) * z }*/
        /* using higher precision computation */
        result = MPY((float)V_2_MINUS1, z);
        result = ADD(result, z);
    }
    /*{ else y <= X_MAX_EXP }*/
    else
    {
        /*{ z = exp(y) }*/
        z = expf(y);

        /*{ result = ((z + 1 / z) / 2 }*/
        result = DIV(0.5, z);
        z = MPY(0.5, z);
        result = ADD(z, result);
    }


    /*{ return result }*/
    return result;
}

/*end of file*/

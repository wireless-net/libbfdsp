// Copyright (C) 2000 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/*______________________________________________________________________

  Func name   : modff

  ----------------------------------------------------------------------

  Purpose     : This function splits a 32-bit float input into an integer 
                and fractional part.
  Description : This function calculates the fractional part and integer part
                of input number x.

  Domain      : Full Range

  Accuracy    : ~ Relative error: 0 bits in error
                ~ Assumption: there is no error in the input value

  Data Memory : ~  0
  Prog Memory : ~ 36
  Cycles      : ~ 34 - max
                ~ 23 - min
  _____________________________________________________________________
*/

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =__modff")
#pragma file_attr("libFunc  =modff")     // from math.h
#pragma file_attr("libFunc  =modf")      // from math.h

/* Called by fmodf */
#pragma file_attr("libFunc  =__fmodf")
#pragma file_attr("libFunc  =fmodf")     // from math.h
#pragma file_attr("libFunc  =fmod")      // from math.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <math.h>
#include "util.h"
#include <math_const.h>

FLOAT                      /*{ ret - modf(x)}*/
_modff(
    FLOAT x,               /*{ (i) - value for which to compute modff }*/
    FLOAT *i               /*{ (o) - address to which integer part is written }*/
)
{
    FLOAT y;
    FLOAT fract;

    /*{ y = |x| }*/
    y = x;
    if (x < (FLOAT)0.0)
    {
        y = -y;
    }

    /*{ if |x| > 2^24 (max 23-bit int) }*/
    if (y >= (FLOAT)16777216.0)
    {
        /*{ int = x }*/
        /*{ return fract = 0.0 }*/
        *i = x;
        return (FLOAT)0.0;
    }

    /*{ if |x| < 1 }*/
    if (y < (FLOAT)1.0)
    {
        /*{ int = 0 }*/
        /*{ return fract = x }*/
        *i = (FLOAT)0.0;
        return x;
    }

    /*{ y = truncate(|x|) }*/
    y = TO_FLOAT(TO_LONG(y));

    /*{ if x < 0, y = -y }*/
    if (x < (FLOAT)0.0)
    {
        y = -y;
    }

    /*{ fract = x - y }*/
    fract = SUB(x, y);

    /*{ *i = y }*/
    *i = y;

    return fract;
}

/*end of file*/

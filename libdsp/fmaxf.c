// Copyright (C) 2000, 2001 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/****************************************************************************
  Func name   : fmaxf

  Purpose     : This function returns the greater of 2 input values.
  Description : 

  Domain      : ~ x = [-3.4e38 ... 3.4e38]
                ~ y = [-3.4e38 ... 3.4e38]

  ******************************************************************************/

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libGroup =math_bf.h")
#pragma file_attr("libFunc  =__fmaxf")
#pragma file_attr("libFunc  =fmaxf")
#pragma file_attr("libFunc  =fmax")

// Called by _coeff_iirdf1_fr16 but not including that here as in normal
// circumstances a builtin will be used not this function

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#define __NO_BUILTIN
#include <math.h>

float                      /*{ ret - max of (x, y) }*/
fmaxf(
    float x,               /*{ (i) - input parameter 1 }*/
    float y                /*{ (i) - input parameter 2 }*/
)
{
    /*{ result = y }*/
    float result = y;

    /*{ if x > y, result = x }*/
    if (x > y)
    {
        result = x;
    }

    /*{ return result }*/
    return result;
}

/* end of file */

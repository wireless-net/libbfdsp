// Copyright (C) 2000, 2001 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/****************************************************************************
  Func name   : copysignf
  
  Purpose     : This function copies the sign of the second argument to the
                first.

  Domain      : ~ x = [-3.4e38 ... 3.4e38]
                ~ y = [-3.4e38 ... 3.4e38]

*****************************************************************************/

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libGroup =math_bf.h")
#pragma file_attr("libFunc  =copysignf")        //from math.h
#pragma file_attr("libFunc  =__copysignf")
#pragma file_attr("libFunc  =copysign")         //from math.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <math.h>

float                      /*{ ret - signof(y) * |x| }*/
_copysignf(
    float x,               /*{ (i) - input parameter 1 }*/
    float y                /*{ (i) - input parameter 2 }*/
)
{
    long *yPtr = (long *)&y;
    long *xPtr = (long *)&x;
    long sign;

    /*{ copy sign of y }*/
    sign = *yPtr & 0x80000000;

    /*{ overwrite sign of x with sign of y }*/
    *xPtr = *xPtr & 0x7fffffff;
    *xPtr = *xPtr | sign;

    /*{ return x }*/
    return x;
}

/*end of file*/

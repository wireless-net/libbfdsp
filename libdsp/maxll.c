// Copyright (C) 2004 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.
/******************************************************************************
  Func name   : llmax

  Purpose     : This function returns the greater of 2 long long input values.

  Domain      : ~ a = [LLONG_MIN ... LLONG_MAX]
                ~ b = [LLONG_MIN ... LLONG_MAX]

******************************************************************************/

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libGroup =math_bf.h")
#pragma file_attr("libFunc  =__llmax")
#pragma file_attr("libFunc  =llmax")     //from math_bf.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <math.h>

long long  _llmax( long long  a, long long  b )
{
    long long  max_val;

    max_val = b;
    if (a > b)
    {
        max_val = a;
    }
    return  max_val;
}

/*end of file*/

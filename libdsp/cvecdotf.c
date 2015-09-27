// Copyright (C) 2000, 2001 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/****************************************************************************
   File: cvecdot.f

   Complex dot product for complex floating point vectors
 
****************************************************************************/

#pragma file_attr("libGroup =vector.h")
#pragma file_attr("libFunc  =__cvecdotf")
#pragma file_attr("libFunc  =cvecdotf")
#pragma file_attr("libFunc  =cvecdot")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <vector.h>

complex_float           /*{ ret - Complex dot product }*/
_cvecdotf(
    const complex_float a[],   /*{ (i) - Input vector `a[]` }*/
    const complex_float b[],   /*{ (i) - Input vector `b[]` }*/
    int n                      /*{ (i) - Number of elements in vector }*/
)
{
    int i;
    complex_float acc;

    /*{ Initialize accumulator }*/
    acc.re = 0.0;
    acc.im = 0.0;

    /*{ Multiply each element of vector `a[]` with each element of
        vector `b[]` and accumulate result. }*/
    for (i = 0; i < n; i++)
    {
        acc.re += a[i].re * b[i].re - a[i].im * b[i].im;
        acc.im +=a[i].re * b[i].im + a[i].im * b[i].re;
    }

    return (acc);
}

/*end of file*/


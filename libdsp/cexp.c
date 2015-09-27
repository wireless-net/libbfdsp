// Copyright (C) 2000, 2001 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/***************************************************************************
   File: cexp.c
  
   complex exponential for floating point input

****************************************************************************/

#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =cexpf")       //from complex_fns.h
#pragma file_attr("libFunc  =__cexpf")
#pragma file_attr("libFunc  =cexp")        //from complex_fns.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <math.h>
#include <complex_fns.h>

complex_float _cexpf(float a )
{
    complex_float c;

    c.re = cosf(a);
    c.im = sinf(a);
    return (c);
}

/*end of file*/

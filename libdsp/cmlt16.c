// Copyright (C) 2000-2005 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/******************************************************************
   Func Name:    cmlt_fr16

   Description:  multiplication of two complex numbers

******************************************************************/

#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =__cmlt_fr16")
#pragma file_attr("libFunc  =cmlt_fr16")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <fract.h>
#include <fract_complex.h>

complex_fract16 _cmlt_fr16 ( complex_fract16 a, complex_fract16 b )
{
    complex_fract16 result;
    fract32 real, imag;

    real = (a.re * b.re - a.im * b.im)>>(FRACT16_BIT-1);
    imag = (a.re * b.im  + a.im * b.re)>>(FRACT16_BIT-1);
	 
    if(real >= 32767)
      result.re = 0x7fff;
    else if(real <= -32768)
      result.re = 0x8000;
    else
      result.re = real;

    if(imag >= 32767)
      result.im = 0x7fff;
    else if(imag <= -32768)
      result.im = 0x8000;
    else
      result.im = imag;

    return (result);
}

/*end of file*/

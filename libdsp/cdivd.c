/************************************************************************
 *
 * cdivd.c
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
 * Description :   Division of two complex numbers.
 *
 *                          a.real * b.real + a.imag * b.imag
 *                 c.real = ---------------------------------
 *                          b.real * b.real + b.imag * b.imag
 *
 *                          a.imag * b.real - a.real * b.imag
 *                 c.imag = ---------------------------------
 *                          b.real * b.real + b.imag * b.imag
 */

#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =__cdivd")
#pragma file_attr("libFunc  =cdivd")
#pragma file_attr("libFunc  =cdiv")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <complex_bf.h>


#include <math.h>


static union _ll2ld
{
  long double    x;
  unsigned long  a[2];
} plus_inf;


complex_long_double               /*{ ret - Complex fraction       }*/
cdivd
(
  complex_long_double a,          /*{ (i) - Complex input `a`      }*/
  complex_long_double b           /*{ (i) - Complex input `b`      }*/
)
{
    complex_long_double    c;
    long double      fractio, denum;


    /*
       To prevent avoidable overflows, underflow or loss of precision,
       the following alternative algorithm is used:

       If |b.re| >= |b.im|
         c.re = (a.re + a.im * (b.im / b.re)) / (b.re + b.im * (b.im / b.re));
         c.im = (a.im - a.re * (b.im / b.re)) / (b.re + b.im * (b.im / b.re));

       Else    // |b.re| < |b.im|
         c.re = (a.re * (b.re / b.im) + a.im) / (b.re * (b.re / b.im) + b.im);
         c.im = (a.im * (b.re / b.im) - a.re) / (b.re * (b.re / b.im) + b.im);
     */

    if( (b.re == 0) && (b.im == 0) )
    {
       /* return +Inf */
       plus_inf.a[1] = 0x7FF00000;
       plus_inf.a[0] = 0x00000000;
       c.re = plus_inf.x;
       c.im = plus_inf.x;
    }
    else if (b.re == 0)
    {
       c.re =   a.im / b.im;
       c.im = -(a.re / b.im);
    }
    else if (b.im == 0)
    {
       c.re =   a.re / b.re;
       c.im =   a.im / b.re;
    }
    else if( fabsd(b.re) >= fabsd(b.im) )
    {
       fractio = b.im / b.re;
       denum   = 1.0L / (b.re + b.im * fractio);
       c.re    = (a.re + a.im * fractio) * denum;
       c.im    = (a.im - a.re * fractio) * denum;
    }
    else
    {
       fractio = b.re / b.im;
       denum   = 1.0L / (b.re * fractio + b.im);
       c.re    = (a.re * fractio + a.im) * denum;
       c.im    = (a.im * fractio - a.re) * denum;
    }

    return (c);
}



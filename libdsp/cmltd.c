/************************************************************************
 *
 * cmltd.c
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
 * Description :   Complex multiplication
 */

#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =cmltd")
#pragma file_attr("libFunc  =__cmltd")
#pragma file_attr("libFunc  =cmlt")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <complex_bf.h>


complex_long_double               /*{ ret - Complex product        }*/
cmltd
(
  complex_long_double a,          /*{ (i) - Complex input `a`      }*/
  complex_long_double b           /*{ (i) - Complex input `b`      }*/
)
{
    complex_long_double  c;

    /*{ Subtract imag portion of `a` times imag portion of `b` from real 
        portion of `a` times real portion of `b` }*/
    c.re = a.re * b.re - a.im * b.im;

    /*{ Add imag portion of `a` times real portion of `b` to real portion of
        `a` times imag portion of `b` }*/
    c.im = a.re * b.im + a.im * b.re;

    return (c);
}

/************************************************************************
 *
 * caddd.c
 *
 * Copyright (C) 2004 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ************************************************************************/

#pragma file_attr("libGroup =fract_complex.h")
#pragma file_attr("libFunc  =caddd")
#pragma file_attr("libFunc  =__caddd")     //from complex_fns.h
#pragma file_attr("libFunc  =cadd")        //from complex_fns.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/*
 * Description :   Addition of two complex numbers.
 */

/* Defined in */
#include <complex_bf.h>


complex_long_double               /*{ ret - Complex sum            }*/
caddd
(
  complex_long_double a,          /*{ (i) - Complex input `a`      }*/
  complex_long_double b           /*{ (i) - Complex input `b`      }*/
)
{
    complex_long_double  c;


    /*{ Sum real portions of `a` and `b` }*/
    c.re = a.re + b.re;

    /*{ Sum imag portions of `a` and `b` }*/
    c.im = a.im + b.im;

    return (c);
}

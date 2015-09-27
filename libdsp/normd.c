/************************************************************************
 *
 * normd.c
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
 * Description :   Complex Normalization
 *                   c.real = a.real / sqrt( (a.real)^2 + (a.imag)^2 )
 *                   c.imag = a.imag / sqrt( (a.real)^2 + (a.imag)^2 )
 */

#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =normd")
#pragma file_attr("libFunc  =__normd")     //from complex_fns.h
#pragma file_attr("libFunc  =norm")        //from complex_fns.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <complex_bf.h>
#include <complex_fns.h>

complex_long_double               /*{ ret - Normalized `a`         }*/
normd
(
  complex_long_double a           /*{ (i) - Complex input `a`      }*/
)
{
    complex_long_double  c;
    long double  d;


    /*{ Calculate the square root of the real portion of `a` times the real
        portion of `a` plus the imag portion of `a` times the imag portion
        of `a` }*/
    d = bf_cabsd( a);


    if( d == 0.0L )
    {
        c.re = 0.0L;
        c.im = 0.0L;
    }
    else
    {
        /*{ Divide the real portion of `a` by the square root obtained above }*/
        c.re = a.re / d;

        /*{ Divide the imag portion of `a` by the square root obtained above }*/
        c.im = a.im / d;
    }

    return (c);
}

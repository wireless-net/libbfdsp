/************************************************************************
 *
 * cexpd.c
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
 * Description :   Calculate the complex exponential of a real number.
 *                       c.re = cos(a), c.im = sin(a) 
 */

#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =cexpd") 
#pragma file_attr("libFunc  =__cexpd")     //from complex_fns.h
#pragma file_attr("libFunc  =cexp")        //from complex_fns.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <complex_fns.h>

#include <math.h>


complex_long_double               /*{ ret - Complex exponential    }*/
bf_cexpd
(
  long double a                   /*{ (i) - Real Exponent a        }*/
)
{
    complex_long_double  c;

    /*{ Take cosine and sine of `a` }*/
    c.re = cosd(a);
    c.im = sind(a);

    /*{ Return result }*/
    return (c);
}

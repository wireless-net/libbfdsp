/************************************************************************
 *
 * conjd.c
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
 * Description :   Complex Conjugate
 */

#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =conjd")
#pragma file_attr("libFunc  =__conjd")
#pragma file_attr("libFunc  =conj")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <complex_fns.h>


complex_long_double               /*{ ret - Complex conjungate 'a' }*/
bf_conjd
(
  complex_long_double a           /*{ (i) - Complex input `a`      }*/
)
{
    complex_long_double  c;

    /*( Negate the imag portion of `a` }*/
    c.re = a.re;
    c.im = -a.im;

    return (c);
}

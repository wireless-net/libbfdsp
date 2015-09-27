/************************************************************************
 *
 * polard.c
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
 * Description :   Conversion from polar notation to rectangular coordinates
 *                   a.real = Magnitude * cos(Phase);
 *                   a.imag = Magnitude * sin(Phase);
 */


#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =polard")       //from complex_fns.h
#pragma file_attr("libFunc  =__polard")
#pragma file_attr("libFunc  =polar")        //from complex_fns.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <complex_bf.h>

#include <math.h>

complex_long_double               /*{ ret - Complex result         }*/
polard
(
  long double mag,                /*{ (i) - Magnitude `mag`        }*/
  long double phase               /*{ (i) - Phase `phase`          }*/
)
{
    complex_long_double  c;


    /*{ Take cosine and sine of `a` }*/
    c.re = mag * cosd(phase);
    c.im = mag * sind(phase);

    return (c);
}

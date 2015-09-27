// Copyright (C) 2000, 2001 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/****************************************************************************
   Func Name:    normf

   Description:  normalizing the complex input a

****************************************************************************/

#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =normf")       //from complex_fns.h
#pragma file_attr("libFunc  =__normf")
#pragma file_attr("libFunc  =norm")        //from complex_fns.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <complex_bf.h>
#include <complex_fns.h>

complex_float _normf(complex_float a )
{
   complex_float  c;
   float          d;

   d = bf_cabsf(a);

   if( d == 0.0F )
   {
      c.re = 0.0F;
      c.im = 0.0F;
   }
   else
   {
      d = 1.0F / d;
      c.re = a.re * d;
      c.im = a.im * d;
   }

   return (c);
}

/*end of file*/

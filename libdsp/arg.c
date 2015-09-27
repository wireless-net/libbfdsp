// Copyright (C) 2000, 2001 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/*********************************************************************
   Func Name:    argf

   Description:  return phase of the complex input a

*********************************************************************/

#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =__argf")
#pragma file_attr("libFunc  =argf")
#pragma file_attr("libFunc  =arg")
/* Called by cartesian */
#pragma file_attr("libFunc  =cartesianf")
#pragma file_attr("libFunc  =__cartesianf")
#pragma file_attr("libFunc  =cartesian")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <math.h>
#include <complex_fns.h>

float _argf( complex_float a )
{
  float arg;

  arg = atan2f(a.im, a.re);
  return(arg);
}

/* end of file */

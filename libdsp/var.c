// Copyright (C) 2000, 2001 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/****************************************************************************
   File: var.c

   Calculates the variance of the floating point input vector.

***************************************************************************/

#pragma file_attr("libGroup =stats.h")
#pragma file_attr("libFunc  =varf")
#pragma file_attr("libFunc  =__varf")     // from stats.h
#pragma file_attr("libFunc  =var")        // from stats.h
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <math.h>
#include <stats.h>
#include "means.h"

float varf(const float *a, int n)
{
  // a is the input vector and n its size.
      float m, ms, v;

      if(n <= 1)
	return 0;

      m = meanf (a, n);
      ms = _meansf (a, n);
      
      v = ms - m*m;
      v = (v * n) / (n-1);

       // v stores the variance of vector a.
      return v;
}
/*end of file*/

// Copyright (C) 2000, 2001 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/**************************************************************************
   File: mean.c

   Calculates the mean value of a vector.

***************************************************************************/

#pragma file_attr("libGroup =stats.h")
#pragma file_attr("libFunc  =meanf")      // from stats.h
#pragma file_attr("libFunc  =__meanf")
#pragma file_attr("libFunc  =mean")        // from stats.h
/* this function gets called by varf */
#pragma file_attr("libFunc  =varf")
#pragma file_attr("libFunc  =__varf")     // from stats.h
#pragma file_attr("libFunc  =var")        // from stats.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <stats.h>

float _meanf(const float *a, int n)
{
      // a is the input vector and n is its size.
      int i; 
      float sum =0;

      if(n <= 0)
	   return 0;

      for (i = 0; i < n; i++) 
           sum += (*a++);   // calculates the summation for mean

      sum = sum / n;        // i stores the mean value
      return sum;
}
/*end of file*/

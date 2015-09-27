// Copyright (C) 2000 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/**************************************************************************
   Func Name:    means

   Description:  Internal function required for calculating rms, var value. 
                 It computes the mean of squared a[i]

**************************************************************************/

#pragma file_attr("libFunc  =__meansf")
/* this function gets called by varf */
#pragma file_attr("libGroup =stats.h")
#pragma file_attr("libFunc  =varf")
#pragma file_attr("libFunc  =__varf")     // from stats.h
#pragma file_attr("libFunc  =var")        // from stats.h

/* called by rmsf */
#pragma file_attr("libFunc  =rmsf")       //from stats.h
#pragma file_attr("libFunc  =__rmsf")
#pragma file_attr("libFunc  =rms")        //from stats.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include "means.h"

float _meansf (const float *a, int n)
{
   int i, m;
   float k, sum;

   if( n <= 0)
      return 0.0;
   else
   {	
      sum = 0;
      for (i = 0; i < n; i++) {
            k = (*a++);
            k *= k;
            sum += k;
      }
      sum = sum / n;
      return sum;
   }
} 
/*end of file*/

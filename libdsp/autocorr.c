// Copyright (C) 2000, 2001 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/**************************************************************************
   File: autocorr.c
  
   Auto Correlation of a vector.

***************************************************************************/
#pragma file_attr("libGroup =stats.h")
#pragma file_attr("libFunc  =__autocorrf")
#pragma file_attr("libFunc  =autocorrf")
#pragma file_attr("libFunc  =autocorr")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <stats.h>

void _autocorrf( const float *a, int n, int m, float *c )
{
  /* a is the input vector
     n is the size of vector
     m is the number of bins 
     c is the output vector.
  */
    int i, j;
    float temp1, temp2;

    if (n <= 0 || m <= 0)
    {
      return;
    }

    //This for loop calculates the auto correlation.
    for (i=0; i < m; i++)
    {
        c[i] = 0.0;
        for (j = 0; j < n-i; j++)
        {
            c[i] += (a[j] * a[j+i]);
        }

        c[i] = c[i] / n;
    }

}

/* end of file */

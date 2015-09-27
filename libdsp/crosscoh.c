// Copyright (C) 2000, 2001 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/**************************************************************************
   File: crosscoh.c
   
   Cross coherance of two floating point vectors.

***************************************************************************/

#pragma file_attr("libGroup =stats.h")
#pragma file_attr("libFunc  =crosscohf")
#pragma file_attr("libFunc  =__crosscohf")
#pragma file_attr("libFunc  =crosscoh")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <stats.h>

void _crosscohf(const float *a, const float *b, int n, int m, float *c)
{   
  /* a and b are the input vectors
     n is the size of vectors
     m is the number of bins 
     c is the output vector.
  */
    int i,j;
    float amean =0, bmean=0;
    float temp1 =0, temp2=0;

    if (n <= 0 || m <= 0)
    {
      return;
    }

    for (i = 0; i < n; i++)
    {
        amean += a[i];
        bmean += b[i];
    }
    amean = amean / n;
    bmean = bmean / n;

    //This for loop calculates the cross coharence of two vectors.
    for (i=0; i < m; i++)
    {
      c[i] = 0.0;
      for (j = 0; j < n-i; j++)
      {
        c[i] += a[j]*b[j+i];
      }
      c[i] = c[i] /n;
      c[i] -= amean * bmean;
    }
}

/*end of file*/

/************************************************************************
 *
 * histogramd.c
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
 * Description :   Histogram function
 *                   This function computes a histogram of its input vector.
 *                   The `max`, `min` amd `m` parameters are used to adjust 
 *                   the width of each individual binsize in the output 
 *                   vector:  `binsize = (max - min) / m`
 *
 *                   The output vector is first zeroed by the function, and
 *                   each sample in the input array is shift by min, 
 *                   multiplied by 1/binsize and rounded. The appropriate 
 *                   bin in the output vector is incremented.
 *
 *                   Boundary on the output array is checked. If a scaled 
 *                   input sample exceeds the boundaries of the out vector, 
 *                   it is discarded.
 */

#pragma file_attr("libGroup =stats.h")
#pragma file_attr("libFunc  =histogramd")
#pragma file_attr("libFunc  =__histogramd")
#pragma file_attr("libFunc  =histogram")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <stats.h>
 
void 
histogramd
( 
  const long double *a,           /*{ (i) - Pointer to input vector       }*/
  int    *c,                      /*{ (o) - Pointer to output vector      }*/
  long double max,                /*{ (i) - Max value of the bin boundary }*/
  long double min,                /*{ (i) - Min value of the bin boundary }*/
  int    n,                       /*{ (i) - Number of input samples       }*/
  int    m                        /*{ (i) - Number of bins                }*/
)
{
    int  i, l;
    long double  binsize;
    long double  inv_binsize;
    long double  offset;


   /* { Check the number of elements `n` and the number of bins `m` } */   
    if ((n <= 0) || (m <= 0))
    {
        return;
    }

   /* { Check the parameter `min` and `max` } */
    if (max <= min)
    {
        return;
    }

    /* { Calculate the binsize } */
    binsize = (max - min) / m;

    inv_binsize = m/(max - min);

    offset = binsize - min;

   /* { Initialize the output vector to zero } */
    for (i = 0; i < m; i++)
    {
        c[i] = 0;
    }

    for (i = 0; i < n; i++)
    {
       /* Compare the value of each element in the input vector 
          with each bin boundary; if it falls within the range of 
          the bin, then increase the corresponding bin count by one 
        */
        l = (int)((a[i] + offset) * inv_binsize);
        
        if (l >= 1 && l <= m)
        {
            c[l-1]++;
        }
    }
}

/************************************************************************
 *
 * autocorrd.c
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
 * Description :   Calculate the autocorrelation for the input vector.
 *                   Autocorrelation is the cross-correlation of a signal 
 *                   with a copy of itself. It provides information about 
 *                   the time variantion of the signal. The signal to be 
 *                   autocorrelated is given by the a[] array.
 *
 *                   c[k] = sum(a[i]*a[i+k])/n;   sum from i = 0 to n-k-1
 */

#pragma file_attr("libGroup =stats.h")
#pragma file_attr("libFunc  =__autocorrd")
#pragma file_attr("libFunc  =autocorrd")
#pragma file_attr("libFunc  =autocorr")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <stats.h>


void 
autocorrd
( 
  const long double *a,           /*{ (i) - Pointer to input vector  }*/
  int    n,                       /*{ (i) - Number of input samples  }*/
  int    m,                       /*{ (i) - Lag count                }*/
  long double *c                  /*{ (o) - Pointer to output vector }*/
)
{
    int  i, j;
    long double  invn;


    /*{ Check the number of element `n` and lag count `m` }*/
    if ( (n <= 0) || (m <= 0) )
    {
        return;
    }

    invn = 1.0L / n;

     /*{ Calculate the autocorrelation of the input vector }*/
    for (i = 0; i < m; i++)
    {
        c[i] = 0.0L;
        for (j = 0; j < n-i; j++)
        {
            c[i] += (a[j] * a[j+i]);
        }

        c[i] = c[i] * invn;
    }
}

/************************************************************************
 *
 * autocohd.c
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
 * Description :   Calculate the autocoherence of the input vector
 *                   This function computes the autochoherence of the
 *                   input vector a[]. The autocoherence of an input 
 *                   signal is its autocorrelation minus its mean square.
 *
 *                   c[k] = sum( a[i] * a[i+k] ) / n - (mean(a) * mean(a));
 *                                  sum from i = 0 to n-k-1
 *                                  mean(a) = sum( a[i] ) / n
 */

#pragma file_attr("libGroup =stats.h")
#pragma file_attr("libFunc  =__autocohd")
#pragma file_attr("libFunc  =autocohd")
#pragma file_attr("libFunc  =autocoh")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <stats.h>

void 
autocohd
( 
  const long double *a,           /*{ (i) - Pointer to input vector  }*/
  int    n,                       /*{ (i) - Number of input samples  }*/
  int    m,                       /*{ (i) - Lag count                }*/
  long double *c                  /*{ (o) - Pointer to output vector }*/
)
{
    int  i, j;
    long double  mean = 0.0L;
    long double  invn;

    /*{ Check the number of element `n` and lag count `m`}*/
    if ( (n <= 0) || (m <= 0) )
    {
        return;
    }

    invn = 1.0L/n;

    /*{ Calculate the mean value of input vector }*/
    for (i = 0; i < n; i++)
    {
        mean += a[i];
    }
    mean *= invn;
    
    /*{ Calculate the autocoherence of the input vector }*/
    for (i = 0; i < m; i++)
    {
        /*{ Calculate the autocorrelation of input vector }*/
        c[i] = 0.0L;
        for (j = 0; j < n-i; j++)
        {
            c[i] +=  (a[j] * a[j+i]) ;
        }

        c[i] = c[i] * invn;

        /*Autocorrelation minus the squared mean*/
        c[i] -= (mean * mean);
    }
}

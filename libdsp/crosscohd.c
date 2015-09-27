/************************************************************************
 *
 * crosscohd.c
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
 * Description :   Crosscoherence
 *                   This function performs a cross coherence on the 
 *                   vectors `a` and `b`, where `m` refers to LAGS in 
 *                   the equation below. The cross coherence is defined 
 *                   as the cross correlation of `a` and `b`, minus the 
 *                   mean of `a` times the mean of `b`.
 *
 *                   c[k] = sum( a[i] * b[i+k]) / n - mean(a) *mean(b);
 *                                   sum over 0 to n-k-1
 *                                   mean(a) = sum( a[i] ) / n
 */

#pragma file_attr("libGroup =stats.h")
#pragma file_attr("libFunc  =crosscohd")
#pragma file_attr("libFunc  =__crosscohd")
#pragma file_attr("libFunc  =crosscoh")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <stats.h>

void 
crosscohd
( 
  const long double *a,           /*{ (i) - Pointer to input vector  }*/
  const long double *b,           /*{ (i) - Pointer to input vector  }*/
  int    n,                       /*{ (i) - Number of input samples  }*/
  int    m,                       /*{ (i) - Lag count                }*/
  long double *c                  /*{ (o) - Pointer to output vector }*/
)
{   
    int  i, j;
    long double  amean = 0.0L, bmean = 0.0L;
    long double  invn;

    /*{ Check the number of element `n` and lag count `m` }*/
    if ( (n <= 0) || (m <= 0) )
    {
        return;
    }

    invn = 1.0L/n;

    /*{ Calculate the means value of input vectors }*/
    for (i = 0; i < n; i++)
    {
        amean += a[i];
        bmean += b[i];
    }
    amean *= invn;
    bmean *= invn;

    /*{ Calculate the crosscoherence of the input vector }*/     
    for (i = 0; i < m; i++)
    {
        /*{ Calculate the crosscorrelation of input vector }*/
        c[i] = 0.0L;
        for (j = 0; j < n-i; j++)
        {
            c[i] += (a[j] * b[j+i]);
        }

        c[i] = c[i] * invn;

        /*Crosscorrelation minus the squared mean*/
        c[i] -= (amean * bmean);
    }
}



/************************************************************************
 *
 * crosscorrd.c
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
 * Description :   Crosscorrelation
 *                   This function performs a cross-correlation between
 *                   two signals. The cross-correlation is the sum of the 
 *                   scalar products of the signals in which the signals 
 *                   are displaced in time with respect to one another.  
 *                   The signals to be correlated are given by a[] and b[].
 *
 *                     c[k] = sum( a[i] * b[i+k] ) / n; sum over 0 to n-k-1
 */

#pragma file_attr("libGroup =stats.h")
#pragma file_attr("libFunc  =crosscorrd")
#pragma file_attr("libFunc  =__crosscorrd")
#pragma file_attr("libFunc  =crosscorr")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <stats.h>


void 
crosscorrd
( 
  const long double *a,           /*{ (i) - Pointer to input vector  }*/
  const long double *b,           /*{ (i) - Pointer to input vector  }*/
  int    n,                       /*{ (i) - Number of input samples  }*/
  int    m,                       /*{ (i) - Lag count                }*/
  long double *c                  /*{ (o) - Pointer to output vector }*/
)
{
    int  i, j;
    long double  invn;


    /*{ Check the number of element `n` and lag count 'm' }*/
    if ( (n <= 0) || (m <= 0) )
    {
        return;
    }

    invn = 1.0L / n;

    /*{ Calculate the crosscorrelation of the input vector }*/
    for (i = 0; i < m; i++)
    {
        c[i] = 0.0L;
        for (j = 0; j < n-i; j++)
        {
            c[i] += (a[j] * b[j+i]);
        }

        c[i] = c[i] * invn;
    }
}   



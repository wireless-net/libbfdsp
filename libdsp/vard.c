/************************************************************************
 *
 * vard.c
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
 * Description :   Variance
 *                   variance = ( (n * sum( a[i] * a[i] ) ) -
 *                                (sum( a[i] ) * sum( a[i] ) )
 *                              / (n * (n-1) )
 */

#pragma file_attr("libGroup =stats.h")
#pragma file_attr("libFunc  =vard")
#pragma file_attr("libFunc  =__vard")     // from stats.h
#pragma file_attr("libFunc  =var")        // from stats.h
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <stats.h>

long double                       /*{ ret - Variance                 }*/   
vard
( 
  const long double *a,           /*{ (i) - Pointer to input vector  }*/
  int   n                         /*{ (i) - Number of input samples  }*/
)
{
    long double  sumsquare = 0.0L, squaresum = 0.0L;
    long double  variance;
    int i;


    /* { Check the number of element `n` } */
    if ( n <= 1 )
    {
        return 0.0L;
    }

    /* Calculate the square summation of input vector element
       and summation of the input vector element square 
     */ 
    for (i = 0; i < n; i++)
    {
        sumsquare += a[i];
        squaresum += (a[i] * a[i]);
    }

    sumsquare *= sumsquare;

    /* { Calculate the variance } */
    variance = n * squaresum - sumsquare;
    variance /= (n * (n - 1));

    return (variance);
}


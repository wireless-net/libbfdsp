/************************************************************************
 *
 * meand.c
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
 * Description :   Mean
 *                   mean = sum( a(i) ) / n
 */

#pragma file_attr("libGroup =stats.h")
#pragma file_attr("libFunc  =meand")      // from stats.h
#pragma file_attr("libFunc  =__meand")
#pragma file_attr("libFunc  =mean")        // from stats.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <stats.h>

long double                       /*{ ret  - Mean value              }*/
meand
( 
  const long double  *a,          /*{ (i)  - Pointer to input vector }*/
  int   n                         /*{ (i)  - Number of input samples }*/
)
{
    long double sum = 0.0L;
    int i;


    /* { Check the number of element `n`} */
    if (n <= 0 )
    {
        return 0.0L;
    }


    /* { Sum each element of the input vector, 
         then divide by the number of elements } */ 
    for (i = 0; i < n; i++)
    {
        sum += a[i];
    }
    sum /= n;

    return (sum);
}

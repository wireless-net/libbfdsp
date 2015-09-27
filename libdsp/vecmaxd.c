/************************************************************************
 *
 * vecmaxd.c
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
 * Description :   Find largest value stored in vector
 */

#pragma file_attr("libGroup =vector.h")
#pragma file_attr("libFunc  =vecmaxd")
#pragma file_attr("libFunc  =__vecmaxd")
#pragma file_attr("libFunc  =vecmax")      // from vector.h
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <vector.h>

long double                       /*{ ret - Largest value in a[]         }*/
vecmaxd
(
  const long double a[],          /*{ (i) - Input vector `a[]`           }*/
  int n                           /*{ (i) - Number of elements in vector }*/
)
{
    int  i;
    long double  max_val;

    /*{ Error Handling }*/
    if (n <= 0)
    {
        return 0.0L;
    }

    /*{ Search through vector a[]. }*/
    max_val = a[0];
    for (i = 1; i < n; i++)
    {
        if( a[i] > max_val )
        {
            max_val = a[i];
        }
    }

    return (max_val);
}

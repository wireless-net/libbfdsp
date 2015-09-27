/************************************************************************
 *
 * vecmaxlocd.c
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
 * Description :   Find location of largest value stored in vector
 */

#pragma file_attr("libGroup =vector.h")
#pragma file_attr("libFunc  =vecmaxlocd")
#pragma file_attr("libFunc  =__vecmaxlocd") // from vector.h
#pragma file_attr("libFunc  =vecmaxloc")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <vector.h>

int                               /*{ ret - Index largest value in a[]   }*/
vecmaxlocd
(
  const long double a[],          /*{ (i) - Input vector `a[]`           }*/
  int n                           /*{ (i) - Number of elements in vector }*/
)
{
    int  i, idx;
    long double*  pmax;


    /*{ Error Handling }*/
    if (n <= 0)
    {
        return 0.0L;
    }

    /*{ Search through vector a[]. }*/
    pmax = (long double*) &a[0];
    for (i = 1; i < n; i++)
    {
        if( a[i] > *pmax )
        {
            pmax = (long double*) &a[i];
        }
    }

    idx = pmax - &a[0];           /*{ Idx = &a[max] - &a[0] }*/
    return (idx);
}

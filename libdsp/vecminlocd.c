/************************************************************************
 *
 * vecminlocd.c
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
 * Description :   Find location of smallest value stored in vector
 */

#pragma file_attr("libGroup =vector.h")
#pragma file_attr("libFunc  =vecminlocd")
#pragma file_attr("libFunc  =__vecminlocd") // from vector.h
#pragma file_attr("libFunc  =vecminloc")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <vector.h>

int                               /*{ ret - Index smallest value in a[]  }*/
vecminlocd
(
  const long double a[],          /*{ (i) - Input vector `a[]`           }*/
  int n                           /*{ (i) - Number of elements in vector }*/
)
{
    int  i, idx;
    long double*  pmin;


    /*{ Error Handling }*/
    if (n <= 0)
    {
        return 0.0L;
    }

    /*{ Search through vector a[]. }*/
    pmin = (long double*) &a[0];
    for (i = 1; i < n; i++)
    {
        if( a[i] < *pmin )
        {
            pmin = (long double*) &a[i];
        }
    }

    idx = pmin - &a[0];           /*{ Idx = &a[min] - &a[0] }*/
    return (idx);
}

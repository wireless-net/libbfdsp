/************************************************************************
 *
 * vecmind.c
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
 * Description :   Find smallest value stored in vector
 */

#pragma file_attr("libGroup =vector.h")
#pragma file_attr("libFunc  =vecmind")
#pragma file_attr("libFunc  =__vecmind")
#pragma file_attr("libFunc  =vecmin")      // from vector.h
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <vector.h>


long double                       /*{ ret - Smallest value in a[]        }*/
vecmind
(
  const long double a[],          /*{ (i) - Input vector `a[]`           }*/
  int n                           /*{ (i) - Number of elements in vector }*/
)
{
    int  i;
    long double  min_val;

    /*{ Error Handling }*/
    if (n <= 0)
    {
        return 0.0L;
    }

    /*{ Search through vector a[]. }*/
    min_val = a[0];
    for (i = 1; i < n; i++)
    {
        if( a[i] < min_val )
        {
            min_val = a[i];
        }
    }

    return (min_val);
}

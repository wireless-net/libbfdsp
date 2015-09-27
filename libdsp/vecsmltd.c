/************************************************************************
 *
 * vecsmltd.c
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
 * Description :   Vector Scalar Multiplication
 */

#pragma file_attr("libGroup =vector.h")
#pragma file_attr("libGroup =matrix.h")
#pragma file_attr("libFunc  =vecsmltd")
#pragma file_attr("libFunc  =__vecsmltd")   // from vector.h
#pragma file_attr("libFunc  =vecsmlt")      // from vector.h
#pragma file_attr("libFunc  =matsmltd")     // from matrix.h
#pragma file_attr("libFunc  =matsmlt")      // from matrix.h
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <vector.h>

void
vecsmltd
(
  const long double a[],          /*{ (i) - Input vector  `a`            }*/
  long double b,                  /*{ (i) - Input scalar  `b`            }*/
  long double c[],                /*{ (o) - Output vector `c`            }*/
  int n                           /*{ (i) - Number of elements in vector }*/
)
{
    int i;


    /*{ Multiply `b` with each element of vector `a[]` and store
        in vector `c[]`. }*/
    for (i = 0; i < n; i++)
    {
        c[i] = a[i] * b;
    }
}


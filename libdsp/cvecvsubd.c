/************************************************************************
 *
 * cvecvsubd.c
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
 * Description :   Complex Vector Vector Subtraction
 */

#pragma file_attr("libGroup =vector.h")
#pragma file_attr("libFunc  =__cvecvsubd")
#pragma file_attr("libFunc  =cvecvsubd")
#pragma file_attr("libFunc  =cvecvsub")
/* Called by cmatmsubd and cmatmsub */
#pragma file_attr("libGroup =matrix.h")
#pragma file_attr("libFunc  =cmatmsubd")
#pragma file_attr("libFunc  =cmatmsub")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <vector.h>



void
cvecvsubd
(
  const complex_long_double a[],  /*{ (i) - Input vector `a[]`           }*/
  const complex_long_double b[],  /*{ (i) - Input vector `b[]`           }*/
  complex_long_double c[],        /*{ (o) - Output vector `c[]`          }*/
  int n                           /*{ (i) - Number of elements in vector }*/
)
{
    int i;


    /*{ Subtract each element of vector `b[]` from each element of 
        vector `a[]` and store in vector `c[]`. }*/
    for (i = 0; i < n; i++)
    {
        c[i].re = a[i].re - b[i].re;
        c[i].im = a[i].im - b[i].im;
    }
}

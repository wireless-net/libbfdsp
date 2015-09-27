// Copyright (C) 2000, 2001 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/*****************************************************************************
   Func Name:    cvecsmltf

   Description:  multiply each complex member a[i] in a[] with complex scalar b

*****************************************************************************/

#pragma file_attr("libGroup =vector.h")
#pragma file_attr("libFunc  =__cvecsmltf")
#pragma file_attr("libFunc  =cvecsmltf")
#pragma file_attr("libFunc  =cvecsmlt")
/* Called by cmatsmlt and cmatsmltf */
#pragma file_attr("libGroup =matrix.h")
#pragma file_attr("libFunc  =cmatsmltf")
#pragma file_attr("libFunc  =cmatsmlt")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <vector.h>

void
_cvecsmltf(
	const complex_float a[],   /*{ (i) - Input vector `a[]` }*/
	complex_float b,           /*{ (i) - Input scalar `b` }*/
	complex_float c[],         /*{ (o) - Output vector `c[]` }*/
	int n                      /*{ (i) - Number of elements in vector }*/
)
{
     int i;

     for (i=0;i<n;i++)
     {
       c[i].re = a[i].re * b.re - a[i].im * b.im;
       c[i].im = a[i].re * b.im + a[i].im * b.re;
     }
}

/*end of file*/

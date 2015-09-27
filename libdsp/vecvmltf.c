// Copyright (C) 2000 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/*______________________________________________________________________

  Func name   : vecvmltf

  ----------------------------------------------------------------------------

  Purpose     : Real vector * vector multiplication for float data types.
  Description : This function multiplies each element of vector `a[]` with
                each element of input vector `b[]` and stores the result in 
                vector `c[]`.
                
  Domain      : Full Range.

  Accuracy    : 0 bits in error.

  Notes       : Output can be written to either input vector.
  _____________________________________________________________________
*/

#pragma file_attr("libGroup =vector.h")
#pragma file_attr("libFunc  =vecvmltf")
#pragma file_attr("libFunc  =__vecvmltf") // from vector.h
#pragma file_attr("libFunc  =vecvmlt")    // from vector.h
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <vector.h>

void
_vecvmltf(
    const float a[],    /*{ (i) - Input vector `a[]` }*/
    const float b[],    /*{ (i) - Input vector `b[]` }*/
    float c[],          /*{ (o) - Output vector `c[]` }*/
    int n               /*{ (i) - Number of elements in vector }*/
)
{
    int i;

    /*{ Multiply each element of vector `a[]` with each element
        of vector `b[]` and store the result in vector `c[]`. }*/
    for (i = 0; i < n; i++)
        c[i] = a[i] * b[i];
}

/*end of file*/

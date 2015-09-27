// Copyright (C) 2000 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.


/*______________________________________________________________________

  Func name   : vecvaddf

  ----------------------------------------------------------------------------

  Purpose     : Real vector + vector addition for float data types.
  Description : This function adds each element of vector `a[]` to each 
                element of input vector `b[]` and stores the result in 
                vector `c[]`.
                
  Domain      : Full Range.

  Accuracy    : 0 bits in error.

  Data Memory : 0 words.
  Prog Memory : 15 words.
  Cycles      : ~ (n <= 0): 17 cycles.
                ~ (n > 0) : 15 + (5 * n) cycles.
                ~ Where `n` is the size of the input data array.

  Notes       : Output can be written to either input vector.
  _____________________________________________________________________
*/

#pragma file_attr("libGroup =vector.h")
#pragma file_attr("libGroup =matrix.h")
#pragma file_attr("libFunc  =vecvaddf")
#pragma file_attr("libFunc  =__vecvaddf")
#pragma file_attr("libFunc  =vecvadd")      // from vector.h
#pragma file_attr("libFunc  =matmaddf")     // from matrix.h
#pragma file_attr("libFunc  =matmadd")      // from matrix.h
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <vector.h>

void
_vecvaddf(
	const float a[],    /* (i) - Input vector `a[]` */
	const float b[],    /* (i) - Input vector `b[]` */
	float c[],          /* (o) - Output vector `c[]` */
	int n               /* (i) - Number of elements in vector */
)
{
	int i;


    /* Add each element of vector `a[]` is added with each element
		of vector `b[]` and stored in vector `c[]`. */
    for (i = 0; i < n; i++)
	    c[i] = a[i] + b[i];
}

/*end of file*/

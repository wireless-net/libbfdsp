// Copyright (C) 2000 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.


/*______________________________________________________________________

  Func name   : vecsaddf

  ----------------------------------------------------------------------------

  Purpose     : Real vector + scalar addition for float data types.
  Description : This function adds input scalar `b` to each element of input 
                vector `a[]` and stores the result in vector `c[]`.
                
  Domain      : Full Range.

  Accuracy    : 0 bits in error.

  Data Memory : 0 words.
  Prog Memory : 13 words.
  Cycles      : ~ (n <= 0): 17 cycles.
                ~ (n > 0): 14 + (4 * n) cycles.
                ~ Where `n` is the size of the input data array.

  Notes       : Output can be written to input vector.
  _____________________________________________________________________
*/

#pragma file_attr("libGroup =vector.h")
#pragma file_attr("libGroup =matrix.h")
#pragma file_attr("libFunc  =vecsaddf")
#pragma file_attr("libFunc  =__vecsaddf")   // from vector.h
#pragma file_attr("libFunc  =vecsadd")      // from vector.h
#pragma file_attr("libFunc  =matsaddf")     // from matrix.h
#pragma file_attr("libFunc  =matsadd")      // from matrix.h
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <vector.h>

void 
_vecsaddf(
	const float a[],    /*{ (i) - Input vector `a[]` }*/
	float b,            /*{ (i) - Input scalar `b` }*/
	float c[],          /*{ (o) - Output vector `c[]` }*/
	int n               /*{ (i) - Number of elements in vector }*/
)
{
	int i;

    /*{ Add `b` to each element of vector `a[]` and store
        in vector `c[]`. }*/
    for (i = 0; i < n; i++)
	    c[i] = a[i] + b;
}
/*end of file*/



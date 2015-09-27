// Copyright (C) 2000 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/*______________________________________________________________________

  Func name   : cvecsaddf

  ----------------------------------------------------------------------------

  Purpose     : Complex vector + scalar addition for float data types.
  Description : This function adds input scalar `b` to each element of 
                input vector `a[]` and stores the result in vector `c[]`.
                
  Domain      : Full Range.

  Accuracy    : 0 bits in error.

  Data Memory : 0 words.
  Prog Memory : 27 words. 
  Cycles      : ~ (n <= 0): 20 cycles.
                ~ (n > 0) : 23 + (8 * n) cycles.
                ~ Where `n` is the size of the input data array.
  _____________________________________________________________________
*/

#pragma file_attr("libGroup =vector.h")
#pragma file_attr("libFunc  =__cvecsaddf")
#pragma file_attr("libFunc  =cvecsaddf")
#pragma file_attr("libFunc  =cvecsadd")
/* Called by cmatsaddf and cmatsadd */
#pragma file_attr("libGroup =matrix.h")
#pragma file_attr("libFunc  =cmatsaddf")
#pragma file_attr("libFunc  =cmatsadd")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")


#include <vector.h>

void 
_cvecsaddf(
	const complex_float a[],   /*{ (i) - Input vector `a[]` }*/
	complex_float b,           /*{ (i) - Input scalar `b` }*/
	complex_float c[],         /*{ (o) - Output vector `c[]` }*/
	int n                      /*{ (i) - Number of elements in vector }*/
)
{
    int i;

    /*{ Add `b` to each element of vector `a[]` and store
        in vector `c[]`. }*/
    for (i = 0; i < n; i++)
    {
        c->re = a->re + b.re;
        c->im = a->im + b.im;
        a++; c++;
    }
}

/*end of file*/ 

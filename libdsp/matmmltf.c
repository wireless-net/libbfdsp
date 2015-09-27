// Copyright (C) 2000, 2001 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/****************************************************************************
   Func name   : mat_mult.c

   Description : Multiplication of two floating point matrices

****************************************************************************/

#pragma file_attr("libGroup =matrix.h")
#pragma file_attr("libFunc  =__matmmltf")
#pragma file_attr("libFunc  =matmmltf")
#pragma file_attr("libFunc  =matmmlt")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <stdio.h>
#include <vector.h>
#include <matrix.h>

void _matmmltf(
  const float *a,  /* first input matrix */
  int n,           /* rows in a */
  int k,           /* columns in a (= rows in b) */
  const float *b,  /* second input matrix */
  int m,           /* columns in b */
  float *c         /* output matrix (n rows, m columns) */
  )
{
	int   h, i, j;
	float tmp;

	if((n==0)||(k==0)||(m==0))
        {
                return;
        }
        if((n==1)&&(k==1)&&(m==1))
        {
                c[0]=(*a) * (*b);
                return;
        }

	for(h=0;h<n;++h)
	{
		for(i=0;i<m;++i)
		{
			tmp = 0.0;
			for(j=0;j<k;++j)
				tmp += a[h*k+j] * b[j*m+i];
			c[h*m+i] = tmp; 			
		}
	}
}

/*end of file*/

/************************************************************************
 *
 * matmmltd.c
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
 * Description :   Matrix Matrix Multiplication
 *                   c[i][j] = sum( a[i][h] * b[h][j] ) 
 *                               where h = 0, 1,2, .., k-1,
 *                                     i = 0, 1,2, .., n-1, 
 *                                     j = 0, 1,2, .., m-1
 */

#pragma file_attr("libGroup =matrix.h")
#pragma file_attr("libFunc  =__matmmltd")
#pragma file_attr("libFunc  =matmmltd")
#pragma file_attr("libFunc  =matmmlt")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <matrix.h>

void 
matmmltd
(
  const long double *a,   /* (i)  - {Pointer to input matrix a[][]}    */
  int   n,                /* (i)  - {Number of rows in matrix a[][]}   */
  int   k,                /* (i)  - {Number of cloumns in matrix a[][]}*/
  const long double *b,   /* (i)  - {Pointer to input matrix b[][]}    */ 
  int   m,                /* (i)  - {Number of columns in matrix b[][]}*/
  long double *c          /* (o)  - {Pointer to output matrix c[][]}   */
)
{
    int  i, j , h;
    long double sum;
    

    /* Error Handling */
    if ((n <= 0) || (m <= 0) || (k <= 0))
    {
        return;
    }
 

    /* Matrix Matrix Multiply */
    /* Every row in a         */
    for (i = 0; i < n; i++)
    {
        /* Every column in b  */
        for (j = 0; j < m; j++)
        {
            /* Initialize accumulator */
            sum = 0.0L;

            /* Multiply each row of matrix `a` 
             * with each column of matrix `b` and 
             * accumulate the result 
             */
            for (h = 0; h < k; h++)
            {
                sum = sum + (*(a + i * k + h)) * (*(b + h * m + j));
            }

            *c++ = sum;
        }
    }
}


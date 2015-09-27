/************************************************************************
 *
 * cmatmmltd.c
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
 * Description :   Complex Matrix Matrix Multiplication
 *
 *                   real(c[i][j]) = sum(real(a[i][h]) * real(b[h][j]) -
 *                                       imag(a[i][h]) * imag(b[h][j]))
 *
 *                   imag(c[i][j]) = sum(real(a[i][h]) * imag(b[h][j]) +
 *                                       imag(a[i][h]) * real(b[h][j]))
 *
 *                       where      h = 0, 1, 2, .., k-1,
 *                                  i = 0, 1, 2, .., n-1,
 *                                  j = 0, 1, 2, .., m-1
 */

#pragma file_attr("libGroup =matrix.h")
#pragma file_attr("libFunc  =__cmatmmltd")
#pragma file_attr("libFunc  =cmatmmltd")
#pragma file_attr("libFunc  =cmatmmlt")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <matrix.h>

void 
cmatmmltd
( 
  const complex_long_double *a,  /* (i) - {Pointer to input matrix a[][]}    */
  int   n,                       /* (i) - {Number of rows in matrix a[][]}   */
  int   k,                       /* (i) - {Number of columns in matrix a[][]}*/
  const complex_long_double *b,  /* (i) - {Pointer to input matrix b[][]}    */
  int   m,                       /* (i) - {Number of columns in matrix b[][]}*/
  complex_long_double *c         /* (i) - {Pointer to output matrix c[][]}   */
)
{
    int  i, j, h;
    long double  reala, realb, imaga, imagb;
    long double  sumr, sumi;


    /* Error Handling */
    if ((n == 0) || (k == 0) || (m == 0))
    {
        return ;
    } 


    /* Complex Matrix Matrix Multiplication */
    /* Every row in a                       */
    for (i = 0; i < n; i++)
    {
        /* Every column in b */
        for (j = 0; j < m; j++)
        {
            /* Initialize accumulator */
            sumr = 0.0L;
            sumi = 0.0L;

            /* Multiply each row of matrix `a` 
             * with each column of matrix `b` and
             * accumulate the result 
             */  
            for (h = 0; h < k; h++)
            {
                reala = a[i * k + h].re;
                imaga = a[i * k + h].im;
                realb = b[h * m + j].re;
                imagb = b[h * m + j].im;

                sumr = sumr + reala * realb - imaga * imagb;
                sumi = sumi + reala * imagb + realb * imaga;
            }
            c[i * m + j].re = sumr;
            c[i * m + j].im = sumi;
        }
    }
}


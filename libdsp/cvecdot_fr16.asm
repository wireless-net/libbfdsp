/*****************************************************************************
 *
 * cvecdot_fr16.asm
 *
 * Copyright (C) 2000-2006 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 *****************************************************************************/

#if defined(__DOCUMENTATION__)

    Function: cvecdot_fr16 - complex vector dot product

    Synopsis:

        #include <complex_fns.h>
        complex_fract16 cvecdot_fr16 (const complex_fract16 vector_a[],
                                      const complex_fract16 vector_b[],
                                      int length);

    Description:

        The cvecdot_fr16 function computes the complex dot product of the
        complex vectors vector_a[] and vector_b[], the number of elements
        in each vector is given by the argument length. The scalar result
        is returned by the function.

    Error Conditions:

        The function will return zero if the argument length is not
        greater than zero.

    Algorithm:

        result.re = SUM( (vector_a[i].re * vector_b[i].re) -
                         (vector_a[i].im * vector_b[i].im) )

        result.im = SUM( (vector_a[i].re * vector_b[i].im) +
                         (vector_a[i].im * vector_b[i].re) )

                    where i = [0, .., length-1]

    Implementation Notes:

        R0 - address of vector_a
        R1 - address of vector_b
        R2 - length

        For optimum performance the two input vectors have to be
        declared in two different data memory banks to avoid data
        bank collision.

    Example:

        #include <vector.h>
        #define N 100

        complex_fract16 x[N];
        complex_fract16 y[N];
        complex_fract16 answer;

        answer = cvecdot_fr16 (x,y,N);

    Cycle Counts:

        28 + (2 * length) cycles

        (measured for a BF532 using version 4.5.0.21 of the ADSP-BF5xx
        Family Simulator and includes the overheads involved in calling
        the library procedure as well as the costs associated with argument
        passing)

 *****************************************************************************/
#endif

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr FuncName      = __cvecdot_fr16;
.file_attr libName       = libdsp;

.file_attr libGroup      = vector.h;
.file_attr libFunc       = __cvecdot_fr16;
.file_attr libFunc       = cvecdot_fr16;

.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";

#endif

#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_AVOID_DAG1)
#define __WORKAROUND_BF532_ANOMALY38__
#endif

.global __cvecdot_fr16;
.type   __cvecdot_fr16,STT_FUNC;

.text;
.align 2;

__cvecdot_fr16:

   /* Initialize */

      I0 = R0;                       // address of the 1st input vector
      I1 = R1;                       // address of the 2nd input vector
      P0 = R2;                       // set loop counter

   /* Check the length */

      CC = R2 <= 0;
      R0 = 0;                        // set return if about to jump
      IF CC JUMP .return;

#if defined(__WORKAROUND_SPECULATIVE_LOADS)
      NOP;
      NOP;
      NOP;
#endif

#if !defined(__WORKAROUND_BF532_ANOMALY38__)

   /* Perform:
   **
   **   A0 = A1 = 0;
   **
   **   for (i = 0; i < length; i++) {
   **      w = (vector_a[i].re * vector_b[i].re);
   **      x = (vector_a[i].im * vector_b[i].im);
   **
   **      y = (vector_a[i].re * vector_b[i].im);
   **      z = (vector_a[i].im * vector_b[i].re);
   **
   **      A0+= (w - x);
   **      A1+= (y + z);
   **   }
   */

      A1 = A0 = 0
      || R1 = [I0++]                 // load real and imag parts of vector_a[0]
      || R3 = [I1++];                // load real and imag parts of vector_b[0]

      // Iterate for each element in vector_a and vector_b
      LSETUP (.start,.finish) LC0 = P0;

.start:
         // y = (vector_a[i].re * vector_b[i].im)
         // x = (vector_a[i].im * vector_b[i].im)
         A1 += R1.H * R3.L, A0 += R1.L * R3.L;

.finish:
         // y + (vector_a[i].im * vector_b[i].re)
         // x - (vector_a[i].re * vector_b[i].re)
         R0.H = (A1 += R1.L * R3.H), R0.L = (A0 -= R1.H * R3.H)
         || R1 = [I0++] || R3 = [I1++];

#else  /* __WORKAROUND_BF532_ANOMALY38__ */
      A1 = A0 = 0 || R1 = [I0++];

      // Iterate for each element in vector_a and vector_b
      LSETUP (.start,.finish) LC0 = P0;
.start:
         R3  = [I1++];
         A1 += R1.H * R3.L, A0 += R1.L * R3.L;
.finish:
         R0.H = (A1+=R1.L * R3.H),
         R0.L = (A0-=R1.H * R3.H) || R1 = [I0++];
#endif /* __WORKAROUND_BF532_ANOMALY38__ */

.return:
      RTS;

.size __cvecdot_fr16, .-__cvecdot_fr16

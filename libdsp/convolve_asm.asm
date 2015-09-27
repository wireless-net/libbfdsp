/*************************************************************************
 *
 * convolve_asm.asm
 *
 * Copyright (C) 2000-2007 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ************************************************************************/

#if defined(__DOCUMENTATION__)

   Function: convolve_fr16 - One dimensional fractional 1.15 convolution

   Synopsis:

      #include <filter.h>
      void convolve_fr16 (const fract16  input_x[],
                          int            length_x,
                          const fract16  input_y[],
                          int            length_y,
                          fract16        output[]  );

   Description:

      This function convolves two sequences pointed to by input_x and input_y. 

      If input_x points to the sequence whose length is length_x and input_y 
      points to the sequence whose length is length_y, the resulting sequence 
      pointed to by output has length length_x + length_y - 1. 

      For best performance, the input arrays input_x and input_y should be
      located in different memory banks.


   Error Conditions:

      If either of the length arguments is negative or zero, the function 
      will terminate without modifying the output array.


   Algorithm:

      output[k] = sum( input_x[j] * input_y[k-j] )  

      where k = [0, 1, 2, ... , (length_x + length_y - 2)]
            j = [max( 0, k + 1 - length_y ), .., min( k, length_x - 1 )]


   Implementation:

      For length_x = 4 and length_y = 3, the convolution of
      a = input_x[length_x] and b = input_y[length_y] is defined as:

            output[0] = a[0] * b[0]
            output[1] = a[0] * b[1] + a[1] * b[0]
            output[2] = a[0] * b[2] + a[1] * b[1] + a[2] * b[0]
            output[3] =               a[1] * b[2] + a[2] * b[1] + a[3] * b[0]
            output[4] =                             a[2] * b[2] + a[3] * b[1]
            output[5] =                                           a[3] * b[2]

      For best accuracy, the 40-bit accumulator is used to compute the
      output values. For efficient computation, the algorithm is broken
      into two parts.

      The first part (=edge handling) deals with the first (length_y - 1) 
      and last (length_y - 1) output values:

            output[0] = a[0] * b[0]
            output[1] = a[0] * b[1] + a[1] * b[0]
            output[4] =                             a[2] * b[2] + a[3] * b[1]
            output[5] =                                           a[3] * b[2]

      Which can be re-written as:

            (1) A1 = a[2] * b[2] + a[3] * b[1] || A0 = a[0] * b[0]
            (2) A1 =               a[3] * b[2] || A0 = a[0] * b[1] + a[1] * b[0]

      Note that all reads in (1) and (2) of vector a and b are consecutive 
      (assuming that circular buffers are being used, which is the case).

      If (length_y == 1), an alternative code sequence will be executed.

           
      The second part deals with the remaining 
      (size output vector - number of outputs computed in the first part)
      = (length_x + length_y - 1) - 2 * (length_y - 1)  
      = (length_x - (length_y - 1))  output values:

            output[2] = a[0] * b[2] + a[1] * b[1] + a[2] * b[0]
            output[3] =               a[1] * b[2] + a[2] * b[1] + a[3] * b[0]

           
      The algorithm assumes that length_x >= length_y. If this is not 
      the case, the input arguments will be swapped, effectively computing:

            convolve_fr16( input_y, length_y, input_x, length_x, output)           


   Stack Size:

      2 * 32-bit words of stack are required to preserve the registers R7..6.
           

   Cycle count:

            79 + compute edges + compute main

            where:  

            compute edges = (length_y - 1) * (7 + length_y)
            compute main  = (length_x - (length_y - 1)) * (3 + length_y)

            and length_x >= length_y                
           

            length_x    length_y    Cycles
              32          8           457
              33          8           468  
              32          9           493
              33          9           505 

      (Measured for an ADSP-BF537 using version 1.0 of the ADSP-BF537 Family
      EZ-Kit and includes the overheads involved in calling the library
      procedure as well as the costs associated with argument passing).
 
*****************************************************************************
#endif


#if !defined(__NO_LIBRARY_ATTRIBUTES__)
.FILE_ATTR  libGroup      = filter.h;
.FILE_ATTR  libFunc       = __convolve_fr16;
.FILE_ATTR  libFunc       = convolve_fr16;
.FILE_ATTR  libName       = libdsp;
.FILE_ATTR  prefersMem    = internal;
.FILE_ATTR  prefersMemNum = "30";
.FILE_ATTR  FuncName      = __convolve_fr16;
#endif


#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_AVOID_DAG1)
#define __WORKAROUND_BF532_ANOMALY38__
#endif


.text;
.ALIGN 2;
.GLOBAL   __convolve_fr16;

__convolve_fr16:

      [--SP] = (R7:6);                 // Save preserved registers

      R3 = [SP+20];                    // Load length vector y
      CC = R3 <= 0;                  
      IF CC JUMP .done;                // Exit if length y <= 0

      CC = R1 <= 0;
      IF CC JUMP .done;                // Exit if length x <= 0


      /* Swap address and length arguments if length x < length y 
         In the following, vector a will refer to the larger of the 
         two vectors, while vector b will denote the shorter vector.
      */
      R6 = R0;
      R7 = R1;
      CC = R1 < R3;
      IF CC R0 = R2;
      IF CC R1 = R3; 
      IF CC R2 = R6;
      IF CC R3 = R7;

      R7 = R1 << 1;                    // Configure vector a as circular buffer
      B0 = R0;
      I0 = R0;
      L0 = R7;

      R6 = R3 << 1;                    // Configure vector b as circular buffer
      B1 = R2;
      I1 = R2;
      L1 = R6;

      R3 += -1;                        // (length b - 1)
      R6 = R1 - R3;                    // (length a - (length b - 1))

      R2 = -3;
      R2 = (R2 + R6) << 1;             // ((length a - (length b - 1)) - 3)
      M1 = R2;                         // Offset = (length a - length b - 2) 

      R0 = [SP+24];                    // Load &output
      R7 = R0 + R7;                    // 
      I3 = R7;                         // &output[length a]
                                       // == first element edge_last
      I2 = R0;                         // &output[0]
                                       // == first element edge_first

      P0 = R3;                         // Loop counter - edges
      P1 = 1;                          // Loop counter - edges
      P2 = R6;                         // Loop counter - main

      CC = R3 == 0;                    // Skip edge handling for length b = 1
      IF CC JUMP .length_b_one;


      R6 = R6 << 1;                    // (length a - (length b - 1)) * 2
      M0 = R6;                         // Offset required for vector a
      

      /* Compute edges first */

#if defined(__WORKAROUND_BF532_ANOMALY38__)

      /* ========= Start of BF532 Anomaly#38 Safe Code ====================*/

      // Loop for (length smaller - 1)
      LSETUP (.edge_outer_start, .edge_outer_end) LC0 = P0;
.edge_outer_start:

         A1 = A0 = 0 || R0.L = W[I0--];
         R1.L = W[I1++];

         // Loop for 1 .. (length smaller - 1)
         LSETUP (.edge_first_start, .edge_first_end) LC1 = P1;
.edge_first_start:
            R2.L = (A0 += R0.L * R1.L) || R0.L = W[I0--];
.edge_first_end:
            R1.L = W[I1++];

         P1 += 1;                      // Increment loop counter

         // Loop for (length smaller - 1) .. 1
         LSETUP (.edge_last_start, .edge_last_end) LC1 = P0;
.edge_last_start:
            R3.H = (A1 += R0.L * R1.L) || R0.L = W[I0--];
.edge_last_end:
            R1.L = W[I1++];

         P0 += -1;                     // Decrement loop counter
         I1 -= 2 || W[I2++] = R2.L;    // Position &b ,save result

.edge_outer_end:
         I0 -= M1 || W[I3++] = R3.H;   // Position &a, save result


      /* Compute main part */
      P1 += -1;                        // Adjust loop counter
      I0 = B0;                         // Position &a
      I1 -= 2;                         // Position &b
      R1.L = W[I1--]; 

      // Loop for (length larger - (length smaller - 1))
      LSETUP (.main_outer_start, .main_outer_end) LC0 = P2;
.main_outer_start:

         A0 = 0 || R0.L = W[I0++];

         // Loop for (length smaller - 1)
         LSETUP (.main_inner_start, .main_inner_end) LC1 = P1;
.main_inner_start:
            A0 += R0.L * R1.L || R0.L = W[I0++];
.main_inner_end:
            R1.L = W[I1--];

         R2.L = (A0 += R0.L * R1.L) || R1.L = W[I1--];

.main_outer_end:
         I0 += M0 || W[I2++] = R2.L;    // Position &a, save result


#else /* ========= End of BF532 Anomaly#38 Safe Code ======================*/


      // Loop for (length smaller - 1)
      LSETUP (.edge_outer_start, .edge_outer_end) LC0 = P0;
.edge_outer_start:

         A1 = A0 = 0 || R0.L = W[I0--] || R1.L = W[I1++];

         // Loop for 1 .. (length smaller - 1)
         LSETUP (.edge_first, .edge_first) LC1 = P1;
.edge_first:
            R2.L = (A0 += R0.L * R1.L) || R0.L = W[I0--] || R1.L = W[I1++];

         P1 += 1;                      // Increment loop counter 
 
         // Loop for (length smaller - 1) .. 1 
         LSETUP (.edge_last, .edge_last) LC1 = P0;
.edge_last:
            R3.H = (A1 += R0.L * R1.L) || R0.L = W[I0--] || R1.L = W[I1++];

         P0 += -1;                     // Decrement loop counter
         I1 -= 2 || W[I2++] = R2.L;    // Position &b ,save result                       
.edge_outer_end:
         I0 -= M1 || W[I3++] = R3.H;   // Position &a, save result



      /* Compute main part */
      P1 += -1;                        // Adjust loop counter
      I0 = B0;                         // Position &a
      I1 -= 2;                         // Position &b

      // Loop for (length larger - (length smaller - 1))
      LSETUP (.main_outer_start, .main_outer_end) LC0 = P2;
.main_outer_start:
       
         A0 = 0 || R0.L = W[I0++] || R1.L = W[I1--];

         // Loop for (length smaller - 1) 
         LSETUP (.main_inner, .main_inner) LC1 = P1; 
.main_inner:
            A0 += R0.L * R1.L || R0.L = W[I0++] || R1.L = W[I1--];

         R2.L = (A0 += R0.L * R1.L);

.main_outer_end:
         I0 += M0 || W[I2++] = R2.L;    // Position &a, save result


#endif   /* ====== End of Alternative to BF532 Anomaly#38 Safe Code ====== */


.done:
      (R7:6) = [SP++];                  // Restore preserved registers

      L0 = 0;                           // Reset circular buffers
      L1 = 0; 

      RTS;   


      /* Alternative code to handle (length smaller) == 1 */
.length_b_one:

#if defined(__WORKAROUND_BF532_ANOMALY38__)
      R0.L = W[I0++];
      R1.L = W[I1];                     // Load only element in vector b
#else
      R0.L = W[I0++] || R1.L = W[I1];   // Load only element in vector b
#endif

      R2.L = (A0 = R0.L * R1.L) || R0.L = W[I0++];

      // Loop for (length larger - (length smaller - 1))
      LSETUP (.one_iter, .one_iter) LC0 = P2;
.one_iter:
         R2.L = (A0 = R0.L * R1.L) || R0.L = W[I0++] || W[I2++] = R2.L;

      JUMP .done;


.size __convolve_fr16, .-__convolve_fr16

/*****************************************************************
  Copyright (C) 2000-2005 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
 *****************************************************************  

    File name   : cvecvmult_fr16.asm  
    Module name : Complex vector - vector multiplication
    Label name  :  __cvecvmlt_fr16
    Description : This program multiplies two 16 bit vectors element by element 

    Registers used :   

        R0 - Starting address of the first 16 bits input vector
        R1 - Starting address of the second 16 bits input vector
        R2 - Starting address of the 16 bits output vector

        Other registers used:
        R0 to R3, I0, I1 & I2, A0 & A1

        Note: The two input vectors have to be declared in two 
              different data memory banks to avoid data bank collision.

        Cycle count: 80 cycles (Vector length - 25)

        Code size  : 52 bytes

 *******************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = vector.h;
.file_attr libFunc       = __cvecvmlt_fr16;
.file_attr libFunc       = cvecvmlt_fr16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __cvecvmlt_fr16;

#endif


#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_AVOID_DAG1)
#  define __WORKAROUND_BF532_ANOMALY38__
#endif

#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_SPECULATIVE_LOADS)
#define __WORKAROUND_BF532_ANOMALY_050000245
#endif

.text;
.align 2;
.global __cvecvmlt_fr16;
__cvecvmlt_fr16:

        I0 = R0;              // Store the address of the first input vector 
        I1 = R1;              // Store the address of the second input vector 
        I2 = R2;              // Store the address of the output vector 
        R2 = [SP+12];         // Fetch the size of the vector from the stack 
        CC = R2 <= 0;         // Check if the vector length is negative or zero 
        IF CC JUMP FINISH;    // Terminate if the vector length is zero 

#if defined(__WORKAROUND_BF532_ANOMALY_050000245)
        NOP;
        NOP;
#endif

        P0 = R2;              // Set loop counter

        R0 = [I0++];          // Fetch 1st element from first vector
        R1 = [I1++];          // Fetch 1st element from second vector

        // I1 = input1[0].im * input2[0].re, 
        // R1 = input1[0].re * input2[0].re
        A1 = R0.H * R1.L, A0 = R0.L * R1.L;

#if defined(__WORKAROUND_BF532_ANOMALY38__)

       /* Start of BF532 Anomaly#38 Safe Code */
        // Im = I1 + input1[i].re * input2[0].im,
        // Re = R1 - input1[i].im * input2[0].im
        R2.H = (A1 += R0.L * R1.H), R2.L = (A0 -= R0.H * R1.H) || R0 = [I0++];
        R1 = [I1++];

                              // Initialize the loop and loop counter
        LSETUP(vv_start, vv_end) LC0 = P0;
vv_start:
           // I1 = input1[i].im * input2[i].re,
           // R1 = input1[i].re * input2[i].re
           A1 = R0.H * R1.L, A0 = R0.L * R1.L || [I2++] = R2;

           // Im = I1 + input1[i].re * input2[i].im,
           // Re = R1 - input1[i].im * input2[0].im
           R2.H = (A1 += R0.L * R1.H), R2.L = (A0 -= R0.H * R1.H) || R0 = [I0++];

vv_end:
           R1 = [I1++];

#else  /* End of BF532 Anomaly#38 Safe Code */

        // Im = I1 + input1[i].re * input2[0].im, 
        // Re = R1 - input1[i].im * input2[0].im
        R2.H = (A1 += R0.L * R1.H), R2.L = (A0 -= R0.H * R1.H) || 
                                          R0 = [I0++] || R1 = [I1++];

                              // Initialize the loop and loop counter
        LSETUP(vv_start, vv_end) LC0 = P0;
vv_start:
           // I1 = input1[i].im * input2[i].re, 
           // R1 = input1[i].re * input2[i].re
           A1 = R0.H * R1.L, A0 = R0.L * R1.L || [I2++] = R2;

vv_end:
           // Im = I1 + input1[i].re * input2[i].im, 
           // Re = R1 - input1[i].im * input2[0].im
           R2.H = (A1 += R0.L * R1.H), R2.L = (A0 -= R0.H * R1.H) || 
                                             R0 = [I0++] || R1 = [I1++];

#endif /* End of Alternative to BF532 Anomaly#38 Safe Code */

FINISH:
        RTS;

.size __cvecvmlt_fr16, .-__cvecvmlt_fr16

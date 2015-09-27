/*****************************************************************
   Copyright (C) 2000-2005 Analog Devices, Inc.
   This file is subject to the terms and conditions of the GNU Lesser
   General Public License. See the file COPYING.LIB for more details.

   Non-LGPL License is also available as part of VisualDSP++
   from Analog Devices, Inc.
 *****************************************************************              

   File name   :   cvecsmlt_fr16.asm
   Module name :   Complex vector - scalar multiplication
   Label name  :   __cvecsmlt_fr16
   Description :   This program multiplies a 16 bit scalar and a 16 bit vector

   void cvecsmlt_fr16 (const complex_fract16 _vector[],
                       complex_fract16 _scalar,
                       complex_fract16 _product[], int _length);
     
   Registers used   :   

   R0  - Address of the input vector            
   RL1 - real part of input scalar            (16 bits)
   RH1 - imaginary part of input scalar       (16 bits)
   R2  - No. of elements in the vector        (32 bits)
   

   Other registers used:
   R0 to R3, I0 & I1, A0 & A1   
   
   Cycle count    :   80 cycles   (Vector length - 25)
   
   Code size      :   48 bytes
 *******************************************************************/   

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = vector.h;
.file_attr libFunc       = __cvecsmlt_fr16;
.file_attr libFunc       = cvecsmlt_fr16;
/* called by cmatsmlt_fr16 */
.file_attr libGroup      = matrix.h;
.file_attr libFunc       = cmatsmlt_fr16;

.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __cvecsmlt_fr16;

#endif

.text;
.align 2;
.global __cvecsmlt_fr16;
__cvecsmlt_fr16:
   R3 = [SP+12];       // Fetch the size of the vector from the stack 
   CC = R3 <= 0;       // Chech if the the vector length is negative or zero 
   IF CC JUMP FINISH;  // Terminate if the vector length is negative or zero

   I0 = R0;            // Store the address of the input vector 
   I1 = R2;            // Store the address of the output vector
   P0 = R3;            // Set loop counter

   R0 = [I0++];        // Load the real and imaginary parts of the input vector
                       // Do the multiplication of the first element outside 
                       // the loop

   // I1 = input[0].im * scalar.re, R1 = input[0].re * scalar.re
   A1 = R0.H * R1.L, A0 = R0.L * R1.L;

   // Im = I1 + input[i].re * scalar.im, Re = R1 - input[i].im * scalar.im
   R2.H = (A1 += R0.L * R1.H), R2.L = (A0 -= R0.H * R1.H) || R0 = [I0++];

                       // Initialize the loop and loop counter 
   LSETUP(vs_start, vs_end) LC0 = P0;               
vs_start:  
       // I1 = input[i].im * scalar.re, R1 = input[i].re * scalar.re 
       A1 = R0.H * R1.L, A0 = R0.L * R1.L || [I1++] = R2;   

vs_end:    
       // Im = I1 + input[i].re * scalar.im, Re = R1 - input[i].im * scalar.im 
       R2.H = (A1 += R0.L * R1.H), R2.L = (A0 -= R0.H * R1.H) || R0 = [I0++];

FINISH:      
   RTS;

.size __cvecsmlt_fr16, .-__cvecsmlt_fr16


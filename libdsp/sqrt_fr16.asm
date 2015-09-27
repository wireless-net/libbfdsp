/*****************************************************************************
 *
 * sqrt_fr16.asm
 *
 * Copyright (C) 2000-2007 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 *****************************************************************************/

#if defined(__DOCUMENTATION__)

    Function: sqrt_fr16 - compute fractional square root of x


    Synopsis: 
 
        #include <math.h>
        fract16 sqrt_fr16( fract16 x );


    Description:

        The square root function returns the positive 
        square root of its argument.


    Error conditions:

        The square root function returns zero if the input
        argument is negative.


    Algorithm:

        The function uses a polynomial approximation.


        For x = [0.25, 0.5), we use the following polynomial P1:
            y = sqrt (x) = P1 (x0), x0 = 0.5 - x;

            where P1 = 0x2d41 + (0xd2ce * x) + (0xe7e8 * x^2)
                              + (0xf848 * x^3) + (0xac7c * x^4)

            using the coefficients stored in .sqrtcoef0.


        For x = [0.5, 1.0), we use a different polynomial P2:
            y = sqrt (x) = P2 (x0), x0 = x - 0.5;

            where P2 = 0x2d42 + (0x2d31 * x) + (0xea5d * x^2)
                              + (0x1021 * x^3) + (0xf89e * x^4)

            using the coefficients stored in .sqrtcoef1.

        For 0.0 < x < 0.25, we shift x even bits 2N to in the
        range [0.25, 1.0), and shift back N after the result.


    Ccle count:

        44 cycles (for x > 0x0) 
  
        ( Measured for an ADSP-BF532 using version 4.5.0.22 of the 
          ADSP-BF532 Family Simulator and includes the overheads 
          involved in calling the library procedure as well as 
          the costs associated with argument passing).

*****************************************************************************
#endif


#if !defined(__NO_LIBRARY_ATTRIBUTES__)
.FILE_ATTR libGroup      = math_bf.h;
.FILE_ATTR libGroup      = math.h;
.FILE_ATTR libFunc       = __sqrt_fr16;
.FILE_ATTR libFunc       = sqrt_fr16;

/* Called from cabfr16.asm */
.FILE_ATTR libGroup      = complex_fns.h;
.FILE_ATTR libFunc       = cabs_fr16;
.FILE_ATTR libFunc       = __cabs_fr16;

/* Called from rms_fr16.asm */
.FILE_ATTR libGroup      = stats.h;
.FILE_ATTR libFunc       = rms_fr16;
.FILE_ATTR libFunc       = __rms_fr16;

.FILE_ATTR libName       = libdsp;
.FILE_ATTR prefersMem    = internal;
.FILE_ATTR prefersMemNum = "30";
.FILE_ATTR FuncName      = __sqrt_fr16;
#endif


#define  N_SEEDS   5

.section .rodata;
.ALIGN 2;
	.type	.sqrtcoef0, @object
	.size	.sqrtcoef0, (N_SEEDS) * 2
.sqrtcoef0:
	.short 0x2D41,0xD2CE,0xE7E8,0xF848,0xAC7C;
	.type	.sqrtcoef1, @object
	.size	.sqrtcoef1, (N_SEEDS) * 2
.sqrtcoef1:
	.short 0x2D42,0x2D31,0xEA5D,0x1021,0xF89E;


.GLOBAL  __sqrt_fr16;
.TYPE    __sqrt_fr16, STT_FUNC;

.text;
.ALIGN 2;

__sqrt_fr16:
       CC = R0 <= 0;                   // Check for <= 0 
       IF CC JUMP .done;               // Return 0 for x <= 0 

       LOAD(P1, .sqrtcoef0);           // Pointer to coefficients 0

       LOAD(P2, .sqrtcoef1);           // Pointer to coefficients 1

       R3.L = SIGNBITS R0.L;           // Signbits(x) - 1
       R2.L = R3.L >> 1;
       R3.L = R2.L << 1;
       R0 = ASHIFT R0 BY R3.L;         // Normalize input  

       R3 = 0x4000;
       R0 = R0 - R3;                   // R0 = R0 - 0x4000
       CC = R0 < 0;                    // If R0 < 0
       IF CC P2 = P1;                  // If true, use coefficent 0
       R0 = ABS R0;

       P0 = R7;                        // Preserve R7

       R1 = -15;
       R2.L = R1.L - R2.L (NS);        // Correction required at the end
 

       R3 = PACK(R0.H,R0.L)            // Save R0 in R3 
       || R7 = W[P2++] (Z);            // Fetch first coefficent

       R7 <<= 16;                      // Convert fract 1.15 to fract 1.31

       A1 = R7                         // Initialize A1 with first coefficent 
       || R7 = W[P2++] (Z);            // and get next coefficent 


       R0.H = R0.L * R3.L;             // p1 = xs^2 

       A1 += R3.L * R7.L               // s1 = xs^0 * coeff0 + xs^1 * coeff1
       || R7 = W[P2++] (Z); 

       R3.L = R0.L * R0.H;             // p2 = xs^3

       R1 = (A1 += R0.H * R7.L)        // s1 = s1 + xs^2 * coeff2
       || R7 = W[P2++] (Z);

       R0.H = R0.L * R3.L;             // p3 = xs^4

       A1 += R3.L * R7.L               // s1 = s1 + xs^3 * coeff3
       || R7 = W[P2++] (Z);

       R1 = (A1 += R0.H * R7.L);       // s1 = s1 + xs^4 * coeff4


       R0 = ASHIFT R1 BY R2.L;         // Save s1 as fract 1.15  

       R7 = P0;                        // Restore R7
       RTS;

.done: R0 = 0;                         // Set return value for x <= 0
       RTS;

.size __sqrt_fr16, .-__sqrt_fr16

/******************************************************************************
  Copyright (C) 2000-2005 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
 ******************************************************************************
  File Name      : matmmlt_fr16.asm
  Include File   : matrix.h
  Label Name     : __matmmlt_fr16

  Description    : This function computes the product of two fractional
                   matrices A[n][k] and B[k][m] and stores the result
                   in matrix C[n][m].

                   The two input matrices have to be declared in
                   two different data memory banks to avoid data
                   bank collision.

  Operand        : R0 - Address input matrix A
                   R1 - Number of rows in matrix A
                   R2 - Number of columns in matrix A
                   Stack1 - Address input matrix B
                   Stack2 - Number of columns in matrix B
                   Stack3 - Address output matrix C

  Registers Used : R0-3, P0-2, P4-5, I0-2, M0-1

  Cycle Count    : 56 + (Ar * (10 + (Bc * (4 + Ac)))))
                        where Ar are the rows in A
                              Ac are the columns in A (= rows in B)
                              Bc are the columns in B

                  (measured for a ADSP-BF532 using version 3.5.0.21 of
                   the ADSP-BF53x Family Simulator and includes the
                   overheads involved in calling the library procedure
                   as well as the costs associated with argument passing)

                   For example: 347 cycles for A[3][25] * B[25][3]

  Code Size      : 110 bytes

 *******************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = matrix.h;
.file_attr libFunc       = __matmmlt_fr16;
.file_attr libFunc       = matmmlt_fr16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __matmmlt_fr16;

#endif

#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_AVOID_DAG1)
#define __WORKAROUND_BF532_ANOMALY38__
#endif

.text;
.global   __matmmlt_fr16;

.align 2;
__matmmlt_fr16:


#if defined(__WORKAROUND_WB_DCACHE)
                   SSYNC;
#endif
                   [--SP] = (P5:4);
                   I0 = R0;                 // Address input matrix A
                   R3 = [SP+20];            // Address input matrix B
                   I1 = R3;
                   R3 = [SP+28];            // Address output matrix C
                   I2 = R3;
                   R3 = [SP+24];            // Columns matrix B

                   CC = R1 <= 0;
                   IF CC JUMP MLT_STOP;     // If n <= 0, terminate

                   CC = R2 <= 0;
                   IF CC JUMP MLT_STOP;     // If k <= 0, terminate

                   CC = R3 <= 0;
                   IF CC JUMP MLT_STOP;     // If m <= 0, terminate

                   P0 = R2;
                   P5 = R3;
                   R0 = R2 << 1;            // Compute the space required for
                                            // one row of input matrix A
                   M1 = R0;
                   R0 += 2;
                   M0 = R0;
                   R2 += 1;
                   R0 = R3 << 1;            // Compute the space required for 
                                            // one row of input matrix B
                   P2 = R0;
                   R0 *= R2;
                   R0 = -R0;
                   R0 += 2;
                   P4 = R0;

REPEAT:
                   P1 = I1;                 // Address input matrix B

#if defined(__WORKAROUND_BF532_ANOMALY38__)

               /* Start of BF532 Anomaly#38 Safe Code */

                   // Set loop for Row-Column fetch
                   LSETUP(ST_PROD_OUT, END_PROD_OUT) LC0 = P5;
ST_PROD_OUT:         A0 = 0 || R0.L = W[I0++];
                     R3.L = W[P1++P2];

                     // Set loop for Row-Column multiplication
                     LSETUP (VDOTST,VDOTEND) LC1 = P0;
VDOTST:                A0 += R0.L * R3.L || R0.L = W[I0++];
VDOTEND:               R3.L = W[P1++P2];

                     R0.L = A0 || R3.L = W[P1++P4];
END_PROD_OUT:        W[I2++] = R0.L || I0 -= M0;	
                                            // Save result in output matrix C

#else   /* End of BF532 Anomaly#38 Safe Code */

                   // Set loop for Row-Column fetch
                   LSETUP(ST_PROD_OUT, END_PROD_OUT) LC0 = P5;
ST_PROD_OUT:         A0 = 0 || R0.L = W[I0++] || R3.L = W[P1++P2];

                     // Set loop for Row-Column multiplication
                     LSETUP (VDOTST,VDOTST) LC1 = P0;
VDOTST:                A0 += R0.L * R3.L || R0.L = W[I0++] || R3.L = W[P1++P2];

                     R0.L = A0 || R3.L = W[P1++P4];
END_PROD_OUT:        W[I2++] = R0.L || I0 -= M0;
                                            // Save result in output matrix C

#endif /* End of Alternative to BF532 Anomaly#38 Safe Code */

                   I0 += M1;
                   R1 += -1;
                   CC = R1 <= 0;
                   IF !CC JUMP REPEAT (BP); // Iterate for Number of rows in
                                            // matrix A
MLT_STOP:
                   (P5:4) = [SP++];
                   RTS;

.size __matmmlt_fr16, .-__matmmlt_fr16

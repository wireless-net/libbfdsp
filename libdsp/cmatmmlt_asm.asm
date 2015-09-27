/******************************************************************************
  Copyright (C) 2000-2005 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
 ******************************************************************************
  File Name      : cmatmmlt_asm.asm
  Include File   : matrix.h
  Label Name     : __cmatmmlt_fr16

  Description    : This function computes the product of two complex
                   matrices A[n][k] and B[k][m] and stores the result
                   in matrix C[n][m].

  Operand        : R0 - Address input matrix A
                   R1 - Number of rows in matrix A
                   R2 - Number of columns in matrix A
                   Stack1 - Address input matrix B
                   Stack2 - Number of columns in matrix B
                   Stack3 - Address output matrix C

  Registers Used : R0-3, P0-2, I0-2, M0-2

  Cycle Count    : 50 + (Ar * (10 + (Bc * (4 + (2 * Ac)))))
                        where Ar are the rows in A
                              Ac are the columns in A (= rows in B)
                              Bc are the columns in B

                  (measured for a ADSP-BF532 using version 3.5.0.21 of
                   the ADSP-BF53x Family Simulator and includes the
                   overheads involved in calling the library procedure
                   as well as the costs associated with argument passing)

                   For example: 1410 cycles for A[8][8] * B[8][8] 

  Code Size      : 114 Bytes.

******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = matrix.h;
.file_attr libFunc       = __cmatmmlt_fr16;
.file_attr libFunc       = cmatmmlt_fr16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __cmatmmlt_fr16;

#endif

#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_AVOID_DAG1)
#define __WORKAROUND_BF532_ANOMALY38__
#endif

.text;
.global   __cmatmmlt_fr16;

.align 2;
__cmatmmlt_fr16:

                   I0 = R0;                 // Address input matrix A
                   P1 = [SP+12];            // Address input matrix B
                   R3 = [SP+20];            // Address output matrix C
                   I2 = R3;

                   CC = R1 <= 0;
                   IF CC JUMP MLT_STOP;     // If n <= 0, terminate

                   CC = R2 <= 0;
                   IF CC JUMP MLT_STOP;     // If k <= 0, terminate

                   R3 = [SP+16];            // Columns matrix B
                   CC = R3 <= 0;
                   IF CC JUMP MLT_STOP;     // If m <= 0, terminate

                   P0 = R2;
                   P2 = R3;
                   R0 = R2 << 2;            // Compute the space required for
                                            // one row of input matrix A
                   R0 += 4;
                   M0 = R0;
                   R2 += 1;
                   R0 = R3 << 2;            // Compute the space required for
                                            // one row of input matrix B
                   M2 = R0;
                   R0 *= R2;
                   R0 = -R0;
                   R0 += 4;
                   M1 = R0;

                   R2 = -1;
                   
REPEAT:            I1 = P1;                 // Address input matrix B

#if defined(__WORKAROUND_BF532_ANOMALY38__)

               /* Start of BF532 Anomaly#38 Safe Code */

                   LSETUP( PROD_OUT_ST, END_PROD_OUT ) LC0 = P2;
PROD_OUT_ST:         A1 = A0 = 0 || R0 = [I0++];
                     R3 = [I1++M2];

                     LSETUP (CVDOTST,CVDOTEND) LC1 = P0;
CVDOTST:               A1 += R0.H * R3.L, A0 += R0.L * R3.L;
                       A1 += R0.L * R3.H, A0 -= R0.H * R3.H
                            || R0 = [I0++];
CVDOTEND:              R3 = [I1++M2];

#else          /* End of BF532 Anomaly#38 Safe Code */

                   // Set loop for Row-Column fetch
                   LSETUP( ST_PROD_OUT, END_PROD_OUT ) LC0 = P2;
ST_PROD_OUT:         A1 = A0 = 0 || R0 = [I0++] || R3 = [I1++M2];

                     // Set loop for Row-Column multiplication
                     //     (C1 + jC2) = ( A1[] +jA2[] ).( B1[] + jB2[] )
                     //      C1 = Sum( A1[i]*B1[i] - A2[i]*B2[i] )
                     LSETUP (CVDOTST,CVDOTEND) LC1 = P0;
CVDOTST:               A1 += R0.H * R3.L, A0 += R0.L * R3.L;
CVDOTEND:              A1 += R0.L * R3.H, A0 -= R0.H * R3.H
                            || R0 = [I0++] || R3 = [I1++M2];

#endif        /* End of Alternative to BF532 Anomaly#38 Safe Code */

                     R0.H = A1, R0.L = A0 || I1+=M1;
                      
END_PROD_OUT:        [I2++] = R0 || I0 -= M0;
                                            // Save result in output matrix C

                   I0 += M0;
                   R1 = R1 + R2 (NS) || I0 -= 4;
                                            // Move I0 by M0 - 4 and
                                            // Decrement R1 by 1
                   CC = R1 <= 0;
                   IF !CC JUMP REPEAT (BP); // Iterate for Number of rows in
                                            // matrix A

MLT_STOP:          RTS;

.size __cmatmmlt_fr16, .-__cmatmmlt_fr16

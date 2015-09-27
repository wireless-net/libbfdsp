/******************************************************************************
  Copyright (C) 2000-2005 Analog Devices, Inc.  
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : mean_fr16.asm
  Include File   : stats.h
  Label name     : __mean_fr16
 
  Description    : This function calculates the mean value of an array
                      mean = (1/N) * (x1 + x2 + ... + xn) 

  Operand        : R0 - Address of input array X, 
                   R1 - Number of samples

  Registers Used : R0-2, P0-1

  Cycle count    : 25 + 43 (___div32) + Number of samples
                   n = 20: 88 Cycles  (BF532, Cycle Accurate Simulator)
  Code size      : 34 Bytes  (exluding ___div32)
******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = stats.h;
.file_attr libFunc       = __mean_fr16;
.file_attr libFunc       = mean_fr16;
.file_attr libName       = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __mean_fr16;

#endif

#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_SPECULATIVE_LOADS)
#define __WORKAROUND_BF532_ANOMALY_050000245
#endif

.text;
.global  __mean_fr16;

.extern  ___div32;

.align 2;
__mean_fr16:

                   P0 = R1;                // SET LOOP COUNTER TO N
                   P1 = R0;                // ADDRESS INPUT ARRAY X

                   CC = R1 <= 0;           // EXIT IF NUMBER OF SAMPLES <=0 
                   IF CC JUMP RET_ZERO;

#if defined(__WORKAROUND_BF532_ANOMALY_050000245)
                   NOP;
                   NOP;
                   NOP;
#endif
                   // MEAN = MEAN + X[i] * 1/N
                   R0 = R0 - R0 (NS) || R2 = W[P1++](X);    
                   LSETUP( MEAN_START, MEAN_START ) LC0 = P0;
MEAN_START:           R0 = R0 + R2 (S) || R2 = W[P1++](X); 

                   JUMP.X ___div32;        // COMPUTE SUM/N USING 
                                           // 32-BIT DIVISION
           
                   // Note that ___div32 performs the return to the caller
    
RET_ZERO:          R0 = 0;                 // RETURN ZERO IF N <= 0 
                   RTS;

.size __mean_fr16, .-__mean_fr16

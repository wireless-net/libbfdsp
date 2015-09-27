/******************************************************************************
  Copyright (C) 2000-2005 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : var_fr16.asm
  Include File   : stats.h
  Label Name     : __var_fr16

  Description    : This function calculates the variance of the data
                   contained in the input array a[]:

                   variance =
                          (n*sum(a[i]*a[i]) - sum(a[i])*sum(a[i])) / (n*(n-1))

                   Alternative formula used:

                   variance = 
                          (sum(a[i]*a[i]) - (sum(a[i])/n)*sum(a[i])) / (n-1)


                   Sum(a[i]) and sum(a[i]*a[i]) are accumulated using 
                   32-bit saturating arithmetic. Therefore a maximum 
                   of 65535 (=2^16 - 1) input values of value 0x8000 can
                   be accumulated before overflow/saturation will occur
                   (= worst case).
 
                   !! Be aware of small input values:
                   (a[i]*a[i]) evaluates to 0 for  | a[i] | <= sqrt(1-2^-15)
                                                             = 0xb6

  Operand        : R0 - Address of input array A,
                   R1 - Number of samples

  Registers Used : R0-R3, P0-2, A0-1

  Cycle count    :  143 + N             for N number of samples < 256
                    145 + (5 * N)       otherwise 

                  (measured for a ADSP-BF532 using version 3.5.0.21 of
                   the ADSP-BF53x Family Simulator and includes the
                   overheads involved in calling the library procedure
                   as well as the costs associated with argument passing)

  Code size      : 166 Bytes
******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = stats.h;
.file_attr libFunc       = var_fr16;
.file_attr libFunc       = __var_fr16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __var_fr16;

#endif

.text;
.global   __var_fr16;

.extern   ____div32;

.align 2;
__var_fr16:
        CC = R1 <= 1;
        IF CC JUMP VAR_RETURN;         // EXIT IF NO. ELEMENTS <= 1

        P0 = R0;                       // ADDRESS INPUT ARRAY
        P1 = R1;                       // SET LOOP COUNT TO N

        R2 = R1 >> 8;
        CC = R2 <= 0;                  // TEST FOR N < 256
        IF !CC JUMP VAR_LARGE;         // EXECUTE ALTERNATIVE ALGORITHM
                                       // FOR LARGER SAMPLE SIZES
 
        // N < 256
        // 40-BIT ACCUMULATOR SUFFICIENTLY LARGE 
        // TO COMPUTE SUMS WITHOUT RISK OF OVERFLOW

        P2 = 2;
        R3.H = 0x8000;
        A1 = A0 = 0 || R3.L = W[P0++P2]; // ZERO SUM(X), SUM(X*X)

        // SUM(X*X):  A0 = A0 + X(i) * X(i)         
        // SUM(X)  :  A1 = A1 - (0x8000 * X(i))
        //               = A1 - ( -X(i) ) = A1 + X1 
        LSETUP( VAR_LOOP, VAR_LOOP ) LC0 = P1;  

VAR_LOOP:  A0 -= R3.L * R3.H,  A1 += R3.L * R3.L || R3.L = W[P0++P2];

        A0 = A0 >>> 16;
        A1 = A1 >>> 16;  
        R2 = A0, R3 = A1; 

        JUMP VAR_FINAL_OPS;


VAR_LARGE:
        // N >= 256
        R2 = 0;                        // ZERO SUM(X)
        R3 = R3 - R3 (NS) || R0 = W[P0++] (X);
                                       // ZERO SUM(X*X) 

        LSETUP( VAR_START, VAR_END ) LC0 = P1;

VAR_START:  R2 = R2 + R0 (S);          // SUM(X) 
            A0 = R0.L * R0.L;
            A0 = A0 >> 16;
            R0 = A0;
VAR_END:    R3 = R3 + R0 (S) || R0 = W[P0++] (X);  
                                       // SUM(X*X)


VAR_FINAL_OPS:

        R0 = R2;

        [--SP] = RETS;
        [--SP] = R1;                   // PRESERVE N
        [--SP] = R3;                   // PRESERVE SUM(X*X) 
        [--SP] = R2;                   // PRESERVE SUM(X)
     
        CALL.X ____div32;               // SUM(X) / N  (RESULT = 1.15)
                  
        R1 = [SP++];                   // LOAD SUM(X) ( = 1.31)
        R0 <<= 16;                     // CONVERT 1.15 TO 1.31

        // SQUARE_SUM_OVER_N = (SUM(X) / N) * SUM(X)
        //   USE 1.31 * 1.31 MULTIPLICATION (RESULT = 1.31) TO
        //     - PRESERVE ACCURACY FOR A SMALL SUM(X) 
        //     - PREVENT OVERFLOW FOR A LARGE SUM(X)

        R3 = PACK(R0.L,R1.L);
        CC = R3;
        A1 = R0.L*R1.L (FU);
        A1 = A1 >>  16;
        A0 = R0.H*R1.H, A1 += R0.H*R1.L (M);
        CC &= AV0;
        A1 += R1.H*R0.L (M);
        A1 = A1 >>>  15;
        R3 = (A0 += A1);
        R2 = CC;
        R2 = R3 + R2;
        
        R0 = [SP++];                   // SUM_SQUARES = SUM(X * X) ( = 1.31)
        R0 = R0 - R2 (NS);             // SUM_SQUARES - SQUARE_SUM_OVER_N

        R1 = [SP++];                   // LOAD N
        R1 += -1;                      // COMPUTE (N - 1)

        RETS = [SP++];                 // RETRIEVE RETURN ADDRESS

        JUMP.X ____div32;               // (SUM_SQUARES - SQUARE_SUM_OVER_N) / 
                                       // (N - 1)

        // Note that ____div32 performs the return to the caller


     /* Return Zero if N <= 1 */

VAR_RETURN:
        R0 = 0;
        RTS;

.size __var_fr16, .-__var_fr16

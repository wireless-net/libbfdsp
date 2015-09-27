/******************************************************************************
  Copyright (C) 2005-2006 Analog Devices, Inc.  
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : transpmd.asm
  Include File   : matrix.h
  Label name     : __transpmd
 
  Description    : This function transposes the input matrix:

                       C = A', so that  C(col,row) = A(row,col)

                   It is implemented using circular buffers 
                   for the output array

  Operand        : void transpmd (const long double _matrix[],
                                  int _rows, int _columns,
                                  long double _transpose[]);

                   R0    - Address of input array A, 
                   R1    - Number of rows in A,
                   R2    - Number of columns in A,
                   STACK - Address of output array C

                   For optimum performance, the input and output matrices
                   have to be declared in two different data memory banks
                   to avoid data bank collision.

  Registers Used : R0-5, P0-1, I0, B0, M0, L0

  Cycle count    : 56 + 2 * Number of samples
                   n = 100: 256 Cycles  (BF532, Cycle Accurate Simulator)
  Code size      : 98 Bytes
******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)
.file_attr libGroup      = matrix.h;
.file_attr libFunc       = __transpmd;
.file_attr libFunc       = transpmd;
.file_attr libFunc       = transpm;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __transpmd;
#endif

#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_AVOID_DAG1)
#define __WORKAROUND_BF532_ANOMALY38__
#endif

.text;
.global  __transpmd;

.align 2;
__transpmd:

        P0 = R0;              // Address input array A
        R3 = [SP+12];         // Address output array C 
        I0 = R3;
        B0 = R3; 

        CC = R1 <= 0;
        IF CC JUMP DONE;      // Terminate if #rows <= 0

        CC = R2 <= 0;
        IF CC JUMP DONE;      // Terminate if #columns <= 0        


        R0 = 1;
        R2 *= R1;             // Total number of elements = rows * columns

        CC = R0 == R2;

        [--SP] = R4;          // Preserve reserved registers
        [--SP] = R5;          // Preserve reserved registers

        R5 = R1 + R1 (S) || R3 = [P0++];          
                              // Compute 2 * Row, Read a[0][0]
        R5 = R5 - R0 (S) || R4 = [P0++];          
                              // Compute (2 * Row) - 1, Read a[0][0]
        IF CC JUMP SINGLE;    // Skip loop for number of elements = 1


        CC = R1 == R2;        
        IF !CC R0 = R5;
        R0 <<= 2;             
        M0 = R0;              // Set step size through output array
                              //   M0 = 4, if only one column in A 
                              //   M0 = (2*rows)-1 in A, otherwise

        R2 += -1;
        P1 = R2;              // Set loop counter to number of elements - 1   
        R2 <<= 3;
        L0 = R2;              // Enable circular buffer for output
         
#if defined(__WORKAROUND_BF532_ANOMALY38__)

        LSETUP (CPY_A_2_C_START, CPY_A_2_C_END) LC0 = P1; 
CPY_A_2_C_START:  [I0++] = R3;  
                  [I0++M0] = R4;
                  R3 = [P0++];
CPY_A_2_C_END:    R4 = [P0++];

#else

        LSETUP (CPY_A_2_C_START, CPY_A_2_C_END) LC0 = P1;
CPY_A_2_C_START:  R3 = [P0++] || [I0++] = R3;
CPY_A_2_C_END:    R4 = [P0++] || [I0++M0] = R4;

#if defined(__WORKAROUND_INFINITE_STALL_202)
        PREFETCH[SP];
        PREFETCH[SP];

#endif  /*__WORKAROUND_INFINITE_STALL_202*/
#endif  /*__WORKAROUND_BF532_ANOMALY38__*/

        M0 = R2;              // Set stride to number of elements - 1
        L0 = 0;               // Reset circular buffer for output
        R1 = [I0++M0];        // Dummy read, position I0 to point at
                              // the last element in the output matrix

SINGLE:
#if defined(__WORKAROUND_WB_DCACHE)
        SSYNC;
#endif
        [I0++] = R3;          // Write final element to the output matrix       
        [I0] = R4;   

        R5 = [SP++];          // Restore preserved registers
        R4 = [SP++];          // Restore preserved registers

DONE:
        RTS;

.size __transpmd, .-__transpmd

/******************************************************************************
  Copyright (C) 2000-2006 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : transpm_fr16.asm
  Include File   : matrix.h
  Label name     : __transpm_fr16

  Description    : This function transposes the input matrix:

                       C = A', so that  C(col,row) = A(row,col)

  Operand        : void transpm_fr16 (const fract16 _matrix[],
                                      int _rows, int _columns,
                                      fract16 _transpose[]);

                   R0    - Address of input array A,
                   R1    - Number of rows in A,
                   R2    - Number of columns in A,
                   STACK - Address of output array C

                   For optimum performance, the input and output matrices
                   have to be declared in two different data memory banks 
                   to avoid data bank collision.

  Registers Used : R0-3, P0-2, P5, I0-1

  Cycle count    : 40 + Number of columns * ( Number of rows + 4)
                   
                   Number of columns = 10, 
                   Number of rows    = 10,
                   = 180 Cycles  (BF532, Cycle Accurate Simulator)

  Code size      : 64 Bytes
******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)
.file_attr libGroup      = matrix.h;
.file_attr libFunc       = __transpm_fr16;
.file_attr libFunc       = transpm_fr16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __transpm_fr16;
#endif

.text;
.global  __transpm_fr16;

.align 2;
__transpm_fr16:

        P0 = R0;              // Address input array A
        R3 = [SP+12];         // Address output array C
        I1 = R3;

        R0 = R2;
        R0 *= R1;				
        CC = R0 == 0;         // Exit if the number of rows 
                              // or columns are zero
        IF CC JUMP FINISH;			
	
        CC = R0 == 1;         // Check if rows = columns = 1
        IF CC JUMP SCALAR;    // If TRUE branch to SCALAR
			
        R3 = R2 << 1;         // Compute the space required for one row 
                              // of the matrix

        P2 = R2;
        P1 = R3;              // Offset for fetching the column elements 
			
        [--SP] = P5;          // Preserve reserved register

        P5 = R1;
        I0 = P0;              // Preserve address

        /* Traverse input column by column */
        LSETUP(START_TR_OUT, END_TR_OUT) LC0 = P2;	
START_TR_OUT:   R0 = W[P0++P1](X);
		
                /* Traverse current column row by row, copy elements */
                LSETUP(START_TR_IN, START_TR_IN) LC1 = P5;
START_TR_IN:            R0 = W[P0++P1](X) || W[I1++] = R0.L; 

#if defined(__WORKAROUND_INFINITE_STALL_202)
                PREFETCH[SP];
                PREFETCH[SP];
#endif

                I0 += 2;      // Point to the next column in the first row
END_TR_OUT:     P0 = I0;      // Re-position input pointer

        P5 = [SP++];          // Restore preserved register
				
FINISH:			
        RTS;

		
SCALAR:
        // If rows = columns = 1
	R0 = W[P0++] (Z);
        W[I1++] = R0.L;

        RTS;


.size __transpm_fr16, .-__transpm_fr16

/******************************************************************************
  Copyright (C) 2000-2006 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : vsmlt.asm
  Module Name    : vector scalar multiplication
  Label name     :  __vecsmlt_fr16
  Description    : This function computes the scalar multiplication of a vector
  Operand        : R0 - Address of input vector,
                   R1 - scalar value,
                   R2 - Address of output vector
  Registers Used : R3,I0,P0,P1
  Notes          : Input and output vectors should be in different banks
                   to achieve the cycle count given below. Also the function
                   reads two elements beyond the end of the input vector to
                   achieve a 1-cycle loop

  CYCLE COUNT    : 10          N == 0
                 : 14 + N      for other N
                               'N' - NUMBER OF ELEMENTS

  CODE SIZE      : 46 BYTES
******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)
.file_attr libGroup      = vector.h;
.file_attr libGroup      = matrix.h;             // called from matrix.h
.file_attr libFunc       = vecsmlt_fr16;
.file_attr libFunc       = __vecsmlt_fr16;
.file_attr libFunc       = matsmlt_fr16;        // called from matrix.h
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __vecsmlt_fr16;
#endif

.text;
.global       __vecsmlt_fr16;
.align 2;

__vecsmlt_fr16:
        R3 = [SP+12];              // NO. OF ELEMENTS IN INPUT VECTOR
        CC = R3 <= 0;              // CHECK IF NO. ELEMENTS(N) <= 0
        IF CC JUMP RET_ZERO;

        P0 = R0;                   // ADDRESS OF INPUT COMPLEX VECTOR
        P1 = R3;                   // SET LOOP COUNTER
        I0 = R2;                   // ADDRESS OF OUTPUT COMPLEX VECTOR
        R0 = W[P0++] (Z);          // FETCH INPUT[0]
        R3.L = R0.L * R1.L || R0 = W[P0++] (Z);  
                                   // CALCULATE OUTPUT[0] AND FETCH INPUT[1]

        LSETUP(ST_VSMLT,ST_VSMLT) LC0 = P1;
            // DO MULTIPLICATION, FETCH NEXT INPUT, STORE PREVIOUS OUTPUT
ST_VSMLT:   R3.L = R0.L * R1.L || R0 = W[P0++] (Z) || W[I0++] = R3.L;

#if defined(__WORKAROUND_INFINITE_STALL_202)
        PREFETCH[SP];
        PREFETCH[SP];
#endif

RET_ZERO:
        RTS;

.size __vecsmlt_fr16, .-__vecsmlt_fr16

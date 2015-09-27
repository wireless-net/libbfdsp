/******************************************************************************
  Copyright (C) 2000-2005 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : cvvsub.asm
  Module Name    : Vector Library
  Label name     :  __cvecvsub_fr16
  Description    : This function computes complex vector vector subtrction
  Operand        : R0 - address of input complex vector A,
                   R1 - address of input complex vector B,
                   R2 - address of output complex vector
  Registers Used : R0,R1,R2,R3,I0,I1,P0,P1.

  Notes          : Input vectors should be in different banks to acheive 
                   the cycle count given below.

  CYCLE COUNT    : 13            N == 0
                 : 10 + 2*N      for other N
  'N' - NUMBER OF ELEMENTS

  CODE SIZE      : 40 BYTES
  
  DATE           : 21-02-01
******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup      = vector.h;
.file_attr libFunc       = __cvecvsub_fr16;
.file_attr libFunc       = cvecvsub_fr16;
/* Called by cmatmsub_fr16 */
.file_attr libGroup      = matrix.h;
.file_attr libFunc       = cmatmsub_fr16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __cvecvsub_fr16;

#endif

#if defined(__ADSPLPBLACKFIN__) && defined(__WORKAROUND_SPECULATIVE_LOADS)
#define __WORKAROUND_BF532_ANOMALY_050000245
#endif

.text;
.global __cvecvsub_fr16;
.align 2;

__cvecvsub_fr16:
        P1 = [SP+12];              // NO. OF ELEMENTS IN INPUT VECTOR
        P0 = R0;                   // ADDRESS OF INPUT COMPLEX VECTOR1
        I0 = R1;                   // ADDRESS OF INPUT COMPLEX VECTOR2
        CC = P1 <= 0;              // CHECK IF NO. ELEMENTS(N) <= 0
        IF CC JUMP RET_ZERO;

#if defined(__WORKAROUND_BF532_ANOMALY_050000245)
        NOP;
        NOP;
#endif
        P2 = R2;                   // ADDRESS OF OUTPUT COMPLEX VECTOR
        R1 = [P0++];               // GET INPUTS FROM VECTOR1 AND VECTOR2
        R2 = [I0++];

        LSETUP(ST_CVVSUB,END_CVVSUB) LC0 = P1;
ST_CVVSUB:   R3 = R1 -|- R2(S) || R1 = [P0++];
                                         // DO SUBTRACTION, FETCH NEXT INPUTS FROM VEC.1

END_CVVSUB:  [P2++] = R3 || R2 = [I0++]; // STORE RESULT IN OUTPUT VECTOR

RET_ZERO:
        RTS;

.size __cvecvsub_fr16, .-__cvecvsub_fr16

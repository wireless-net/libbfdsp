/******************************************************************************
  Copyright (C) 2000-2006 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
 ******************************************************************************
  File Name      : csadd.asm
  Module Name    : complex vector scalar addition
  Label name     :  __cvecsadd_fr16
  Description    : This function computes complex vector/scalar addition
  Operand        : R0 - address of input complex vector A,
                   R1 - complex scalar B,
                   R2 - address of output complex vector
  Registers Used : R0,R1,R2,R3,I0,P0,P1.

  Notes          : Input and output vectors should be in different banks to
                   avoid memory bank collisions

  CYCLE COUNT    : 28          N == 0
                   25 + N      for other N
                  (measured for a ADSP-BF532 using version 3.5.0.21 of
                   the ADSP-BF53x Family Simulator and includes the
                   overheads involved in calling the library procedure
                   as well as the costs associated with argument passing)

  CODE SIZE      : 36 BYTES

******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)
.file_attr libGroup      = vector.h;
.file_attr libFunc       = __cvecsadd_fr16;
.file_attr libFunc       = cvecsadd_fr16;
/* Called by cmatsadd_fr16 */
.file_attr libGroup      = matrix.h;
.file_attr libFunc       = cmatsadd_fr16;
.file_attr libName = libdsp;
.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";
.file_attr FuncName      = __cvecsadd_fr16;
#endif

.text;
.global __cvecsadd_fr16;
.align 2;

__cvecsadd_fr16:
        R3 = [SP+12];                  // No. of elements in input vector
        CC = R3 <= 0;                  // Check if no. elements <= 0
        IF CC JUMP RET_ZERO;
        P0 = R0;                       // Address of input complex vector
        I0 = R2;                       // Address of output complex vector
        P1 = R3;                       // Set loop counter

        R2 = [P0++];                   // Load input[0]
        R3 = R2 +|+ R1(S) || R2 = [P0++]; // Calculate output[0], Load input[1]

        LSETUP(ST_CSADD,ST_CSADD) LC0 = P1;
ST_CSADD:  R3 = R2 +|+ R1(S) || R2=[P0++] || [I0++] = R3;
                          // Do addition,
                          // Fetch next element,
                          // Store previous output

#if defined(__WORKAROUND_INFINITE_STALL_202)
        PREFETCH[SP];
        PREFETCH[SP];
#endif

RET_ZERO:
        RTS;

.size __cvecsadd_fr16, .-__cvecsadd_fr16

/******************************************************************************
  Copyright (C) 2006 Analog Devices, Inc.
  This file is subject to the terms and conditions of the GNU Lesser
  General Public License. See the file COPYING.LIB for more details.

  Non-LGPL License is also available as part of VisualDSP++
  from Analog Devices, Inc.
******************************************************************************
  File Name      : sqrtd.asm
  Include File   : math.h
  Label name     : __sqrtd

  Description    : This routine computes a double-precision, floating
                   point square root

                   It returns 0 for denormalized inputs, negative inputs,
                   NaN's, and Inf's.

  Operand        : R0-1 - Input value, Return value

  Registers Used : R0-7, A0-1, P0-2, P4, P5, I0

  Cycle count    : 655
                   (BF532, Cycle Accurate Simulator)

  Code size      : 256 Bytes
******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup = math_bf.h;
.file_attr libGroup = math.h;
.file_attr libName  = libdsp;
.file_attr FuncName = __sqrtd;

      /* Called from acosd */
.file_attr libFunc  = acosd;
.file_attr libFunc  = __acosd;
.file_attr libFunc  = acosl;
.file_attr libFunc  = acos;

      /* Called from asind */
.file_attr libFunc  = asind;
.file_attr libFunc  = __asind;
.file_attr libFunc  = asinl;
.file_attr libFunc  = asin;

      /* Called from cabsd */
.file_attr libFunc  = cabsd;
.file_attr libFunc  = __cabsd;
.file_attr libFunc  = cabs;

      /* cabsd is called by cartesiand */
.file_attr libFunc  = cartesiand;
.file_attr libFunc  = __cartesiand;
.file_attr libFunc  = cartesian;

      /* cabsf is called by normd */
.file_attr libFunc  = normd;
.file_attr libFunc  = __normd;
.file_attr libFunc  = norm;

      /* Called from rmsd */
.file_attr libFunc  = rmsd;
.file_attr libFunc  = __rmsd;
.file_attr libFunc  = rms;

      /* Called from sqrtd */
.file_attr libFunc  = sqrtd;
.file_attr libFunc  = __sqrtd;
.file_attr libFunc  = sqrtl;
.file_attr libFunc  = sqrt;

.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";

#endif

/* Data placement on the stack
**
**      Top of stack  -------------
**                         xn
**                    -------------
**                      TempInput
**                    -------------
**                        Temp
**                    -------------
**                       Exponent
**                    -------------
**                       RTS, Regs
**                    -------------
*/

#define  _OFFSET_XN         0            // .byte4 _xn[2];
#define  _OFFSET_TEMPIN     8            // .byte4 _TempInput[2];
#define  _OFFSET_TEMP      16            // .byte4 _Temp[3];
#define  _OFFSET_EXPONENT  28            // .byte4 _Exponent;

.section .rodata;

/* Const data */

.align 2;
	.type	_Zero, @object
	.size	_Zero, 2
_Zero:
	.short 0;

.align 4;
	.type	_OnePtFive, @object
	.size	_OnePtFive, 4
_OnePtFive:
	.long 0x30000000;


.text;
.global  __sqrtd;

.extern  ___SQRT_Mult64;
.extern  ___SQRT_Seed_Table;

.align 2;
__sqrtd:

       //************************** Check Input ******************************

       r2 = r1 >>> 20;             // get the sign and exponent
       CC = r2 <= 0;
       if CC jump _ErrSqrtd;       // return 0 if input<=0 or input is a denorm

          /* Note: we now know that the input value is +ve
          **       and therefore that the sign bit is zero
          **       and therefore R2 contains (just) the exponent
          */

       r3 = 0x07ff;
       CC = r2 == r3;
       if CC jump _ErrSqrtd;       // return 0 if input=Inf or NaN


       //******************* Convert from double to 1.63U ********************

       r3.l = 0x3ff;               // 0x3ff = offset
       r2.l = r2.l - r3.l (ns);
       r2.l = r2.l >>> 1;
       r2.l = r2.l + r3.l (ns);

       [--SP] = (R7:4,P5:4);       // Save registers R4-R7 and P4 and P5
       [--SP] = RETS;

       p0 = 9;
       p4 = 8;

       SP += -32;                  // allocate space on stack for local data

       CC = bittst(r1,20);         // exponent odd?
       if CC p4 = p0;

       [SP+_OFFSET_EXPONENT] = r2; // write contents of r2 to _Exponent

       r1 <<= 12;                  // clear the exponent
       r1 >>= 12;
       bitset(r1,20);              // set implicit bit
       CC = r7 < 0 (IU);           // Clear CC

       r2 = rot r0 by 1;
       r3 = rot r1 by 1;

       lsetup(_ConvDb2FracStart, _ConvDb2FracEnd) lc0 = p4;

_ConvDb2FracStart:
          r2 = rot r2 by 1;
_ConvDb2FracEnd:
          r3 = rot r3 by 1;

       [SP+_OFFSET_TEMPIN  ] = r2; // [r3:r2] = y = normalized input
       [SP+_OFFSET_TEMPIN+4] = r3; // write contents r3:r2 to _TempInput


       //***************************** Get seed ******************************

       p2.l = ___SQRT_Seed_Table-0x20; // pointer to const data
       p2.h = ___SQRT_Seed_Table-0x20;

       r0 = r3 >> 24;
       p1 = r0;

       LOAD_IND(i0, _OnePtFive, p0);  // pointer to const data

       LOAD(p0, _Zero);               // pointer to const data
                                      // (required by function ___SQRT_Mult64)

       p2 = p2 + p1;
       r0 = r0 - r0 (ns) || r1 = b[p2] (Z);
       p2 = 4;
       r1 <<= 24;

       p5 = SP;

       [SP+_OFFSET_XN  ] = r0;
       [SP+_OFFSET_XN+4] = r1;     // write contents r1:r0 to _xn

       p5 += _OFFSET_TEMP;         // set pointer local data to &_Temp
                                   // (required by function ___SQRT_Mult64)


       //******************* Iterate Newton Approximation ********************

       lsetup(_Sqrt64Start, _Sqrt64End) lc0=p2;

_Sqrt64Start:
          r2 = r0;
          r3 = r1;

          call.x ___SQRT_Mult64;   // [r1:r0] = x0^2

          r2 = [SP+_OFFSET_TEMPIN  ];
          r3 = [SP+_OFFSET_TEMPIN+4];
                                   // [r3:r2] = y = input
                                   // write contents r3:r2 to _TempInput

          call.x ___SQRT_Mult64;   // [r1:r0] = y*x0^2/2

          r2 = r2-r2 (ns) || r3 = [i0];
                                   // [r3:r2] = 1.5
          CC = r2 < r0 (IU);
          r7 = CC;                 // R7 = Carry
          r0 = r2-r0 (ns);
          r5 = r3-r7 (ns) || r2 = [SP+_OFFSET_XN];
                                   // [r3:r2] = x(n)
          r1 = r5-r1 (ns) || r3 = [SP+_OFFSET_XN+4];
                                   // [r1:r0] = (3.0-y*x(n)^2)/2

          call.x ___SQRT_Mult64;   // [r5:r4] = x(n+1) = x(n)*(3-y*x(n)^2)/2

          r4 = r0 >> 29;
          r0 = r0 << 3;
          r1 = r1 << 3;
          r1 = r1+r4 (ns) || [SP+_OFFSET_XN] = r0;

_Sqrt64End:
          [SP+_OFFSET_XN+4] = r1;  // write contents r1:r0 to _xn

       r2 = [SP+_OFFSET_TEMPIN  ];
       r3 = [SP+_OFFSET_TEMPIN+4]; // [r3:r2] = y = input

       call.x ___SQRT_Mult64;      // [r1:r0] = y/sqrt(y) = sqrt(y)


       //******************* Convert from 1.63U to double ********************

       lsetup(_ConvFrac2DbStart, _ConvFrac2DbEnd) lc0 = p4;

_ConvFrac2DbStart:
          r1 = rot r1 by -1;
_ConvFrac2DbEnd:
          r0 = rot r0 by -1;

       SP += _OFFSET_EXPONENT;     // pop all local data, with the exception
                                   // of _Exponent, from the stack

       r1 <<= 12;                  // Clear exponent field and implied bit
       r1 >>= 12;

       r2 = [SP++];                // Get exponent
                                   // and pop remaining local data of the stack
       r2 <<= 20;
       r1 = r1 | r2;


       //***************************** Exit **********************************

_EndSqrtd:

       RETS = [SP++];

       (R7:4,P5:4) = [SP++];       // Restore all registers that were saved

       rts;

_ErrSqrtd:
       r0 = 0;                     // set return value to zero
       r1 = 0;

       rts;

.size __sqrtd, .-__sqrtd

/*****************************************************************************
 *
 * rms_fr16.asm
 *
 * Copyright (C) 2000-2006 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 *****************************************************************************/

#if defined(__DOCUMENTATION__)

    Function: rms_fr16 - root mean square

    Synopsis:

        #include <stats.h>
        fract16 rms_fr16(const fract16 samples[],
                         int           sample_length);

    Description:

        This function returns the root mean square of the elements within
        the input vector samples[]. The number of elements in the vector
        is sample_length.

    Error Conditions:

        If the number of samples is less than 1, then the function will
        return zero.

        If the function detects an overflow, then it will return 0x7FFF.

    Algorithm:

        The root mean square is defined as

            sqrt( (x[0]^2 + x[1]^2 + ........ + x[N-1]^2)/N )

    Implementation:

        The function uses the accumulator to calculate the sum of the
        square of each array element. This preserves accuracy up to
        9:31 notation. The intermediate sum is then moved to a register
        prior to performing the division (by N) - this may involve first
        scaling the calculation to avoid saturation.

        The function sqrt_fr16 is used to calculate the square root, which
        means that the result of the division must be no greater than 0x7FFF.
        This may involve further scaling of the intermediate result. At this
        point the function may detect overflow if the total scaling required
        is more than 2^16.

    Stack Size:

        Two words to preserve registers

    Example:

        #include <stats.h>
        #define SIZE 256

        fract16 input[SIZE];
        fract16 result;

        result = rms_fr16 (input,SIZE);

    Cycle Counts:

        55 + sample_length + cost of sdiv32 + cost of sqrt_fr16

        Measured using version 4.5.0.22 of the ADSP-BF5xx Blackfin
        Family Simulator and includes the overheads involved in
        calling the library procedure and passing in the arguments.

 *****************************************************************************
#endif

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.FILE_ATTR FuncName      = __rms_fr16;
.FILE_ATTR libNamei      = libdsp;

.FILE_ATTR libGroup      = stats.h;
.FILE_ATTR libFunc       = __rms_fr16;
.FILE_ATTR libFunc       = rms_fr16;

.FILE_ATTR prefersMem    = internal;
.FILE_ATTR prefersMemNum = "30";

#endif

/* Macros */

#define BIT0_MASK 0x00000001

/* The macro BIT0_MASK above identifies the least significant bit in a word */


.EXTERN  ___div32;
.TYPE    ___div32,STT_FUNC;

.EXTERN  __sqrt_fr16;
.TYPE    __sqrt_fr16,STT_FUNC;

.GLOBAL  __rms_fr16;
.TYPE    __rms_fr16,STT_FUNC;

.text;
.ALIGN 2;

__rms_fr16:

   /* Check for valid input and initialize */

      P0 = R0;                /* address input array X       */
      CC = R1 <= 1;           /* test the number of samples  */
      IF CC JUMP .ret_short;

      P1 = R1;                /* initialize the loop counter to N */
      [--SP] = RETS;          /* push RETS onto the stack         */
      [--SP] = R4;            /* preserve R4                      */

      A1 = A0 = 0
      || R2 = w[P0++](Z);     /* Prime loop by loading X[0]  */

   /* Calculate the sum of the square of each element */

      /* loop over number of samples */
      LSETUP (.loop,.loop) LC0 = P1;
.loop:
         A0 += R2.L * R2.L  || R2 = w[P0++](Z);

   /* Convert the intermediate sum to 1.31 notation */

      R4 = 16;             /* the intermediate sum must be scaled by 16 before
                           ** calculating the square root (or by 8 after the
                           ** square root) - also avoid Issue 05-00-0209 and
                           ** separate the SIGNBITS instruction from the source
                           ** of A0
                           */

      R2.L = SIGNBITS A0;
      R2 = R2.L (X);
      CC = R2 < 0;         /* CC = 1 if R0=A0 would saturate         */

      R0 = A0;             /* R0 = the intermediate sum              */
      A0 = A0 >> 16;
      R2 = A0;             /* R2 = the scaled intermediate sum       */

      IF CC R0 = R2;       /* R0 = the scaled sum if R0=A0 saturates */

   /* Record the scaling performed above */

      R2 = 0;
      IF CC R4 = R2;       /* R4 = 0 if A0 has already been scaled   */

   /* Divide the sum of the squares by N */

      CALL.X ____div32;

   /* Convert the quotient from 1:31 to 1:15 notation
   **
   ** (If the quotient is less than 32768 then no special action is
   ** required - otherwise it must be scaled to that it is just less
   ** than 32768.
   **
   ** Note that R4 indicates the amount of scaling that has to be applied
   ** to the final result and also note that:
   **
   **    SQRT (X/(2^n)) == SQRT(X) / (2^m)      where m = n/2
   **
   ** This means that any scaling prior to calculating the sqrt must be
   ** an even power. It also means that R4 must be adjusted to compensate
   ** for the pre-scaling)
   */

      R2.L = SIGNBITS R0;
      R2 = R2.L (X);

      R1 = 16;
      R1 = R1 - R2;              /* R1 = amount of scaling reqd if R1>0   */
      R2 = 0;
      CC = R1 <= 0;              /* CC = 1 if quotient is less than 32768 */
      IF CC R1 = R2;             /* R1 = 0 if CC=1
                                 ** so that next 4 instrs are effective no-ops
                                 */

      R1 += 1;                      /* Round scaling reqd          */
      BITCLR(R1,0); /*       to next even multiple */

   /* Check for overflow
   **
   ** (typically the intermediate sum of squares is divided by 2^16
   ** before calculating the square root - but this scaling is sometimes
   ** deferred in the interests of preserving precision. The amount of
   ** scaling still required is recorded in R4 and if this value turns
   ** negative then there is an overflow condition)
   */

      R4 = R4 - R1;
      CC = R4 < 0;
      IF CC JUMP .overflow;

   /* Calculate SQRT ((sum of the squares)/N) */

      R0 >>= R1;                 /* scale the quotient appropriately     */
      CALL.X __sqrt_fr16;

      R4 >>= 1;
      R0 >>= R4;                 /* apply any remaining scaling required */

.exit:
      R4   = [SP++];
      RETS = [SP++];
      RTS;

.ret_short:
      CC = R1 == 1;
      IF CC JUMP .ret_single;
      R0 = 0;                    /* return zero if N <= 0 */
      RTS;

.ret_single:
      R0 = w[P0] (Z);
      R0 = ABS R0 (V);           /* if n=1 then SQRT(x1^2/1) = |x1| */
      RTS;

.overflow:
      R0 = 0x7FFF;
      JUMP .exit;

.size __rms_fr16, .-__rms_fr16

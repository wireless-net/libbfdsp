/***************************************************************************
*
* Function:  FR32_TO_FLOAT -- Convert a fract32 to a floating-point value
*
* Synopsis:
*
*       #include <fract2float_conv.h>
*       float fr32_to_float(fract32 x);
*
* Description:
*
*       The fr32_to_float converts a fixed-point, 32-bit fractional number
*       in 1.31 notation into a single precision, 32-bit IEEE floating-point
*       value. No rounding is performed and so, for example, 0x7fffffff is
*       converted to 0.99999994e0 and not to 1.0e0.
*
* Algorithm:
*
*       The traditional algorithm to convert a 1.31 fractional numbers to
*       floating-point value is:
*
*           r = (float)(x) / 2147483648.0
*           r = copysignf(minf(fabs(r),0.99999994e0),r)
*
*       However on Blackfin, floating-point division is relatively slow,
*       and one can alternatively adapt the algorithm for converting from
*       an int to a float and then subtracting 31 from the exponent to
*       simulate a division by 2147483648.0.
*
*       The following is a slower C implementation of this function:

            #include <fract2float_conv.h>

            extern float
            fr32_to_float(fract32 x)
            {

                float result;
                int *presult = (int *)(&result);

                if (x == 0x80000000)
                   return -1.0;

                result = fabsf(x);
                if (result != 0.0) {
                    *presult = *ptemp - 0x0f800000;
                    if (x < 0)
                       result = -result;
                }

                return result;

            }
*
*       WARNING: This algorithm assumes that the floating-point number
*       representation is conformant with IEEE.
*
* Cycle Counts:
*
*       26 cycles when the input is 0 or 0x80000000
*       26 cycles for all other input
*
*       These cycle counts were measured using the BF532 cycle accurate
*       simulator and include the overheads involved in calling the function
*       as well as the costs associated with argument passing.
*
* Code Size:
*
*       52 bytes
*
* Registers Used:
*
*       R0 - the input argument and result
*       R1 - various
*       R2 - various
*
* Copyright (C) 2006 Analog Devices, Inc.
*
*
***************************************************************************/

        .file "dfr2fr.asm";

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup = floating_point_support;
.file_attr libGroup = integer_support;
.file_attr libName  = librt;
.file_attr libName  = librt_fileio;

.file_attr libFunc  = fr32_to_float;
.file_attr libFunc  = _fr32_to_float;
.file_attr FuncName = _fr32_to_float;

.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";

#endif


/* Macro Definitions (to calculate the exponent) */

#define EXP_BIAS		(0x7F)
#define SIGNBITS_BIAS		(30)
#define SIGNBITS_ADJ		(6)
#define DIVIDE_BY_2_POW_31	(31)
#define EXP_FIELD_ADJ		(1)

    /* EXP_BIAS is the constant that is applied to every binary exponent
    **    before it becomes part of an IEEE representation. After this
    **    has been applied, all exponents greater than EXP_BIAS will
    **    represent powers of 2 that are +ve, and all exponents less
    **    than EXP_BIAS will represent powers of 2 that are -ve.
    **
    ** SIGNBITS_BIAS
    **    The result of the SIGNBITS instruction is subtracted from
    **    this constant to give the unbias'ed exponent of the floating-
    **    point number.
    **
    ** SIGNBITS_ADJ
    **    The algorithm subtracts this from the result of SIGNBITS
    **    and so we have to factor this into the calculation of the
    **    exponent.
    **
    ** DIVIDE_BY_2_POW_31 is set to the binary power of 2147483648.0
    **
    ** EXP_FIELD_ADJ
    **    The algorithm initializes the exponent field to 1 and so
    **    we have to compensate.
    */

#define EXP_ADJUST	(EXP_BIAS             \
			 + SIGNBITS_BIAS      \
			 - SIGNBITS_ADJ       \
			 - DIVIDE_BY_2_POW_31 \
			 - EXP_FIELD_ADJ)

    /* The exponent of the result is calculated by subtracting the
    ** result of the SIGNBITS instruction from this constant.
    **
    **      EXP_ADJUST = 119
    */


.text;
        .align 2;

        .global _fr32_to_float;

_fr32_to_float:

    /*  Test for Special Case: X == 0 or X == 0x80000000 */

        R1 = R0 << 1;
        CC = AZ;
        IF CC JUMP .special_return;


/* The following algorithm contains four tricks:
**
** Trick [1]:
**     This is not a trick but it is worth pointing out that no rounding
**     is required (otherwise 0x7fffffff will be converted to 1.0 which
**     is outside the domain of fractional numbers expressed in 1.31
**     notation).
**
** Trick [2]:
**     After normalizing X, use its MSB as the LSB of the exponent - this
**     means that we do not have to arrange for this bit (which represents the
**     hidden bit of an IEEE floating-point number) to be discarded. What we
**     do is shift the bit into the LSB of the exponent field and then *add*
**     the (suitably-adjusted) value of the exponent into this field.
**
** Trick [3]:
**     Implement a floating-point divide by 2147483648.0 by subtracting 31
**     from the exponent of the dividend (because 2^31 == 2147483648.0); this
**     trick is utilized while calculating the required value of the exponent.
**
** Trick [4]:
**     This is a short-cut to adding the sign bit to the final result - a
**     typical way of doing this would be to set the MSB of the result but
**     only if the original argument was negative - this particular trick
**     uses two instructions by utilizing the ROT(ate) instruction. We start
**     by making sure that CC is set if the input argument is -ve; we then
**     perform a 1-bit rotate to the right, which rotates the source register
**     by copying the CC register to the MSB of the result and copying the
**     LSB of the source register into the CC register. So for this trick
**     to work, we shall have to set up the exponent field in bits 31-24
**     (rather than bits 30-23), and the mantissa in bits 23-1.

** So the algorithm works as follows:
**
** Step [1]:
**     Normalizes (shifts) X so that the MSB is at bit 24 (ie 0x01000000)
**
** Step [2]:
**     Calculates the value of the exponent minus 1 and shifts it 24 bits
**     to the left (so that it occupies the most significant byte)
**
** Step [3]:
**     Adds Step [1] and Step [2]
**
** Step [4]:
**     Sets CC if X is negative
**
** Step [5]:
**     Rotates Step [3] one place to the right
*/

        R1 = ABS R0;                  /* Only work with +ve values    */
        CC = BITTST(R0,31);           /* Record whether X is negative */

        R2.L = SIGNBITS R1;           /* Number of sign bits minus 1  */
        R2   = R2.L;

                /* Note:
                **
                ** Anomalies 05-00-209 and 05-00-127 require the input
                ** for the SIGNBITS instruction to be created more than
                ** one instruction earlier. Then convert the result from
                ** a short int to an int to allow us to perform arithmetic
                ** on it.
                */

        R2 += -SIGNBITS_ADJ;          /* See Trick [2] + [4] above */
        R1  = LSHIFT R1 BY R2.L;      /* See Step [1]              */

    /*  Calculate the Exponent and Move it into Position (see Step [2]) */

        R0 = EXP_ADJUST;
        R0 = R0 - R2;
        R0 <<= 24;

    /*  Form the Result (see Step [3] and Trick [4]) */

        R0 = R0 + R1;
        R0 = ROT R0 BY -1;

        RTS;

.special_return:

    /*  Handle an Input of either 0 or 0x80000000 */

        CC = BITTST(R0,31);            /* Test the top bit of X      */
        R1.H = 0XBF80;                 /* Sign and exponent for -1.0 */
        IF CC R0 = R1;                 /* Input was 0X80000000       */

        RTS;

.size _fr32_to_float, .-_fr32_to_float

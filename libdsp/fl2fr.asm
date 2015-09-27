/***************************************************************************
*
* Function:  FLOAT_TO_FR16 -- Convert a floating-point value to a fract16
*
* Synopsis:
*
*       #include <fract2float_conv.h>
*       fract16 float_to_fr16(float x);
*
* Description:
*
*       The float_to_fr16 function converts a single precision, 32-bit IEEE
*       value into a fract16 number in 1.15 notation. Floating-point values
*       that cannot be converted to fract15 notation are handled as follows:
*
*           Return 0x7fffffff if x >= 1.0 or  NaN or +Inf
*           Return 0x80000000 if x < -1.0 or -NaN or -Inf
*           Return 0          if fabs(x) < 3.0517578125e-5
*
*       (Note that the IEEE single precision, 32-bit, representation
*       contains 24 bits of precision, made up of a hidden bit and 23
*       bits of mantissa, and thus some precision may be lost by converting
*       a float to a fract16).
*
* Algorithm:
*
*       The traditional algorithm to convert a floating-point value to 1.15
*       fractional notation is:
*
*           (fract16) (x * 32768.0)
*
*       However on Blackfin, floating-point multiplication is relatively
*       slow is emulated in software, and this basic algorithm does not
*       handle out of range results.
*
*       This implementation is based on the support routine that converts
*       a float to fract32, and then converts the fract32 into a fract16
*       by performing an arithmetic right shift by 16 bits. (It is possible
*       to avoid the shift by coding the function to "multiply" the input
*       input argument by 2^15 (rather than 2^31) but this approach can lead
*       to the loss of 1-bit precision when handling negative inputs).
*
*       The following is a C implementation of this function and is about
*       a third slower:

            #include <fract2float_conv.h>

            extern fract16
            float_to_fr16(float x)
            {

                int temp;
                fract32 result;

                temp = *(int *)(&x);

                if ((temp & 0x7f800000) >= 0x3f800000) {
                    result = 0x7fffffff;
                    if (temp < 0)
                        result = 0x80000000;
                } else {
                    temp = temp + 0x0f800000;
                    result = *(float *)(&temp);
                }

                return (result >> 16);

            }
*
*       WARNING: This algorithm assumes that the floating-point number
*       representation is conformant with IEEE.
*
* Cycle Counts:
*
*       31 cycles when the result is within range
*       30 cycles when the result is out of range
*       28 cycles when the input is 0.0
*
*       These cycle counts were measured using the BF532 cycle accurate
*       simulator and include the overheads involved in calling the function
*       as well as the costs associated with argument passing.
*
* Code Size:
*
*       76 bytes
*
* Registers Used:
*
*       R0 - the input argument
*       R1 - various constants
*       R2 - the exponent of the input argument or a shift amount
*       R3 - the mantissa of the input argument
*
* Copyright (C) 2006 Analog Devices, Inc.
*
*
***************************************************************************/

        .file "fl2fr.asm";

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

.file_attr libGroup = floating_point_support;
.file_attr libGroup = integer_support;
.file_attr libName  = librt;
.file_attr libName  = librt_fileio;

.file_attr libFunc  = float_to_fr16;
.file_attr libFunc  = _float_to_fr16;
.file_attr FuncName = _float_to_fr16;

.file_attr prefersMem    = internal;
.file_attr prefersMemNum = "30";

#endif


/* Macro Definitions */

#define EXP_BIAS	(0x7F)
#define EXP_CONST1	(23)
#define EXP_CONST2	(31)
#define EXP_ADJUST	(EXP_BIAS + EXP_CONST1 - EXP_CONST2)

    /* EXP_BIAS is the constant that is applied to every binary exponent
    **    before it becomes part of an IEEE representation. After this
    **    has been applied, all exponents greater than EXP_BIAS will
    **    represent powers of 2 that are +ve, and all exponents less
    **    than EXP_BIAS will represent powers of 2 that are -ve.
    **
    ** EXP_CONST1
    **    The exponent represents the scale of the most significant bit
    **    of the mantissa; the scale of the least significant bit can
    **    be determined by subtracting this constant from the exponent.
    **    It is set to 23 for single-precision floating-point numbers
    **    because there are 23 bits in the mantissa.
    **
    ** EXP_CONST2
    **    This constant is set to the value of x where (2^x) = 2147483648.
    **    Thus by adding EXP_CONST2 to the exponent of a floating-point
    **    single precision number, we are effectively multiplying it
    **    by 2147483648.0
    **
    ** EXP_ADJUST
    **    When this constant is subtracted from a (raw) exponent, we are
    **    effectively doing two things - we are [1] multiplying the argument
    **    by 2147483648.0 and then determining the scale of the least
    **    significant bit if the result. We then use this value to shift
    **    the floating-point mantissa into a fixed-point, fract32 value.
    */


.text;
        .align 2;

        .global _float_to_fr16

_float_to_fr16:

    /*  Extract the exponent from X and check it is not greater than 1.0 */

        R1.L = 0x1708;            /* Load EXTRACT mask                      */

        // Anomaly 05-00-0209 says that neither register that is read by
        // the EXTRACT instruction may be created by the previous instruction
        // - so work around the anomaly by inserting a useful instruction.
        // (which in this case is the binary exponent of 1.0)
        R3 = 127;

        R2 = EXTRACT(R0,R1.L) (Z);
        CC = R3 <= R2;            /* Compare exponent of 1.0 and of X       */

        IF CC JUMP .saturate;     /* Jump away to saturate if abs(x) >= 1.0 */

                /* Note: we will also jump if the argument is a NaN or Inf */

    /*  Check if X is (effectively) Zero */

        CC = R2 == 0;             /* Test if the exponent is zero */
        IF CC JUMP .return_zero;
                /* If the exponent is zero, the either the argument is +0.0
                ** or -0.0 or a denormalized number - in all three cases we
                ** will return zero.
                */

    /*  Determine Shift Amount for the Mantissa */

        R1 = EXP_ADJUST;
        R2 = R2 - R1;             /* shift amount = exponent - EXP_ADJUST */

        R3.L = 0x0017;
                /* This is initializing the 2nd operand for the EXTRACT
                ** instruction below - it has been moved away from the EXTRACT
                ** instruction to avoid Anomaly 05-00-0209 which requires
                ** that the instruction that precedes the EXTRACT instruction
                ** must not create one of its operands
                */

        R1 = -32;
        R2 = MAX(R2,R1);
                /* Clip the shift magnitude. There is no need to do a
                ** clip of R2 to +31 because if R2 > 31 at this point
                ** the C standard says the behaviour is undefined.
                */

    /*  Extract the Mantissa from X */

        R3 = EXTRACT(R0,R3.L) (Z);
        BITSET(R3,23);              /* Add the hidden bit to the mantissa */

    /*  and Apply the Shift Amount */

        CC = R0 < 0;                /* Set CC if the argument is negative */
        R0 = ASHIFT R3 BY R2.L (S);

        R1 = -R0;
        IF CC R0 = R1;

        R0 >>>= 16;                 /* Truncate a fract32 to a fract16    */
        RTS;

.saturate:
    /* Handle extremes via Saturation */

        CC = R0 <= 0;           /* Test whether the parameter is positive  */

        R0 = R3 << 31;          /* Generate 0x80000000 (from 127)          */
        R1 = ABS R0;            /* Generate 0x7fffffff from 0x80000000     */
        IF !CC R0 = R1;         /* which we return if the parameter is +ve */

        R0 >>>= 16;             /* Truncate a fract32 to a fract16         */
        RTS;

.return_zero:
    /* Return a Zero */

        R0 = 0;
        RTS;

.size _float_to_fr16, .-_float_to_fr16

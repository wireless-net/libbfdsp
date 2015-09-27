/************************************************************************
 *
 * sinf
 *
 * Copyright (C) 2001-2006 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =sinf")
#pragma file_attr("libFunc  =__sinf")
#pragma file_attr("libFunc  =sin")

    /* Called by polarf */
#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =polarf")
#pragma file_attr("libFunc  =__polarf")
#pragma file_attr("libFunc  =polar")

    /* Called by cexpf */
#pragma file_attr("libFunc  =cexpf")
#pragma file_attr("libFunc  =__cexpf")
#pragma file_attr("libFunc  =cexp")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#endif

#include <math.h>

#include "util.h"
#include "math_const.h"

/*____________________________________________________________________________

  Func name   : sin.c

  Purpose     : Computes sinf(x) using 32-bit floating-point arithmetic.
  Description : The algorithm used to implement this function is adapted from
                Cody & Waite, "Software Manual for the Elementary Functions",
                Prentice-Hall, New Jersey, 1980.

                If x is an IEEE NaN or an IEEE Infinity, then sinf will
                return a NaN.

                If x is a denormalized number or 0.0, then sinf will
                return 0.0

                If x is outside the defined domain (see below) then sinf
                will return 0.0

  Domain      : x = [-102940.0 .. 102940.0]       (==  2^15 * PI)

  Accuracy    : Relative error:
                  * Primary range (-PI/2 to PI/2) - 1 bits of error or less
                  * Outside primary range         - 1 bits of error or less
                Assumption: there is no error in the input value

  Note        : This source assumes that floating-point arithmetic is
                emulated in software.
  ____________________________________________________________________________
*/

    /* Definitions */

#define EXP_MASK	0X7F800000


FLOAT
_sinf(FLOAT x)
{

    FLOAT xn;       /* Cody and Waite Variables */
    FLOAT f, g;
    FLOAT result;

    FLOAT x_int;    /* integral value of x   */
    FLOAT x_fract;  /* fractional value of x */

    LONG exp;       /* copy of x with just an exponent */
    LONG n;
    INT  sign = 0;  /* set 1 if x is -ve */

    const FLOAT NaN    = 0x1.002468p+128; /* (this is 0x7fc01234) */
    const FLOAT domain = SIN32_X_MAX;

    const LONG *const domain_ptr = (LONG *)(&domain);
         /* use *domain_ptr to access domain as a LONG */

    LONG  *const x_ptr = (LONG *)(&x);
         /* use *x_ptr to access x as a LONG */

    /* Make x positive */

    if (*x_ptr < 0)
    {
        x    = -x;
        sign =  1;
    }

    /*
    ** Classify x as one of:
    **
    **    an IEEE NaN           (exponent = 0x7f800000 - mantissa != 0)
    **    an IEEE Infinity      (exponent = 0x7f800000 - mantissa == 0)
    **    a denormalized number (exponent = 0          - mantissa != 0)
    **    0.0                   (exponent = 0          - mantissa == 0)
    */

    exp = *x_ptr & EXP_MASK;
    if (exp == EXP_MASK)
        return NaN;             /* when x is a NaN or a Inf */

    if (exp == 0)
        return 0.0F;            /* when x is a denorm or 0.0 */

    /*
    ** Check whether x is outside the defined domain
    **
    **    The defined domain is (2^15 * PI)
    */

    if (*x_ptr > *domain_ptr)
        return 0.0F;

    /* Calculate the nearest integer to x/PI */

    n  = TO_LONG(ADD(MPY(x, (FLOAT)INV_PI), 0.5F));
    xn = TO_FLOAT(n);

    /* Split x into x_int and x_fract for better argument reduction */

    x_int = TO_FLOAT(TO_LONG(x));
    x_fract = SUB(x, x_int);

    /* Calculate f = ((X_int - (XN*C1)) +  X_fract) - (XN*C2) */

    f = SUB(x_int, MPY(xn, PI_C1));
    f = ADD(f, x_fract);
    f = SUB(f, MPY(xn, PI_C2));
    f = SUB(f, MPY(xn, PI_C3));

        /* Note that PI_C2 + PI_C3 == C2 */

    if (fabsf(f) >= EPS_FLOAT)
    {
        /* Calculate g = f * f */

        g = MPY(f, f);

        /*
        ** Compute sine approximation on reduced argument
        **
        **    Result = ((((g * C4 + C3) * g + C2) * g + C1) * g) * f + f
        */

        result = MPY(g, SINF_COEF4);
        result = ADD(result, SINF_COEF3);
        result = MPY(result, g);
        result = ADD(result, SINF_COEF2);
        result = MPY(result, g);
        result = ADD(result, SINF_COEF1);
        result = MPY(result, g);

        result = MPY(result, f);
        f = ADD(result, f);
    }

    /*
    ** Determine the sign of the result
    **
    **    result is +ve if x is +ve and an even multiple of PI
    **           is -ve if   is +ve     an odd  multiple of PI
    **           is -ve if x is -ve and an even multiple of PI
    **           is +ve if   is -ve     an odd  multiple of PI
    */

    if ((n & 1) ^ sign)
        f = -f;

    /* Return result */

    return f;

}

/* end of file */

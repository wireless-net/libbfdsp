/************************************************************************
 *
 * powd.c
 *
 * Copyright (C) 2004 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ************************************************************************/

/*
 * Description :  This file contains the 64-bit implementation of pow().
 *                This function computes x^y using 64-bit float precision.
 *                The algorithm used to implement this function is adapted
 *                from Cody & Waite, "Software Manual for the Elementary
 *                Functions", Prentice-Hall, New Jersey, 1980.
 *
 *                Domain      : x = Full Range, y = Full Range
 *                                when x < 0, then |y| = 1.0, 2.0, 3.0, ...
 *                                NOT x = 0, y < 0
 *
 *                                For x < 0, |y| != 1.0, 2.0, ... ,
 *                                  this function returns 0.0.
 *                                For x = 0, y < 0,
 *                                  this function returns 1.7e308.
 *                                For x^y > 1.7e308,
 *                                  this function returns 1.7e308.
 *                                For x^y < -1.7e308,
 *                                  this function returns -1.7e308.
 *
 *                Accuracy    : 6 bits of error or less over entire range
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =powd")
#pragma file_attr("libFunc  =__powd")     //from math_bf.h
#pragma file_attr("libFunc  =powl")       //from math_bf.h
#pragma file_attr("libFunc  =pow")        //from math_bf.h

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "math_const.h"
#include "util.h"


DOUBLE                            /*{ ret - powd(x, y) }*/
powd
(
  DOUBLE x,                       /*{ (i) - base       }*/
  DOUBLE y                        /*{ (i) - power      }*/
)
{
    DOUBLE tmp;
    DOUBLE znum, zden, result;
    DOUBLE g, r, u1, u2, v, z;
    LONG m, p, negate, n;
    LONG mi, pi, iw1;
    DOUBLE y1, y2, w1, w2, w;
    DOUBLE *a1, *a2;
    DOUBLE xtmp;
    LONG *lPtr = (LONG *)&xtmp;
    DOUBLE *fPtr = &xtmp;
    static const LONG a1l[][2] =  
                           {{0,          0         },   /* 0.0 */
                            {0x00000000, 0x3ff00000},   /* 1.0 */
                            {0xa2a490d9, 0x3feea4af},   /* 0.9576032757759... */
                            {0xdcfba487, 0x3fed5818},   /* 0.9170039892197... */
                            {0xdd85529c, 0x3fec199b},   /* 0.8781260251999... */
                            {0x995ad3ad, 0x3feae89f},   /* 0.8408963680267... */
                            {0x82a3f090, 0x3fe9c491},   /* 0.8052451610565... */
                            {0x422aa0db, 0x3fe8ace5},   /* 0.7711054086685... */
                            {0x73eb0186, 0x3fe7a114},   /* 0.7384130358696... */
                            {0x667f3bcc, 0x3fe6a09e},   /* 0.7071067690849... */
                            {0xdd485429, 0x3fe5ab07},   /* 0.6771277189255... */
                            {0xd5362a27, 0x3fe4bfda},   /* 0.6484197378159... */
                            {0x4c123422, 0x3fe3dea6},   /* 0.6209288835526... */
                            {0x0a31b715, 0x3fe306fe},   /* 0.5946035385132... */
                            {0x6e756238, 0x3fe2387a},   /* 0.5693942904472... */
                            {0x3c7d517a, 0x3fe172b8},   /* 0.5452538132668... */
                            {0x6cf9890f, 0x3fe0b558},   /* 0.5221368670464... */
                            {0x00000000, 0x3fe00000}};  /* 0.5 */

    static const LONG a2l[][2] =  
                           {{0         , 0         },
                            {0x74320000, 0x3c90b1ee},
                            {0x89500000, 0x3c711065},
                            {0xb0700000, 0x3c6c7c46},
                            {0x047f0000, 0x3c9afaa2},
                            {0x05460000, 0x3c86324c},
                            {0x11f00000, 0x3c7ada09},
                            {0xb6c80000, 0x3c89b07e},
                            {0x4adc0000, 0x3c88a62e}};

    a1 = (DOUBLE *)a1l;
    a2 = (DOUBLE *)a2l; 
    negate = 0;

    /*{ if x == 0, compute 0^y }*/
    if (x == 0.0L)
    {
        /*{ if y == 0, return 0^0 = 1.0 }*/
        if (y == 0.0L)
        {
            return 1.0L;
        }
        /*{ else if (y > 0), return 0^y = 0.0 }*/
        else if (y > 0.0L)
        {
            return 0.0L;
        }
        /*{ else (y < 0), return 1/0^y = 1.7e308 }*/
        else
        {
            return LDBL_MAX;
        }
    }
    /*{ else if x < 0, compute -|x|^y }*/
    else if (x < 0.0L)
    {
        modfd(y, &tmp);
        /*{ if (y is not an integer power), return 0.0 }*/
        if (tmp != y)
        {
            return 0.0L;
        }

        /*{ x = |x| }*/
        x = -x;
        /*{ negate = 1 if y is odd }*/
        negate = 0;
        if (modfd(DIVD(y, 2.0L), &tmp) != 0.0L)
        {
            negate = 1;
        }
    }

    /*{ at this point, x = |x|, now compute x^y }*/
    xtmp = x;
    
    /*{ m = exponent part of x }*/
    m = lPtr[1] >> 20;
    m = m - 1022;

    /*{ g = fractional part of x }*/
    /* g = setxp(x, 0) -- done by setting exponent to 1022 */
    lPtr[1] = (lPtr[1] & 0x800fffff) | (1022 << 20);
    g = *fPtr;

    /*{ determine p using binary search }*/
    /*{!INDENT}*/
    /*{ p = 1 }*/
    p = 1;
    /*{ if (g <= A1[9]), then p = 9 }*/
    if (g <= a1[9])
    {
        p = 9;
    }
    /*{ if (g <= A1[p+4], then p = p + 4 }*/
    if (g <= a1[p + 4])
    {
        p = p + 4;
    }
    /*{ if (g <= A1[p+2], then p = p + 2 }*/
    if (g <= a1[p + 2])
    {
        p = p + 2;
    }
    /*{!OUTDENT}*/

    p = p + 1;

    /*{ determine z = 2 * znum / zden }*/
    /*{!INDENT}*/
    /*{ znum = g - A1[p+1] - A2[(p+1)/2] }*/
    znum = SUBD(g, a1[p]);
    znum = SUBD(znum, a2[p >> 1]);

    /*{ zden = g + A1[p+1] }*/
    zden = ADDD(g, a1[p]);
    /*{!OUTDENT}*/

    p = p - 1;

    z = DIVD(znum, zden);
    z = ADDD(z, z);

    /* At this point, |z| < 0.044 */

    /*{ v = z * z }*/
    v = MPYD(z, z);

    /*{ Compute R(z)) = (((p4 * v + p3) * v + p2) * v + p1) * v * z }*/
    r = MPYD(POWDP_COEF4, v);
    r = ADDD(r, POWDP_COEF3);
    r = MPYD(r, v);
    r = ADDD(r, POWDP_COEF2);
    r = MPYD(r, v);
    r = ADDD(r, POWDP_COEF1);
    r = MPYD(r, v);
    r = MPYD(r, z);
    
    /*{ u2 = (z + R)&log2(e) }*/
    /* Using higher precision calculation */
    r = ADDD(r, MPYD(LOG2E_MINUS1, r));
    u2 = MPYD(LOG2E_MINUS1, z);
    u2 = ADDD(r, u2);
    u2 = ADDD(u2, z);

    /*{ U1 = (float)(m*16 - p)/16 }*/
    u1 = TO_DOUBLE((m * 16) - p);
    u1 = MPYD(u1, 0.0625);

    /*{ y1 = REDUCE(y) }*/
    REDUCE_DOUBLE(y, y1);

    /*{ y2 = y - y1 }*/
    y2 = SUBD(y, y1);

    /*{ w = u2*y + u1*y2 }*/
    w = MPYD(u1, y2);
    tmp = MPYD(u2, y);
    w = ADDD(tmp, w);

    /*{ w1 = reduce(w) }*/
    REDUCE_DOUBLE(w, w1);

    /*{ w2 = w - w1 }*/
    w2 = SUBD(w, w1);

    /*{ w = w1 + u1*y1 }*/
    w = MPYD(u1, y1);
    w = ADDD(w, w1);

    /*{ w1 = reduce(w) }*/
    REDUCE_DOUBLE(w, w1);

    /*{ w2 = w2 + (w - w1) }*/
    tmp = SUBD(w, w1);
    w2 = ADDD(w2, tmp);

    /*{ w = REDUCE(w2) }*/
    REDUCE_DOUBLE(w2, w);

    /*{ iw1 = INT(16 * (w1+w)) }*/
    tmp = ADDD(w1, w);
    tmp = MPYD(16.0L, tmp);
    iw1 = TO_LONG(tmp);

    /*{ w2 = w2 - w }*/
    w2 = SUBD(w2, w);

    /*{ if iw1 > INT(16*log2(FLT_MAX) - 1), return +-3.8e34 }*/
    if (iw1 > POWDOUBLE_BIGNUM)
    {
        result = LDBL_MAX;
        if (negate == 1)
        {
            result = -result;
        }
        return result;
    }

    /*{ if w2 > 0 then w2 = w2 - 1/16 and iw1 = iw1 + 1 }*/
    if (w2 > 0.0L)
    {
        w2 = SUBD(w2, 0.0625L);
        iw1++;
    }

    /*{ if iw1 < INT(16*log2(FLT_MIN) + 1), return 0.0 }*/
    if (iw1 < POWDOUBLE_SMALLNUM)
    {
        return 0.0L;
    }

    /*{ form p', m' }*/
    if (iw1 < 0)
    {
        mi = 0;
    }
    else
    {
        mi = 1;
    }
    n = iw1 / 16;
    mi = mi + n;
    pi = (mi * 16) - iw1;

    /*{ evaluate 2^w2 - 1 using min-max polynomial }*/
    /*{!INDENT}*/
    /*{ - z = ((((((q7 * w2 + q6) * w2 + q5) * w2 + q4) * w2 + q3) * w2 + 
                q2) * w2 + q1) * w2 }*/
    z = MPYD(POWDQ_COEF7, w2);
    z = ADDD(z, POWDQ_COEF6);
    z = MPYD(z, w2);
    z = ADDD(z, POWDQ_COEF5);
    z = MPYD(z, w2);
    z = ADDD(z, POWDQ_COEF4);
    z = MPYD(z, w2);
    z = ADDD(z, POWDQ_COEF3);
    z = MPYD(z, w2);
    z = ADDD(z, POWDQ_COEF2);
    z = MPYD(z, w2);
    z = ADDD(z, POWDQ_COEF1);
    z = MPYD(z, w2);
    /*{!OUTDENT}*/

    /*{ z = (z + 1)*2^(-pi/16) }*/
    z = MPYD(z, a1[pi + 1]);
    z = ADDD(a1[pi + 1], z);

    /*{ result = add exponent mi into z }*/
    fPtr = &z;
    lPtr = (LONG *)fPtr;
    n = (lPtr[1] >> 20) & 0xfff;   /* exponent of z */
    n = n - 1023;                  /* subtract exponent offset */
    mi = mi + n;                   /* add exponents */
    mi = mi + 1023;                /* add exponent offset */

    /* there is no need to check if max exponent exceeded */
    
    mi = mi & 0xfff;             /* mask exponent */
    lPtr[1] = lPtr[1] & (0x800fffff); /* add exponent back into number */
    lPtr[1] = lPtr[1] | mi << 20;

    result = *fPtr;

    /*{ if negate, result = -result }*/
    if (negate)
    {
        result = -result;
    }

    /*{ return result }*/
    return result;
}

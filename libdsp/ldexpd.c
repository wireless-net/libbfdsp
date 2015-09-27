/************************************************************************
 *
 * ldexpd.c
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
 * Description :   This function computes x * (2 ^ expo) for 64-bit
 *                 floating point numbers.
 *
 *                 Domain      : Full Range
 *                                 If the result overflows, Inf is returned
 *                                 If the result underflows, 0.0 is returned
 *                 Accuracy    : 0 bits in error.
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =ldexpd")
#pragma file_attr("libFunc  =__ldexpd")
#pragma file_attr("libFunc  =ldexpl")
#pragma file_attr("libFunc  =ldexp")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "util.h"


DOUBLE                            /*{ ret - ldexpd(x, expo) }*/
ldexpd
(
  DOUBLE c1,                      /*{ (i) - Input value c1  }*/
  int    expo                     /*{ (i) - Exponent        }*/
)
{
  int                 xexp, xsign;
  unsigned long long  mant;
  DOUBLE              x;

  xsign=((*(unsigned long long *)(&c1))>>(63))&1;
  xexp =((*(unsigned long long *)(&c1))>>(52))&0x7ff;
  mant =((*(unsigned long long *)(&c1))&0xFFFFFFFFFFFFF);

  /* if 0, return 0; if Nan, return Nan */
  if (xexp==0) 
    return(0);
  else if (xexp==2047) 
    return(c1);

  /* adjust exponent */
  xexp+=expo;

  /* if too big, set to INF; too small, set to ZERO */
  if (xexp>2046)
  {
    xexp=0x7FF;
    mant=0;
  }
  else if (xexp<0)
  {
    xexp=0;
    mant=0;
  }

  /* recompose double */
  *((unsigned int*)&x)  =(unsigned int) mant;
  *((unsigned int*)&x+1)=(xsign<<31)+(((unsigned int) xexp)<<20)+
                                       (unsigned int)(mant>>(32));

  return(x);
}

/************************************************************************
 *
 * fmind.c
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
 * Description :   Find minimum value of two long double inputs
 *                 The function fmin(x,y) returns  x,  if x < y
 *                                                 y,  otherwise
 *
 *                 Domain      : Full Range
 *                 Accuracy    : 0 bits in error.
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libGroup =math_bf.h")
#pragma file_attr("libFunc  =__fmind")
#pragma file_attr("libFunc  =fmind")
#pragma file_attr("libFunc  =fmin")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "util.h"

DOUBLE                            /*{ ret - fmind(x,y)    }*/
fmind
(
  DOUBLE x,                       /*{ (i) - Input value x }*/
  DOUBLE y                        /*{ (i) - Input value y }*/ 
)
{
      return ( x < y ? x : y );    
}


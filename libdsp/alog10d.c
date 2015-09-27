/************************************************************************
 *
 * alog10d.c
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
 * Description    : This file contains the 64-bit implementation of alog10().
 *                  The function calculates the base-10 anti-log of its 
 *                  argument. 
 *
 *                  Domain      : domain of exp / log(10.0)
 *                  Notes       : An anti-log function performs the reverse of
 *                                a log function and is therefore equivalent 
 *                                to an exponentation operation.
 *                                    
 *                                Thus alog10f(x) === 10 ^ x
 *                                                === exp(x * log(10.0))
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libGroup =math_bf.h")
#pragma file_attr("libFunc  =__alog10d")
#pragma file_attr("libFunc  =alog10d")
#pragma file_attr("libFunc  =alog10")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "math_const.h"
#include "util.h"


DOUBLE                            /*{ ret - acosd(x)       }*/
alog10d
(
  DOUBLE x                        /*{ (i) - input value x  }*/
)
{
    /*{ return result }*/
    return expd(x * LOGE_10);
}

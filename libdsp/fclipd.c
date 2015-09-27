/************************************************************************
 *
 * fclipd.c
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
 * Description :   Clip a value x if it exceeds the absolute maximum boundary.
 *                 The function returns the maximum boundary, if x too large
 *                 |x| * sign( maximum boundary), otherwise.
 *
 *                 Domain      : Full Range
 *                 Accuracy    : 0 bits in error.
 */

#pragma file_attr("libGroup =math.h")
#pragma file_attr("libGroup =math_bf.h")
#pragma file_attr("libFunc  =__fclipd")
#pragma file_attr("libFunc  =fclipd")
#pragma file_attr("libFunc  =fclip")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

/* Defined in */
#include <math.h>

#include "util.h"


DOUBLE                            /*{ ret - fclipd(x)                }*/
fclipd
(
  DOUBLE  max_val,                /*{ (i) - Input `maximum boundary` }*/
  DOUBLE  x                       /*{ (i) - Input `x`                }*/
)
{
      DOUBLE  abs_max_val, abs_x;

      abs_max_val = fabsd(max_val);
      abs_x       = fabsd(x);

      if( abs_max_val < abs_x )
      {
        return max_val;
      }
      else
      {
        return ( max_val < 0 ? -abs_x : abs_x );
      }
}


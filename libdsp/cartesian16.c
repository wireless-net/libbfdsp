/***************************************************************************
 *
 * cartesian16.c
 *
 * Copyright (C) 2003 Analog Devices, Inc.
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License. See the file COPYING.LIB for more details.
 *
 * Non-LGPL License is also available as part of VisualDSP++
 * from Analog Devices, Inc.
 *
 ***************************************************************************/

/* This function converts a complex number 
   from cartesian to polar notation. 
 */

#pragma file_attr("libGroup =complex_fns.h")
#pragma file_attr("libFunc  =__cartesian_fr16")
#pragma file_attr("libFunc  =cartesian_fr16")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <complex_fns.h>

fract16 _cartesian_fr16 ( complex_fract16 a, fract16* phase )
{
   *phase = arg_fr16(a);      /* compute phase     */
   return( cabs_fr16(a) );    /* compute magnitude */
}


// Copyright (C) 2000-2006 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/******************************************************************************
  Func name   : gen_vonhann_fr16

  Purpose     : Calculate Vonhann Window.
  Description : This function generates a vector containing the Hanning window. 
                The length is specified by parameter `N`.

*******************************************************************************/

#if !defined(__NO_LIBRARY_ATTRIBUTES__)

#pragma file_attr ("libGroup=window.h")
#pragma file_attr ("libName=libdsp")

#pragma file_attr ("libFunc=gen_vonhann_fr16")
#pragma file_attr ("libFunc=__gen_vonhann_fr16")

#pragma file_attr ("prefersMem=external")
#pragma file_attr ("prefersMemNum=70")
	/* (Use prefersMem=external because the function
	**  is usually called no more than once)
	*/
#endif

#include <math.h>
#include <window.h>
#include <fract.h>

void
gen_vonhann_fr16(
    fract16 w[],      /* Window array `w` */
    int a,            /* Address stride   */
    int n             /* Window length    */
)
{
  gen_hanning_fr16(w,a,n);
}

/*end of file*/

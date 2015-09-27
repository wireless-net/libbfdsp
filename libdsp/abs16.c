// Copyright (C) 2004 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/********************************************************************
   File Name      : abs16.c

   Description    : Returning the absolute value 
                    of a fractional number

********************************************************************/

#pragma file_attr("libGroup =fract.h")
#pragma file_attr("libGroup =fract_math.h")
#pragma file_attr("libGroup =math_bf.h")
#pragma file_attr("libGroup =math.h")
#pragma file_attr("libFunc  =__abs_fr16")
#pragma file_attr("libFunc  =abs_fr16")

#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")


#include <fract.h>
#include <math.h>

fract16 _abs_fr16(fract16 x)
{
    fract16 result; 

    /* Returns the 16-bit value that is the absolute value 
       of the input parameter. 
       Where the input is 0x8000, saturation occurs
       and 0x7fff is returned. 
    */
    if (x >= 0)
    {
       result = x;
    }
    else if ((x < 0) && (x > 0xffff8000))
    {
       result = -x;
    }
    else
    {
       result = 0x7fff;
    }

    /*{ return result }*/
    return result;
}

/*end of file*/

// Copyright (C) 2000, 2001 Analog Devices, Inc.
// This file is subject to the terms and conditions of the GNU Lesser
// General Public License. See the file COPYING.LIB for more details.
//
// Non-LGPL License is also available as part of VisualDSP++
// from Analog Devices, Inc.

/****************************************************************************
   File: vecmaxf.c
 
   Returns maximum value stored in input vector a
    
***************************************************************************/

#pragma file_attr("libGroup =vector.h")
#pragma file_attr("libFunc  =vecmaxf")
#pragma file_attr("libFunc  =__vecmaxf")
#pragma file_attr("libFunc  =vecmax")      // from vector.h
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#include <vector.h>

float _vecmaxf(const float a[],int n)
{
	float max;	
	int i;

 	if( n<= 0 )
		return 0.0;  //as done for fract16

	max = a[0];
	for(i=1;i<n;i++)
	{
		if(a[i]>max)
		{
			max = a[i];
		}
	}
   
        return max;
}

/*end of file*/

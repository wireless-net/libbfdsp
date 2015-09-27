/* Copyright (C) 2000 Analog Devices, Inc.
** This file is subject to the terms and conditions of the GNU Lesser
** General Public License. See the file COPYING.LIB for more details.
**
** Non-LGPL License is also available as part of VisualDSP++
** from Analog Devices, Inc.
*/
/*
 * Convert floating point to unsigned int.
 * XXX doesn't recognise +-inf, or NaN.
 */

#pragma file_attr("libGroup =integer_support")
#pragma file_attr("libGroup =floating_point_support")
#pragma file_attr("libFunc  =___trncr4u4")
#pragma file_attr("libName =libdsp")
#pragma file_attr("prefersMem =internal")
#pragma file_attr("prefersMemNum =30")

#define Nm 23
unsigned int __trncr4u4(float f)
{
	union {	float f; unsigned int u; } u;
	unsigned int E, S, M, m;
	int e, i, n, ne;

	u.f = f;
	S = (u.u & 1<<31)>>31;
	M = u.u & 0x7fffff; /* ((1<<Nm)-1) */
	E = (u.u >> Nm) & 0xff;

	e = (int)E - 127;

	/* check for all fractional, or for Zero value */
	if (e < 0 || (M==0 && E==0))
		return 0;
	m = M << 9;	/* Move up to MSBs */
	i = 1<<e;

	ne = e - 1;
	for (n = 1; m && n <= Nm && n <= e; n++, ne--, m <<= 1)
		if (m & (1<<31))
			i |= 1<<ne;
		return i;	/* or return S? -i : i; if float->int */
}

# a_fix_linkage_name.sed
#
# Copyright (C) 2007 Analog Devices, Inc.
# Written by Jie Zhang  <jie.zhang@analog.com>
#
# This file is subject to the terms and conditions of the GNU General  
# Public License, either version 2, or (at your option) any later version.
# See the file COPYING for more details.
#
#
# This scipt transform VDSP linkage_name pragma into GCC asm () syntax.
#
# For an example,
#
# #pragma linkage_name __cabsf
#         float cabsf (complex_float _a);
#
# is tranformed to
#
#         float cabsf (complex_float _a) asm ("__cabsf");
#
# For another example,
#
# #ifdef __DOUBLES_ARE_FLOATS__
# #pragma linkage_name __cabsf
# #else
# #pragma linkage_name __cabsd
# #endif
#         double cabs (complex_double _a);
#
# is transformed to
#
# #ifdef __DOUBLES_ARE_FLOATS__
#         double cabs (complex_double _a) asm ("__cabsf");
# #else
#         double cabs (complex_double _a) asm ("__cabsd");
# #endif
#

/^#if[d 	]/{
:again1
N
/\n[ 	]*$/bagain1
:again2
N
/\n[ 	]*$/bagain2
/\n#pragma[ 	]*linkage_name.*\n*#endif/bprocess1
/\n#pragma[ 	]*linkage_name.*\n*#el/bprocess2
bend
:process1
:again3
N
/\n[ 	]*$/bagain3
s/^\(#if[d 	].*\)\n*#pragma[ 	]*linkage_name[ 	]*\([a-zA-Z0-9_]*\)[ 	]*\n*#endif[ 	]*\n*\(.*\);/\1\3 asm ("\2");\n#endif/
tend
bprocess1
:process2
:again4
N
/\n[ 	]*$/bagain4
:again5
N
/\n[ 	]*$/bagain5
:top
:again6
N
/\n[ 	]*$/bagain6
s/^\(#if[d 	].*\)\n*#pragma[ 	]*linkage_name[ 	]*\([a-zA-Z0-9_]*\)[ 	]*\n*\(#el.*\)\n*#pragma[ 	]*linkage_name[ 	]*\([a-zA-Z0-9_]*\)[ 	]*\n*#endif[ 	]*\n*\(.*\);/\1\5 asm ("\2");\n\3\5 asm ("\4");\n#endif/
tend
btop
:end
}

/#pragma[ 	]*linkage_name/{
:top2
s/#pragma[ 	]*linkage_name[ 	]*\([a-zA-Z0-9_]*\)[ 	]*\n*\(.*\);/\2 asm ("\1");/
tend2
:again7
N
/\n[ 	]*$/bagain7
btop2
:end2
}


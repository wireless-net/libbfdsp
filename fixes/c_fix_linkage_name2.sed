# fix_linkage_name2.sed
#
# Copyright (C) 2007 Analog Devices, Inc.
# Written by Jie Zhang  <jie.zhang@analog.com>
#
# This file is subject to the terms and conditions of the GNU General  
# Public License, either version 2, or (at your option) any later version.
# See the file COPYING for more details.
#
#
# This scipt transform VDSP linkage_name _Pragma into GCC asm () syntax.
#
# For an example,
#
# #if !defined(__DOUBLES_ARE_FLOATS__)
#                _Pragma("linkage_name __snprintf64")
# #endif
# int snprintf(char *_s, size_t _n, const char *_format, ...);
#
# is transformed to
#
# #if !defined(__DOUBLES_ARE_FLOATS__)
#                int snprintf(char *_s, size_t _n, const char *_format, ...) asm ("__snprintf64");
# #endif

/^#if[d 	]/{
:again1
N
/\n[ 	]*$/bagain1
:again2
N
/\n[ 	]*$/bagain2
/\n[ 	]*_Pragma[ 	]*("linkage_name.*\n*#endif/bprocess1
/\n[ 	]*_Pragma[ 	]*("linkage_name.*\n*#el/bprocess2
bend
:process1
:again3
N
/\n[ 	]*$/bagain3
s/^\(#if[d 	].*\)\n*[ 	]*_Pragma[ 	]*("linkage_name[ 	]*\([a-zA-Z0-9_]*\)"[ 	]*)[ 	]*\n*#endif[ 	]*\n*\(.*\);/\1\3 asm ("\2");\n#endif/
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
s/^\(#if[d 	].*\)\n*[ 	]*_Pragma[ 	]*("linkage_name[ 	]*\([a-zA-Z0-9_]*\)"[ 	]*)[ 	]*\n*\(#el.*\)\n*[ 	]*_Pragma[ 	]*("linkage_name[ 	]*\([a-zA-Z0-9_]*\)"[ 	]*)[ 	]*\n*#endif[ 	]*\n*\(.*\);/\1\5 asm ("\2");\n\3\5 asm ("\4");\n#endif/
tend
btop
:end
}

/_Pragma[ 	]*("linkage_name/{
:top2
s/_Pragma[ 	]*("linkage_name[ 	]*\([a-zA-Z0-9_]*\)"[ 	]*)[ 	]*\n*\(.*\);/\2 asm ("\1");/
tend2
:again7
N
/\n[ 	]*$/bagain7
btop2
:end2
}


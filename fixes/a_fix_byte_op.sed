# a_fix_byte_op.sed
#
# Copyright (C) 2007 Analog Devices, Inc.
# Written by Jie Zhang  <jie.zhang@analog.com>
#
# This file is subject to the terms and conditions of the GNU General  
# Public License, either version 2, or (at your option) any later version.
# See the file COPYING for more details.
#
#
# This scipt transform VDSP .byte directives into GAS ones


s/\.[Bb][Yy][Tt][Ee][ 	]*=[ 	]*\(.*;\)[ 	]*$/.byte \1/
s/\.[Bb][Yy][Tt][Ee]2[ 	]*=[ 	]*\(.*;\)[ 	]*$/.short \1/
s/\.[Bb][Yy][Tt][Ee]4[ 	]*=[ 	]*\(.*;\)[ 	]*$/.long \1/

s/\.[Bb][Yy][Tt][Ee][ 	]*\([_a-zA-Z0-9.]*\)[ 	]*=[ 	]*\(.*;\)[ 	]*$/	.type	\1, @object\n	.size	\1, 1\n\1:\n	.byte \2/
s/\.[Bb][Yy][Tt][Ee]2[ 	]*\([_a-zA-Z0-9.]*\)[ 	]*=[ 	]*\(.*;\)[ 	]*$/	.type	\1, @object\n	.size	\1, 2\n\1:\n	.short \2/
s/\.[Bb][Yy][Tt][Ee]4[ 	]*\([_a-zA-Z0-9.]*\)[ 	]*=[ 	]*\(.*;\)[ 	]*$/	.type	\1, @object\n	.size	\1, 4\n\1:\n	.long \2/

s/\.[Bb][Yy][Tt][Ee][ 	]*\([_a-zA-Z0-9.]*\)\[\(.*\)\][ 	]*=[ 	]*\(.*;\)[ 	]*$/	.type	\1, @object\n	.size	\1, \2\n\1:\n	.byte \3/
s/\.[Bb][Yy][Tt][Ee]2[ 	]*\([_a-zA-Z0-9.]*\)\[\(.*\)\][ 	]*=[ 	]*\(.*;\)[ 	]*$/	.type	\1, @object\n	.size	\1, (\2) * 2\n\1:\n	.short \3/
s/\.[Bb][Yy][Tt][Ee]4[ 	]*\([_a-zA-Z0-9.]*\)\[\(.*\)\][ 	]*=[ 	]*\(.*;\)[ 	]*$/	.type	\1, @object\n	.size	\1, (\2) * 4\n\1:\n	.long \3/


/\.[Bb][Yy][Tt][Ee][ 	]*=[ 	]*.*,[ 	]*$/{
s/\.[Bb][Yy][Tt][Ee][ 	]*=[ 	]*\(.*\),[ 	]*$/.byte \1;/
:NEXTB
n
s/^[ 	]*\(.*\),[ 	]*$/	.byte \1;/
tNEXTB
s/^[ 	]*\(.*\);[ 	]*$/	.byte \1;/
}

/\.[Bb][Yy][Tt][Ee]2[ 	]*=[ 	]*.*,[ 	]*$/{
s/\.[Bb][Yy][Tt][Ee]2[ 	]*=[ 	]*\(.*\),[ 	]*$/.short \1;/
:NEXTS
n
s/^[ 	]*\(.*\),[ 	]*$/	.short \1;/
tNEXTS
s/^[ 	]*\(.*\);[ 	]*$/	.short \1;/
}

/\.[Bb][Yy][Tt][Ee]4[ 	]*=[ 	]*.*,[ 	]*$/{
s/\.[Bb][Yy][Tt][Ee]4[ 	]*=[ 	]*\(.*\),[ 	]*$/.long \1;/
:NEXTL
n
s/^[ 	]*\(.*\),[ 	]*$/	.long \1;/
tNEXTL
s/^[ 	]*\(.*\);[ 	]*$/	.long \1;/
}

/\.[Bb][Yy][Tt][Ee][ 	]*[_a-zA-Z0-9.]*\[.*\][ 	]*=.*$/{
s/\.[Bb][Yy][Tt][Ee][ 	]*\([_a-zA-Z0-9.]*\)\[\(.*\)\][ 	]*=[ 	]*\(.*\),[ 	]*$/	.type	\1, @object\n	.size	\1, \2\n\1:	.byte \3;/
s/\.[Bb][Yy][Tt][Ee][ 	]*\([_a-zA-Z0-9.]*\)\[\(.*\)\][ 	]*=[ 	]*$/	.type	\1, @object\n	.size	\1, \2\n\1:/
:NEXTB2
n
s/^[ 	]*\(.*\),[ 	]*$/	.byte \1;/
tNEXTB2
s/^[ 	]*\(.*\);[ 	]*$/	.byte \1;/
}

/\.[Bb][Yy][Tt][Ee]2[ 	]*[_a-zA-Z0-9.]*\[.*\][ 	]*=.*$/{
s/\.[Bb][Yy][Tt][Ee]2[ 	]*\([_a-zA-Z0-9.]*\)\[\(.*\)\][ 	]*=[ 	]*\(.*\),[ 	]*$/	.type	\1, @object\n	.size	\1, (\2) * 2\n\1:	.short \3;/
s/\.[Bb][Yy][Tt][Ee]2[ 	]*\([_a-zA-Z0-9.]*\)\[\(.*\)\][ 	]*=[ 	]*$/	.type	\1, @object\n	.size	\1, (\2) * 2\n\1:/
:NEXTS2
n
s/^[ 	]*\(.*\),[ 	]*$/	.short \1;/
tNEXTS2
s/^[ 	]*\(.*\);[ 	]*$/	.short \1;/
}

/\.[Bb][Yy][Tt][Ee]4[ 	]*[_a-zA-Z0-9.]*\[.*\][ 	]*=.*$/{
s/\.[Bb][Yy][Tt][Ee]4[ 	]*\([_a-zA-Z0-9.]*\)\[\(.*\)\][ 	]*=[ 	]*\(.*\),[ 	]*$/	.type	\1, @object\n	.size	\1, (\2) * 4\n\1:	.long \3;/
s/\.[Bb][Yy][Tt][Ee]4[ 	]*\([_a-zA-Z0-9.]*\)\[\(.*\)\][ 	]*=[ 	]*$/	.type	\1, @object\n	.size	\1, (\2) * 4\n\1:/
:NEXTL2
n
s/^[ 	]*\(.*\),[ 	]*$/	.long \1;/
tNEXTL2
s/^[ 	]*\(.*\);[ 	]*$/	.long \1;/
}


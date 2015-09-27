# a_fix_file_attr_op.sed
#
# Copyright (C) 2007 Analog Devices, Inc.
# Written by Jie Zhang  <jie.zhang@analog.com>
#
# This file is subject to the terms and conditions of the GNU General  
# Public License, either version 2, or (at your option) any later version.
# See the file COPYING for more details.
#
#
# This scipt enclose VDSP specific .file_attr directives with
#   #if !defined(__NO_LIBRARY_ATTRIBUTES__)
# and
#   #endif
# .

/defined(__NO_LIBRARY_ATTRIBUTES__)/,/endif/!{
/^[ 	]*\.file_attr /{
i\
#if !defined(__NO_LIBRARY_ATTRIBUTES__)\

:next
n
/^[ 	]*\.file_attr /bnext
/^[ 	]*$/!{
/^\/\*.*\*\/$/!bend
}
n
/^[ 	]*\.file_attr /bnext
/^[ |___]*$/bend2
/^\/\*.*\*\/$/!bend2
:end
i\
\
#endif
bend3
:end2
i\
#endif\

:end3
}
}

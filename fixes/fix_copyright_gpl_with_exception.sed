# fix_copyright.sed
#
# Copyright (C) 2007 Analog Devices, Inc.
# Written by Jie Zhang  <jie.zhang@analog.com>
#
# This file is subject to the terms and conditions of the GNU General  
# Public License, either version 2, or (at your option) any later version.
# See the file COPYING for more details.
#
#
# This script edits the file to use LGPL as the Copyright.

/^Copyright/{
a\
This file is subject to the terms and conditions of the GNU General\
Public License. See the file COPYING for more details.\
\
In addition to the permissions in the GNU General Public License,\
Analog Devices gives you unlimited permission to link the\
compiled version of this file into combinations with other programs,\
and to distribute those combinations without any restriction coming\
from the use of this file.  (The General Public License restrictions\
do apply in other respects; for example, they cover modification of\
the file, and distribution when not linked into a combine\
executable.)\
\
Non-GPL License is also available as part of VisualDSP++\
from Analog Devices, Inc.
}

/^ Copyright/{
a\
 This file is subject to the terms and conditions of the GNU General\
 Public License. See the file COPYING for more details.\
\
 In addition to the permissions in the GNU General Public License,\
 Analog Devices gives you unlimited permission to link the\
 compiled version of this file into combinations with other programs,\
 and to distribute those combinations without any restriction coming\
 from the use of this file.  (The General Public License restrictions\
 do apply in other respects; for example, they cover modification of\
 the file, and distribution when not linked into a combine\
 executable.)\
\
 Non-GPL License is also available as part of VisualDSP++\
 from Analog Devices, Inc.
}

/^  Copyright/{
a\
  This file is subject to the terms and conditions of the GNU General\
  Public License. See the file COPYING for more details.\
\
  In addition to the permissions in the GNU General Public License,\
  Analog Devices gives you unlimited permission to link the\
  compiled version of this file into combinations with other programs,\
  and to distribute those combinations without any restriction coming\
  from the use of this file.  (The General Public License restrictions\
  do apply in other respects; for example, they cover modification of\
  the file, and distribution when not linked into a combine\
  executable.)\
\
  Non-GPL License is also available as part of VisualDSP++\
  from Analog Devices, Inc.
}

/^   Copyright/{
a\
   This file is subject to the terms and conditions of the GNU General\
   Public License. See the file COPYING for more details.\
\
   In addition to the permissions in the GNU General Public License,\
   Analog Devices gives you unlimited permission to link the\
   compiled version of this file into combinations with other programs,\
   and to distribute those combinations without any restriction coming\
   from the use of this file.  (The General Public License restrictions\
   do apply in other respects; for example, they cover modification of\
   the file, and distribution when not linked into a combine\
   executable.)\
\
   Non-GPL License is also available as part of VisualDSP++\
   from Analog Devices, Inc.
}

/^ \* Copyright/{
a\
 * This file is subject to the terms and conditions of the GNU General\
 * Public License. See the file COPYING for more details.\
 *\
 * In addition to the permissions in the GNU General Public License,\
 * Analog Devices gives you unlimited permission to link the\
 * compiled version of this file into combinations with other programs,\
 * and to distribute those combinations without any restriction coming\
 * from the use of this file.  (The General Public License restrictions\
 * do apply in other respects; for example, they cover modification of\
 * the file, and distribution when not linked into a combine\
 * executable.)\
 *\
 * Non-GPL License is also available as part of VisualDSP++\
 * from Analog Devices, Inc.
}

/^\/\/ Copyright/{
a\
// This file is subject to the terms and conditions of the GNU General\
// Public License. See the file COPYING for more details.\
//\
// In addition to the permissions in the GNU General Public License,\
// Analog Devices gives you unlimited permission to link the\
// compiled version of this file into combinations with other programs,\
// and to distribute those combinations without any restriction coming\
// from the use of this file.  (The General Public License restrictions\
// do apply in other respects; for example, they cover modification of\
// the file, and distribution when not linked into a combine\
// executable.)\
//\
// Non-GPL License is also available as part of VisualDSP++\
// from Analog Devices, Inc.
}

/^\*\* Copyright/{
a\
** This file is subject to the terms and conditions of the GNU General\
** Public License. See the file COPYING for more details.\
**\
** In addition to the permissions in the GNU General Public License,\
** Analog Devices gives you unlimited permission to link the\
** compiled version of this file into combinations with other programs,\
** and to distribute those combinations without any restriction coming\
** from the use of this file.  (The General Public License restrictions\
** do apply in other respects; for example, they cover modification of\
** the file, and distribution when not linked into a combine\
** executable.)\
**\
** Non-GPL License is also available as part of VisualDSP++\
** from Analog Devices, Inc.
}

/^	Copyright/{
a\
	This file is subject to the terms and conditions of the GNU General\
	Public License. See the file COPYING for more details.\
\
	In addition to the permissions in the GNU General Public License,\
	Analog Devices gives you unlimited permission to link the\
	compiled version of this file into combinations with other programs,\
	and to distribute those combinations without any restriction coming\
	from the use of this file.  (The General Public License restrictions\
	do apply in other respects; for example, they cover modification of\
	the file, and distribution when not linked into a combine\
	executable.)\
\
	Non-GPL License is also available as part of VisualDSP++\
	from Analog Devices, Inc.
}

/^\/\* Copyright/{
/^\/\*[ 	]*Copyright.*[ 	]*\*\/[ 	]*$/{
s|^/\*[ 	]*\(Copyright.*Inc\.\)[ 	]*\*/[ 	]*$|/\* \1|
a\
 * This file is subject to the terms and conditions of the GNU General\
 * Public License. See the file COPYING for more details.\
 *\
 * In addition to the permissions in the GNU General Public License,\
 * Analog Devices gives you unlimited permission to link the\
 * compiled version of this file into combinations with other programs,\
 * and to distribute those combinations without any restriction coming\
 * from the use of this file.  (The General Public License restrictions\
 * do apply in other respects; for example, they cover modification of\
 * the file, and distribution when not linked into a combine\
 * executable.)\
 *\
 * Non-GPL License is also available as part of VisualDSP++\
 * from Analog Devices, Inc.\
 */
bend
}
n
/\*\* .*/i\
** This file is subject to the terms and conditions of the GNU General\
** Public License. See the file COPYING for more details.\
**\
** In addition to the permissions in the GNU General Public License,\
** Analog Devices gives you unlimited permission to link the\
** compiled version of this file into combinations with other programs,\
** and to distribute those combinations without any restriction coming\
** from the use of this file.  (The General Public License restrictions\
** do apply in other respects; for example, they cover modification of\
** the file, and distribution when not linked into a combine\
** executable.)\
**\
** Non-GPL License is also available as part of VisualDSP++\
** from Analog Devices, Inc.
/\*\//i\
** This file is subject to the terms and conditions of the GNU General\
** Public License. See the file COPYING for more details.\
**\
** In addition to the permissions in the GNU General Public License,\
** Analog Devices gives you unlimited permission to link the\
** compiled version of this file into combinations with other programs,\
** and to distribute those combinations without any restriction coming\
** from the use of this file.  (The General Public License restrictions\
** do apply in other respects; for example, they cover modification of\
** the file, and distribution when not linked into a combine\
** executable.)\
**\
** Non-GPL License is also available as part of VisualDSP++\
** from Analog Devices, Inc.
/ \* .*/i\
 * This file is subject to the terms and conditions of the GNU General\
 * Public License. See the file COPYING for more details.\
 *\
 * In addition to the permissions in the GNU General Public License,\
 * Analog Devices gives you unlimited permission to link the\
 * compiled version of this file into combinations with other programs,\
 * and to distribute those combinations without any restriction coming\
 * from the use of this file.  (The General Public License restrictions\
 * do apply in other respects; for example, they cover modification of\
 * the file, and distribution when not linked into a combine\
 * executable.)\
 *\
 * Non-GPL License is also available as part of VisualDSP++\
 * from Analog Devices, Inc.
/ \*\//i\
 * This file is subject to the terms and conditions of the GNU General\
 * Public License. See the file COPYING for more details.\
 *\
 * In addition to the permissions in the GNU General Public License,\
 * Analog Devices gives you unlimited permission to link the\
 * compiled version of this file into combinations with other programs,\
 * and to distribute those combinations without any restriction coming\
 * from the use of this file.  (The General Public License restrictions\
 * do apply in other respects; for example, they cover modification of\
 * the file, and distribution when not linked into a combine\
 * executable.)\
 *\
 * Non-GPL License is also available as part of VisualDSP++\
 * from Analog Devices, Inc.
/   .*/i\
   This file is subject to the terms and conditions of the GNU General\
   Public License. See the file COPYING for more details.\
\
   In addition to the permissions in the GNU General Public License,\
   Analog Devices gives you unlimited permission to link the\
   compiled version of this file into combinations with other programs,\
   and to distribute those combinations without any restriction coming\
   from the use of this file.  (The General Public License restrictions\
   do apply in other respects; for example, they cover modification of\
   the file, and distribution when not linked into a combine\
   executable.)\
\
   Non-GPL License is also available as part of VisualDSP++\
   from Analog Devices, Inc.
:end
}


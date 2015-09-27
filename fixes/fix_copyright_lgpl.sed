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
This file is subject to the terms and conditions of the GNU Lesser\
General Public License. See the file COPYING.LIB for more details.\
\
Non-LGPL License is also available as part of VisualDSP++\
from Analog Devices, Inc.
}

/^ Copyright/{
a\
 This file is subject to the terms and conditions of the GNU Lesser\
 General Public License. See the file COPYING.LIB for more details.\
\
 Non-LGPL License is also available as part of VisualDSP++\
 from Analog Devices, Inc.
}

/^  Copyright/{
a\
  This file is subject to the terms and conditions of the GNU Lesser\
  General Public License. See the file COPYING.LIB for more details.\
\
  Non-LGPL License is also available as part of VisualDSP++\
  from Analog Devices, Inc.
}

/^   Copyright/{
a\
   This file is subject to the terms and conditions of the GNU Lesser\
   General Public License. See the file COPYING.LIB for more details.\
\
   Non-LGPL License is also available as part of VisualDSP++\
   from Analog Devices, Inc.
}

/^ \* Copyright/{
a\
 * This file is subject to the terms and conditions of the GNU Lesser\
 * General Public License. See the file COPYING.LIB for more details.\
 *\
 * Non-LGPL License is also available as part of VisualDSP++\
 * from Analog Devices, Inc.
}

/^\/\/ Copyright/{
a\
// This file is subject to the terms and conditions of the GNU Lesser\
// General Public License. See the file COPYING.LIB for more details.\
//\
// Non-LGPL License is also available as part of VisualDSP++\
// from Analog Devices, Inc.
}

/^\*\* Copyright/{
a\
** This file is subject to the terms and conditions of the GNU Lesser\
** General Public License. See the file COPYING.LIB for more details.\
**\
** Non-LGPL License is also available as part of VisualDSP++\
** from Analog Devices, Inc.
}

/^	Copyright/{
a\
	This file is subject to the terms and conditions of the GNU Lesser\
	General Public License. See the file COPYING.LIB for more details.\
\
	Non-LGPL License is also available as part of VisualDSP++\
	from Analog Devices, Inc.
}

/^\/\* Copyright/{
/^\/\*[ 	]*Copyright.*[ 	]*\*\/[ 	]*$/{
s|^/\*[ 	]*\(Copyright.*Inc\.\)[ 	]*\*/[ 	]*$|/\* \1|
a\
 * This file is subject to the terms and conditions of the GNU Lesser\
 * General Public License. See the file COPYING.LIB for more details.\
 *\
 * Non-LGPL License is also available as part of VisualDSP++\
 * from Analog Devices, Inc.\
 */
bend
}
n
/\*\* .*/i\
** This file is subject to the terms and conditions of the GNU Lesser\
** General Public License. See the file COPYING.LIB for more details.\
**\
** Non-LGPL License is also available as part of VisualDSP++\
** from Analog Devices, Inc.
/\*\//i\
** This file is subject to the terms and conditions of the GNU Lesser\
** General Public License. See the file COPYING.LIB for more details.\
**\
** Non-LGPL License is also available as part of VisualDSP++\
** from Analog Devices, Inc.
/ \* .*/i\
 * This file is subject to the terms and conditions of the GNU Lesser\
 * General Public License. See the file COPYING.LIB for more details.\
 *\
 * Non-LGPL License is also available as part of VisualDSP++\
 * from Analog Devices, Inc.
/ \*\//i\
 * This file is subject to the terms and conditions of the GNU Lesser\
 * General Public License. See the file COPYING.LIB for more details.\
 *\
 * Non-LGPL License is also available as part of VisualDSP++\
 * from Analog Devices, Inc.
/   .*/i\
   This file is subject to the terms and conditions of the GNU Lesser\
   General Public License. See the file COPYING.LIB for more details.\
\
   Non-LGPL License is also available as part of VisualDSP++\
   from Analog Devices, Inc.
:end
}


#==============================================================================
# NOTE:
# For backwards compatibility with older version of autoconf, we conditionally
# define AS_VAR_COPY. This macro, along with the original copyright notice
# accompanying it are reproduced below from:
# git://git.sv.gnu.org/autoconf
#==============================================================================

#==============================================================================
# This file is part of Autoconf.                          -*- Autoconf -*-
# M4 sugar for common shell constructs.
# Requires GNU M4 and M4sugar.
#
# Copyright (C) 2000-2015 Free Software Foundation, Inc.

# This file is part of Autoconf.  This program is free
# software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Under Section 7 of GPL version 3, you are granted additional
# permissions described in the Autoconf Configure Script Exception,
# version 3.0, as published by the Free Software Foundation.
#
# You should have received a copy of the GNU General Public License
# and a copy of the Autoconf Configure Script Exception along with
# this program; see the files COPYINGv3 and COPYING.EXCEPTION
# respectively.  If not, see <http://www.gnu.org/licenses/>.

# Written by Akim Demaille, Pavel Roskin, Alexandre Oliva, Lars J. Aas
# and many other people.
# AS_VAR_COPY(DEST, SOURCE)
# -------------------------
# Set the polymorphic shell variable DEST to the contents of the polymorphic
# shell variable SOURCE.
m4_ifndef([AS_VAR_COPY,[
    m4_define([AS_VAR_COPY],
    [AS_LITERAL_WORD_IF([$1[]$2], [$1=$$2], [eval $1=\$$2])])
])

# EOF


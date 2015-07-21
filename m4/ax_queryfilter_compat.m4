#==============================================================================
#                                !!!ATTENTION!!!
#------------------------------------------------------------------------------
# NOTE:
# For backwards compatibility with older version of autoconf, we conditionally
# define the following m4sh macros:
# - AS_LITERAL_IF
# - AS_LITERAL_WORD_IF
# - AS_VAR_COPY
# The macros are reproduced below with the original copyright notice from:
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

# AS_LITERAL_IF(EXPRESSION, IF-LITERAL, IF-NOT-LITERAL,
#               [IF-SIMPLE-REF = IF-NOT-LITERAL])
# -----------------------------------------------------
# If EXPRESSION has no shell indirections ($var or `expr`), expand
# IF-LITERAL, else IF-NOT-LITERAL.  In some cases, IF-NOT-LITERAL
# must be complex to safely deal with ``, while a simpler
# expression IF-SIMPLE-REF can be used if the indirection
# involves only shell variable expansion (as in ${varname}).
#
# EXPRESSION is treated as a literal if it results in the same
# interpretation whether it is unquoted or contained within double
# quotes, with the exception that whitespace is ignored (on the
# assumption that it will be flattened to _).  Therefore, neither `\$'
# nor `a''b' is a literal, since both backslash and single quotes have
# different quoting behavior in the two contexts; and `a*' is not a
# literal, because it has different globbing.  Note, however, that
# while `${a+b}' is neither a literal nor a simple ref, `a+b' is a
# literal.  This macro is an *approximation*: it is possible that
# there are some EXPRESSIONs which the shell would treat as literals,
# but which this macro does not recognize.
#
# Why do we reject EXPRESSION expanding with `[' or `]' as a literal?
# Because AS_TR_SH is MUCH faster if it can use m4_translit on literals
# instead of m4_bpatsubst; but m4_translit is much tougher to do safely
# if `[' is translated.  That, and file globbing matters.
#
# Note that the quadrigraph @S|@ can result in non-literals, but outright
# rejecting all @ would make AC_INIT complain on its bug report address.
#
# We used to use m4_bmatch(m4_quote($1), [[`$]], [$3], [$2]), but
# profiling shows that it is faster to use m4_translit.
#
# Because the translit is stripping quotes, it must also neutralize
# anything that might be in a macro name, as well as comments, commas,
# or unbalanced parentheses.  Valid shell variable characters and
# unambiguous literal characters are deleted (`a.b'), and remaining
# characters are normalized into `$' if they can form simple refs
# (${a}), `+' if they can potentially form literals (a+b), ``' if they
# can interfere with m4 parsing, or left alone otherwise.  If both `$'
# and `+' are left, it is treated as a complex reference (${a+b}),
# even though it could technically be a simple reference (${a}+b).
# _AS_LITERAL_IF_ only has to check for an empty string after removing
# one of the two normalized characters.
#
# Rather than expand m4_defn every time AS_LITERAL_IF is expanded, we
# inline its expansion up front.  _AS_LITERAL_IF expands to the name
# of a macro that takes three arguments: IF-SIMPLE-REF,
# IF-NOT-LITERAL, IF-LITERAL.  It also takes an optional argument of
# any additional characters to allow as literals (useful for AS_TR_SH
# and AS_TR_CPP to perform inline conversion of whitespace to _).  The
# order of the arguments allows reuse of m4_default.
m4_ifndef([AS_LITERAL_IF],[
    m4_define([AS_LITERAL_IF],
    [_$0(m4_expand([$1]), [  ][
    ])([$4], [$3], [$2])])
])

m4_ifndef([_AS_LITERAL_IF],[
    m4_define([_AS_LITERAL_IF],
    [m4_if(m4_index([$1], [@S|@]), [-1], [$0_(m4_translit([$1],
      [-:=%/@{}[]#(),.$2]]]m4_dquote(m4_dquote(m4_defn([m4_cr_symbols2])))[[,
      [++++++$$`````]))], [$0_NO])])
])

m4_ifndef([_AS_LITERAL_IF_],[
    m4_define([_AS_LITERAL_IF_],
    [m4_if(m4_translit([$1], [+]), [], [$0YES],
           m4_translit([$1], [$]), [], [m4_default], [$0NO])])
])

m4_ifndef([_AS_LITERAL_IF_YES],[
    m4_define([_AS_LITERAL_IF_YES], [$3])
])
m4_ifndef([_AS_LITERAL_IF_NO],[
    m4_define([_AS_LITERAL_IF_NO], [$2])
])

# AS_LITERAL_WORD_IF(EXPRESSION, IF-LITERAL, IF-NOT-LITERAL,
#                    [IF-SIMPLE-REF = IF-NOT-LITERAL])
# ----------------------------------------------------------
# Like AS_LITERAL_IF, except that spaces and tabs in EXPRESSION
# are treated as non-literal.
m4_ifndef([AS_LITERAL_WORD_IF],[
    m4_define([AS_LITERAL_WORD_IF],
    [_AS_LITERAL_IF(m4_expand([$1]))([$4], [$3], [$2])])
])

# Written by Akim Demaille, Pavel Roskin, Alexandre Oliva, Lars J. Aas
# and many other people.
# AS_VAR_COPY(DEST, SOURCE)
# -------------------------
# Set the polymorphic shell variable DEST to the contents of the polymorphic
# shell variable SOURCE.
m4_ifndef([AS_VAR_COPY],[
    m4_define([AS_VAR_COPY],
    [AS_LITERAL_WORD_IF([$1[]$2], [$1=$$2], [eval $1=\$$2])])
])


#==============================================================================
#                                !!!ATTENTION!!!
#------------------------------------------------------------------------------
# NOTE:
# For backwards compatibility with older version of pkg-config, we
# conditionally define PKG_CHECK_VAR. This macro, along with the original
# copyright notice accompanying it are reproduced below from:
# http://www.freedesktop.org/wiki/Software/pkg-config/
#==============================================================================

# ============================================================================
# pkg.m4 - Macros to locate and utilise pkg-config.            -*- Autoconf -*-
# serial 1 (pkg-config-0.24)
# 
# Copyright © 2004 Scott James Remnant <scott@netsplit.com>.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
# As a special exception to the GNU General Public License, if you
# distribute this file as part of a program that contains a
# configuration script generated by Autoconf, you may include it under
# the same distribution terms that you use for the rest of that program.
# =============================================================================
m4_ifndef([PKG_CHECK_VAR],[
    # PKG_CHECK_VAR(VARIABLE, MODULE, CONFIG-VARIABLE,
    # [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
    # -------------------------------------------
    # Retrieves the value of the pkg-config variable for the given module.
    AC_DEFUN([PKG_CHECK_VAR],
    [AC_REQUIRE([PKG_PROG_PKG_CONFIG])dnl
    AC_ARG_VAR([$1], [value of $3 for $2, overriding pkg-config])dnl

    _PKG_CONFIG([$1], [variable="][$3]["], [$2])
    AS_VAR_COPY([$1], [pkg_cv_][$1])

    AS_VAR_IF([$1], [""], [$5], [$4])dnl
    ])# PKG_CHECK_VAR
])

# EOF


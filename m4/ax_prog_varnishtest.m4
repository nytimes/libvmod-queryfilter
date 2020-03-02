# =============================================================================
# https://github.com/NYTimes/libvmod-queryfilter/m4/ax_prog_varnishtest.m4
# =============================================================================
#
#
# SYNOPSIS
#  AX_PROG_VARNISHTEST([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
#
# DESCRIPTION
#   Set the VARNISHTEST output variable to the absolute path to the Varnish
#   Cache VMOD tool and execute ACTION-IF-FOUND, on success. On failure, invoke
#   ACTION-IF-NOT-FOUND.
#
#  Declares the following precious variables:
#   * VARNISHTEST - path to varnishtest vtc runner
#
# LICENSE
#
#   Copyright © 2014-2018 The New York Times Company
#   
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#   
#       http://www.apache.org/licenses/LICENSE-2.0
#   
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
# =============================================================================

# serial 1

# AX_PROG_VARNISHTEST([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
# ---------------------------------------------------------------
AC_DEFUN([AX_PROG_VARNISHTEST],[
    AC_ARG_VAR([VARNISHTEST],[path to varnishtest (optional)])

    # Check that varnishtest is built and in the varnish source directory:
    AS_IF([test "x$VARNISHSRC" != "x"],[
        _varnishtest_basepath="$VARNISHSRC/bin/varnishtest"
    ],[
        PKG_CHECK_VAR([VARNISH_BINDIR],[varnishapi],[bindir],[
            _varnishtest_basepath="$VARNISH_BINDIR"
            ],[$2])
    ])
    AC_PATH_PROG([VARNISHTEST],[varnishtest],[],[$_varnishtest_basepath])
    AC_SUBST([VARNISHTEST_PATH],[$_varnishtest_basepath])
    AS_IF([test "x$VARNISHTEST" != "x"],[$1],[$2])
])

## EOF


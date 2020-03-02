# =============================================================================
# https://github.com/NYTimes/libvmod-queryfilter/m4/ax_check_varnish.m4
# =============================================================================
#
#
# SYNOPSIS
#  AX_CHECK_VARNISH_VMOD_DEV([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
#
# DESCRIPTION
#   Ensure that we have everything necessary for Varnish vmod development.
#
#  Leverages the following macros:
#   * AX_CHECK_VARNISHSRC
#   * AX_CHECK_VMOD_DIR
#   * AX_CHECK_VMODTOOL
#   * AX_PROG_VARNISHTEST
#
#
#  Declares the following precious variables (via invoked functions):
#   * VARNISHSRC - path to source directory
#   * VARNISHTEST - path to varnishtest vtc runner
#   * VMOD_DIR - path to vmod installation directory
#   * VMODTOOL - path to the vmod.py utility script used to generate certain
#                auxiliary files (typically named vcc_if.c and vcc_if.h)
#
#  And performs the following actions:
#    * Require VARNISHSRC to be set to the path to a Varnish source directory
#    * If relative, convert VARNISHSRC to an absolute file path
#    * Set the VMODTOOL output variable to the path to the vmod utility
#    * If unset, set the VARNISHTEST output variable to the path to varnishtest
#    * If unset, Set the VMOD_DIR output variable to the vmod installation dir
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

# serial 3

# AX_CHECK_VARNISH_VMOD_REQ([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
# ------------------------------------------------------------------
# Required to build:
# - Determine varnish API major version:
#   - VARNISHSRC_3_x, VARNISH_4_x, or VARNISH_5_x AM conditional to be set
# - Determine paths to:
#   - @VARNISHD@
#   - @VARNISHTEST@
#   - @VARNISH_VMODDIR@
#   - @VMODTOOL@ / @VARNISH_VMODTOOL@
AC_DEFUN([AX_CHECK_VARNISH_VMOD_REQ],[
    AX_CHECK_VARNISH_VERSION([
        AX_PROG_VARNISHD([
            AX_PROG_VARNISHTEST([
                PKG_CHECK_VAR([VARNISH_VMODDIR],[varnishapi],[vmoddir],[
                    AX_CHECK_VMODTOOL([$1],[$2])
                ], [$2])
            ], [$2])
        ],[$2])
    ], [$2])
])

# AX_CHECK_VARNISH_VMOD_DEV([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
# ------------------------------------------------------------------
# - If $VARNISHSRC:
#   - Confirmed VARNISHSRC exists and is built
#   - Set VARNISH_CFLAGS / VARNISH_LIBS
#   - Run common config
# - Else:
#   - Load "varnishapi.pc" pkg-config file or bail
#   - Run common config
#
# - Set required flags:
#   - @VARNISH_CFLAGS@
#   - @VARNISH_LIBS@
# ------------------------------------------------------------------
AC_DEFUN([AX_CHECK_VARNISH_VMOD_DEV],[
    AC_MSG_CHECKING([to see if VARNISHSRC set])
    AS_IF([test "x${VARNISHSRC}" != "x" ],[
        AC_MSG_RESULT([$VARNISHSRC])

        AX_CHECK_VARNISHSRC([
            AC_SUBST([VARNISH_CFLAGS],["-I${VARNISHSRC}/include -I${VARNISHSRC}/bin/varnishd -I${VARNISHSRC}"])
            old_PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"
            export PKG_CONFIG_PATH="${VARNISHSRC}"
            # TODO: AX_SET_VARNISH_BUILD_FLAGS()
            AX_CHECK_VARNISH_VMOD_REQ([$1],[$2])
            export PKG_CONFIG_PATH="${old_PKG_CONFIG_PATH}"
        ],[$2])
    ],[
        AC_MSG_RESULT([no])
        PKG_CHECK_MODULES([VARNISH],[varnishapi],[
            AX_CHECK_VARNISH_VMOD_REQ([$1],[$2])
        ],[$2])
    ])
])

## EOF


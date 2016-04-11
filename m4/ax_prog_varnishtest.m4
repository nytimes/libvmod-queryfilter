# =============================================================================
# https://github.com/andrew-canaday/libvmod-queryfilter/m4/ax_check_varnish.m4
# =============================================================================
#
#
# SYNOPSIS
#  AX_PROG_VARNISHTEST([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
#
# DESCRIPTION
#  Find and set the path to varnishtest.
#
#  Declares the following precious variables:
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
#   Copyright 2014,2015 The New York Times Company
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

# serial 2

# AX_PROG_VARNISHTEST([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
# ---------------------------------------------------------------
AC_DEFUN([AX_PROG_VARNISHTEST],[
    AC_ARG_VAR([VARNISHTEST],[path to varnishtest (optional)])

    # Check that varnishtest is built and in the varnish source directory:
    AC_PATH_PROG([VARNISHTEST],[varnishtest],[],[$VARNISHSRC/bin/varnishtest])
    AS_IF([test "x$VARNISHTEST" != "x"],[$1],[$2])
])

## EOF


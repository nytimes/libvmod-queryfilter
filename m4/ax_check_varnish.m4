# =============================================================================
# https://github.com/andrew-canaday/libvmod-queryfilter/m4/ax_check_varnish.m4
# =============================================================================
#
#
# SYNOPSIS
#  AX_CHECK_VARNISH_VMOD_DEV([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
#
# DESCRIPTION
#   Ensure that we have everything necessary for Varnish vmod development.
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
#   Copyright 2014-2016 The New York Times Company
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

# AX_CHECK_VARNISH_VMOD_DEV([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
# ------------------------------------------------------------------
AC_DEFUN([AX_CHECK_VARNISH_VMOD_DEV],[
    # Ensure we have/know everything we need for vmod development:
    # - Check that VARNISHSRC is set and is a directory we can access
    # - Determine the path to varnishtest
    # - Check vmod installation directory
    # - Find the vmod tool (vmod.py or vmodtool.py) - this effectively
    #   also determines the Varnish Cache major version
    AX_CHECK_VARNISHSRC([
        AX_PROG_VARNISHTEST([
            AX_CHECK_VMOD_DIR([
                AX_PROG_VMODTOOL
            ])
        ])
    ])

    AS_IF([test "x$VARNISH_API_MAJOR" != "x"],[$1],[$2])
])

## EOF


# =============================================================================
# https://github.com/NYTimes/libvmod-queryfilter/m4/ax_check_varnishsrc.m4
# =============================================================================
#
#
# SYNOPSIS
#  AX_CHECK_VARNISHSRC([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
#
# DESCRIPTION
#   Verify that the directory given by VARNISHSRC exists. Execute
#   ACTION-IF-FOUND on success; execute ACTION-IF-NOT-FOUND on failure.
#
#  Declares the following precious variables:
#   * VARNISHSRC - path to source directory
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

# AX_CHECK_VARNISHSRC([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
# ---------------------------------------------------------------
AC_DEFUN([AX_CHECK_VARNISHSRC],[
    AC_ARG_VAR([VARNISHSRC],[path to Varnish source tree (mandatory)])

    # Locate the varnish source tree
    AS_IF([test "x$VARNISHSRC" != "x" -a -d "$VARNISHSRC"],[
        VARNISHSRC=[$(cd $VARNISHSRC && pwd)]
        $1
    ],[
        $2
    ])
])




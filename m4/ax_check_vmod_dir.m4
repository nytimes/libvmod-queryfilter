# =============================================================================
# https://github.com/NYTimes/libvmod-queryfilter/m4/ax_check_vmoddir.m4
# =============================================================================
#
#
# SYNOPSIS
#  AX_CHECK_VMOD_DIR([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
#
# DESCRIPTION
#   Set the VMOD_DIR output variable to the absolute path of the vmod
#   installation directory. Execute ACTION-IF-FOUND on success; execute
#   ACTION-IF-NOT-FOUND on failure.
#
#  Declares the following precious variables:
#   * VMOD_DIR - path to vmod installation directory
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

# AX_CHECK_VMOD_DIR([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
# ---------------------------------------------------------------
AC_DEFUN([AX_CHECK_VMOD_DIR],[
    AC_MSG_CHECKING([Varnish Cache VMOD dir])
    AC_ARG_VAR([VMOD_DIR],
        [vmod installation directory @<:@LIBDIR/varnish/vmods@:>@])

    # If not explicitly set, attempt to determine vmoddir via pkg-config
    AS_IF([test "x$VMOD_DIR" = "x"],[
        _vmoddir=`PKG_CONFIG_PATH="${VARNISHSRC}:${PKG_CONFIG_PATH}" $PKG_CONFIG varnishapi --variable=vmoddir`
        AS_IF([test "x$_vmoddir" != "x"],[
                AC_MSG_RESULT([$_vmoddir])
                AC_SUBST([VMOD_DIR],[$_vmoddir])
                $1
        ],[
                AC_MSG_RESULT([not found])
                $2
        ])
    ])
])




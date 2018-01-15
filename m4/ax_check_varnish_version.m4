# =============================================================================
# https://github.com/NYTimes/libvmod-queryfilter/m4/ax_check_vmod_dir.m4
# =============================================================================
#
#
# SYNOPSIS
#  AX_CHECK_VARNISH_VERSION([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
#
# DESCRIPTION
#   Set the VARNISH_VERSION output variable to the varnish API version.
#   Set the VARNISH_API_MAJOR output variable to API major version.
#   Execute ACTION-IF-FOUND on success; execute ACTION-IF-NOT-FOUND on failure.
#
#  Declares the following precious variables:
#   * VARNISH_VERSION - path to vmod installation directory
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

# AX_CHECK_VARNISH_VERSION([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
# ---------------------------------------------------------------
AC_DEFUN([AX_CHECK_VARNISH_VERSION],[
    AC_MSG_CHECKING([Varnish Cache API version])
    AC_ARG_VAR([VARNISH_VERSION],[varnish cache version])

    # If not explicitly set, attempt to determine varnish version via pkg-config
    AS_IF([test "x$VARNISH_VERSION" = "x"],[
        _varnish_version=`PKG_CONFIG_PATH="${VARNISHSRC}:${PKG_CONFIG_PATH}" $PKG_CONFIG varnishapi --modversion`
        AS_IF([test "x$_varnish_version" != "x"],[
            AC_MSG_RESULT([$_varnish_version])
            AC_SUBST([VARNISH_VERSION],[$_varnish_version])
            AC_SUBST([VARNISH_API_MAJOR],[${_varnish_version%%.*}])
            $1
        ],[
            AC_MSG_RESULT([not found])
            $2
        ])
    ])
])




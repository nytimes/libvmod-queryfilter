# =============================================================================
# https://github.com/NYTimes/libvmod-queryfilter/m4/ax_check_vmod_dir.m4
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

# serial 1

# AX_CHECK_VMOD_DIR([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
# ---------------------------------------------------------------
AC_DEFUN([AX_CHECK_VMOD_DIR],[
    AC_ARG_VAR([VMOD_DIR],
        [vmod installation directory @<:@LIBDIR/varnish/vmods@:>@])

    # If not explicitly set, attempt to determine vmoddir via pkg-config
    AS_IF([test "x$VMOD_DIR" = "x"],[
        # NOTE:
        # I'm not sure we should just silently export variables on behalf of
        # the user. However, existing users already expect this to work,
        # setting only VARNISHSRC. We try once without and then do it for them:
        PKG_CHECK_VAR([VMOD_DIR],[varnishapi],[vmoddir],[$1],[
            # If VARNISHSRC is defined, go ahead and extend pkg-config
            # params to use it.
            AS_IF([test "x$VARNISHSRC" != "x"],[
                AC_MSG_WARN([
No VMOD_DIR set and unable to locate via pkg-config.
Trying now with PKG_CONFIG_PATH=$VARNISHSRC....

To avoid this warning in the future, consider setting the VMOD_DIR environment
variable or re-running configure with a PKG_CONFIG_PATH pointing to your
varnish source directory, e.g.:

${0} PKG_CONFIG_PATH="${VARNISHSRC}:\${PKG_CONFIG_PATH}" #...

                ])

                export PKG_CONFIG_PATH="${VARNISHSRC}:${PKG_CONFIG_PATH}"
                PKG_CHECK_VAR([VMOD_DIR],[varnishapi],[vmoddir],[$1],[$2])
            ],[$2])
        ])
    ])
])




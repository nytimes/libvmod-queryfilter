# =============================================================================
# https://github.com/andrew-canaday/libvmod-queryfilter/m4/ax_check_varnish.m4
# =============================================================================
#
#
# SYNOPSIS
#  AX_CHECK_VARNISHSRC_DIR([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
#  AX_PROG_VMODTOOL([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
#  AX_PROG_VARNISHTEST([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
#  AX_CHECK_VMOD_DIR([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
#  AX_CHECK_VARNISH_VMOD_DEV([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
#
# DESCRIPTION
#   Declares the following precious variables:
#    * VARNISHSRC - path to source directory
#    * VARNISHTEST - path to varnishtest vtc runner
#    * VMOD_DIR - path to vmod installation directory
#
#  Sets the following output variables (in addition to those listed above):
#    * VMODTOOL - path to the vmod.py utility script used to generate certain
#                 auxiliary files (typically named vcc_if.c and vcc_if.h)
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

# AX_CHECK_VARNISHSRC_DIR([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
# ---------------------------------------------------------------
AC_DEFUN([AX_CHECK_VARNISHSRC_DIR],[
    AC_ARG_VAR([VARNISHSRC],[path to Varnish source tree (mandatory)])

    # Locate the varnish source tree
    AS_IF([test "x$VARNISHSRC" != "x" -a -d "$VARNISHSRC"],[
        VARNISHSRC=[$(cd $VARNISHSRC && pwd)]
        $1
    ],[
        $2
    ])
])


# AX_PROG_VMODTOOL([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
# ---------------------------------------------------------------
AC_DEFUN([AX_PROG_VMODTOOL],[
    # Check for vmodtool.py (varnish 4.x):
    vmodtool_path=[$VARNISHSRC/lib/libvcc/vmodtool.py]
    AC_CHECK_FILE([$vmodtool_path],[
        AC_SUBST([VMODTOOL],[$vmodtool_path])
        AC_SUBST([VARNISH_API_MAJOR],[4])
        $1
    ],[
        # Check for vmod.py (varnish 3.x):
        vmod_py_path=[$VARNISHSRC/lib/libvmod_std/vmod.py]
        AC_CHECK_FILE([$vmod_py_path],[
            AC_SUBST([VMODTOOL],[$vmod_py_path])
            AC_SUBST([VARNISH_API_MAJOR],[3])
            $1
        ],[
            $2
        ])
    ])
])


# AX_PROG_VARNISHTEST([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
# ---------------------------------------------------------------
AC_DEFUN([AX_PROG_VARNISHTEST],[
    AC_ARG_VAR([VARNISHTEST],[path to varnishtest (optional)])

    # Check that varnishtest is built and in the varnish source directory:
    AC_PATH_PROG([VARNISHTEST],[varnishtest],[],[$VARNISHSRC/bin/varnishtest])
    AS_IF([test "x$VARNISHTEST" != "x"],[$1],[$2])
])


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
        ])
    ])
])


# AX_CHECK_VARNISH_VMOD_DEV([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
# ------------------------------------------------------------------
AC_DEFUN([AX_CHECK_VARNISH_VMOD_DEV],[
    AX_CHECK_VARNISHSRC_DIR([
        AX_PROG_VMODTOOL([
            AX_PROG_VARNISHTEST([
                AX_CHECK_VMOD_DIR
            ])
        ])
    ])

    AS_IF([test "x$VARNISH_API_VERSION" != "x"],[$1],[$2])
])

## EOF


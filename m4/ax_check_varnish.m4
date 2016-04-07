# =============================================================================
# https://github.com/andrew-canaday/libvmod-queryfilter/m4/ax_check_varnish.m4
# =============================================================================
#
#
# SYNOPSIS
#  AX_CHECK_VARNISH3_SRC()
#  AX_CHECK_VARNISH4_SRC()
#
# DESCRIPTION
#   This macro finds files, programs, and scripts required to build a vmod for
#   varnish 3.x using a path to varnish 3.x source directory (must be built!).
# 
#   Declares the following precious variables:
#    * VARNISHSRC - path to source directory
#    * VARNISHTEST - path to varnishtest vtc runner
#    * VMODDIR - path to vmod installation directory
#
#  Sets the following output variables (in addition to those listed above):
#    * VMOD_PY - path to the vmod.py utility script used to generate certain
#                auxiliary files (typically named vcc_if.c and vcc_if.h)
#
#  And performs the following actions:
#    * Require VARNISHSRC to be set to the path to a Varnish 3 source directory
#    * If relative, convert VARNISHSRC to an absolute file path
#    * Verify that the Varnish source includes varnishapi.h (3.x sanity check)
#    * Set the VMOD_PY output variable to the path to the vmod.py utility
#    * If unset, set the VARNISHTEST output variable to the path to varnishtest
#    * If unset, Set the VMODDIR output variable to the vmod installation dir
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

# AX_CHECK_VARNISH3_SRC()
# ---------------------------------------------------------------
AC_DEFUN([AX_CHECK_VARNISH3_SRC],[
    #--- Declare our precious variables ---
    AC_ARG_VAR([VARNISHSRC],[path to Varnish source tree (mandatory)])
    AC_ARG_VAR([VARNISHTEST],[path to varnishtest (optional)])
    AC_ARG_VAR([VMODDIR],
        [vmod installation directory @<:@LIBDIR/varnish/vmods@:>@])

    #--- Varnish Source Tree: ---
    # Locate the varnish source tree
    AS_IF([test "x$VARNISHSRC" = "x" -o ! -d "$VARNISHSRC"],[
        AC_MSG_ERROR([VARNISHSRC must be set to the varnish source tree])
    ])
    VARNISHSRC=$(cd $VARNISHSRC && pwd)

    #--- Validate Varnish 3.x build: ---
    # Ensure varnishapi.h is where we expect it:
    varnishapi_path=[$VARNISHSRC/include/varnishapi.h]
    AC_CHECK_FILES([$varnishapi_path],[],[
        AC_MSG_ERROR([Invalid Varnish 3 source: $varnishapi_path not found])
    ])

    # And that we have vmod.py:
    vmod_py_path=[$VARNISHSRC/lib/libvmod_std/vmod.py]
    AC_CHECK_FILE([$vmod_py_path],[
        AC_SUBST([VMOD_PY],[$vmod_py_path])
    ],[
        AC_MSG_ERROR([Invalid Varnish 3 source: $vmod_py_path not found])
    ])

    #--- Varnishtest: ---
    # Check that varnishtest is built in the varnish source directory:
    AC_PATH_PROG([VARNISHTEST],[varnishtest],[],[$VARNISHSRC/bin/varnishtest])
    AS_IF([test "x$VARNISHTEST" == "x"],[
        AC_MSG_ERROR([Unable to find varnishtest: please build varnish])
    ])

    #--- VMOD Installation directory:
    # If not explicitly set, attempt to determine vmoddir via pkg-config
    # TODO: use PKG_CHECK_VAR
    AS_IF([test "x$VMODDIR" = "x"],[
        # I'm not sure we should just silently export variables on behalf of
        # the user. However, existing users already expect this to work,
        # setting only VARNISHSRC. We try once without and then do it for them:
        PKG_CHECK_VAR([VMODDIR],[varnishapi],[vmoddir],[],[
            AC_MSG_WARN([No VMODDIR set and unable to locate via pkg-config.
Trying now with PKG_CONFIG_PATH=$VARNISHSRC....

To avoid this warning in the future, consider setting the VMODDIR environment
variable or re-running configure with a PKG_CONFIG_PATH pointing to your
varnish source directory, e.g.:

${0} PKG_CONFIG_PATH="${VARNISHSRC}:\${PKG_CONFIG_PATH}" #...

])
            export PKG_CONFIG_PATH="${VARNISHSRC}:${PKG_CONFIG_PATH}"
            PKG_CHECK_VAR([VMODDIR],[varnishapi],[vmoddir],[],[
                AC_MSG_ERROR([Unable to determine VMODDIR])
            ])
        ])
    ])
])


# AX_CHECK_VARNISH4_SRC()
# ---------------------------------------------------------------
AC_DEFUN([AX_CHECK_VARNISH4_SRC],[
    #--- Declare our precious variables ---
    AC_ARG_VAR([VARNISHSRC],[path to Varnish source tree (mandatory)])
    AC_ARG_VAR([VARNISHTEST],[path to varnishtest (optional)])
    AC_ARG_VAR([VMODDIR],
        [vmod installation directory @<:@LIBDIR/varnish/vmods@:>@])

    #--- Varnish Source Tree: ---
    # Locate the varnish source tree
    AS_IF([test "x$VARNISHSRC" = "x" -o ! -d "$VARNISHSRC"],[
        AC_MSG_ERROR([VARNISHSRC must be set to the varnish source tree])
    ])
    VARNISHSRC=$(cd $VARNISHSRC && pwd)

    # And that we have vmod.py:
    vmod_py_path=[$VARNISHSRC/lib/libvcc/vmodtool.py]
    AC_CHECK_FILE([$vmod_py_path],[
        AC_SUBST([VMOD_PY],[$vmod_py_path])
    ],[
        AC_MSG_ERROR([Invalid Varnish 4 source: $vmod_py_path not found])
    ])

    #--- Varnishtest: ---
    # Check that varnishtest is built in the varnish source directory:
    AC_PATH_PROG([VARNISHTEST],[varnishtest],[],[$VARNISHSRC/bin/varnishtest])
    AS_IF([test "x$VARNISHTEST" == "x"],[
        AC_MSG_ERROR([Unable to find varnishtest: please build varnish])
    ])

    #--- VMOD Installation directory:
    # If not explicitly set, attempt to determine vmoddir via pkg-config
    # TODO: use PKG_CHECK_VAR
    AS_IF([test "x$VMODDIR" = "x"],[
        # I'm not sure we should just silently export variables on behalf of
        # the user. However, existing users already expect this to work,
        # setting only VARNISHSRC. We try once without and then do it for them:
        PKG_CHECK_VAR([VMODDIR],[varnishapi],[vmoddir],[],[
            AC_MSG_WARN([No VMODDIR set and unable to locate via pkg-config.
Trying now with PKG_CONFIG_PATH=$VARNISHSRC....

To avoid this warning in the future, consider setting the VMODDIR environment
variable or re-running configure with a PKG_CONFIG_PATH pointing to your
varnish source directory, e.g.:

${0} PKG_CONFIG_PATH="${VARNISHSRC}:\${PKG_CONFIG_PATH}" #...

])
            export PKG_CONFIG_PATH="${VARNISHSRC}:${PKG_CONFIG_PATH}"
            PKG_CHECK_VAR([VMODDIR],[varnishapi],[vmoddir],[],[
                AC_MSG_ERROR([Unable to determine VMODDIR])
            ])
        ])
    ])
])

## EOF


# =============================================================================
# https://github.com/andrew-canaday/libvmod-queryfilter/m4/ax_check_varnish.m4
# =============================================================================
#
#
# SYNOPSIS
#
#  AX_CHECK_VARNISH3_SRC([ACTION-IF-FOUND[, ACTION-IF-NOT-FOUND]])
#
# DESCRIPTION
#   This macro finds files, programs, and scripts required to build a vmod for
#   varnish 3.x. Actions taken (TODO: clean up description!):
#    - Declare VARNISHSRC as a precious variable
#    - Require VARNISHSRC to be set to the path to a Varnish 3 source directory
#    - If relative, convert VARNISHSRC to an absolute file path
#    - Verify that the Varnish source includes varnishapi.h
#    - Set the VMOD_PY output variable to the path to the vmod.py utility
#    - Set the VARNISHTEST output variable to the path to varnishtest
#    - Set the VMODDIR output variable to the installation directory for vmod's
#
# If specified, execute ACTION-IF-FOUND on success and ACTION-IF-NOT-FOUND on
# failure.
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

# serial 1

AC_DEFUN([AX_CHECK_VARNISH3_SRC],[
    #--- Varnish Source Tree: ---
    # Locate the varnish source tree
    AC_ARG_VAR([VARNISHSRC], [path to Varnish source tree (mandatory)])
    AS_IF([test "x$VARNISHSRC" = "x" -o ! -d "$VARNISHSRC"],[
        AC_MSG_ERROR([VARNISHSRC must be set to the varnish source tree])
    ])
    VARNISHSRC=$(cd $VARNISHSRC && pwd)

    #--- Validate Varnish 3.x build: ---
    # Ensure varnishapi.h is where we expect it:
    varnishapi_path=[$VARNISHSRC/include/varnishapi.h]
    AC_CHECK_FILES([$varnishapi_path],[],[
        AC_MSG_ERROR([Invalid VARNISHSRC: $varnishapi_path not found])
    ])

    # And that we have vmod.py:
    vmod_py_path=[$VARNISHSRC/lib/libvmod_std/vmod.py]
    AC_CHECK_FILE([$vmod_py_path],[
        AC_SUBST([VMOD_PY],[$vmod_py_path])
    ],[
        AC_MSG_ERROR([Invalid VARNISHSRC: $vmod_py_path not found])
    ])

    #--- Varnishtest: ---
    # Check that varnishtest is built in the varnish source directory:
    AC_PATH_PROG([VARNISHTEST],[varnishtest],[],[$VARNISHSRC/bin/varnishtest])
    AS_IF([test "x$VARNISHTEST" == "x"],[
        AC_MSG_ERROR([Unable to find varnishtest: please build varnish])
    ])

    #--- VMOD Installation directory:
    AC_ARG_VAR([VMODDIR],
        [vmod installation directory @<:@LIBDIR/varnish/vmods@:>@])

    # If not explicitly set, attempt to determine vmoddir via pkg-config
    # TODO: use PKG_CHECK_VAR
    AS_IF([test "x$VMODDIR" = "x"],[
        VMODDIR=`PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:$VARNISHSRC" \
            $PKG_CONFIG --variable=vmoddir varnishapi`
        AS_IF([test "x$VMODDIR" = "x"],[
            AC_MSG_FAILURE([Please set VMODDIR to the vmod installation path])
        ])
    ])
])

# EOF



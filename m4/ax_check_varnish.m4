#==============================================================================
#
# m4/queryfilter_varnish.m4: autoconf macros for finding varnish files required
#                            for build.
#
#==============================================================================

AC_DEFUN([QUERYFILTER_VARNISH],[
    #--- Varnish Source Tree: ---
    # Locate the varnish source tree
    AC_ARG_VAR([VARNISHSRC], [path to Varnish source tree (mandatory)])
    AS_IF([test "x$VARNISHSRC" = "x" -o ! -d "$VARNISHSRC"],[
        AC_MSG_ERROR([VARNISHSRC must be set to the varnish source tree])
    ])
    VARNISHSRC=`cd $VARNISHSRC && pwd`

    #--- Validate Varnish 3.x build: ---
    # Ensure varnishapi.h is where we expect it:
    AC_CHECK_FILES([$VARNISHSRC/include/varnishapi.h],[],[varnish_src="no"])

    # And that we have vmod.py:
    AC_CHECK_FILE([$VARNISHSRC/lib/libvmod_std/vmod.py],
        AC_SUBST([VMOD_PY],[$VARNISHSRC/lib/libvmod_std/vmod.py]),
        [varnish_src="no"])

    # Bail if any required varnish source files were not found:
    AS_IF([test "x$varnishsrc" = "xno"],[
        AC_MSG_FAILURE(["$VARNISHSRC" is not a Varnish source directory])
    ])

    #--- Varnishtest: ---
    # Check that varnishtest is built in the varnish source directory:
    AC_PATH_PROG([VARNISHTEST],[varnishtest],[],[$VARNISHSRC/bin/varnishtest])
    AS_IF([test "x$VARNISHTEST" == "x"],[
        AC_MSG_ERROR([$VARNISHSRC/bin/varnishtest not found. \
    Please build your varnish source directory.])
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



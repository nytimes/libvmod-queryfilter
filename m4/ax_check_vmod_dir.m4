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




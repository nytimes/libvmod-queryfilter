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




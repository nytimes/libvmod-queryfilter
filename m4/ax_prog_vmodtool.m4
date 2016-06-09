# AX_PROG_VMODTOOL([ACTION-IF-FOUND],[ACTION-IF-NOT-FOUND])
# ---------------------------------------------------------------
AC_DEFUN([AX_PROG_VMODTOOL],[
    AC_ARG_VAR([VMODTOOL], [Path to varnish vmod tool])

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




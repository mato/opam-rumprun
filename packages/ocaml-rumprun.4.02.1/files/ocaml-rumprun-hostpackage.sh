#!/bin/sh

usage()
{
    echo "ERROR: usage: ocaml-rumprun-hostpackage [ install | remove ]  PACKAGE" 1>&2
    exit 1
}

[ $# -ne 2 ] && usage
CMD="$1"
PACKAGE="$2"
OPAM_LIB="$(opam config var lib)"
RUMPRUN_PREFIX="$(opam config var ocaml-rumprun-prefix)"

case ${CMD} in
    install)
        ln -sf ${OPAM_LIB}/${PACKAGE} ${RUMPRUN_PREFIX}/lib/${PACKAGE} || exit 1
        # Ensure we get the host package, not a cross package in case the user
        # has OCAMLFIND_TOOLCHAIN in her environment.
        [ -n "${OCAMLFIND_TOOLCHAIN}" ] && unset OCAMLFIND_TOOLCHAIN
        ln -sf $(ocamlfind query ${PACKAGE}) ${RUMPRUN_PREFIX}/lib/ocaml/${PACKAGE} || exit 1
        ;;
    remove)
        rm -f ${RUMPRUN_PREFIX}/lib/${PACKAGE} ${RUMPRUN_PREFIX}/lib/ocaml/${PACKAGE}
        ;;
    *)
        usage
        ;;
esac


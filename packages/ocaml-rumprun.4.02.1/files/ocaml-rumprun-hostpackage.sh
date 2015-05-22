#!/bin/sh
set -x
usage()
{
    cat <<EOM 1>&2
ERROR: usage: ocaml-rumprun-hostpackage COMMAND ARGUMENTS

    COMMAND is:

    install PACKAGE

    installs the host package PACKAGE into the rumprun toolchain

    remove PACKAGE
    
    removes the host package PACKAGE from the rumprun toolchain

    install-files PACKAGE FINDSPEC...

    installs the files specified in FINDSPEC (passed to 'find' command as
    predicates) from host package PACKAGE into the rumprun toolchain.
    Intended for installing syntax plugins.

EOM
    exit 1
}

[ $# -lt 2 ] && usage
CMD="$1"; shift
PACKAGE="$1"; shift
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
    install-files)
        [ $# -lt 1 ] && usage
        find $(opam config var ${PACKAGE}:lib) "$@" -exec ln -sf '{}' ${RUMPRUN_PREFIX}/lib/${PACKAGE}/ \; || exit 1
        ;;
    *)
        usage
        ;;
esac


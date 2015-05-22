#!/bin/sh
if [ $# -ne 2 ]; then
    echo "ERROR: usage: remove.sh OPAM_PREFIX OPAM_BIN" 1>&2
    exit 1
fi
OPAM_PREFIX="$1"
OPAM_BIN="$2"

RUMPRUN_PREFIX=$(ocaml-rumprun-prefix)
if [ -z "${RUMPRUN_PREFIX}" -o ! -d "${RUMPRUN_PREFIX}" ]; then
    echo "WARNING: could not determine toolchain-specific prefix." 1>&2
    echo "WARNING: not fully installed? not removing anything." 1>&2
    exit 0
fi

rm -rf ${RUMPRUN_PREFIX}
rm -f ${OPAM_PREFIX}/lib/findlib.conf.d/rumprun.conf
rm -f ${OPAM_BIN}/ocaml-rumprun-prefix


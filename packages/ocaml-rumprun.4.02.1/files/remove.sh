#!/bin/sh
OPAM_PREFIX="$(opam config var prefix)"
OPAM_BIN="$(opam config var bin)"

RUMPRUN_PREFIX="$(opam config var ocaml-rumprun-prefix)"
if [ -z "${RUMPRUN_PREFIX}" -o ! -d "${RUMPRUN_PREFIX}" ]; then
    echo "WARNING: could not determine toolchain-specific prefix." 1>&2
    echo "WARNING: not fully installed? not removing anything." 1>&2
    exit 0
fi

rm -rf ${RUMPRUN_PREFIX}
rm -f ${OPAM_PREFIX}/lib/findlib.conf.d/rumprun.conf

# "unset" the ocaml-rumprun-prefix global variable created by install.sh
sed -i '/^ocaml-rumprun-prefix:/d' ${OPAM_PREFIX}/config/global-config.config


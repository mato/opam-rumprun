#!/bin/sh -e
OPAM_PREFIX="$(opam config var prefix)"
OPAM_BIN="$(opam config var bin)"

# Check that the rumprun platform has been specified, and that its compiler is
# available.
if [ -z "${RUMPRUN_PLATFORM}" ]; then
    echo "ERROR: RUMPRUN_PLATFORM not set. Set this to the rumprun platform you wish" 1>&2
    echo "ERROR: to build this toolchain for." 1>&2
    exit 1
fi

RUMPRUN_CC=${RUMPRUN_PLATFORM}-cc
if [ -z "$(command -v ${RUMPRUN_CC})" ]; then
    echo "ERROR: \`${RUMPRUN_CC}\' not found on PATH. Have you added the rumprun" 1>&2
    echo "ERROR: toolchain app-tools directory to your PATH?" 1>&2
    exit 1
fi

# Verify that the correct host compiler is available.
CROSS_OCAML_VERSION=4.02.1
HOST_OCAML_VERSION="$(opam config var ocaml-version)"
if [ "${HOST_OCAML_VERSION}" != "${CROSS_OCAML_VERSION}" ]; then
    echo "ERROR: Host compiler version must match cross compiler version." 1>&2
    echo "ERROR: Host compiler version is \`${HOST_OCAML_VERSION}\', cross compiler version is \`${CROSS_OCAML_VERSION}\'." 1>&2
    echo "ERROR: Please switch to a matching host compiler." 1>&2
    exit 1
fi
# Baremetal platform requires a 32-bit compiler.
if [ "${RUMPRUN_PLATFORM}" = "rumprun-bmk" ]; then
    # XXX There should be a way to query the compiler bitness, rather than
    # relying on the compiler name.
    HOST_OCAML_COMPILER="$(opam config var compiler)"
    HOST_ARCH="$(opam config var arch)"
    if [ "${HOST_ARCH}" = "x86_64" -a \
        "${HOST_OCAML_COMPILER}" != "${CROSS_OCAML_VERSION}+32bit" ]; then
        echo "ERROR: Building for \`${RUMPRUN_PLATFORM}\' on a 64-bit system requires a 32-bit compiler." 1>&2
        echo "ERROR: Try \`opam switch ${CROSS_OCAML_VERSION}+32bit\'." 1>&2
        exit 1
    fi
    CROSS_OCAML_ARCH="i386"
else
    CROSS_OCAML_ARCH="amd64"
fi
cp config-${CROSS_OCAML_ARCH}/* config/

# Perform substitutions on Makefile.in and rumprun.config.in. We can't do these
# through OPAM as we don't have all the information needed in OPAM variables.
sed -e "s%@OPAM_PREFIX@%${OPAM_PREFIX}%g" \
    -e "s%@RUMPRUN_PLATFORM@%${RUMPRUN_PLATFORM}%g" \
    -e "s%@RUMPRUN_CC@%${RUMPRUN_CC}%g" \
    config/Makefile.in > config/Makefile
sed -e "s%@OPAM_PREFIX@%${OPAM_PREFIX}%g" \
    -e "s%@RUMPRUN_PLATFORM@%${RUMPRUN_PLATFORM}%g" \
    rumprun.conf.in > rumprun.conf

# Build the cross compiler.
make world opt


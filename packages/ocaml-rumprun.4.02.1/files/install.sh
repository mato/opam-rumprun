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

# Install the cross compiler.
make install || exit 1

# Replace bytecode interpreter path with host ocamlrun.
for bin in ${OPAM_PREFIX}/${RUMPRUN_PLATFORM}/bin/*; do
    sed -i "s%^.*ocamlrun$%#\!$(which ocamlrun)%" ${bin}
done

# "Install" built-in bytecode packages by copying them from the host compiler.
BUILTIN_PKGS="bigarray bytes compiler-libs dynlink findlib graphics num num-top ocamlbuild stdlib str threads unix"
for pkg in ${BUILTIN_PKGS}; do
    cp -r "${OPAM_PREFIX}/lib/${pkg}" "${OPAM_PREFIX}/${RUMPRUN_PLATFORM}/lib/" || exit 1
done

# Install ocamlfind toolchain configuration.
mkdir -p "${OPAM_PREFIX}/lib/findlib.conf.d"
cp rumprun.conf "${OPAM_PREFIX}/lib/findlib.conf.d"

# Install the ocaml-rumprun-hostpackage script.
cp ocaml-rumprun-hostpackage.sh ${OPAM_BIN}/ocaml-rumprun-hostpackage
chmod +x ${OPAM_BIN}/ocaml-rumprun-hostpackage

# Install a `ocaml-rumprun-prefix' variable to record the prefix used for this
# toolchain installation; this is used by cross builds of packages.
# XXX This should be installed in the opam.config file for ocaml-rumprun, but 
# that gets overwritten by OPAM. so we abuse the global config instead.
echo "ocaml-rumprun-prefix: \"${OPAM_PREFIX}/${RUMPRUN_PLATFORM}\"" \
    >>${OPAM_PREFIX}/config/global-config.config
# And the same for `ocaml-rumprun-platform'.
echo "ocaml-rumprun-platform: \"${RUMPRUN_PLATFORM}\"" \
    >>${OPAM_PREFIX}/config/global-config.config

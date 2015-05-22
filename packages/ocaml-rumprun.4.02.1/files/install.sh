#!/bin/sh -e
if [ $# -ne 2 ]; then
    echo "ERROR: usage: install.sh OPAM_PREFIX OPAM_BIN" 1>&2
    exit 1
fi
OPAM_PREFIX="$1"
OPAM_BIN="$2"

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

# Perform substitutions on Makefile.in and rumprun.config.in. We can't do these
# through OPAM as we don't have all the information needed in OPAM variables.
sed -e "s%@OPAM_PREFIX@%${OPAM_PREFIX}%g" \
    -e "s%@RUMPRUN_PLATFORM@%${RUMPRUN_PLATFORM}%g" \
    -e "s%@RUMPRUN_CC@%${RUMPRUN_CC}%g" \
    config/Makefile.in > config/Makefile
sed -e "s%@OPAM_PREFIX@%${OPAM_PREFIX}%g" \
    -e "s%@RUMPRUN_PLATFORM@%${RUMPRUN_PLATFORM}%g" \
    rumprun.conf.in > rumprun.conf

# Build and install the cross compiler.
make world opt install || exit 1

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

# Install a `ocaml-rumprun-prefix' script to record the prefix used for this
# toolchain installation; this is used by cross builds of packages.
cat <<EOM >${OPAM_BIN}/ocaml-rumprun-prefix
#!/bin/sh
echo ${OPAM_PREFIX}/${RUMPRUN_PLATFORM}
EOM
chmod +x ${OPAM_BIN}/ocaml-rumprun-prefix


#!/bin/sh -e
set -x
PREFIX="$1"

# Replace bytecode interpreter with current runtime path.
# XXX: Unclear why the original code does not work.
for bin in ${PREFIX}/x86_64-rumprun-netbsd/bin/*; do
    sed -i "s%^.*ocamlrun$%#\!$(which ocamlrun)%" $bin
done

for pkg in bigarray bytes compiler-libs dynlink findlib graphics num num-top ocamlbuild stdlib str threads unix; do
  cp -r "${PREFIX}/lib/${pkg}" "${PREFIX}/x86_64-rumprun-netbsd/lib/"
done

mkdir -p "${PREFIX}/lib/findlib.conf.d"
cp rumprun.conf "${PREFIX}/lib/findlib.conf.d"

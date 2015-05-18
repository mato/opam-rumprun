#!/bin/sh -e

PREFIX="$1"

for bin in ocaml ocamlbuild ocamlbuild.byte ocamlc ocamlcp ocamldebug ocamldep ocamldoc ocamllex ocamlmklib ocamlmktop ocamlobjinfo ocamlopt ocamloptp ocamlprof ocamlrun ocamlyacc; do
  rm -f "${PREFIX}/x86_64-rumprun-netbsd/bin/${bin}"
done

rm -rf "${PREFIX}/x86_64-rumprun-netbsd/lib/ocaml"
rm -rf "${PREFIX}/lib/findlib.conf.d/rumprun.conf"

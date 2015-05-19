#!/bin/sh

LIB=$1
PREFIX=$2
set -x

ln -sf $LIB/camlp4 $PREFIX/x86_64-rumprun-netbsd/lib/camlp4
[ -n "$OCAMLFIND_TOOLCHAIN" ] && unset OCAMLFIND_TOOLCHAIN
ln -sf $(ocamlfind query camlp4) $PREFIX/x86_64-rumprun-netbsd/lib/ocaml/camlp4


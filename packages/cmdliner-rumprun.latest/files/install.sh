#!/bin/sh

LIB=$1
PREFIX=$2
set -x

ln -sf $LIB/cmdliner $PREFIX/x86_64-rumprun-netbsd/lib/cmdliner
[ -n "$OCAMLFIND_TOOLCHAIN" ] && unset OCAMLFIND_TOOLCHAIN
ln -sf $(ocamlfind query cmdliner) $PREFIX/x86_64-rumprun-netbsd/lib/ocaml/cmdliner


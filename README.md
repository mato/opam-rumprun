# opam-rumprun

OCaml 4.02 toolchain for [rumprun](http://repo.rumpkernel.org/rumprun).

*Experimental work in progress*, may eat your data!

## Prerequisites

* OCaml and OPAM installed.
* If you are on a 64-bit build host and want to build for the rumprun baremetal
  platform, ensure that you are using a _32-bit OCaml compiler_ matching the
  version of `ocaml-rumprun`. `opam switch 4.02.1+32bit` should do the trick.
* A rumprun toolchain, installed according to the
  [instructions](http://wiki.rumpkernel.org/Repo%3A-rumprun) and the
  `app-tools` directory on your `$PATH`.
* Add this repository to your OPAM installation:
````
    opam repository add rumprun git://github.com/mato/opam-rumprun
````

## Pure OCaml "Hello, World"

1. Install the `ocaml-rumprun` package, specifying `RUMPRUN_PLATFORM` as either `rumprun-bmk` (baremetal / KVM / QEMU) or `rumprun-xen` (Xen).
````
    RUMPRUN_PLATFORM=rumprun-bmk opam install ocaml-rumprun
````

2. Build a native "Hello, World!"
````
    echo 'let () = print_endline "Hello, World!" > hello.ml
    ocamlfind -toolchain rumprun ocamlopt hello.ml -o hello
````
3. Run it using (for example) KVM (root required):
````
    rumprun kvm -i ./hello
````

## Mirage on bare metal "Hello, World"

1. `opam install mirage`. Verify that version `2.4.0+rumprun` is installed.
2. Clone the `github.com:mirage/mirage-skeleton` repository.
3. `cd mirage-skeleton`
4. `mirage configure --target rumprun`
5. `make depend && make`
6. `rumprun kvm -i ./mir-console`

*NOTE*: Only the Mirage Console and Clock drivers are functional at the moment.


# opam-rumprun

This OPAM repository contains:

1. _ocaml-rumprun_, an OCaml 4.02 cross compiler for the
   [rumprun](http://repo.rumpkernel.org/rumprun) unikernel stack.
2. _mirage_, a [MirageOS](http://openmirage.org) package which supports rumprun
   as a target.
3. ~25 and counting packages with their build systems fixed to support
   cross-compliation. These packages are required by MirageOS, but can of
   course be used to build standalone OCaml applications running on top of
   rumprun.

*Experimental work in progress*, may eat your data or at least wreak havoc with
your OPAM instrallation! Using a separate OPAM switch is recommended.

# Building the ocaml-rumprun cross compiler

## Prerequisites

* A Linux/x86 or Linux/x86\_64 machine to build on.
* OCaml and [OPAM](https://opam.ocaml.org) installed.

*If you are using an x86_64 machine* to build: ensure that you are using a
32-bit OCaml compiler matching the version of `ocaml-rumprun`. `opam switch
4.02.1+32bit` should do the trick.

Add this repository to your OPAM installation:
````
    opam repository add rumprun git://github.com/mato/opam-rumprun

````

## Build steps

1. Build the [rumprun](http://repo.rumpkernel.org/rumprun) toolchain for the _hw_
platform:

  *On an x86_64 machine*:

  ````
  ./build-rr.sh hw -- -F ACFLAGS=-m32 -F ACLFLAGS=-march=i686
  ````

  *On an x86 machine*:

  ````
  ./build-rr.sh hw
  ````

2. Add the `app-tools` directory added to your `$PATH`.

3. Install the `ocaml-rumprun` package, specifying `RUMPRUN_PLATFORM` either
`rumprun-bmk` (baremetal / KVM / QEMU):
  
  ````
      RUMPRUN_PLATFORM=rumprun-bmk opam install ocaml-rumprun
  ````

# Example: Standalone OCaml

## "Hello, World"

Build a native "Hello, World!":
````
    echo 'let () = print_endline "Hello, World!"' > hello.ml
    ocamlfind -toolchain rumprun ocamlopt hello.ml -o hello
    rumpbake hw_virtio hello.bin hello
````

Run it using (for example) KVM (root may be required):
````
    rumprun kvm -i ./hello.bin
````

## Using the Unix module for POSIX calls

Rumprun provides a POSIX-like environment, so you can use the normal OCaml Unix
module and pthreads. A simple example:

````
    echo 'open Unix;; let () = print_endline (string_of_float (Unix.gettimeofday ()))' > unixtime.ml
    ocamlfind -toolchain rumprun ocamlopt -package unix -linkpkg unixtime.ml -o unixtime
    rumpbake hw_virtio unixtime.bin unixtime
````

Run it using (for example) KVM (root may be required):
````
    rumprun kvm -i ./unixtime.bin
````

# Example: MirageOS on bare metal

The following examples require that you install the MirageOS package:

````
    opam install mirage
    (...)
    ∗  installed mirage.2.5.0+rumprun
    Done.

````
Verify that version _2.5.0+rumprun_ is installed.

You will also need to clone the
[mirage-skeleton](https://github.com/mirage/mirage-skeleton) repository and
check out the _mirage-dev_ branch.

## "Hello, World"

1. `cd mirage-skeleton/console`
2. `mirage configure --target rumprun`
3. `make depend && make`
4. `rumpbake hw_virtio mir-console.bin mir-console`
5. `rumprun kvm -i ./mir-console.bin`

## MirageOS network stack example

1. `cd mirage-skeleton/stackv4`
2. `NET=socket mirage configure --target rumprun`
3. `make depend && make`
4. `rumpbake hw_virtio mir-stackv4.bin mir-stackv4`
5. `rumprun kvm -i [network configuration...] ./mir-stackv4.bin`

For the KVM network configuration, something like this will give you a
host-only tap0 network interface which can talk to the mirage unikernel:

`-I 'qnet0,vioif,-net tap,ifname=tap0' -W qnet0,inet,static,172.20.0.10/24`

The exact syntax depends on your QEMU version, networking setup and the phase
of the moon. YMWV.

## MirageOS static website example

1. `cd mirage-skeleton/static_website`
2. `NET=socket mirage configure --target rumprun`
3. `make depend && make`
4. `rumpbake hw_virtio mir-www.bin mir-www`
5. `rumprun kvm -i [network configuration...] ./mir-www.bin`

# Example: mirage-seal

[mirage-seal](https://github.com/mirage/mirage-seal) is a tool that seals the
contents of a directory into a static unikernel, serving its contents over
HTTP(S).

To use mirage-seal on rumprun:

Add an OPAM pin for the version with rumprun target support:

````
opam pin add mirage-seal git://github.com/mato/mirage-seal#rumprun

````

Put some HTML files in `files/`, and run:
````
mirage-seal -d files/ --no-tls --sockets -t rumprun

````

This will build `./mir-seal` which you can rumpbake and rumprun as appropriate.


# MirageOS status on rumprun

Currently the following MirageOS components are working on rumprun:

* Block
* Clock (However rumprun on KVM/QEMU has no wall time at present)
* Conduit
* Console
* STACKV4\_socket (The socket-based network stack)

Work in progress:

* TLS (Builds and links, but not operational yet)

# QuEST_jl
[![Build Status](https://travis-ci.com/TartuQC/QuEST_jl.svg?branch=dev)](https://travis-ci.com/TartuQC/QuEST_jl)
[![Coverage Status](https://coveralls.io/repos/github/TartuQC/QuEST_jl/badge.svg?branch=dev)](https://coveralls.io/github/TartuQC/QuEST_jl?branch=dev)
#### Julia wrapper for the Quantum Exact Simulation Toolkit (QuEST)

This package makes available the high-performance quantum circuit
simulator as a package in the the Matlab-like rapid-prototyping
scientific computing language [Julia](https://julialang.org/).

## Note on Julia 1.6

Clang.jl currently doesn't work with Julia 1.6, so if you want to use QuEST_jl with Julia 1.6, you have to jump through some hoops:

#### To use Julia 1.6...
1. Git-clone QuEST_jl
2. `] activate` it
3. `(QuEST_jl) pkg> rm Clang`
4. `(QuEST_jl) pkg> add "https://github.com/JuliaInterop/Clang.jl#master"`
5. Build manually: `(QuEST_jl) pkg> build` as described below

## Installation

There are two ways to build Quest_jl, depending on the person building it.

**Expert build** is intended for people who want to tune their QuEST installation to their hardware.
An expert must download and build QuEST himself, and make it compatible with the QuEST_jl expert-build process, see below.

**Non-expert build** is intended for people who are happy with the default QuEST build, but want to QuEST_jl to work out of the box.

### Building QuEST_jl as non-expert

The non-expert build clones a copy of QuEST from our fork, [TartuQC/QuEST](https://github.com/TartuQC/QuEST), which it then automatically compiles using make and C-compiler and whatnot -- you don't want to know.

You do, however, need to have the necessary software on your system.

##### Software requirements on Linux
* Git
* Julia 1.5.4 (currently,
  [Clang.jl](https://github.com/JuliaInterop/Clang.jl) does not work
  with Julia 1.6)
* build-essential (or the equivalent in your Linux distribution)
* CMAKE

##### Software requirements on MacOS
* xcode
* Julia 1.6 (from homebrew) with the hack above to get around the Clang.jl problem.

Note on Apple silicon (e.g., MadcBook Air M1): It doesn't work currently.  Julia comes for x86 out of Homebrew, but the QuEST library is built by xcode for ARM, so Julia cannot load it.

##### Software requirements on Windows 10

*We cannot make the Windows build work right now, as we don't know how to make make make a `.dll` file; see [issue # 10](https://github.com/TartuQC/QuEST_jl/issues/10).

* Git
* Julia 1.5.4 (currently,
  [Clang.jl](https://github.com/JuliaInterop/Clang.jl) does not work
  with Julia 1.6)
* [CMAKE](https://cmake.org/download/) (added to path)
* [make](https://community.chocolatey.org/packages/make) through [chocolatey](https://chocolatey.org/install) package manager
* MSYS with `mingw-w64-x86_64-gcc` and `mingw-w64-x86_64-make` (add
  `msys64/mingw64/bin` to
  path). [Tutorial](https://www.youtube.com/watch?v=aXF4A5UeSeM)
* You may need to start Julia from the Git Bash console.


### Building instructions

Download and build the Julia package like this:

```{julia}
] add QuEST_jl
```

QuEST is automatically cloned from GitHub (from this fork:
https://github.com/Ketita/QuEST) to your Julia packages folder, and
built in two versions, one for 32-bit precision and one for 64-bit
precision.

After that, just use it!  Whenever you use it, you have to decide which
"QuEST precision" you want: wither `Qreal` is 32-bit (Float32) or
64-bit (Float64).  The two variants are in different sub-modules of
QuEST_jl.  For example, to use 32-bit precision, just do this:

```{julia}
using QuEST_jl
const QuEST = QuEST32
qenv = QuEST.createQuESTenv()
```

The QuEST dynamic libary is loaded when you create your (first) QuEST
environment.  In order to switch to another precision, you have to
terminate Julia, and start it again.

### Building QuEST_jl as "expert"

**This hasn't been tested!**

To activate "expert" mode, before building the QuEST_jl package, you have to set the environment variable
```{bash}
export QUEST_JL_EXPERT_BUILD=1
```

The value doesn't matter, the build process checks only *whether* the
environment variable is set or not.

If it is set, QuEST will *not* be cloned from GitHub.  Instead you are
expected to make it available in your own, expertly tuned version.

You need to make available for automatic loading two dynamically loaded libraries, with the names

* `libQuEST_32`  -- compiled with 32-bit precision
* `libQuEST_64`  -- compiled with 64-bit precision.

As in the non-expert version, once you create a QuEST environment with
a precision, the library is loaded, and Julia is bound to that
precision, until you stop Julia.

## Documentation

In Julia:
* The module `QuEST_jl.QuEST`*xx* contains all functions (`createQureg()` and whatnot)
* The module `QuEST_jl.QuEST`*xx*`.QuEST_Types` contains all types (`Qureg` and whatnot)

We refer to QuEST for the documentation of all functions and types.


#### Difference from documented QuEST behavior

* `measureWithStats()`: instead of taking a reference to the probability, the Julia function
  returns a tuple (outcome,probability)

#### Julia-extensions to the QuEST interface

* Type `QuEST𝑥𝑦.QubitIdx` (exported): The element-type for arrays of qubits (a C-integer type)

## Contributing

You can contribute by:
* Using QuEST_jl and reporting bugs by creating issues
* Looking at & resolving some of the issues (this requires familiarity with QuEST)

#### Contribution policies

1. By creating a pull request, you agree to irrevocably license your contribution under the MIT license to the whole universe.
2. To contribute, fork the repository, then create a pull request. In the pull request, note the issue that you're addressing.

#### Code policy

* Type ⃰ all you can!

 ⃰) Restrict the data type of.

## Version History

* Feb 19, 2021: v0.1.0
   * Non-expert build system is running
   * Todo: Tests, expert build system
* May 2020: Project started

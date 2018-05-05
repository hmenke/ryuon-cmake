# ryuon-cmake

[![Build status][travis-svg]][travis-link]

This project provides a CMake-based build system for the [RYUON
libraries](https://kichiki.github.io/ryuon/index.html).  The original
build system is based on GNU autotools which I don't like.
Furthermore cross-dependencies are not automatically detected which
makes the build process unnecessarily hard.

All build dependencies which are not available through the package
repositories of big Linux distributions are included as submodules.
These are

* NITSOL: newton iterative solver for nonlinear systems (written in
  FORTRAN)
* libiter: library containing iterative solvers for linear set of
  equations
* libstokes: solve resistance and mobility problems
* stokes: the Stokesian dynamics simulator

Currently only the `stokes3` executable and the Python interface are
generated.  Let me know in the
[issues](https://github.com/hmenke/ryuon-cmake/issues) if you need
more.

## Usage

The usage is simple.  Just follow your regular CMake workflow.
```bash
mkdir build
cd build
cmake ..
make -j 16
```

## Requirements

* CMake 3.9

    - supported C compiler
    - supported FORTRAN compiler

* ARPACK
* BLAS
* GSL
* Guile
* LAPACK
* NetCDF
* Python 2
* SWIG

To find out which packages you need on Ubuntu, take a look into
`.travis.yml`.

[travis-svg]: https://travis-ci.org/hmenke/ryuon-cmake.svg?branch=master
[travis-link]: https://travis-ci.org/hmenke/ryuon-cmake

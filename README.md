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

The usage is simple.  Just follow your regular CMake workflow.  The
repository has to be cloned recursively because RYUON itself is
incorporated as submodules.
```bash
git clone --recursive https://github.com/hmenke/ryuon-cmake.git
cd ryuon-cmake
mkdir build
cd build
cmake ..
make -j 16
```

## Requirements

* C compiler
* FORTRAN compiler
* CMake (>=3.9)
* ARPACK
* BLAS
* GSL
* Guile (<=2.0) yes, this is indeed **less or equal**
* LAPACK
* NetCDF
* Python 2
* SWIG

On a naked Ubuntu 18.04 LTS you can easily install all the required
dependencies using
```bash
apt-get install build-essential cmake git libarpack2-dev libblas-dev libgsl-dev gfortran guile-2.0-dev liblapack-dev libnetcdf-dev libpython2.7-dev python2.7 swig
```

[travis-svg]: https://travis-ci.org/hmenke/ryuon-cmake.svg?branch=master
[travis-link]: https://travis-ci.org/hmenke/ryuon-cmake

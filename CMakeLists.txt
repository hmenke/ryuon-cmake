cmake_minimum_required(VERSION 3.9 FATAL_ERROR)

project(stokes C)
enable_testing()
enable_language(Fortran)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/libiter/src)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/libstokes/src)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/stokes/src)

# Find all required packages

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})

find_package(ARPACK REQUIRED)
find_package(BLAS REQUIRED)
find_package(GSL REQUIRED)
find_package(Guile REQUIRED)
find_package(LAPACK REQUIRED)
find_package(NetCDF REQUIRED)
find_package(PythonInterp 2 REQUIRED)
find_package(PythonLibs 2 REQUIRED)
find_package(SWIG REQUIRED)

set(SYSTEM_LIBRARIES
  ${ARPACK_LIBRARIES}
  ${BLAS_LIBRARIES}
  ${GSL_LIBRARIES}
  ${GUILE_LIBRARIES}
  ${LAPACK_LIBRARIES}
  ${NETCDF_LIBRARIES})

# Set config flags (emulate autoconf)

set(HAVE_BLAS_H ${BLAS_FOUND})
configure_file(config.h.in ${CMAKE_CURRENT_SOURCE_DIR}/libiter/config.h)

# nitsol

file(GLOB NITSOL_SRC ${CMAKE_CURRENT_SOURCE_DIR}/nitsol/Nitsol/*.f)
add_library(nitsol ${NITSOL_SRC})
target_link_libraries(nitsol ${BLAS_LIBRARIES})

# libiter

file(GLOB LIBITER_SRC ${CMAKE_CURRENT_SOURCE_DIR}/libiter/src/*.c)
add_library(iter ${LIBITER_SRC})
target_link_libraries(iter m ${BLAS_LIBRARIES})

# libstokes

file(GLOB LIBSTOKES_SRC ${CMAKE_CURRENT_SOURCE_DIR}/libstokes/src/*.c)
add_library(stokes ${LIBSTOKES_SRC})
include_directories(${GUILE_INCLUDE_DIRS})
target_link_libraries(stokes nitsol iter ${GUILE_LIBRARIES})

# stokes3

set(STOKES3_SRC
  ${CMAKE_CURRENT_SOURCE_DIR}/stokes/src/file.c
  ${CMAKE_CURRENT_SOURCE_DIR}/stokes/src/stokes3.c)
add_executable(stokes3 ${STOKES3_SRC})
target_link_libraries(stokes3 nitsol iter stokes ${SYSTEM_LIBRARIES})

# Python interface

include(${SWIG_USE_FILE})
include_directories(${PYTHON_INCLUDE_PATH})

swig_add_library(stokes
  LANGUAGE python
  SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/stokes/src/stokes.i)
swig_link_libraries(stokes nitsol iter stokes
  ${SYSTEM_LIBRARIES} ${PYTHON_LIBRARIES})

# Tests

add_executable(test-stokes ${CMAKE_CURRENT_SOURCE_DIR}/stokes/src/test-stokes.c)
target_link_libraries(test-stokes nitsol iter stokes ${SYSTEM_LIBRARIES})
add_test(NAME test-stokes.c COMMAND test-stokes)

file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/stokes/python/test-stokes.py
  DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
add_test(NAME test-stokes.py COMMAND ${PYTHON_EXECUTABLE} test-stokes.py)

# print summary

include(FeatureSummary)
feature_summary(WHAT ALL)

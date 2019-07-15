cmake_minimum_required(VERSION 3.9 FATAL_ERROR)

project(stokes C)
enable_testing()
enable_language(Fortran)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Update the submodules

set(SUBMODULES "libiter;libstokes;nitsol;stokes")
if(EXISTS "${CMAKE_SOURCE_DIR}/.git")
  find_package(Git)
  if(GIT_FOUND)
    execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
  endif()
  foreach(SUBMODULE ${SUBMODULES})
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${SUBMODULE}/.git")
      message(FATAL_ERROR "Submodule ${SUBMODULE} missing!")
    endif()
  endforeach()
endif()

# Include the RYUON sources

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
if(GUILE_VERSION VERSION_GREATER 1.9) # Require Guile 1.8.x
  message(FATAL_ERROR "RYUON requires Guile with version <= 1.8 but ${GUILE_VERSION} was found.")
endif()
find_package(LAPACK REQUIRED)
find_package(NetCDF REQUIRED)
find_package(PythonInterp 2 REQUIRED)
find_package(PythonLibs 2 REQUIRED)

execute_process(
  COMMAND "${PYTHON_EXECUTABLE}" -c "from distutils.sysconfig import get_python_lib; print(get_python_lib(prefix=''));"
  OUTPUT_VARIABLE PY_MOD_DIR
  OUTPUT_STRIP_TRAILING_WHITESPACE
  ERROR_VARIABLE PY_MOD_ERR)

message(STATUS "Python module directory: ${PY_MOD_DIR}")

if((PY_MOD_DIR STREQUAL "") OR NOT (PY_MOD_ERR STREQUAL ""))
  message(FATAL_ERROR "${PY_MOD_ERR}")
endif()

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
add_library(nitsol_object OBJECT ${NITSOL_SRC})
add_library(nitsol_static STATIC $<TARGET_OBJECTS:nitsol_object>)
set_target_properties(nitsol_static PROPERTIES OUTPUT_NAME nitsol)
target_link_libraries(nitsol_static ${BLAS_LIBRARIES})
add_library(nitsol_shared SHARED $<TARGET_OBJECTS:nitsol_object>)
set_target_properties(nitsol_shared PROPERTIES OUTPUT_NAME nitsol)
target_link_libraries(nitsol_shared ${BLAS_LIBRARIES})

# libiter

file(GLOB LIBITER_SRC ${CMAKE_CURRENT_SOURCE_DIR}/libiter/src/*.c)
add_library(iter_object OBJECT ${LIBITER_SRC})
add_library(iter_static STATIC $<TARGET_OBJECTS:iter_object>)
set_target_properties(iter_static PROPERTIES OUTPUT_NAME iter)
target_link_libraries(iter_static m ${BLAS_LIBRARIES})
add_library(iter_shared SHARED $<TARGET_OBJECTS:iter_object>)
set_target_properties(iter_shared PROPERTIES OUTPUT_NAME iter)
target_link_libraries(iter_shared m ${BLAS_LIBRARIES})

# libstokes

file(GLOB LIBSTOKES_SRC ${CMAKE_CURRENT_SOURCE_DIR}/libstokes/src/*.c)
add_library(stokes_object OBJECT ${LIBSTOKES_SRC})
add_library(stokes_static STATIC $<TARGET_OBJECTS:stokes_object>)
set_target_properties(stokes_static PROPERTIES OUTPUT_NAME stokes)
include_directories(${GUILE_INCLUDE_DIRS})
target_link_libraries(stokes_static nitsol_static iter_static ${SYSTEM_LIBRARIES})
add_library(stokes_shared SHARED $<TARGET_OBJECTS:stokes_object>)
set_target_properties(stokes_shared PROPERTIES OUTPUT_NAME stokes)
target_link_libraries(stokes_shared nitsol_shared iter_shared ${SYSTEM_LIBRARIES})
# stokes3

set(STOKES3_SRC
  ${CMAKE_CURRENT_SOURCE_DIR}/stokes/src/file.c
  ${CMAKE_CURRENT_SOURCE_DIR}/stokes/src/stokes3.c)
add_executable(stokes3 ${STOKES3_SRC})
target_link_libraries(stokes3 nitsol_static iter_static stokes_static ${SYSTEM_LIBRARIES})

# Python interface

include(${SWIG_USE_FILE})
include_directories(${PYTHON_INCLUDE_PATH})

swig_add_library(stokes
  LANGUAGE python
  SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/stokes/src/stokes.i)
swig_link_libraries(stokes nitsol_static iter_static stokes_static
  ${SYSTEM_LIBRARIES} ${PYTHON_LIBRARIES})

# Tests

add_executable(test-stokes ${CMAKE_CURRENT_SOURCE_DIR}/stokes/src/test-stokes.c)
target_link_libraries(test-stokes nitsol_static iter_static stokes_static ${SYSTEM_LIBRARIES})
add_test(NAME test-stokes.c COMMAND test-stokes)

file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/stokes/python/test-stokes.py
  DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
add_test(NAME test-stokes.py COMMAND ${PYTHON_EXECUTABLE} test-stokes.py)

# Installation targets

# Install nitsol
install(FILES nitsol.h DESTINATION include/nitsol)
install(TARGETS nitsol_shared LIBRARY DESTINATION lib)

# Install libiter
install(DIRECTORY libiter/src/ DESTINATION include/libiter FILES_MATCHING PATTERN "*.h")
install(TARGETS iter_shared LIBRARY DESTINATION lib)

# Install libstokes
install(DIRECTORY libstokes/src/ DESTINATION include/libstokes FILES_MATCHING PATTERN "*.h")
install(TARGETS stokes_shared LIBRARY DESTINATION lib)

# Install Python modules
file(WRITE ${CMAKE_BINARY_DIR}/__init__.py "from stokes import *")
install(FILES ${CMAKE_BINARY_DIR}/__init__.py DESTINATION ${PY_MOD_DIR}/stokes)
install(FILES ${CMAKE_BINARY_DIR}/stokes.py DESTINATION ${PY_MOD_DIR}/stokes)
install(TARGETS _stokes LIBRARY DESTINATION ${PY_MOD_DIR}/stokes)

# print summary

include(FeatureSummary)
feature_summary(WHAT ALL)

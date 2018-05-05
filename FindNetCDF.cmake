find_path(NETCDF_INCLUDE_DIR netcdf.h)

find_library(NETCDF_LIBRARY NAMES netcdf)

set(NETCDF_LIBRARIES ${NETCDF_LIBRARY})
set(NETCDF_INCLUDE_DIRS ${NETCDF_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(NetCDF REQUIRED_VARS NETCDF_INCLUDE_DIRS NETCDF_LIBRARIES)

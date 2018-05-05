find_library(ARPACK_LIBRARY NAMES arpack)

set(ARPACK_LIBRARIES ${ARPACK_LIBRARY})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ARPACK REQUIRED_VARS ARPACK_LIBRARIES)

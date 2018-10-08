# Find the native numpy includes
# This module defines
#  NUMPY_INCLUDE_DIR, where to find numpy/arrayobject.h, etc.
#  NUMPY_FOUND, If false, do not try to use numpy headers.

# first find python executable
if ("${Python3_EXECUTABLE}" STREQUAL "")
  message(FATAL_ERROR "Python3 executable not found while searching for package NumPy!")
endif()

if (NOT NUMPY_INCLUDE_DIR)
    execute_process(COMMAND ${Python3_EXECUTABLE} -c "import numpy; print(numpy.get_include())"
      OUTPUT_VARIABLE NUMPY_INCLUDE_DIR)
    if(NUMPY_INCLUDE_DIR MATCHES "Traceback")
    # Did not successfully include numpy
      set(NUMPY_FOUND FALSE)
    else(NUMPY_INCLUDE_DIR MATCHES "Traceback")
    # successful
      set(NUMPY_FOUND TRUE)
      set(NUMPY_INCLUDE_DIR ${NUMPY_INCLUDE_DIR} CACHE PATH "Numpy include path")
    endif()
    if(NUMPY_FOUND)
      if(NOT NUMPY_FIND_QUIETLY)
        message (STATUS "Numpy headers found")
      endif()
    else(NUMPY_FOUND)
      if(NUMPY_FIND_REQUIRED)
        message (FATAL_ERROR "Numpy headers missing")
      endif()
    endif()
    mark_as_advanced(NUMPY_INCLUDE_DIR)
endif(NOT NUMPY_INCLUDE_DIR)

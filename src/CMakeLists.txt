##############################################
#          Library Creation                  #
##############################################
set(LIBRARY_NAME matplotlib-cpp)
set(LIB_MAJOR 0)
set(LIB_MINOR 0)
set(LIB_RELEASE 1)

set(SRCS
    matplotlib-cpp.cpp
)

add_library(${LIBRARY_NAME} SHARED
  ${SRCS}
  )

target_link_libraries(${LIBRARY_NAME}
  PUBLIC
    Python3::Python
)

target_compile_features(${LIBRARY_NAME}
  PUBLIC
    cxx_std_14
  )

set(_soversion ${LIB_MAJOR}.${LIB_MINOR}.${LIB_RELEASE})

set_target_properties(
  ${LIBRARY_NAME}
  PROPERTIES
  SOVERSION ${LIB_MAJOR}
  VERSION ${_soversion}
  )

# target_include_directories(${LIBRARY_NAME}
#   PUBLIC
#   "$<INSTALL_INTERFACE:include;${NUMPY_INCLUDE_DIR}>"
#   "$<BUILD_INTERFACE:${PROJECT_INC_DIR};${NUMPY_INCLUDE_DIR}>"
# )
target_include_directories(${LIBRARY_NAME}
  PUBLIC
  "$<INSTALL_INTERFACE:include;${NUMPY_INCLUDE_DIR}>"
  "$<BUILD_INTERFACE:${PROJECT_INC_DIR};${NUMPY_INCLUDE_DIR}>"
)

install(TARGETS ${LIBRARY_NAME}
  # IMPORTANT: Add the library to the "export-set"
  EXPORT ${PROJECT_NAME}-targets
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
)

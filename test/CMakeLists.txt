add_executable(minimal minimal.cpp)
target_link_libraries(minimal
  PUBLIC
    Python3::Python)

target_compile_features(minimal
  PUBLIC
    cxx_std_14)

target_include_directories(minimal
  PUBLIC
  "$<INSTALL_INTERFACE:include;${NUMPY_INCLUDE_DIR}>"
  "$<BUILD_INTERFACE:${PROJECT_INC_DIR};${NUMPY_INCLUDE_DIR}>")

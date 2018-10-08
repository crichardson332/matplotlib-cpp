cmake_minimum_required(VERSION 3.8)

option(ADD_HOME_LOCAL_PREFIX "Add ~/.local to cmake prefix" ON)
if(ADD_HOME_LOCAL_PREFIX)
  set(CMAKE_PREFIX_PATH $ENV{HOME}/.local/ ${CMAKE_PREFIX_PATH})
endif()

# see : https://crascit.com/2016/04/09/using-ccache-with-cmake/
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CCACHE_PROGRAM}")
else()
  message("ccache not found, repeated builds will be faster if this program is installed")
endif()

project(matplotlib-cpp)

set(PROJECT_VERSION_MAJOR "0")
set(PROJECT_VERSION_MINOR "0")
set(PROJECT_VERSION_PATCH "0")
set(PROJECT_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
set(PROJECT_VERSION_DATE "2018.08.08")

# give PROJECT 1 series a few more soversions
set(PROJECT_SOVERSION "00")

if(NOT CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX /usr/local)
endif()

# fetch all the local directories for generated code
get_filename_component(PROJECT_LIB_DIR ${PROJECT_BINARY_DIR}/lib ABSOLUTE)
get_filename_component(PROJECT_BIN_DIR ${PROJECT_BINARY_DIR}/bin ABSOLUTE)
get_filename_component(PROJECT_INC_DIR ./include ABSOLUTE)
# get_filename_component(PROJECT_SRC_DIR ./src ABSOLUTE)
# get_filename_component(PROJECT_SHARE_DIR ./share ABSOLUTE)
# get_filename_component(PROJECT_SCRIPTS_DIR ./scripts ABSOLUTE)
# get_filename_component(PROJECT_SETUP_DIR ./setup ABSOLUTE)
get_filename_component(PROJECT_MODULES_DIR ./cmake/Modules ABSOLUTE)
set(PROJECT_CMAKE_DIR ${PROJECT_SOURCE_DIR})

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${PROJECT_MODULES_DIR})

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING
    "Choose the type of build, options are: Debug Release
      RelWithDebInfo MinSizeRel." FORCE)
endif()

set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BIN_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_LIB_DIR})

## set the cmake defaults for libraries and binaries
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_LIB_DIR} CACHE PATH
  "Output directory for the dynamic libraries" )
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BIN_DIR} CACHE PATH
  "Output directory for the binaries" )
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_LIB_DIR} CACHE PATH
  "Output directory for the static libraries (archives)" )

# Find python
find_package(Python3 REQUIRED COMPONENTS Interpreter Development)
find_package(NumPy REQUIRED)
message("numpy include dir: " ${NUMPY_INCLUDE_DIR})
include_directories(${NUMPY_INCLUDE_DIR})

#add_subdirectory(share)
#add_subdirectory(msgs)
add_subdirectory(src)

if(BUILD_TESTS)
  add_subdirectory(test)
endif()

option(BUILD_DOCS "Build documentation" OFF)
if (BUILD_DOCS)
  add_subdirectory(docs)
endif()

# add_subdirectory(test)

# Add a distclean target to the Makefile
set (DIST_CLEAN_DIRS "${PROJECT_LIB_DIR};${PROJECT_BIN_DIR};${PROJECT_PLUGIN_LIBS_DIR};${CMAKE_BINARY_DIR}")
ADD_CUSTOM_TARGET(distclean
  COMMAND ${CMAKE_COMMAND} -DDIRS_TO_REMOVE="${DIST_CLEAN_DIRS}" -P ${PROJECT_SOURCE_DIR}/cmake/Modules/distclean.cmake
  )

###############################################################################
# Installation
###############################################################################
set(PROJECT_DESCRIPTION "Matplotlib library for C++")

#############################################################################
# Generate the cmake configuration files for the build tree
#############################################################################
include(CMakePackageConfigHelpers)

set(INCLUDE_INSTALL_DIR include/ CACHE PATH "Include install dir")
set(LIB_INSTALL_DIR lib/ CACHE PATH "Library install dir")
set(CMAKE_CONFIG_DEST "${LIB_INSTALL_DIR}/${PROJECT_NAME}/cmake")

configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/project-config.cmake.in
  ${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake
  INSTALL_DESTINATION ${PROJECT_BINARY_DIR}
  PATH_VARS INCLUDE_INSTALL_DIR
  )

write_basic_package_version_file(
  ${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
  )

# Export project export set to the build tree
export(
  EXPORT ${PROJECT_NAME}-targets
  FILE "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-targets.cmake"
  )

# Export the package for use from the build-tree
# (this registers the build-tree with a global CMake-registry ~/.cmake)
export(PACKAGE ${PROJECT_NAME})

#############################################################################
# Generate the cmake configuration files for the install tree
#############################################################################
configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/project-config.cmake.in
  ${PROJECT_BINARY_DIR}/${CMAKE_FILES_DIRECTORY}/${PROJECT_NAME}-config.cmake
  INSTALL_DESTINATION ${CMAKE_CONFIG_DEST}
  PATH_VARS INCLUDE_INSTALL_DIR
  )

write_basic_package_version_file(
  ${PROJECT_BINARY_DIR}/${CMAKE_FILES_DIRECTORY}/${PROJECT_NAME}-config-version.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
  )

# Install cmake config files
install(FILES ${PROJECT_BINARY_DIR}/${CMAKE_FILES_DIRECTORY}/${PROJECT_NAME}-config.cmake
  ${PROJECT_BINARY_DIR}/${CMAKE_FILES_DIRECTORY}/${PROJECT_NAME}-config-version.cmake
  DESTINATION ${CMAKE_CONFIG_DEST})

# install export targets
install(
  EXPORT ${PROJECT_NAME}-targets
  DESTINATION ${CMAKE_CONFIG_DEST}
  )

#############################################################################
# Install Targets
#############################################################################

# Install all library headers
install(
  DIRECTORY include/${PROJECT_NAME}
  DESTINATION include
  )

if(UNIX AND NOT APPLE)
  # Create the ld.so.conf.d/project.conf file
  file(WRITE
    ${PROJECT_BINARY_DIR}/${CMAKE_FILES_DIRECTORY}/${PROJECT_NAME}.conf
    ${CMAKE_INSTALL_PREFIX}/lib
    )
  install(
    FILES ${PROJECT_BINARY_DIR}/${CMAKE_FILES_DIRECTORY}/${PROJECT_NAME}.conf
    DESTINATION /etc/ld.so.conf.d
    )
endif()

###############################################################################
# Binary installation generation
###############################################################################
if(UNIX AND NOT APPLE)
  set(CPACK_INSTALL_CMAKE_PROJECTS "${PROJECT_BINARY_DIR};${PROJECT_NAME};ALL;/")
  set(CPACK_OUTPUT_CONFIG_FILE "${PROJECT_BINARY_DIR}/CPackConfig.cmake")
  set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_DESCRIPTION}")
  set(CPACK_GENERATOR "DEB")
  set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
  set(CPACK_PACKAGE_RELEASE 1)
  set(CPACK_PACKAGE_CONTACT "Christopher Richardson")
  set(CPACK_PACKAGE_VENDOR "GTRI")
  set(CPACK_PACKAGING_INSTALL_PREFIX "/usr")
  set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${CMAKE_SYSTEM_PROCESSOR}")
  include(CPack)
endif()

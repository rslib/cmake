cmake_minimum_required(VERSION 3.14)

project(rs-cmake VERSION 1.0.0 LANGUAGES NONE)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Define the module directory for use by consumers
set(RS_CMAKE_MODULE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Install cmake modules
install(
  DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/cmake/
  DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/rs-cmake/modules
  FILES_MATCHING
  PATTERN "*.cmake"
)

# Generate package config
configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/rs-cmakeConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/rs-cmakeConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/rs-cmake
)

# Generate version file
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/rs-cmakeConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)

# Install config files
install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/rs-cmakeConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/rs-cmakeConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/rs-cmake
)

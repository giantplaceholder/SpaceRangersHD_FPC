cmake_minimum_required(VERSION 3.20)
project(rangers_native LANGUAGES C)
set(OKGF_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../vendor/okgf")
if(NOT EXISTS "${OKGF_ROOT}/CMakeLists.txt")
  message(FATAL_ERROR "Initialize dependencies with: git submodule update --init --recursive")
endif()
# Use host arithmetic for graphics on every target. FORCE also updates existing
# build directories that previously selected EXACT on x86.
set(OKGF_MATH_BACKEND
    NATIVE
    CACHE STRING "OKGF arithmetic backend" FORCE)
add_subdirectory("${OKGF_ROOT}" okgf)
set_target_properties(okgf PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
if(APPLE)
  set_target_properties(okgf PROPERTIES BUILD_WITH_INSTALL_NAME_DIR YES INSTALL_NAME_DIR "@rpath")
endif()
if(ANDROID)
  target_link_options(okgf PRIVATE "-Wl,-z,max-page-size=16384")
endif()

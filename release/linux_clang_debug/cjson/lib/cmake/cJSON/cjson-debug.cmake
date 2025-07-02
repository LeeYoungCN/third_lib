#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "cjson" for configuration "Debug"
set_property(TARGET cjson APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(cjson PROPERTIES
  IMPORTED_LINK_INTERFACE_LIBRARIES_DEBUG "m"
  IMPORTED_LOCATION_DEBUG "/home/ly/code/third_lib/release/linux_clang_debug/cjson/lib/libcjson.so.1.7.15"
  IMPORTED_SONAME_DEBUG "libcjson.so.1"
  )

list(APPEND _cmake_import_check_targets cjson )
list(APPEND _cmake_import_check_files_for_cjson "/home/ly/code/third_lib/release/linux_clang_debug/cjson/lib/libcjson.so.1.7.15" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)

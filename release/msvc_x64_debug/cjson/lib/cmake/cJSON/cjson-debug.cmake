#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "cjson" for configuration "Debug"
set_property(TARGET cjson APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(cjson PROPERTIES
  IMPORTED_IMPLIB_DEBUG "E:/Program/third_lib/release/msvc_x64_debug/cjson/lib/cjson.lib"
  IMPORTED_LOCATION_DEBUG "E:/Program/third_lib/release/msvc_x64_debug/cjson/bin/cjson.dll"
  )

list(APPEND _cmake_import_check_targets cjson )
list(APPEND _cmake_import_check_files_for_cjson "E:/Program/third_lib/release/msvc_x64_debug/cjson/lib/cjson.lib" "E:/Program/third_lib/release/msvc_x64_debug/cjson/bin/cjson.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)

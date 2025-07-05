#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "cjson" for configuration "Debug"
set_property(TARGET cjson APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(cjson PROPERTIES
  IMPORTED_LOCATION_DEBUG "/Users/xuyingying/Code_LY/third_lib/release/darwin_clang_debug/cjson/lib/libcjson.1.7.15.dylib"
  IMPORTED_SONAME_DEBUG "@rpath/libcjson.1.dylib"
  )

list(APPEND _cmake_import_check_targets cjson )
list(APPEND _cmake_import_check_files_for_cjson "/Users/xuyingying/Code_LY/third_lib/release/darwin_clang_debug/cjson/lib/libcjson.1.7.15.dylib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)

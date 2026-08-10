cmake_minimum_required(VERSION 3.14)
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(FATAL_ERROR
    "In-source builds are not supported. "
    "You may need to delete 'CMakeCache.txt' and 'CMakeFiles/' before rebuilding this project."
  )
endif()

project(libserialport
  VERSION 0.1.2
  LANGUAGES C
)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/libserialport_compiler_options.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/libserialport_platform_config.cmake)

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/src/config.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/include/config.h
)

set(sp_sources
  src/serialport.c
  src/timing.c
)
if (WIN32)
  list(APPEND sp_sources src/windows.c)
elseif(UNIX)
  list(APPEND sp_sources
    src/linux.c
    src/linux_termios.c
  )
  if(APPLE)
    list(APPEND sp_sources src/macosx.c)
  endif()
endif()
if(CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
  list(APPEND sp_sources src/freebsd.c)
endif()

add_library(libserialport ${SERIAL_LIB_TYPE} ${sp_sources})
add_library(libserialport::libserialport ALIAS libserialport)
target_link_libraries(libserialport PRIVATE libserialport_internal_options)
target_include_directories(libserialport
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  PRIVATE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
)
if(WIN32)
  target_link_libraries(libserialport PRIVATE cfgmgr32 SetupAPI)
endif()
if(BUILD_SHARED_LIBS)
  target_compile_definitions(libserialport
    PRIVATE
      LIBSERIALPORT_LIB_EXPORT
    INTERFACE
      LIBSERIALPORT_SHARED
  )
endif()

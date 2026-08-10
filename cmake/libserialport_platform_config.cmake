#[=======================================================================[.rst:
Setup System Libraries
----------------------

Checks for and links against required system libraries based on feature
detection rather than hardcoded OS checks where possible.
#]=======================================================================]

include(CheckIncludeFiles)
include(CheckSymbolExists)
include(CheckLibraryExists)
include(CheckTypeSize)
include(CheckCSourceCompiles)

# ---------- Standard header checks ----------

check_include_files("inttypes.h" HAVE_INTTYPES_H)
check_include_files("sys/types.h" HAVE_SYS_TYPES_H)
check_include_files("sys/stat.h" HAVE_SYS_STAT_H)
check_include_files("stdlib.h" HAVE_STDLIB_H)
check_include_files("string.h" HAVE_STRING_H)
check_include_files("memory.h" HAVE_MEMORY_H)
check_include_files("strings.h" HAVE_STRINGS_H)
check_include_files("stdint.h" HAVE_STDINT_H)
check_include_files("unistd.h" HAVE_UNISTD_H)
check_include_files("dlfcn.h" HAVE_DLFCN_H)
check_include_files("sys/file.h" HAVE_SYS_FILE_H)

# ---------- STDC_HEADERS ----------

check_c_source_compiles("
  #include <stdlib.h>
  #include <stdarg.h>
  #include <string.h>
  #include <float.h>
  int main(void) { return 0; }
" STDC_HEADERS)

# ---------- Function checks ----------

check_symbol_exists("clock_gettime" "time.h" HAVE_CLOCK_GETTIME)
check_symbol_exists("realpath" "stdlib.h" HAVE_REALPATH)
check_symbol_exists("flock" "sys/file.h" HAVE_FLOCK)
check_symbol_exists("memrchr" "string.h" HAVE_MEMRCHR)

if(UNIX AND NOT APPLE)
  if(NOT HAVE_CLOCK_GETTIME)
    check_library_exists("rt" "clock_gettime" "" HAVE_CLOCK_GETTIME_IN_RT)
    if(HAVE_CLOCK_GETTIME_IN_RT)
      set(HAVE_CLOCK_GETTIME TRUE)
      target_link_libraries(libserialport_internal_options INTERFACE rt)
    endif()
  endif()
endif()

# ---------- Linux-specific checks ----------

if(CMAKE_SYSTEM_NAME MATCHES "Linux")
  # struct termios2
  set(CMAKE_REQUIRED_INCLUDES_SAVE ${CMAKE_REQUIRED_INCLUDES})
  set(CMAKE_REQUIRED_INCLUDES "linux/termios.h")
  check_type_size("struct termios2" HAVE_STRUCT_TERMIOS2 BUILTIN_TYPES_ONLY LANGUAGE C)
  set(CMAKE_REQUIRED_INCLUDES ${CMAKE_REQUIRED_INCLUDES_SAVE})

  # struct serial_struct
  set(CMAKE_REQUIRED_INCLUDES_SAVE ${CMAKE_REQUIRED_INCLUDES})
  set(CMAKE_REQUIRED_INCLUDES "linux/serial.h")
  check_type_size("struct serial_struct" HAVE_STRUCT_SERIAL_STRUCT BUILTIN_TYPES_ONLY LANGUAGE C)
  set(CMAKE_REQUIRED_INCLUDES ${CMAKE_REQUIRED_INCLUDES_SAVE})

  # struct termios / termios2 speed members
  set(CMAKE_REQUIRED_INCLUDES_SAVE ${CMAKE_REQUIRED_INCLUDES})
  set(CMAKE_REQUIRED_INCLUDES "linux/termios.h")
  check_c_source_compiles("
    #include <linux/termios.h>
    int main(void) {
      struct termios t;
      (void)t.c_ispeed;
      (void)t.c_ospeed;
      return 0;
    }
  " HAVE_STRUCT_TERMIOS_C_ISPEED_OSPEED)
  if(HAVE_STRUCT_TERMIOS_C_ISPEED_OSPEED)
    set(HAVE_STRUCT_TERMIOS_C_ISPEED 1)
    set(HAVE_STRUCT_TERMIOS_C_OSPEED 1)
  endif()
  check_c_source_compiles("
    #include <linux/termios.h>
    int main(void) {
      struct termios2 t;
      (void)t.c_ispeed;
      (void)t.c_ospeed;
      return 0;
    }
  " HAVE_STRUCT_TERMIOS2_C_ISPEED_OSPEED)
  if(HAVE_STRUCT_TERMIOS2_C_ISPEED_OSPEED)
    set(HAVE_STRUCT_TERMIOS2_C_ISPEED 1)
    set(HAVE_STRUCT_TERMIOS2_C_OSPEED 1)
  endif()
  set(CMAKE_REQUIRED_INCLUDES ${CMAKE_REQUIRED_INCLUDES_SAVE})

  # BOTHER declaration
  set(CMAKE_REQUIRED_INCLUDES_SAVE ${CMAKE_REQUIRED_INCLUDES})
  set(CMAKE_REQUIRED_INCLUDES "linux/termios.h")
  check_symbol_exists("BOTHER" "linux/termios.h" HAVE_DECL_BOTHER)
  set(CMAKE_REQUIRED_INCLUDES ${CMAKE_REQUIRED_INCLUDES_SAVE})
endif()

# ---------- Platform feature macros ----------

# libserialport only supports enumeration/metadata on known platforms.
if(NOT CMAKE_SYSTEM_NAME MATCHES "Linux|Darwin|Windows|FreeBSD")
  set(NO_ENUMERATION 1)
  set(NO_PORT_METADATA 1)
endif()

# ---------- Package identity ----------

set(PACKAGE_NAME "${PROJECT_NAME}")
set(PACKAGE_VERSION "${PROJECT_VERSION}")
set(PACKAGE_STRING "${PROJECT_NAME} ${PROJECT_VERSION}")
set(PACKAGE_TARNAME "${PROJECT_NAME}")
set(PACKAGE_BUGREPORT "martin-libserialport@earth.li")
set(PACKAGE_URL "http://sigrok.org/wiki/Libserialport")

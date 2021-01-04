include(CheckCSourceCompiles)
include(CheckIncludeFile)
include(CheckFunctionExists)
include(CheckTypeSize)
include(GNUInstallDirs) # For install paths

# We install so many files... skip up-to-date messages
set(CMAKE_INSTALL_MESSAGE LAZY)

# Language support
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED TRUE)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

# Should be available in C++11 but not all systems have it
check_function_exists(at_quick_exit HAVE_AT_QUICK_EXIT)

# Required to generate the network protocol implementation
find_package(PythonInterp 3 REQUIRED)

# Required as the main networking and utility library
find_package(Qt5 5.10 COMPONENTS Core Network REQUIRED)


# Required for utility
find_package(Iconv)
if(Iconv_FOUND)
  set(HAVE_ICONV TRUE) # For compiler macro
  set(FREECIV_HAVE_ICONV TRUE) # For CMake code
endif()
find_package(Readline REQUIRED)

# Internationalization
add_custom_target(freeciv_translations)
if(FREECIV_ENABLE_NLS)
  find_package(Intl REQUIRED)
  set(FREECIV_HAVE_LIBINTL_H TRUE)
  set(ENABLE_NLS TRUE)
  set(LOCALEDIR "${CMAKE_INSTALL_FULL_LOCALEDIR}")
  include(GettextTranslate)
  set(GettextTranslate_GMO_BINARY TRUE)
  set(GettextTranslate_POT_BINARY TRUE)
  add_subdirectory(translations/core)
  add_subdirectory(translations/nations)
  add_dependencies(freeciv_translations freeciv-core.pot-update)
  add_dependencies(freeciv_translations freeciv-nations.pot-update)
  if (FREECIV_BUILD_TOOLS EQUAL ON)
    add_subdirectory(translations/ruledit)
    add_dependencies(ruledit_translations freeciv-ruledit.pot-update)
  endif()
  add_dependencies(freeciv_translations update-po)
  add_dependencies(freeciv_translations update-gmo)
endif()

# SDL2 for audio
find_package(SDL2 QUIET)
find_package(SDL2_mixer QUIET)
if (SDL2_MIXER_LIBRARIES AND SDL2_LIBRARY)
  set(AUDIO_SDL TRUE)
endif()
if (NOT SDL2_LIBRARY)
  message("SDL2 not found")
  set(SDL2_INCLUDE_DIR "")
endif()
if (NOT SDL2_MIXER_LIBRARIES)
  message("SDL2_mixer not found")
  set(SDL2_MIXER_LIBRARIES "")
  set(SDL2_MIXER_INCLUDE_DIR "")
endif()

# Lua
#
# Lua is not binary compatible even between minor releases. We stick to Lua 5.4.
#
# The tolua program is compatible with Lua 5.4, but the library may not be (eg
# on Debian it's linked to Lua 5.2). We always build the library. When not
# cross-compiling, we can also build the program. When cross-compiling, an
# externally provided tolua program is required (or an emulator for the target
# platform, eg qemu).
if (CMAKE_CROSSCOMPILING AND NOT CMAKE_CROSSCOMPILING_EMULATOR)
  find_package(ToLuaProgram REQUIRED)
else()
  find_package(ToLuaProgram)
endif()
add_subdirectory(dependencies/lua-5.4)
add_subdirectory(dependencies/tolua-5.2) # Will build the program if not found.

# backward-cpp
include(FreecivBackward)

# Compression
find_package(KF5Archive REQUIRED)
set(FREECIV_HAVE_BZ2 ${KArchive_HAVE_BZIP2})
set(FREECIV_HAVE_LZMA ${KArchive_HAVE_LZMA})

find_package(ZLIB REQUIRED) # Network protocol code

# Some systems don't have a well-defined root user
if (EMSCRIPTEN)
  set(ALWAYS_ROOT TRUE)
endif()

# Networking library
if (WIN32 OR MINGW OR MSYS)
  set(FREECIV_MSWINDOWS TRUE)
endif()

if (EMSCRIPTEN)
  # This is a bit hacky and maybe it should be removed.
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s ERROR_ON_UNDEFINED_SYMBOLS=0")
endif()

if (FREECIV_BUILD_LIBCLIENT)
  # Version comparison library (this should really be part of utility/)
  add_subdirectory(dependencies/cvercmp)
endif()

# GUI dependencies
if (FREECIV_ENABLE_CLIENT
    OR FREECIV_ENABLE_FCMP_QT
    OR FREECIV_ENABLE_RULEDIT)
  # May want to relax the version later
  find_package(Qt5 5.10 COMPONENTS Widgets REQUIRED)
endif()

# FCMP-specific dependencies
if (FREECIV_ENABLE_FCMP_CLI OR FREECIV_ENABLE_FCMP_QT)
  find_package(SQLite3 REQUIRED)
endif()

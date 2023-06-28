#############################################################################
#
# Baysen Inc Limited.
# Copyright (C) 2014 - 2023. All rights reserved.
#
# This software is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# See the file LICENSE.txt at the root directory of this source
# distribution for additional information about the GNU GPL.
#
# For using this code with software that can not be combined with the GNU
# GPL, please contact Baysen Inc. about acquiring a Professional
# Edition License.
#
# See https://baysen.com/licenses for more information.
#
# This software was developed at:
# Baysen Inc. Limited 
# Campus Chengdu
# 5 Gaopeng Ave. Suite B-208
# Chengdu, China
#
#
# This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
# WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
# Description:
# CMake configuration file for GenICam
#
# GENICAM_FOUND
# GENICAM_INCLUDE_DIRS
# GENICAM_LIBRARIES
# 
#
# Authors:
# Nan Zhang
# 
#
#############################################################################


get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/" ABSOLUTE)

if (UNIX)
  # try to get architecture from compiler
  EXECUTE_PROCESS(COMMAND ${CMAKE_CXX_COMPILER} -dumpmachine COMMAND tr -d '\n' OUTPUT_VARIABLE CXX_MACHINE)
  string(REGEX REPLACE "([a-zA-Z_0-9]+).*" "\\1" ARCHITECTURE ${CXX_MACHINE})
elseif (WIN32)
  if ("${CMAKE_SIZEOF_VOID_P}" STREQUAL "4")
    set(ARCHITECTURE WIN32_i86)
  else ()
    set(ARCHITECTURE WIN64_x64)
  endif ()
endif ()

message(STATUS "FindGenICam Detected architecture ${ARCHITECTURE}")

# Try to use Basler Pylon implementation of GenICam
if("$ENV{PYLON_DEV_DIR}" STREQUAL "")
  message(STATUS "FindGenICam: PYLON_DEV_DIR not set. Install Basler Pylon SDK and set the PYLON_DEV_DIR environment variable")
  set(GENICAM_FOUND FALSE)
  return()
endif()

find_path(GENICAM_INCLUDE_DIR GenICam.h
    PATHS "$ENV{PYLON_DEV_DIR}/include/")

message(STATUS "GenICam inlude directory: ${GENICAM_INCLUDE_DIR}")
# Use file read to get the genicam version from _GenICamVersion.h
file(READ "${GENICAM_INCLUDE_DIR}/_GenICamVersion.h" header)
string(REGEX MATCH "#define GENICAM_VERSION_MAJOR [0-9]+" majordef "${header}")
string(REGEX MATCH "[0-9]+" GENICAM_MAJOR_VER "${majordef}")
string(REGEX MATCH "#define GENICAM_VERSION_MINOR [0-9]+" minordef "${header}")
string(REGEX MATCH "[0-9]+" GENICAM_MINOR_VER "${minordef}")
string(REGEX MATCH "#define GENICAM_MAIN_COMPILER [a-zA-Z]+[0-9]+" compilerdef "${header}")
string(REGEX REPLACE "([^ ]+) ([^ ]+) ([^ ]+).*" "\\3" GENICAM_COMPILER "${compilerdef}")
string(REGEX MATCH "#define GENICAM_COMPANY_SUFFIX [a-zA-Z0-9_]+" companydef "${header}")
string(REGEX REPLACE "([^ ]+) ([^ ]+) ([^ ]+).*" "\\3" GENICAM_COMPANY_SUFFIX "${companydef}")

set(GENICAM_SUFFIX "${GENICAM_COMPILER}_v${GENICAM_MAJOR_VER}_${GENICAM_MINOR_VER}_${GENICAM_COMPANY_SUFFIX}")
message(STATUS "Genicam suffix: ${GENICAM_SUFFIX}")
set(GENICAM_LIB_SUFFIX)

if ("${ARCHITECTURE}" STREQUAL "arm")
  set(GENICAM_LIBRARIES
    libGCBase_gcc494_v3_4
    libGenApi_gcc494_v3_4
    liblog4cpp_gcc494_v3_4
    libLog_gcc494_v3_4
    libMathParser_gcc494_v3_4
    libNodeMapData_gcc494_v3_4
    libXmlParser_gcc494_v3_4)
  set(GENICAM_LIBRARIES_DIR ${PACKAGE_PREFIX_DIR}/bin/Linux32_ARMhf)
  set(GENICAM_LIB_SUFFIX ".so")
elseif ("${ARCHITECTURE}" STREQUAL "aarch64")
  set(GENICAM_LIBRARIES
    libGCBase_gcc49_v3_4
    libGenApi_gcc49_v3_4
    liblog4cpp_gcc49_v3_4
    libLog_gcc49_v3_4
    libMathParser_gcc49_v3_4
    libNodeMapData_gcc49_v3_4
    libXmlParser_gcc49_v3_4)
  set(GENICAM_LIBRARIES_DIR ${PACKAGE_PREFIX_DIR}/bin/Linux64_ARM)
  set(GENICAM_LIB_SUFFIX ".so")
elseif ("${ARCHITECTURE}" STREQUAL "i686")
  set(GENICAM_LIBRARIES
    libGCBase_gcc48_v3_4
    libGenApi_gcc48_v3_4
    liblog4cpp_gcc48_v3_4
    libLog_gcc48_v3_4
    libMathParser_gcc48_v3_4
    libNodeMapData_gcc48_v3_4
    libXmlParser_gcc48_v3_4)
  set(GENICAM_LIBRARIES_DIR ${PACKAGE_PREFIX_DIR}/bin/Linux32_i86)
  set(GENICAM_LIB_SUFFIX ".so")
elseif ("${ARCHITECTURE}" STREQUAL "x86_64")
  set(GENICAM_LIBRARIES
    libGCBase_gcc48_v3_4
    libGenApi_gcc48_v3_4
    liblog4cpp_gcc48_v3_4
    libLog_gcc48_v3_4
    libMathParser_gcc48_v3_4
    libNodeMapData_gcc48_v3_4
    libXmlParser_gcc48_v3_4)
  set(GENICAM_LIBRARIES_DIR ${PACKAGE_PREFIX_DIR}/bin/Linux64_x64)
  set(GENICAM_LIB_SUFFIX ".so")
elseif ("${ARCHITECTURE}" STREQUAL "WIN32_i86")
  set(GENICAM_LIBRARIES
    GCBase_MD_VC141_v3_4
    GenApi_MD_VC141_v3_4)
  set(GENICAM_LIBRARIES_DIR ${PACKAGE_PREFIX_DIR}/library/CPP/lib/Win32_i86)
  set(GENICAM_LIB_SUFFIX ".lib")
elseif ("${ARCHITECTURE}" STREQUAL "WIN64_x64")
  set(GENICAM_LIBRARIES
    GCBase_MD_VC141_v3_4
    GenApi_MD_VC141_v3_4)
  set(GENICAM_LIBRARIES_DIR ${PACKAGE_PREFIX_DIR}/library/CPP/lib/Win64_x64)
  set(GENICAM_LIB_SUFFIX ".lib")
else ()
  message(FATAL_ERROR "Unknown architecture")
endif ()

set(GENICAM_NAMESPACED_TARGETS)
foreach(GENICAM_LIB ${GENICAM_LIBRARIES})
  set(GENICAM_NAMESPACE_LIB "genicam::${GENICAM_LIB}")
  list(APPEND GENICAM_NAMESPACED_TARGETS ${GENICAM_NAMESPACE_LIB})
  add_library(${GENICAM_NAMESPACE_LIB} SHARED IMPORTED)
  message(STATUS "Adding imported: ${GENICAM_NAMESPACE_LIB}")
  set_property(TARGET ${GENICAM_NAMESPACE_LIB} APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
  set_property(TARGET ${GENICAM_NAMESPACE_LIB} APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)

  set(GENICAM_LIB_FILE "${GENICAM_LIBRARIES_DIR}/${GENICAM_LIB}${GENICAM_LIB_SUFFIX}")
  if (UNIX)
	  set_target_properties(${GENICAM_NAMESPACE_LIB}
	      PROPERTIES
			  INTERFACE_INCLUDE_DIRECTORIES "${PACKAGE_PREFIX_DIR}/library/CPP/include/"
		      IMPORTED_LOCATION_DEBUG "${GENICAM_LIB_FILE}"
		      IMPORTED_LOCATION_RELEASE "${GENICAM_LIB_FILE}"
		      IMPORTED_LOCATION "${GENICAM_LIB_FILE}")
  elseif (WIN32)
	  set_target_properties(${GENICAM_NAMESPACE_LIB}
	      PROPERTIES
			  INTERFACE_INCLUDE_DIRECTORIES "${PACKAGE_PREFIX_DIR}/library/CPP/include/"
		      IMPORTED_IMPLIB_DEBUG  "${GENICAM_LIB_FILE}"
		      IMPORTED_IMPLIB_RELEASE "${GENICAM_LIB_FILE}"
		      IMPORTED_IMPLIB "${GENICAM_LIB_FILE}")
  endif ()
endforeach()

add_library(genicam INTERFACE)
add_library(genicam::genicam ALIAS genicam)
target_link_libraries(genicam INTERFACE ${GENICAM_NAMESPACED_TARGETS})

set(Genicam_LIBRARIES ${GENICAM_LIBRARIES} CACHE STRING "Genicam libraries")
set(Genicam_TARGETS ${GENICAM_NAMESPACED_TARGETS} CACHE STRING "Genicam targets with namespace")
set(Genicam_FOUND ON CACHE BOOL "")
set(PACKAGE_PREFIX_DIR)

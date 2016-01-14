project(s3)

cmake_minimum_required(VERSION 2.8)
set(CMAKE_COLOR_MAKEFILE ON)

if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set (CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/installed" CACHE PATH "default install path" FORCE )
endif()

# - curl development libraries
# - libxml2 development libraries, and the libraries that it requires (iconv, zlib)
set(EXT_LIBS_IMPORT CACHE FILEPATH "Definition for libraries 'xml' and 'curl' (import.cmake)")
set(curl_PUBLIC_INCLUDES CACHE FILEPATH "Custom includes of CURL library")
set(xml_PUBLIC_INCLUDES CACHE FILEPATH "Custom includes of CURL library")



if(EXISTS ${EXT_LIBS_IMPORT})
	include("${EXT_LIBS_IMPORT}")
	message(STATUS " Included Cmake import EXT_LIBS_IMPORT=${EXT_LIBS_IMPORT}")
else()
	message(FATAL_ERROR
		"EXT_LIBS_IMPORT is not defined and it must contain definition for libraries 'xml' and 'curl'. "
		"It can be passed on comand line e.g cmake -DEXT_LIBS_IMPORT=<path>"
	 )
endif()

if(curl_PUBLIC_INCLUDES)
	include_directories("${curl_PUBLIC_INCLUDES}")
	message(STATUS " Added a custom include dir: '${curl_PUBLIC_INCLUDES}'")
endif()
if(xml_PUBLIC_INCLUDES)
	include_directories("${xml_PUBLIC_INCLUDES}")
	message(STATUS " Added a custom include dir: '${xml_PUBLIC_INCLUDES}'")
endif()

################################################################################
set(LIBS3_VER_MAJOR  "2")
set(LIBS3_VER_MINOR  "0")
set(LIBS3_VER "${LIBS3_VER_MAJOR}.${LIBS3_VER_MINOR}")

add_definitions(
-DLIBS3_VER_MAJOR="${LIBS3_VER_MAJOR}"
-DLIBS3_VER_MINOR="${LIBS3_VER_MINOR}"
-DLIBS3_VER="${LIBS3_VER}"
)

################################################################################
include_directories(inc)

file(GLOB s3_PUBLIC_HEADERS inc/*.h)
file(GLOB s3_PUBLIC_PRIVATE inc/mingw/*.h)
file(GLOB s3_SOURCES src/*.c)
file(GLOB s3_Win_SOURCES src/mingw*.c)
file(GLOB s3_client_SOURCES src/s3.c)
list(REMOVE_ITEM s3_SOURCES ${s3_client_SOURCES})
list(REMOVE_ITEM s3_SOURCES ${s3_Win_SOURCES})

source_group("Public Header Files" FILES ${s3_PUBLIC_HEADERS})
source_group("Source Files" FILES ${s3_SOURCES})

IF(MSVC)
	if (MSVC_VERSION LESS 1900)
		message (STATUS "Enabling patch for Visual Studio 2010 and lower")
		set_source_files_properties(${s3_SOURCES} ${s3_PUBLIC_HEADERS} PROPERTIES LANGUAGE CXX )
		add_definitions(-DMSVC_NO_C99=1)
	endif()
	
	set(s3_SOURCES ${s3_SOURCES} mswin/libs3.def)
	add_definitions(-Ds3_EXPORTS=1)
	include_directories(inc/mingw)
ENDIF()

add_library(s3 SHARED ${s3_SOURCES} ${s3_PUBLIC_HEADERS} ${s3_PUBLIC_PRIVATE})
target_link_libraries(s3 xml curl)
install(TARGETS s3
	RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
	ARCHIVE DESTINATION lib
)
install(DIRECTORY ${CMAKE_SOURCE_DIR}/inc/ DESTINATION include/s3)

IF(MSVC)
	target_link_libraries(s3 ws2_32)
	set_target_properties(s3 PROPERTIES
		DEBUG_OUTPUT_NAME "s3_d"
		RELWITHDEBINFO_OUTPUT_NAME "s3"
	)
	install(DIRECTORY "${CMAKE_BINARY_DIR}/Debug/"           DESTINATION bin CONFIGURATIONS "DEBUG" FILES_MATCHING PATTERN "*.pdb")
	install(DIRECTORY "${CMAKE_BINARY_DIR}/RelWithDebInfo/"  DESTINATION bin CONFIGURATIONS "RELWITHDEBINFO" FILES_MATCHING PATTERN "*.pdb")
ENDIF()

################################################################################
# print all compile flags on terminal
set(variables
  CMAKE_C_FLAGS_DEBUG
  CMAKE_C_FLAGS_MINSIZEREL
  CMAKE_C_FLAGS_RELEASE
  CMAKE_C_FLAGS_RELWITHDEBINFO
  CMAKE_CXX_FLAGS_DEBUG
  CMAKE_CXX_FLAGS_MINSIZEREL
  CMAKE_CXX_FLAGS_RELEASE
  CMAKE_CXX_FLAGS_RELWITHDEBINFO
)
message(STATUS "Initial build flags:")
foreach(variable ${variables})
	message(STATUS "  '${variable}': ${${variable}}")
endforeach()
message(STATUS "")
################################################################################

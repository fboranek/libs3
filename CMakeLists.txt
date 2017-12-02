project(libs3)

cmake_minimum_required(VERSION 3.0)
set(CMAKE_COLOR_MAKEFILE ON)

if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set (CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "default install path" FORCE )
endif()
set(CMAKE_DEBUG_POSTFIX CACHE STRING "Postfix for debug library name. Usualy '_d'")


if(EXISTS ${EXT_LIBS_IMPORT})
    
    # - curl development libraries
    # - libxml2 development libraries, and the libraries that it requires (iconv, zlib)
    set(EXT_LIBS_IMPORT CACHE FILEPATH "Definition for libraries 'xml' and 'curl' (import.cmake)")
    
    include("${EXT_LIBS_IMPORT}")

    if(curl_PUBLIC_INCLUDES)
        include_directories("${curl_PUBLIC_INCLUDES}")
        message(STATUS " Added a custom include dir: '${curl_PUBLIC_INCLUDES}'")
    endif()
    if(xml_PUBLIC_INCLUDES)
        include_directories("${xml_PUBLIC_INCLUDES}")
        message(STATUS " Added a custom include dir: '${xml_PUBLIC_INCLUDES}'")
    endif()

else()

    find_package(PkgConfig REQUIRED)

    # copy-paste: sudo apt-get install libxml2-dev libcurl4-openssl-dev
    set(LIB_DEPS_LIST
        libxml-2.0 # libxml2-dev
        libcurl    # libcurl4-openssl-dev
    )
    pkg_check_modules(PKGCONFIG_DEPS REQUIRED ${LIB_DEPS_LIST})
    
    include_directories(${PKGCONFIG_DEPS_INCLUDE_DIRS})
    #include(CMakeImports/import-Linux.cmake)

endif()

################################################################################
set(LIBS3_VER_MAJOR  "4")
set(LIBS3_VER_MINOR  "1")
set(LIBS3_VER "${LIBS3_VER_MAJOR}.${LIBS3_VER_MINOR}")

add_definitions(
-DLIBS3_VER_MAJOR="${LIBS3_VER_MAJOR}"
-DLIBS3_VER_MINOR="${LIBS3_VER_MINOR}"
-DLIBS3_VER="${LIBS3_VER}"
)

################################################################################
include_directories(inc)

file(GLOB libs3_PUBLIC_HEADERS inc/*.h)
file(GLOB libs3_PUBLIC_PRIVATE inc/mingw/*.h)
file(GLOB libs3_SOURCES src/*.c)
file(GLOB libs3_Win_SOURCES src/mingw*.c)
file(GLOB libs3_client_SOURCES src/s3.c)
list(REMOVE_ITEM libs3_SOURCES ${libs3_client_SOURCES})
list(REMOVE_ITEM libs3_SOURCES ${libs3_Win_SOURCES})

source_group("Public Header Files" FILES ${libs3_PUBLIC_HEADERS})
source_group("Source Files" FILES ${libs3_SOURCES})

IF(MSVC)
	set(libs3_SOURCES ${libs3_SOURCES} ${libs3_Win_SOURCES})
#	if (MSVC_VERSION LESS 1900) # unfortunetely C99 still not work with VS 2015
		message (STATUS "Enabling patch for Visual Studio 2015 and lower")
		set_source_files_properties(${libs3_SOURCES} ${libs3_PUBLIC_HEADERS} PROPERTIES LANGUAGE CXX )
		add_definitions(-DMSVC_NO_C99=1)
#	endif()

	set(libs3_SOURCES ${libs3_SOURCES} mswin/libs3.def)
	add_definitions(-Ds3_EXPORTS=1)
	include_directories(inc/mingw)
ENDIF()

add_library(libs3 SHARED ${libs3_SOURCES} ${libs3_PUBLIC_HEADERS} ${libs3_PUBLIC_PRIVATE})
if(EXISTS ${EXT_LIBS_IMPORT})
    target_link_libraries(libs3 xml curl)
else()
    target_link_libraries(libs3 ${PKGCONFIG_DEPS_LIBRARIES})
endif()
install(TARGETS libs3
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
install(DIRECTORY ${CMAKE_SOURCE_DIR}/inc/ DESTINATION include/s3)

IF(MSVC)
	target_link_libraries(libs3 ws2_32)
	set_target_properties(libs3 PROPERTIES
		OUTPUT_NAME "libs3"
	)
	
	install(DIRECTORY "${CMAKE_BINARY_DIR}/Debug/"           DESTINATION bin CONFIGURATIONS "DEBUG" FILES_MATCHING PATTERN "*.pdb")
	install(DIRECTORY "${CMAKE_BINARY_DIR}/RelWithDebInfo/"  DESTINATION bin CONFIGURATIONS "RELWITHDEBINFO" FILES_MATCHING PATTERN "*.pdb")
ELSE()
	set_target_properties(libs3 PROPERTIES
		OUTPUT_NAME "s3"
	)
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
  EXT_LIBS_IMPORT
  CMAKE_DEBUG_POSTFIX
)
message(STATUS "Initial build flags:")
foreach(variable ${variables})
	message(STATUS "  '${variable}': ${${variable}}")
endforeach()
message(STATUS "")
################################################################################

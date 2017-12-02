# apt install libxml2-dev
add_library(xml SHARED IMPORTED)
set_property(TARGET xml APPEND PROPERTY
    IMPORTED_LOCATION "${PKGCONFIG_DEPS_libxml-2.0_LIBDIR}/libxml2.so"
)

# apt install libcurl4-openssl-dev
add_library(curl SHARED IMPORTED)
set_property(TARGET curl APPEND PROPERTY
    IMPORTED_LOCATION "${PKGCONFIG_DEPS_libcurl_LIBDIR}/libcurl.so"
)


add_library(s3 SHARED RadosExample.cpp S3Example.cpp main.cpp)
target_link_libraries(s3 ${LIB_XML2} ${LIB_CURL})

install(TARGETS s3 RUNTIME DESTINATION lib)
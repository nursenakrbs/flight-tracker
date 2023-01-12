cmake_minimum_required(VERSION 3.9)

project (vehicle-tracking-core)

file(GLOB SOURCE_FILES "*.cpp")
file(GLOB HEADER_FILES "*.h")

add_library(${PROJECT_NAME} SHARED ${SOURCE_FILES} ${HEADER_FILES})
target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

if(TESTING_ENABLED)
    set(TEST_APP_NAME ${PROJECT_NAME}-test)
    add_executable(${TEST_APP_NAME} test.cc)
    target_link_libraries(${TEST_APP_NAME} ${PROJECT_NAME} pthread)
endif()

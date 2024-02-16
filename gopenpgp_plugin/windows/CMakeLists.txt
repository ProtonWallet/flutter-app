# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "proton_crypto")
project(${PROJECT_NAME} C CXX)

# Add the source file
set(SOURCE_FILE ../src/proton_crypto.go)

find_program(GO_EXECUTABLE go)
if(NOT GO_EXECUTABLE)
    message(FATAL_ERROR "Go compiler not found!")
endif()

# execute go build to generate .dll file
execute_process(
        COMMAND ${GO_EXECUTABLE} build -o ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.dll -buildmode=c-shared ${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE_FILE}
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../src"
        RESULT_VARIABLE EXEC_RESULT
        OUTPUT_VARIABLE EXEC_OUTPUT
        ERROR_VARIABLE EXEC_ERROR
)

# check build result
if(EXEC_RESULT EQUAL 0)
    message(STATUS "Command executed successfully")
else()
    message(FATAL_ERROR "Command failed with error code ${EXEC_RESULT}")
endif()

message(STATUS "Output: ${EXEC_OUTPUT}")
# message(STATUS "Error: ${EXEC_ERROR}")

set(proton_crypto_bundled_libraries
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.dll"
    PARENT_SCOPE
)

message("Copy DLL file from: ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.dll")
message("To: ${CMAKE_CURRENT_SOURCE_DIR}/../../../../../../gopenpgp_plugin/windows/shared/")

# copy file to root folder for flutter test to load
file(COPY "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.dll" DESTINATION "${CMAKE_CURRENT_SOURCE_DIR}/../../../../../../gopenpgp_plugin/windows/shared/")
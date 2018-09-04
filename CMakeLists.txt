project(kin-gen)
cmake_minimum_required(VERSION 2.6)

add_custom_target(submodules
    COMMAND git submodule update --init
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)

# This target triggers the actual building of the ilk-generator, by using the
# local Makefile. Note the 'ALL' keyword, required to add this target to the
# default cmake targets.
#
add_custom_target(localbuild ALL
    COMMAND make
    DEPENDS submodules
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/ilk-generator
)

install(CODE "MESSAGE(\"Kin-gen installation...\")" )


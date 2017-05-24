#! /bin/sh

# $1: hex file basname
# $2: path to project (top qbs file path)

#post_compile:
[TEENSY_TOOLS_PATH]/teensy_post_compile -file="$1" -path="$2/build/" -tools="[TEENSY_TOOLS_PATH]"

#reboot:
[TEENSY_TOOLS_PATH]/teensy_reboot
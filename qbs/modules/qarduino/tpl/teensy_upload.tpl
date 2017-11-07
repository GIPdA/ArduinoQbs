#! /bin/sh

# -file: hex file basname (without .hex)
# -path: path to hex file

#post_compile:
[TEENSY_TOOLS_PATH]/teensy_post_compile -file="[TEENSY_HEX_BASENAME]" -path="[TEENSY_HEX_PATH]" -tools="[TEENSY_TOOLS_PATH]"

#reboot:
[TEENSY_TOOLS_PATH]/teensy_reboot

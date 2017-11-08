import qbs
import "qbs/imports/arduino/ArduinoApplication.qbs" as ArduinoApplication

ArduinoApplication
{
    // Don't forget to change the compiler accordingly if you change board architecture (i.e. avr/teensy) !

    board: "teensy32"    // Board Ref: 30, 31, 35, 36, LC
    frequency: "96" // CPU Frequency in MHz

    //board: "pro5Vatmega328p"

    serialport: "/dev/cu.usbmodem1411"

    //usbType: "USB_SERIAL" // USB_RAWHID
    //keyLayout: "FRENCH"


    files: [ // List of source files (c, cpp, headers)
        "main.cpp"
    ]

    // Other include paths
    includePaths: []

    // Teensy/Arduino Core libraries and Project libraries (inside the folder named 'libraries') and External libraries (externalLibrariesPath).
    // Priorities: Project libs > External libs > Core libs
    libraries: ["SPI", "EEPROM"] // Examples


    //projectLibrariesPath: "libraries" // To change the default folder name
    //externalLibrariesPath: "/path/to/custom/lib/folder" // Relative or absolute

    // Optmization: small for size, fast for speed, or none.
    qbs.optimization: "small" // fast, none
}


/* #### Build Configuration Guide ####
 * /!\ Install root must be the same as build directory. /!\
 * Can't use default install root location because we cannot get the path in the run configuration.
 * But you can set the build directory you want.
 *
 * 1. Check "Install"
 * 2. Uncheck "Use default location"
 * 3. Change installation directory to default build directory or %{buildDir} (remove everything after the default build dir)
 */

/* #### Run Configuration ####
 * Executable:              /usr/bin/env
 * Command line arguments:  %{CurrentProject:BuildPath}/upload.sh
 * Working directory:       %{buildDir}
 */


// #### FREQUENCY (Teensy) ####
// 2   MHz      31  35  36
// 4   MHz      31  35  36
// 8   MHz      31  35  36
// 16  MHz      31  35  36
// 24  MHz  30  31  35  36  LC
// 48  MHz  30  31  35  36  LC
// 72  MHz      31  35  36
// 96  MHz  30o 31o 35  36
// 120 MHz      31o 35  36
// 144 MHz      31o 35o 36
// 168 MHz      31o 35o 36
// 180 MHz          35o 36
// 192 MHz          35o 36o
// 216 MHz              36o
// 240 MHz              36o
// Note: o = overclock


// #### USB (Teensy) ####
// Serial                               USB_SERIAL
// Keyboard                             USB_KEYBOARDONLY
// Keyboard + Touch Screen              USB_TOUCHSCREEN
// Keyboard + Mouse + Touch Screen      USB_HID_TOUCHSCREEN
// Keyboard + Mouse + Joystick          USB_HID
// Serial + Keyboard + Mouse + Joystick USB_SERIAL_HID
// MIDI                                 USB_MIDI
// Serial + MIDI                        USB_MIDI_SERIAL
// Audio                                USB_AUDIO
// Serial + MIDI + Audio                USB_MIDI_AUDIO_SERIAL
// Raw HID                              USB_RAWHID
// Flight Sim Controls                  USB_FLIGHTSIM
// Flight Sim Controls + Joystick       USB_FLIGHTSIM_JOYSTICK
// All of the Above                     USB_EVERYTHING
// No USB                               USB_DISABLED


// #### KEYBOARD (Teensy) ####
// en-us  US English               US_ENGLISH
// fr-ca  Canadian French          CANADIAN_FRENCH
// xx-ca  Canadian Multilingual    CANADIAN_MULTILINGUAL
// cz-cz  Czech                    CZECH
// da-da  Danish                   DANISH
// fi-fi  Finnish                  FINNISH
// fr-fr  French                   FRENCH
// fr-be  French Belgian           FRENCH_BELGIAN
// fr-ch  French Swiss             FRENCH_SWISS
// de-de  German                   GERMAN
// de-dm  German (Mac)             GERMAN_MAC
// de-ch  German Swiss             GERMAN_SWISS
// is-is  Icelandic                ICELANDIC
// en-ie  Irish                    IRISH
// it-it  Italian                  ITALIAN
// no-no  Norwegian                NORWEGIAN
// pt-pt  Portuguese               PORTUGUESE
// pt-br  Portuguese Brazilian     PORTUGUESE_BRAZILIAN
// rs-rs  Serbian (Latin Only)     SERBIAN_LATIN_ONLY
// es-es  Spanish                  SPANISH
// es-mx  Spanish Latin America    SPANISH_LATIN_AMERICA
// sv-se  Swedish                  SWEDISH
// tr-tr  Turkish (partial)        TURKISH
// en-gb  United Kingdom           UNITED_KINGDOM
// usint  US International         US_INTERNATIONAL

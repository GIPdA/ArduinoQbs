import qbs
import qbs.FileInfo
import qbs.Process
import "qbs/js/functions.js" as TeensyFunctions

CppApplication {
    type: ["application", "ihex", "eeprom", "binary", "size"]

    //project.minimumQbsVersion: "1.6" // Break everything

    property string teensy: "undefined" // Board Ref: 30, 31, 35, 36, LC


    // #### FREQUENCY ####
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
    property string frequency: "48"     // CPU MHz


    // #### USB ####
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
    property string usbType: "USB_SERIAL"


    // #### KEYBOARD ####
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
    property string keyLayout: "FRENCH"


    //cpp.debugInformation: true
    cpp.warningLevel: "all"


    qbsSearchPaths: ["qbs"]
    Depends { name: "teensyBoard" }

    teensyBoard.boardName: "teensy"+teensy


    property string compilerPath: "/Applications/Arduino.app/Contents/Java/hardware/tools"
    property string corePath: "/Applications/Arduino.app/Contents/Java/hardware/teensy/avr/cores/teensy3"



    // Time
    property string time_utc: {
        var lt = TeensyFunctions.getTimes()
        return lt["utc"].toString()
    }

    property string time_local: {
        var lt = TeensyFunctions.getTimes()
        return lt["local"].toString()
    }

    property string time_zone: {
        var lt = TeensyFunctions.getTimes()
        return lt["zone"].toString()
    }

    property string time_dst: {
        var lt = TeensyFunctions.getTimes()
        return lt["dst"].toString()
    }


    /*Probe {
        id: timeProbe

        property string dst: "0"

        // TODO: check DST?

        configure: {
            var cmd;
            var args;
            if (qbs.targetOS.contains("windows")) {
                cmd = "cmd";
                args = ["/c", "date", "/t"]; // TODO
                found = false;
                return;
            } else {
                cmd = 'date';
                args = ["+%s"];
            }

            var p = new Process();
            if (p.exec(cmd, args) === 0) {
                found = true;
                utc = p.readLine();
                //console.warn("Time UTC: "+utc)
            } else {
                found = false;
            }
            p.close();
        }
    }//*/


    property string fcpu: frequency+"000000"

    property stringList flags_common: ["-mthumb", "-ffunction-sections","-fdata-sections","-nostdlib","-MMD"]
    property stringList flags_cpp: ["-felide-constructors","-std=gnu++0x"]
    property stringList flags_c: []
    property stringList flags_S: ["-x","assembler-with-cpp"]

    property stringList flags_ld: ["-Wl,--gc-sections,--relax,--defsym=__rtc_localtime="+time_local,"--specs=nano.specs"]

    property stringList flags_libs: ["m"]

    property stringList flags_defines: ["ARDUINO=10612", "TEENSYDUINO=141", usbType, "LAYOUT_"+keyLayout, "F_CPU="+fcpu]


    cpp.cFlags: flags_c
    cpp.cxxFlags: flags_cpp
    cpp.assemblerFlags: flags_S

    cpp.dynamicLibraries: flags_libs

    cpp.commonCompilerFlags: flags_common
    cpp.linkerFlags: flags_ld
    cpp.defines: flags_defines

    cpp.positionIndependentCode: false
    cpp.enableExceptions: false
    cpp.enableRtti: false

    //cpp.cxxLanguageVersion: "c++11"


    // Core includes
    cpp.includePaths: [corePath,
        corePath+"/avr",
        corePath+"/util"
    ]


    // Core source files
    Group {
        name: "Core files"
        files: [corePath+"/*.c", corePath+"/*.cpp"]
    }


    cpp.executableSuffix: ".elf"


    // Binaries generation

    Rule {
        inputs: ["application"]

        Artifact {
            fileTags: ["ihex"]
            filePath: product.destinationDirectory + "/" + product.name + ".hex"
        }

        prepare: {
            var args = ["-O","ihex","-R",".eeprom", input.filePath, output.filePath];
            var cmd = new Command(product.moduleProperty("cpp", "objcopyPath"), args);

            cmd.description = "Building hex file: " + FileInfo.fileName(input.filePath)
            cmd.highlight = "filegen";
            return cmd;
        }
    }


    // EEPROM
    Rule {
        inputs: ["application"]

        Artifact {
            fileTags: ["eeprom"]
            filePath: product.destinationDirectory + "/" + product.name + ".eep"
        }

        prepare: {
            var args = ["-O","ihex","-j",".eeprom","--set-section-flags=.eeprom=alloc,load","--no-change-warnings","--change-section-lma",".eeprom=0", input.filePath, output.filePath];
            var cmd = new Command(product.moduleProperty("cpp", "objcopyPath"), args);

            cmd.description = "Building eeprom file: " + FileInfo.fileName(input.filePath)
            cmd.highlight = "filegen";
            return cmd;
        }
    }


    Rule {
        inputs: ["application"]

        Artifact {
            fileTags: ["binary"]
            filePath: product.destinationDirectory + "/" + product.name + ".bin"
        }

        prepare: {
            var args = ["-O", "binary", input.filePath, output.filePath];
            var cmd = new Command(product.moduleProperty("cpp", "objcopyPath"), args);

            cmd.description = "Building bin file: " + FileInfo.fileName(input.filePath)
            cmd.highlight = "filegen";
            return cmd;
        }
    }


    Rule {
        multiplex: true
        inputs: ["application"]
        alwaysRun: true

        Artifact {
            filePath: "size.txt"
            fileTags: ["size"]
        }

        prepare: {
            /*var sizePath = product.moduleProperty("cpp", "toolchainPathPrefix") + "size";
            var args = [input.filePath];
            var cmd = new Command(sizePath, args);

            console.warn(">>");

            cmd.description = "Size: " + FileInfo.fileName(input.filePath)
            cmd.highlight = "compiler";
            return cmd;//*/


            var cmd = new JavaScriptCommand();
            cmd.description = "Size: " + FileInfo.fileName(input.filePath)
            //cmd.silent = true;
            cmd.sourceCode = function() {
                var sizeCmd = product.moduleProperty("cpp", "toolchainPathPrefix") + "size";
                var process = new Process();

                process.exec(sizeCmd, ["-A", input.filePath]);

                console.warn(">>" + process.readStdOut());
                process.close();
            };
            return [cmd];//*/
        }
    }
}

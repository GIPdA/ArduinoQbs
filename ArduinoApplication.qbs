import qbs
import qbs.FileInfo
import qbs.File
import qbs.Process
import "qbs/js/functions.js" as Helpers

CppApplication {
    type: ["application", "ihex", "eeprom", "binary", "size"]

    //project.minimumQbsVersion: "1.6" // Break everything

    // Teensy Board Ref: teensy30, 31, 35, 36, LC
    property string board: "undefined"
    property string arduinoArch: "undefined"


    /* #### Run Configuration ####
     * Executable:              %{CurrentProject:Path}/qbs/tools/teensy_load
     * Command line arguments:  %{CurrentProject:FileBaseName} %{CurrentProject:Path}
     * Working directory:       %{CurrentProject:Path}/build
     */


    /* #### FREQUENCY ####
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
    //*/
    property string frequency: "48"     // CPU MHz


    /* #### USB ####
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
    //*/
    property string usbType: "USB_SERIAL"


    /* #### KEYBOARD ####
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
    //*/
    property string keyLayout: "FRENCH"


    //cpp.debugInformation: true
    cpp.warningLevel: "all"

    property string boardName: board
    property string arduinoArchName: arduinoArch

    property string customArduinoPath: ""

    qbsSearchPaths: ["qbs"]
    Depends { name: "arduinoboard" }
    Depends { name: "arduinobuild" }


    // Path to arduino 'Java' folder (the one with the 'hardware' folder in)
    property string arduinoPath: {
        // If custom path to Arduino Java folder, use it.
        if (customArduinoPath != "") {
            return customArduinoPath
        }

        // Default paths to Arduino Java folder on main operating systems.
        if (qbs.hostOS.contains("macos")) {
            return "/Applications/Arduino.app/Contents/Java/"
        }
        if (qbs.hostOS.contains("linux")) {
            throw "Default Arduino Java folder path is not implemented yet... please set it manually with 'customArduinoPath'."
            return "~/Arduino/Java/" // Maybe ??
        }
        if (qbs.hostOS.contains("windows")) {
            return "C:/Program Files (x86)/Arduino/Java/"
        }
    }

    property string compilerPath: arduinoPath+arduinobuild.compilerPath
    property string corePath: arduinoPath+arduinobuild.corePath
    property string coreLibrariesPath: arduinoPath+arduinobuild.coreLibrariesPath


    property bool compilerPathExists: {
        if (!File.exists(compilerPath)) {
            console.warn("Arduino path may be wrong (compiler path is invalid), please check or set 'customArduinoPath' to the 'Java' folder in your Arduino install.")
            return false
        }
        return true
    }
    property bool corePathExists: {
        if (!File.exists(corePath)) {
            console.warn("Arduino path may be wrong (core path is invalid), please check or set 'customArduinoPath' to the 'Java' folder in your Arduino install.")
            return false
        }
        return true
    }
    property bool coreLibrariesPathExists: {
        if (!File.exists(coreLibrariesPath)) {
            console.warn("Arduino path may be wrong (core libraries path is invalid), please check or set 'customArduinoPath' to the 'Java' folder in your Arduino install.")
            return false
        }
        return true
    }


//    property string compilerPath: "/Applications/Arduino.app/Contents/Java/hardware/tools"
//    property string corePath: "/Applications/Arduino.app/Contents/Java/hardware/teensy/avr/cores/teensy3"
//    property string coreLibrariesPath: "/Applications/Arduino.app/Contents/Java/hardware/teensy/avr/libraries" // Arduino core libs

    property string projectLibrariesPath: "libraries"   // Project libs
    property string externalLibrariesPath: ""   // Other libs
    property string projectPath: path

    // Libs: Project libs > External libs > Core libs

    property string externalLibrariesPath_abs: FileInfo.isAbsolutePath(externalLibrariesPath) ? externalLibrariesPath : projectPath+"/"+externalLibrariesPath



    // Time
    property string time_utc: {
        var lt = Helpers.getTimes()
        return lt["utc"].toString()
    }

    property string time_local: {
        var lt = Helpers.getTimes()
        return lt["local"].toString()
    }

    property string time_zone: {
        var lt = Helpers.getTimes()
        return lt["zone"].toString()
    }

    property string time_dst: {
        var lt = Helpers.getTimes()
        return lt["dst"].toString()
    }


    property string fcpu: frequency+"000000L"


    //cpp.cxxLanguageVersion: "c++11"

    property stringList includePaths: []

    // Core libs and local libs.
    // Source files and include paths will be built from that.
    property stringList libraries: []


    property pathList librariesIncludePaths: {
        var l = []
        for (var i = 0; i < libraries.length; i++) {
            if (Helpers.isProjectLibrary(libraries[i])) {
                l = l.concat(projectLibrariesPath+"/"+libraries[i])
                l = l.concat(projectLibrariesPath+"/"+libraries[i]+"/src")
            } else if (Helpers.isExternalLibrary(libraries[i])) {
                l = l.concat(externalLibrariesPath_abs+"/"+libraries[i])
                l = l.concat(externalLibrariesPath_abs+"/"+libraries[i]+"/src")
            } else if (Helpers.isCoreLibrary(libraries[i])) {
                l = l.concat(coreLibrariesPath+"/"+libraries[i])
                l = l.concat(coreLibrariesPath+"/"+libraries[i]+"/src")
            }
        }
        return l
    }





    // All includes
    cpp.includePaths: {
        var l = []
        return l.concat(
            [ // Core
            corePath,
            //corePath+"/avr",
            corePath+"/util",
            ],
            // Core+local Libraries
            librariesIncludePaths)
    }



    // Core source files
    Group {
        name: "Core files"
        files: ["*.c", "*.cpp"]
        prefix: corePath+"/"
        cpp.warningLevel: "none"
    }


    // Core libraries
    Group {
        name: "Core Libraries files"
        files: {
            var l = []
            for (var i = 0; i < libraries.length; i++) {
                // If not in 'project' or 'external' libs
                if (Helpers.isCoreLibrary(libraries[i]) &&
                    !Helpers.isProjectLibrary(libraries[i]) &&
                    !Helpers.isExternalLibrary(libraries[i]) ) {
                    l = l.concat(libraries[i]+"/*.cpp")
                    l = l.concat(libraries[i]+"/*.c")
                    l = l.concat(libraries[i]+"/*.h")
                    l = l.concat(libraries[i]+"/*.hpp")
                    l = l.concat(libraries[i]+"/src/*.cpp")
                    l = l.concat(libraries[i]+"/src/*.c")
                    l = l.concat(libraries[i]+"/src/*.h")
                    l = l.concat(libraries[i]+"/src/*.hpp")

                    console.warn("Using Core library: " + libraries[i])
                    console.info("Using Core library: " + libraries[i])
                }
            }
            return l
        }
        prefix: coreLibrariesPath+"/" // From Arduino App
        cpp.warningLevel: "none"
    }


    // Project libraries
    Group {
        name: "Project Libraries files"
        files: {
            var l = []
            for (var i = 0; i < libraries.length; i++) {
                if (Helpers.isProjectLibrary(libraries[i])) {
                    l = l.concat(libraries[i]+"/*.cpp")
                    l = l.concat(libraries[i]+"/*.c")
                    l = l.concat(libraries[i]+"/*.h")
                    l = l.concat(libraries[i]+"/*.hpp")
                    l = l.concat(libraries[i]+"/src/*.cpp")
                    l = l.concat(libraries[i]+"/src/*.c")
                    l = l.concat(libraries[i]+"/src/*.h")
                    l = l.concat(libraries[i]+"/src/*.hpp")

                    console.warn("Using Project library: " + libraries[i])
                    console.info("Using Project library: " + libraries[i])
                }
            }

            return l
        }
        prefix: projectLibrariesPath+"/"
    }

    /*Group {
        name: "Local Libraries"
        files: ["*.c", "*.cpp", "src/ *.c", "src/ *.cpp", "*.h", "src/ *.h", "*.hpp", "src/ *.hpp"]
        prefix: localLibrariesPath + "/ * /"
        //cpp.warningLevel: "none"
    }//*/


    // External libraries
    Group {
        name: "External Libraries files"
        condition: (externalLibrariesPath != "")
        files: {
            var l = []
            for (var i = 0; i < libraries.length; i++) {
                // If not in 'project' libs
                if (Helpers.isExternalLibrary(libraries[i]) &&
                    !Helpers.isProjectLibrary(libraries[i]) ) {
                    l = l.concat(libraries[i]+"/*.cpp")
                    l = l.concat(libraries[i]+"/*.c")
                    l = l.concat(libraries[i]+"/*.h")
                    l = l.concat(libraries[i]+"/*.hpp")
                    l = l.concat(libraries[i]+"/src/*.cpp")
                    l = l.concat(libraries[i]+"/src/*.c")
                    l = l.concat(libraries[i]+"/src/*.h")
                    l = l.concat(libraries[i]+"/src/*.hpp")

                    console.warn("Using External library: " + libraries[i])
                    console.info("Using External library: " + libraries[i])
                }
            }
            return l
        }
        prefix: externalLibrariesPath_abs+"/"
    }


    // Build core libraries names
    Probe {
        id: coreLibsProbe
        condition: true

        property stringList availableCoreLibraries: []

        configure: {
            // Get core libs names
            var coreLibs = File.directoryEntries(coreLibrariesPath, File.AllDirs)

            availableCoreLibraries = coreLibs

            if (coreLibs.count > 0)
                found = true
            else
                found = false

            //console.warn("Core libs: " + coreLibs);
        }
    }//*/




    cpp.executableSuffix: ".elf"


    // Install hex to build dir for upload (need to check "Install" in Project Build Settings)
    qbs.installRoot: path
    Group {
        name: "Hex - Teensy Loader"
        fileTagsFilter: ["application", "ihex"]
        qbs.install: true
        qbs.installDir: "build"
    }//*/



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

            //console.warn("Build dir: " + product.buildDirectory);

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
    }//*/


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
    }//*/


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

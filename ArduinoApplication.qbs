import qbs
import qbs.FileInfo
import qbs.File
import qbs.TextFile
import qbs.Process
import "qbs/js/functions.js" as Helpers

CppApplication {
    id: rootApp

    qbsSearchPaths: "qbs"
    Depends { name: "qarduino" }
    // FIXME: Why "qarduino"? => Workaround for bug QBS-1240. Maybe change back to "arduino" when fixed.

    // TODO: add uploads to the qarduino module

    // Teensy board refs: teensy30, 31, 32, 35, 36, LC
    // AVR board refs: <todo>
    property string board: "undefined"
    PropertyOptions {
        name: "board"
        description: "The Arduino board name to compile for."
    }
    qarduino.boardName: board


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
    // CPU clock in MHz
    property string frequency: qarduino.frequency


    /* #### USB (Teensy) ####
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
    qarduino.usbType: usbType


    /* #### KEYBOARD (Teensy) ####
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
    qarduino.keyLayout: keyLayout



    //cpp.debugInformation: true
    cpp.warningLevel: "all"

    property string serialport: "" // 'auto' to look for a fit?

    // If default paths to Arduino install dir doesn't fit, set your own.
    property string customArduinoPath: ""



    // Debug build system used
    property string printBuildSystem: {
        console.warn("Build system: " + qarduino.arduinoCore)
        return qarduino.arduinoCore
    }


    // Path to arduino 'Java' folder (the one with the 'hardware' folder in)
    qarduino.arduinoPath: {
        // If custom path to Arduino Java folder, use it.
        if (customArduinoPath != "") {
            return customArduinoPath
        }

        // Default paths to Arduino Java folder on main operating systems.
        if (qbs.hostOS.contains("macos")) {
            return "/Applications/Arduino.app/Contents/Java/"
        }
        if (qbs.hostOS.contains("linux")) {
            throw "Default Arduino Java folder path for Linux is not implemented yet... please set it manually with 'customArduinoPath'."
            return "~/Arduino/Java/" // Maybe ??
        }
        if (qbs.hostOS.contains("windows")) {
            return "C:/Program Files (x86)/Arduino/Java/"
        }
    }

    //property string compilerPath: qarduino.compilerPath
    property string corePath: qarduino.corePath
    property string coreLibrariesPath: qarduino.coreLibrariesPath

    property pathList coreIncludePaths: {
        var l = []
        for (var i = 0; i < qarduino.coreIncludePaths.length; i++) {
            l = l.concat(qarduino.coreIncludePaths[i])
        }
        return l
    }


    // Warn for invalid paths
    property bool compilerPathExists: {
        if (!File.exists(qarduino.compilerPath)) {
            console.warn("Arduino path may be wrong (compiler path is invalid), please check or set 'customArduinoPath' to the 'Java' folder in your Arduino install.")
            return false
        }
        return true
    }
    property bool corePathExists: {
        if (!File.exists(qarduino.corePath)) {
            console.warn("Arduino path may be wrong (core path is invalid), please check or set 'customArduinoPath' to the 'Java' folder in your Arduino install.")
            return false
        }
        return true
    }
    property bool coreLibrariesPathExists: {
        if (!File.exists(qarduino.coreLibrariesPath)) {
            console.warn("Arduino path may be wrong (core libraries path is invalid), please check or set 'customArduinoPath' to the 'Java' folder in your Arduino install.")
            return false
        }
        return true
    }

    property string projectLibrariesPath: "libraries"   // Project libs
    property string externalLibrariesPath: ""   // Other libs
    property string projectPath: path

    // Libs priority: Project libs > External libs > Core libs

    property string externalLibrariesPath_abs: FileInfo.isAbsolutePath(externalLibrariesPath) ? externalLibrariesPath : projectPath+"/"+externalLibrariesPath


    // Times
    qarduino.time_utc: Helpers.getTime("utc")
    qarduino.time_local: Helpers.getTime("local")
    qarduino.time_zone: Helpers.getTime("zone")
    qarduino.time_dst: Helpers.getTime("dst")


    property pathList includePaths: []

    // Core libs and local libs.
    // Source files and include paths will be built from that.
    property stringList libraries: []

    property pathList librariesIncludePaths: {
        var l = []
        for (var i = 0; i < libraries.length; i++) {
            // Include root lib and lib/src as some libs put their sources in "src" subdir
            if (Helpers.isProjectLibrary(libraries[i], rootApp)) {
                l = l.concat(projectLibrariesPath+"/"+libraries[i])
                l = l.concat(projectLibrariesPath+"/"+libraries[i]+"/src")
            } else if (Helpers.isExternalLibrary(libraries[i], rootApp)) {
                l = l.concat(externalLibrariesPath_abs+"/"+libraries[i])
                l = l.concat(externalLibrariesPath_abs+"/"+libraries[i]+"/src")
            } else if (Helpers.isCoreLibrary(libraries[i], rootApp)) {
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
            // Core
            corePath,
            coreIncludePaths,
            // Core+local Libraries
            librariesIncludePaths,
            // Project include path
            includePaths
            )
    }



    // Core source files
    Group {
        name: "Core files"
        files: ["*.c", "*.cpp", "*.h"]
        prefix: corePath+"/"
        cpp.warningLevel: "none"
    }


    // Core libraries
    Group {
        condition: true
        name: "Core Libraries files"
        files: {
            var l = []
            for (var i = 0; i < libraries.length; i++) {
                // If not in 'project' or 'external' libs
                if (Helpers.isCoreLibrary(libraries[i], rootApp) &&
                    !Helpers.isProjectLibrary(libraries[i], rootApp) &&
                    !Helpers.isExternalLibrary(libraries[i], rootApp) ) {
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
        prefix: coreLibrariesPath + "/" // From Arduino App
        cpp.warningLevel: "none"
    }


    // Project libraries
    Group {
        name: "Project Libraries files"
        files: {
            var l = []
            for (var i = 0; i < libraries.length; i++) {
                if (Helpers.isProjectLibrary(libraries[i], rootApp)) {
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
        prefix: projectLibrariesPath + "/"
    }


    // External libraries
    Group {
        name: "External Libraries files"
        condition: (externalLibrariesPath != "")
        files: {
            var l = []
            for (var i = 0; i < libraries.length; i++) {
                // If not in 'project' libs
                if (Helpers.isExternalLibrary(libraries[i], rootApp) &&
                    !Helpers.isProjectLibrary(libraries[i], rootApp) ) {
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
        prefix: externalLibrariesPath_abs + "/"
    }


    // Raise error if a lib is not found anywhere
    property bool unkownLibraryFound: {
        for (var i = 0; i < libraries.length; i++) {
            if (!Helpers.isCoreLibrary(libraries[i], rootApp) &&
                !Helpers.isProjectLibrary(libraries[i], rootApp) &&
                !Helpers.isExternalLibrary(libraries[i], rootApp) ) {

                //console.error("Library not found: " + libraries[i])
                throw ("Library not found: " + libraries[i])
                return true
            }
        }
        return false
    }




    // Build core libraries names
    property stringList availableCoreLibraries: coreLibsProbe.coreLibrariesEntries

    Probe {
        id: coreLibsProbe
        condition: true

        property stringList coreLibrariesEntries: []

        configure: {
            // Get core libs names
            var coreLibs = File.directoryEntries(coreLibrariesPath, File.AllDirs | File.NoDotAndDotDot)

            coreLibrariesEntries = coreLibs

            if (coreLibs.count > 0)
                found = true
            else
                found = false

            //console.warn("Core libs: " + coreLibs);
        }
    }




    type: ["application", "ihex", "eeprom", "binary", "size", "upload"]

    cpp.executableSuffix: ".elf"


    // Install hex to known dir for upload (need to check "Install" in Project Build Settings)
    // TODO: installRoot needs to be manually set in project config panel, find an alternative to not do that (no qtc variable to install root)
    Group {
        name: "Hex - Teensy Loader"
        fileTagsFilter: ["application", "ihex", "upload"]
        qbs.install: true
        //qbs.installDir: "build"
    }



    // Binaries generation

    // Hex
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
    }


    // Binary
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


    // Print binary size
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
            return [cmd];
        }
    }
}

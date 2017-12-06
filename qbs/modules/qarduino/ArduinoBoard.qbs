import qbs
import "boardscanner.js" as BoardScanner
import "utils.js" as UT

ArduinoCore {
    id: root
    condition: true
    Depends { name: "cpp" }

    property bool loaded: {
        UT.setRootId(root) // utils.js needs access to some module properties
        return true
    }


    // Scans Arduino's board.txt files
    Probe {
        id: boardScannerProbe
        condition: true

        property var boardsMap: {}

        property path arduinoPath: root.arduinoPath

        configure: {
            boardsMap = BoardScanner.loadBoardFile(boardsMap, arduinoPath+"/hardware/arduino/avr/boards.txt")
            boardsMap = BoardScanner.loadBoardFile(boardsMap, arduinoPath+"/hardware/teensy/avr/boards.txt")
            // TODO: allow user to load custom board files (or/and add directly a board dict?)

            //console.warn("Name: " + boardsMap["nano"]["name"]["value"])

            //console.warn("Core: " + BoardScanner.getCore(boardsMap, boardName))
        }
    }

    // Build dict for the current board
    property var boardBuild: BoardScanner.getBuildMap(boardScannerProbe.boardsMap, boardName)

    arduinoCore: boardBuild.core
    cpu: boardBuild.mcu
    frequency: boardBuild.f_cpu ? boardBuild.f_cpu : "48000000L" // Default FCPU for teensy


    Properties {
        condition: arduinoCore === "teensy3" && loaded

        property stringList flags_cpu: UT.flags(boardBuild.flags.cpu)
        property stringList flags_defines: [boardBuild.board]

        property stringList flags_ldspecs: UT.flags(boardBuild.flags.ld)
        property stringList flags_libs: UT.flags(boardBuild.flags.libs, true)

        //cpp.architecture: "armv4t"

        cpp.commonCompilerFlags: base.concat(flags_cpu, UT.flags(boardBuild.flags.common))

        cpp.cxxFlags: base.concat(UT.flags(boardBuild.flags.dep), UT.flags(boardBuild.flags.cpp))
        //cpp.cFlags: base.concat(UT.flags(boardBuild.flags.c))
        cpp.assemblerFlags: base.concat(UT.flags(boardBuild.flags.S))

        cpp.dynamicLibraries: base.concat(flags_libs)
        cpp.driverFlags: base.concat(flags_cpu, flags_ldspecs)
        cpp.defines: base.concat(flags_defines, UT.flags(boardBuild.flags.defs, true))
    }

    Properties {
        condition: arduinoCore === "arduino" && loaded
        //cpp.architecture: "avr5"

        property stringList flags_cpu: ["-mmcu="+boardBuild.mcu]
        property stringList flags_defines: [boardBuild.board]

        property stringList flags_ldspecs: []
        property stringList flags_libs: []

        cpp.commonCompilerFlags: base.concat(flags_cpu)

        cpp.dynamicLibraries: base.concat(flags_libs)
        cpp.driverFlags: base.concat(flags_cpu, flags_ldspecs)
        cpp.defines: base.concat(flags_defines)

        cpp.includePaths: base.concat([corePath+"/../../variants/"+boardBuild.variant])
    }



    /*Properties {
        condition: boardName === "teensy30"
        //cpu: "mk20dx128" // FIXME: Workaround for bug QBS-1240, remove comments when fixed

        property stringList flags_cpu: ["-mcpu=cortex-m4","-fsingle-precision-constant"]
        property stringList flags_defines: ["__MK20DX128__"]

        property stringList flags_ldspecs: ["-mthumb", "-T"+corePath+"/mk20dx128.ld"]
        property stringList flags_libs: ["arm_cortexM4l_math"]

        cpp.architecture: "armv4t"
        frequency: "48"

        cpp.commonCompilerFlags: base.concat(flags_cpu)

        //cpp.libraryPaths:
        cpp.dynamicLibraries: base.concat(flags_libs)
        cpp.driverFlags: base.concat(flags_cpu, flags_ldspecs)
        cpp.defines: base.concat(flags_defines)

        arduinoCore: "teensy3"
    }

    Properties {
        condition: boardName === "teensy31" || boardName === "teensy32"
        //cpu: "mk20dx256"

        property stringList flags_cpu: ["-mcpu=cortex-m4","-fsingle-precision-constant"]
        property stringList flags_defines: ["__MK20DX256__"]

        property stringList flags_ldspecs: ["-mthumb", "-T"+corePath+"/mk20dx256.ld"]
        property stringList flags_libs: ["arm_cortexM4l_math"]

        cpp.architecture: "armv4t"
        frequency: "72"

        cpp.commonCompilerFlags: base.concat(flags_cpu)

        //cpp.libraryPaths:
        cpp.dynamicLibraries: base.concat(flags_libs)
        cpp.driverFlags: base.concat(flags_cpu, flags_ldspecs)
        cpp.defines: base.concat(flags_defines)

        arduinoCore: "teensy3"
    }

    Properties {
        condition: boardName === "teensy35"
        //cpu: "mk64fx512"

        property stringList flags_cpu: ["-mcpu=cortex-m4","-fsingle-precision-constant", "-mfloat-abi=hard", "-mfpu=fpv4-sp-d16"]
        property stringList flags_defines: ["__MK64FX512__"]

        property stringList flags_ldspecs: ["-mthumb", "-T"+corePath+"/mk64fx512.ld"]
        property stringList flags_libs: ["arm_cortexM4lf_math"]

        frequency: "180"

        cpp.commonCompilerFlags: base.concat(flags_cpu)

        cpp.dynamicLibraries: base.concat(flags_libs)
        cpp.driverFlags: base.concat(flags_cpu, flags_ldspecs)
        cpp.defines: base.concat(flags_defines)

        arduinoCore: "teensy3"
    }

    Properties {
        condition: boardName === "teensy36"
        //cpu: "mk66fx1m0"

        property stringList flags_cpu: ["-mcpu=cortex-m4","-fsingle-precision-constant", "-mfloat-abi=hard", "-mfpu=fpv4-sp-d16"]
        property stringList flags_defines: ["__MK66FX1M0__"]

        property stringList flags_ldspecs: ["-mthumb", "-T"+corePath+"/mk66fx1m0.ld"]
        property stringList flags_libs: ["arm_cortexM4lf_math"]

        frequency: "180"

        cpp.commonCompilerFlags: base.concat(flags_cpu)

        cpp.dynamicLibraries: base.concat(flags_libs)
        cpp.driverFlags: base.concat(flags_cpu, flags_ldspecs)
        cpp.defines: base.concat(flags_defines)

        arduinoCore: "teensy3"
    }

    Properties {
        condition: boardName === "pro5Vatmega328p" // Arduino Pro or Pro Mini 5V, 16MHz, ATmega328p
        //cpu: "atmega328p"
        cpp.architecture: "avr5"

        property stringList flags_cpu: ["-mmcu=atmega328p"]
        property stringList flags_defines: ["AVR_PRO"]

        property stringList flags_ldspecs: []
        property stringList flags_libs: []

        frequency: "16" // 16 MHz

        cpp.commonCompilerFlags: base.concat(flags_cpu)

        cpp.dynamicLibraries: base.concat(flags_libs)
        cpp.driverFlags: base.concat(flags_cpu, flags_ldspecs)
        cpp.defines: base.concat(flags_defines)

        cpp.includePaths: base.concat([corePath+"/../../variants/eightanaloginputs"])

        arduinoCore: "avr"
    }

    Properties {
        condition: boardName === "pro3V3atmega328p" // Arduino Pro or Pro Mini 3.3V, 8MHz, ATmega328p
        //cpu: "atmega328p"
        cpp.architecture: "avr5"

        property stringList flags_cpu: ["-mmcu=atmega328p"]
        property stringList flags_defines: ["AVR_PRO", "ARDUINO_ARCH_AVR"] // TODO: check defines

        property stringList flags_ldspecs: []
        property stringList flags_libs: []

        frequency: "8" // 8 MHz

        cpp.commonCompilerFlags: base.concat(flags_cpu)

        cpp.dynamicLibraries: base.concat(flags_libs)
        cpp.driverFlags: base.concat(flags_cpu, flags_ldspecs)
        cpp.defines: base.concat(flags_defines)

        cpp.includePaths: base.concat([corePath+"/../../variants/eightanaloginputs"])

        arduinoCore: "avr"
    }//*/
}

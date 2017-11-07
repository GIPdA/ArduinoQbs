import qbs

ArduinoBase {
    condition: false
    Depends { name: "cpp" }

    // FIXME: Workaround for bug QBS-1240, remove comments when fixed
    compilerPath: arduinoPath+"/hardware/tools"

    corePath: {
        if (arduinoCore === "teensy3")
            return arduinoPath+"/hardware/teensy/avr/cores/teensy3"
        if (arduinoCore === "avr")
            return arduinoPath+"/hardware/arduino/avr/cores/arduino"
    }

    coreLibrariesPath: {
        if (arduinoCore === "teensy3")
            return arduinoPath+"/hardware/teensy/avr/libraries"
        if (arduinoCore === "avr")
            return arduinoPath+"/hardware/arduino/avr/libraries"
    }
    coreIncludePaths: {
        if (arduinoCore === "teensy3")
            return [corePath+"/util"/*, corePath+"/avr"*/]
        if (arduinoCore === "avr")
            return []
    }

    Properties {
        condition: arduinoCore === "teensy3"

        //TODO: check compiler and throw error if not compatible

        cpp.architecture: "armv4t"
        //cpp.cFlags:
        cpp.cxxFlags: ["-MMD","-felide-constructors"]
        cpp.assemblerFlags: ["-x","assembler-with-cpp"]

        cpp.dynamicLibraries: ["m"]

        cpp.commonCompilerFlags: ["-mthumb", "-ffunction-sections","-fdata-sections","-nostdlib",
             "-Wcast-align", "-fpack-struct=1" // Default packed struct
            ]


        //cpp.driverFlags: ["--specs=nano.specs"]
        cpp.driverFlags: ["-Wl,--gc-sections,--relax,--defsym=__rtc_localtime="+time_local,"--specs=nano.specs"]


        //cpp.defines: ["ARDUINO=10802"]
        cpp.defines: ["ARDUINO=10802", "TEENSYDUINO=141", usbType, "LAYOUT_"+keyLayout, "F_CPU="+fcpu]


        // Relative paths
        // FIXME: Workaround for bug QBS-1240, remove comments when fixed
//        compilerPath: "hardware/tools"
//        corePath: "hardware/teensy/avr/cores/teensy3"
//        coreLibrariesPath: "hardware/teensy/avr/libraries" // Arduino core libs
//        coreIncludePaths: [corePath+"/util"/*, corePath+"/avr"*/]
    }

    Properties {
        condition: arduinoCore === "avr"

        //TODO: check compiler and throw error if not compatible

        cpp.architecture: "avr"
        cpp.cFlags: ["-fno-fat-lto-objects"]
        cpp.cxxFlags: ["-fpermissive","-fno-threadsafe-statics","-felide-constructors"]
        cpp.assemblerFlags: ["-x","assembler-with-cpp"]

        cpp.dynamicLibraries: ["m"]

        cpp.commonCompilerFlags: ["-MMD","-flto","-ffunction-sections","-fdata-sections","-nostdlib",
             "-Wcast-align","-fpack-struct=1" // Default packed struct
            ]


        cpp.driverFlags: ["-fuse-linker-plugin"]


        cpp.defines: ["ARDUINO=10802", "F_CPU="+fcpu]


        // Relative paths
        // FIXME: Workaround for bug QBS-1240, remove comments when fixed
        //compilerPath: "hardware/tools"
        //corePath: "hardware/arduino/avr/cores/arduino"
        //coreLibrariesPath: "hardware/arduino/avr/libraries" // Arduino core libs
    }//*/
}

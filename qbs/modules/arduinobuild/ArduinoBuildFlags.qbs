import qbs

Module {
    Depends { name: "cpp" }

    property string compilerPath: ""
    property string corePath: ""
    property string coreLibrariesPath: ""

    Properties {
        condition: arduinoArchName === "teensy3"

        //cpp.cFlags: outer.concat()
        cpp.cxxFlags: outer.concat(["-MMD","-felide-constructors"])
        cpp.assemblerFlags: outer.concat(["-x","assembler-with-cpp"])

        cpp.dynamicLibraries: outer.concat(["m"])

        cpp.commonCompilerFlags: outer.concat(
            ["-mthumb", "-ffunction-sections","-fdata-sections","-nostdlib",
             "-Wcast-align", "-fpack-struct=1" // Default packed struct
            ]
        )

        cpp.linkerFlags: outer.concat(
            ["-Wl,--gc-sections,--relax,--defsym=__rtc_localtime="+time_local,"--specs=nano.specs"]
        )

        cpp.defines: outer.concat(
            ["ARDUINO=10802", "TEENSYDUINO=141", usbType, "LAYOUT_"+keyLayout, "F_CPU="+fcpu]
        )

        cpp.positionIndependentCode: false
        cpp.enableExceptions: false
        cpp.enableRtti: false
        cpp.cxxLanguageVersion: "gnu++0x"

        compilerPath: "/Applications/Arduino.app/Contents/Java/hardware/tools"
        corePath: "/Applications/Arduino.app/Contents/Java/hardware/teensy/avr/cores/teensy3"
        coreLibrariesPath: "/Applications/Arduino.app/Contents/Java/hardware/teensy/avr/libraries" // Arduino core libs
    }

    Properties {
        condition: arduinoArchName === "avr"

        cpp.cFlags: outer.concat(["-fno-fat-lto-objects"])
        cpp.cxxFlags: outer.concat(["-fpermissive","-fno-threadsafe-statics","-felide-constructors"])
        cpp.assemblerFlags: outer.concat(["-x","assembler-with-cpp"])

        cpp.dynamicLibraries: outer.concat(["m"])

        cpp.commonCompilerFlags: outer.concat(
            ["-MMD","-flto","-ffunction-sections","-fdata-sections","-nostdlib",
             "-Wcast-align","-fpack-struct=1" // Default packed struct
            ]
        )

        cpp.linkerFlags: outer.concat(
            ["-fuse-linker-plugin"]
        )

        cpp.defines: outer.concat(
            ["ARDUINO=10802", "F_CPU="+fcpu]
        )

        cpp.positionIndependentCode: false
        cpp.enableExceptions: false
        cpp.enableRtti: false
        cpp.cxxLanguageVersion: "gnu++0x"

        compilerPath: "/Applications/Arduino.app/Contents/Java/hardware/tools"
        corePath: "/Applications/Arduino.app/Contents/Java/hardware/arduino/avr/cores/arduino"
        coreLibrariesPath: "/Applications/Arduino.app/Contents/Java/hardware/arduino/avr/libraries" // Arduino core libs
    }
}

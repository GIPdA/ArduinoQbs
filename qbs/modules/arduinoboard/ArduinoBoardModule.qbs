import qbs
import qbs.FileInfo
import qbs.Process

Module {
    Depends { name: "cpp" }

    Properties {
        condition: boardName === "teensy30"

        property stringList flags_cpu: ["-mcpu=cortex-m4","-fsingle-precision-constant"]
        property stringList flags_defines: ["__MK20DX128__"]

        property stringList flags_ldspecs: ["-mthumb", "-T"+corePath+"/mk20dx128.ld"]
        property stringList flags_libs: ["arm_cortexM4l_math"]

        cpp.commonCompilerFlags: outer.concat(flags_cpu)

        //cpp.libraryPaths:
        cpp.dynamicLibraries: outer.concat(flags_libs)
        cpp.linkerFlags: outer.concat(flags_cpu, flags_ldspecs)
        cpp.defines: outer.concat(flags_defines)
    }

    Properties {
        condition: boardName === "teensy31"

        property stringList flags_cpu: ["-mcpu=cortex-m4","-fsingle-precision-constant"]
        property stringList flags_defines: ["__MK20DX256__"]

        property stringList flags_ldspecs: ["-mthumb", "-T"+corePath+"/mk20dx256.ld"]
        property stringList flags_libs: ["arm_cortexM4l_math"]

        cpp.commonCompilerFlags: outer.concat(flags_cpu)

        //cpp.libraryPaths:
        cpp.dynamicLibraries: outer.concat(flags_libs)
        cpp.linkerFlags: outer.concat(flags_cpu, flags_ldspecs)
        cpp.defines: outer.concat(flags_defines)
    }

    Properties {
        condition: boardName === "teensy35"

        property stringList flags_cpu: ["-mcpu=cortex-m4","-fsingle-precision-constant", "-mfloat-abi=hard", "-mfpu=fpv4-sp-d16"]
        property stringList flags_defines: ["__MK64FX512__"]

        property stringList flags_ldspecs: ["-mthumb", "-T"+corePath+"/mk64fx512.ld"]
        property stringList flags_libs: ["arm_cortexM4lf_math"]

        cpp.commonCompilerFlags: outer.concat(flags_cpu)

        cpp.dynamicLibraries: outer.concat(flags_libs)
        cpp.linkerFlags: outer.concat(flags_cpu, flags_ldspecs)
        cpp.defines: outer.concat(flags_defines)
    }

    Properties {
        condition: boardName === "teensy36"

        property stringList flags_cpu: ["-mcpu=cortex-m4","-fsingle-precision-constant", "-mfloat-abi=hard", "-mfpu=fpv4-sp-d16"]
        property stringList flags_defines: ["__MK66FX1M0__"]

        property stringList flags_ldspecs: ["-mthumb", "-T"+corePath+"/mk66fx1m0.ld"]
        property stringList flags_libs: ["arm_cortexM4lf_math"]

        cpp.commonCompilerFlags: outer.concat(flags_cpu)

        cpp.dynamicLibraries: outer.concat(flags_libs)
        cpp.linkerFlags: outer.concat(flags_cpu, flags_ldspecs)
        cpp.defines: outer.concat(flags_defines)
    }

    Properties {
        condition: boardName === "pro5Vatmega328" // Arduino Pro or Pro Mini 5V, 16MHz, ATmega328p

        property stringList flags_cpu: ["-mmcu=atmega328p"]
        property stringList flags_defines: ["AVR_PRO"]

        property stringList flags_ldspecs: []
        property stringList flags_libs: []

        frequency: "16" // 16 MHz

        cpp.commonCompilerFlags: outer.concat(flags_cpu)

        cpp.dynamicLibraries: outer.concat(flags_libs)
        cpp.linkerFlags: outer.concat(flags_cpu, flags_ldspecs)
        cpp.defines: outer.concat(flags_defines)

        cpp.includePaths: outer.concat([corePath+"/../../variants/eightanaloginputs"])
    }

    Properties {
        condition: boardName === "pro3V3atmega328" // Arduino Pro or Pro Mini 3.3V, 16MHz, ATmega328p

        property stringList flags_cpu: ["-mmcu=atmega328p"]
        property stringList flags_defines: ["AVR_PRO", "ARDUINO_AVR_PRO", "ARDUINO_ARCH_AVR"]

        property stringList flags_ldspecs: []
        property stringList flags_libs: []

        frequency: "8" // 8 MHz

        cpp.commonCompilerFlags: outer.concat(flags_cpu)

        cpp.dynamicLibraries: outer.concat(flags_libs)
        cpp.linkerFlags: outer.concat(flags_cpu, flags_ldspecs)
        cpp.defines: outer.concat(flags_defines)

        cpp.includePaths: outer.concat([corePath+"/../../variants/eightanaloginputs"])
    }
}

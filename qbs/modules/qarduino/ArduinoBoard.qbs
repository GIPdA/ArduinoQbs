import qbs

ArduinoCore {
    condition: true
    Depends { name: "cpp" }

    cpu: { // FIXME: Workaround for bug QBS-1240, remove comments when fixed
        if (boardName === "teensy30") return "mk20dx128"
        if (boardName === "teensy31" || boardName === "teensy32") return "mk20dx256"
        if (boardName === "teensy35") return "mk64fx512"
        if (boardName === "teensy36") return "mk66fx1m0"
        if (boardName === "pro5Vatmega328p") return "atmega328p"
        if (boardName === "pro3V3atmega328p") return "atmega328p"
    }

    Properties {
        condition: boardName === "teensy30"
        //cpu: "mk20dx128" // FIXME: Workaround for bug QBS-1240, remove comments when fixed

        property stringList flags_cpu: ["-mcpu=cortex-m4","-fsingle-precision-constant"]
        property stringList flags_defines: ["__MK20DX128__"]

        property stringList flags_ldspecs: ["-mthumb", "-T"+corePath+"/mk20dx128.ld"]
        property stringList flags_libs: ["arm_cortexM4l_math"]

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
    }
}

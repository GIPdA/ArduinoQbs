import qbs
import qbs.FileInfo
import qbs.File
import qbs.TextFile
import qbs.Process


ArduinoBase {
    condition: false
    Depends { name: "cpp" }

    // FIXME: Workaround for bug QBS-1240, remove comments when fixed
    toolsPath: arduinoPath+"/hardware/tools"

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

        cpp.architecture: "avr2"
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
//        compilerPath: "hardware/tools"
//        corePath: "hardware/arduino/avr/cores/arduino"
//        coreLibrariesPath: "hardware/arduino/avr/libraries" // Arduino core libs
    }


    property string uploadTemplatesPath: path+"/tpl"

    // Write script to upload hex file to the Teensy using Teensy Loader shipped with Teensyduino install
    Rule {
        inputs: ["ihex"]

        condition: arduinoCore === "teensy3"

        Artifact {
            fileTags: ["upload"]
            filePath: product.destinationDirectory + "/" + "upload.sh"
        }

        prepare: {
            var cmd = new JavaScriptCommand();
            cmd.description = "Upload Teensy: " + FileInfo.fileName(input.filePath)
            //cmd.silent = true;

            cmd.templateFilePath = product.moduleProperty("qarduino", "uploadTemplatesPath") + "/teensy_upload.tpl"
            cmd.toolsPath = product.moduleProperty("qarduino", "toolsPath")

            cmd.sourceCode = function() {
                // Read template file
                var tpl = TextFile(templateFilePath, TextFile.ReadOnly)
                var tplStr = tpl.readAll()
                tpl.close()

                // Replace tags
                tplStr = tplStr.replace(/\[TEENSY_TOOLS_PATH\]/gi, toolsPath)
                tplStr = tplStr.replace(/\[TEENSY_HEX_PATH\]/gi, FileInfo.path(input.filePath))
                tplStr = tplStr.replace(/\[TEENSY_HEX_BASENAME\]/gi, FileInfo.baseName(input.filePath))

                // Write script
                var f = TextFile(output.filePath, TextFile.WriteOnly)
                f.write(tplStr)
                f.close();

                // Script needs to be executable
                var process = new Process();
                process.exec("chmod", ["u+x", output.filePath]);
                process.close();
            };
            return [cmd];
        }
    }

    // Write script to upload hex file to AVR using avrdude
    Rule {
        inputs: ["ihex"]

        condition: arduinoCore === "avr"

        Artifact {
            fileTags: ["upload"]
            filePath: product.destinationDirectory + "/" + "upload.sh"
        }

        prepare: {
            var cmd = new JavaScriptCommand();
            cmd.description = "Upload AVR: " + FileInfo.fileName(input.filePath)
            //cmd.silent = true;

            cmd.templateFilePath = product.moduleProperty("qarduino", "uploadTemplatesPath") + "/avr_upload.tpl"
            cmd.toolsPath = product.moduleProperty("qarduino", "toolsPath")

            cmd.cpu = product.moduleProperty("qarduino", "cpu")

            cmd.sourceCode = function() {
                // Setup command
                // TODO: use template
                var avrdude = toolsPath + "/avr/bin/avrdude"
                var config = toolsPath + "/avr/etc/avrdude.conf"

                var cmd = [avrdude, "-C"+config,
                           "-v",
                           "-p"+cpu,
                           "-carduino",
                           "-P"+product.serialport, "-b57600",
                           "-D",
                           "-Uflash:w:" + input.filePath + ":i"
                        ]

                // Write script
                var f = TextFile(output.filePath, TextFile.WriteOnly)
                f.writeLine(cmd.join(' '))
                f.close();

                // Script needs to be executable
                var process = new Process();
                process.exec("chmod", ["u+x", output.filePath]);
                process.close();
            };
            return [cmd];
        }
    }
}

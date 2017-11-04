import qbs
import qbs.FileInfo
import qbs.File
import qbs.TextFile
import qbs.Process

Module {

    // Write script to upload hex file to the Teensy using Teensy Loader shipped with Teensyduino install
    Rule {
        inputs: ["ihex"]

        condition: arduinoBuildSystem === "teensy3"

        Artifact {
            fileTags: ["upload"]
            filePath: product.destinationDirectory + "/" + "upload.sh"
        }

        prepare: {
            var cmd = new JavaScriptCommand();
            cmd.description = "Upload Teensy: " + FileInfo.fileName(input.filePath)
            //cmd.silent = true;
            cmd.sourceCode = function() {
                // Read template file
                var tpl = TextFile(product.projectPath + "/qbs/tools/teensy_upload.tpl", TextFile.ReadOnly)
                var tplStr = tpl.readAll()
                tpl.close()

                // Replace tags
                tplStr = tplStr.replace(/\[TEENSY_TOOLS_PATH\]/gi, product.compilerPath)
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

        condition: arduinoBuildSystem === "avr"

        Artifact {
            fileTags: ["upload"]
            filePath: product.destinationDirectory + "/" + "upload.sh"
        }

        prepare: {
            var cmd = new JavaScriptCommand();
            cmd.description = "Upload AVR: " + FileInfo.fileName(input.filePath)
            //cmd.silent = true;
            cmd.sourceCode = function() {
                // Setup command
                // TODO: use template
                var avrdude = product.compilerPath + "/avr/bin/avrdude"
                var config = product.compilerPath + "/avr/etc/avrdude.conf"

                var cmd = [avrdude, "-C"+config,
                           "-v",
                           "-p"+product.arduinoboard.cpu,
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

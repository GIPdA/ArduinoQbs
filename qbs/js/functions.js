
var File = require("qbs.File");
var TextFile = require("qbs.TextFile");


function getTimes()
{
    //https://forum.pjrc.com/threads/27740-Arduino-1-6-0-any-plans-to-support-it?p=64814&viewfull=1#post64814

    var d = new Date()
    var current = d.getTime()/1000 // To seconds
    var timezone = d.getTimezoneOffset()*60 // To seconds
    var daylight = 0

    return {"utc":current.toFixed(),
        "local":(current+timezone+daylight).toFixed(),
        "zone":timezone.toFixed(),
        "dst":daylight.toFixed()}
}

function getTime(key)
{
    return getTimes()[key].toString()
}


// Lib helpers
function isCoreLibrary(libName, rootApp)
{
    return rootApp.availableCoreLibraries.contains(libName)
}
function isProjectLibrary(libName, rootApp)
{
    return File.exists(rootApp.projectPath+"/"+rootApp.projectLibrariesPath+"/"+libName)
}
function isExternalLibrary(libName, rootApp)
{
    return File.exists(rootApp.externalLibrariesPath_abs+"/"+libName)
}

function readBoards(board, variant)
{
    var tpl = TextFile("/Applications/Arduino.app/Contents/Java/hardware/arduino/avr/boards.txt", TextFile.ReadOnly)
    //var tplStr = tpl.readAll()

    var map = {}

    while (!tpl.atEof()) {
        var str = tpl.readLine()

        if (str.startsWith(board)) {
            //console.warn(str)

            if (str.contains(variant)) {
                var n = str.indexOf("build.mcu")
                if (n > 0) {
                    map["mcu"] = str.substring(n+10)
                    console.warn(str.substring(n+10))
                }

                n = str.indexOf("build.f_cpu")
                if (n > 0) {
                    map["fcpu"] = str.substring(n+12)
                    console.warn(map["fcpu"])
                }
            } else {
                n = str.indexOf("build.variant")
                if (n > 0) {
                    map["variant"] = str.substring(n+14)
                    console.warn(map["variant"])
                }
            }

        }
    }

    tpl.close()

    return map
}

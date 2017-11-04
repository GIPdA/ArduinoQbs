
var File = require("qbs.File");


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

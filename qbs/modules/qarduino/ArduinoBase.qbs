import qbs

Module {
    condition: false
    Depends { name: "cpp" }

    property path arduinoPath

    property path toolsPath
    property path corePath
    property path coreLibrariesPath
    property pathList coreIncludePaths: []

    property string arduinoCore
    PropertyOptions {
        name: "arduinoCore"
        allowedValues: ["teensy3", "avr"]
        description: "Target architecture to compile for ('teensy3' for Teensy 3.x or 'avr' for AVR boards)."
    }

    property string boardName

    property string cpu
    property string frequency

    property string usbType
    property string keyLayout

    property string time_local
    property string time_utc
    property string time_zone
    property string time_dst

    property string fcpu: frequency+"000000L"

    cpp.positionIndependentCode: false
    cpp.enableExceptions: false
    cpp.enableRtti: false
    cpp.cxxLanguageVersion: "gnu++0x"
    //cpp.cxxLanguageVersion: "c++11"
}

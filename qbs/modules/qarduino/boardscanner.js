var File = require("qbs.File");
var TextFile = require("qbs.TextFile");


function findBoard(map, board)
{
    return map[board];
}

// Retreive arduino core system for this board
// Name: <board>,<variant> (example: "pro,16MHzatmega328")
function getCore(map, name)
{
    var bv = name.split(",")
    return findBuildValue(map, "core", bv[0], bv[1])
}

// Retreive board name
// Name: <board>,<variant> (example: "pro,16MHzatmega328")
function getBoardName(name) {
    return name.split(",")[0]
}
// Retreive board variant
// Name: <board>,<variant> (example: "pro,16MHzatmega328")
function getBoardVariantName(name) {
    return name.split(",")[1]
}


// Recursively loop map to add sub-dicts and values (remove .value keys)
function addBuildMapEntry(bmap, map)
{
    for (var bv in map) {
        if (typeof map[bv].value !== "undefined") {
            bmap[bv] = map[bv].value
        } else {
            bmap[bv] = {}
            addBuildMapEntry(bmap[bv], map[bv])
        }
    }
}

// Construct an object of all "build" items of specified board+cpu
// Name: <board>,<variant> (example: "pro,16MHzatmega328")
function getBuildMap(map, name)
{
    var bmap = {}
    var bname = name.split(",")

    var boardBuildObj = boardBuildObject(map, bname[0])
    if (boardBuildObj) {
        addBuildMapEntry(bmap, boardBuildObj)
    }

    var variantBuildObj = boardVariantBuildObject(map, bname[1])
    if (variantBuildObj) {
        addBuildMapEntry(bmap, variantBuildObj)
    }

    //console.warn("Build map: " + bmap["core"])

    return bmap
}



// Returns the object of the "build" key of the specified board variant, if any.
// Path: <bmap>.menu.cpu.<variant>.build
function boardVariantBuildObject(bmap, variant)
{
    if (typeof bmap.menu === "undefined") return
    if (typeof bmap.menu.cpu === "undefined") return
    var varmap = bmap.menu.cpu[variant]
    if (typeof varmap === "undefined") return
    if (typeof varmap.build === "undefined") return
    return varmap.build
}

// Search the build value for the key in board variant
function findVariantBuildValue(bmap, key, variant)
{
    if (typeof bmap.menu === "undefined") return
    if (typeof bmap.menu.cpu === "undefined") return
    var varmap = bmap.menu.cpu[variant]
    if (typeof varmap === "undefined") return
    if (typeof varmap.build === "undefined") return
    if (typeof varmap.build[key] === "undefined") return

    var build = boardVariantBuildObject(bmap, variant)
    if (typeof build === "undefined") return

    console.warn("Found variant build key: " + key + " = " + build[key].value)

    return build[key].value
}


// Returns the object of the "build" key of the specified board, if any.
// Path: <board>.build
function boardBuildObject(map, board)
{
    var boardmap = findBoard(map, board)
    if (typeof boardmap === "undefined") return
    return boardmap.build
}

// Search the build value for the key in board or board variant
function findBuildValue(map, key, board, variant)
{
    var buildmap = boardBuildObject(map, board)
    if (typeof buildmap === "undefined") return

    var boardValue
    if (typeof buildmap[key] !== "undefined") {
        console.warn("Found build key: " + key + " = " + buildmap[key].value)
        boardValue = buildmap[key].value
    }

    if (!variant) return boardValue

    // Search in variant boards
    var varValue = findVariantBuildValue(boardmap, key, variant)

    if (typeof varValue !== "undefined") return varValue
    return boardValue
}


// Add key[.subkey]-value pair entry to the map
function addEntry(map, entries, index, value)
{
    var key = entries[index]
    if (index === entries.length) {
        // Need to add a .value item because it can be both a string or a dict
        map.value = value
        return
    }

    if (typeof map[key] === "undefined") {
        // Create empty entry if non-existing
        map[key] = {}
    }

    addEntry(map[key], entries, index+1, value)
}


// Load a board file into map
function loadBoardFile(map, fileName)
{
    var tpl = TextFile(fileName, TextFile.ReadOnly)

    if (typeof map === "undefined")
        map = {}

    while (!tpl.atEof()) {
        var str = tpl.readLine()

        if (str.startsWith("#")) continue // Comment

        var n = str.indexOf("=")
        if (n <= 0) continue // Bad entry?

        var leftStr = str.substring(0, n)

        var entries = leftStr.split('.')
        if (entries.length <= 1) continue // Bad entry?

        if (entries[0] === "menu") continue // Ignore root menu items

        //console.warn("LINE: " + leftStr + " = " + str.substring(n+1))
        //console.warn("ENTRIES: " + entries)

        addEntry(map, entries, 0, str.substring(n+1))
    }

    //console.warn("Name: " + map["yun"]["name"]["value"])

    //console.warn("Name: " + map["pro"]["menu"]["cpu"]["16MHzatmega328"]["build"]["mcu"]["value"])
    //console.warn("Name: " + map.pro.menu.cpu.16MHzatmega328.build.mcu.value)

    //testMap(map)

    tpl.close()

    return map
}


function testMap(map)
{
    testFindBuildValue(map, "mcu", "pro", "16MHzatmega328", true)
    testFindBuildValue(map, "board", "pro", "16MHzatmega328", true)
    testFindBuildValue(map, "board", "pro", "", true)

    testFindBuildValue(map, "toto", "pro", "16MHzatmega328", false)
    testFindBuildValue(map, "mcu", "pro", "", false)
}

function testFindBuildValue(map, key, board, variant, expected)
{
    var r = findBuildValue(map, key, board, variant)

    if (expected && r) {
        console.warn("TEST OK: " + key + " = " + r)
    } else if (!expected && !r) {
        console.warn("TEST OK: " + key + " = " + r)
    } else {
        console.warn("TEST FAILED! " + key + " = " + r)
    }
}

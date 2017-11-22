var File = require("qbs.File");
var TextFile = require("qbs.TextFile");


function getCore(map, name)
{
    var bv = name.split(",")
    return findBuildValue(map, "core", bv[0], bv[1])
}

function getBoard(name) {
    return name.split(",")[0]
}
function getBoardVariant(name) {
    return name.split(",")[1]
}

function getBuildMap(map, name)
{
    var bmap = {}
    var bname = name.split(",")

    var boardBuildObj = boardBuildObject(map, bname[0])
    if (boardBuildObj) {
        for (var bv in boardBuildObj) {
            if (typeof boardBuildObj[bv].value !== "undefined")
                bmap[bv] = boardBuildObj[bv].value
            else
                bmap[bv] = boardBuildObj[bv]
        }
    }

    var variantBuildObj = boardVariantBuildObject(map, bname[1])
    if (variantBuildObj) {
        for (var bv in variantBuildObj) {
            if (typeof variantBuildObj[bv].value !== "undefined")
                bmap[bv] = variantBuildObj[bv].value
            else
                bmap[bv] = variantBuildObj[bv]
        }
    }

    //console.warn("Build map: " + bmap["core"])

    return bmap
}



function boardVariantBuildObject(bmap, variant)
{
    if (typeof bmap.menu === "undefined") return
    if (typeof bmap.menu.cpu === "undefined") return
    var varmap = bmap.menu.cpu[variant]
    if (typeof varmap === "undefined") return
    if (typeof varmap.build === "undefined") return
    return varmap.build
}

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


function boardBuildObject(map, board)
{
    var boardmap = findBoard(map, board)
    if (typeof boardmap === "undefined") return
    return boardmap.build
}

function findBuildValue(map, key, board, variant)
{
    var boardmap = findBoard(map, board)

    if (typeof boardmap === "undefined") return
    var buildmap = boardmap.build
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

function findBoard(map, board)
{
    return map[board];
}


function addEntry(map, entries, index, value)
{
    var key = entries[index]
    if (index === entries.length) {
        map.value = value
        return
    }

    if (typeof map[key] === "undefined") {
        // Create empty entry if non-existing
        map[key] = {}
    }

    addEntry(map[key], entries, index+1, value)
}

function loadBoardFile(map, fileName)
{
    var tpl = TextFile(fileName, TextFile.ReadOnly)
    //var tplStr = tpl.readAll()

    if (typeof map === "undefined")
        map = {}

    //var map = {}
    while (!tpl.atEof()) {
        var str = tpl.readLine()

        if (str.startsWith("#")) continue // Comment

        var n = str.indexOf("=")
        if (n <= 0) continue // Bad entry?

        var leftStr = str.substring(0, n)

        var entries = leftStr.split('.')
        if (entries.length <= 1) continue // Bad entry?

        if (entries[0] === "menu") continue

        //console.warn("LINE: " + leftStr + " = " + str.substring(n+1))
        //console.warn("ENTRIES: " + entries)

        addEntry(map, entries, 0, str.substring(n+1))

        //console.warn("Name: " + map["yun"]["name"]["value"])
    }

    //console.warn("Name: " + map["yun"]["name"]["value"])

    //console.warn("Name: " + map["pro"]["menu"]["cpu"]["16MHzatmega328"]["build"]["mcu"]["value"])

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

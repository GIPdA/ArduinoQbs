// Some operations on build flags strings, mainly for Teensy

var rootApp // id to the root module for property access
function setRootId(root) {
    rootApp = root
}

// Remove defines (-D) and libs (-l) prefixes
function cleanFlags(str) {
    return str.replace(/^(-D|-l)/, '')
}
// Remove extra " but not \"
function _clean(str) {
    return str.replace(/(\\)?"/gi, function($0,$1){ return $1?$0:'';})
}
// Replace placeholders
function _replace(str) {
    str = str.replace("{build.core.path}", rootApp.corePath)
    str = str.replace("{extra.time.local}", rootApp.time_local)
    return str
}


function flags(str, clean) {
    var list = str.split(/\s+/)
    var ret = []
    for (var i = 0; i < list.length; ++i) {
        var s = _clean(list[i])
        if (clean) s = cleanFlags(s)
        s = _replace(s)
        ret.push(s)
    }
    //console.warn("cleaned " + str + " to "+ ret)
    return ret
}

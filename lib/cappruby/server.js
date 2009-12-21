var FILE = require("file");
var OS = require("os");
var CAPPRUBY = require("../cappruby");

exports.Server = function(root) {
    var root = FILE.path(root);
    
    return function(env) {
        if (!(/\.rb$/).test(env['PATH_INFO']))
            return {
                status : 404,
                headers : { "Content-Type" : "text/plain", "Content-Length" : "0" },
                body : []
            };
        
        var fin = root.join(env['PATH_INFO']).open("r", { charset : "UTF-8" });
        var code = "";
        try {
            code = CAPPRUBY.ruby2objjFromStream(fin);
        } finally {
            fin.close();
        }
        
        return {
            status : 200,
            headers : { "Content-Type" : "application/javascript", "Content-Length" : code.length.toString() },
            body : [code]
        };
    }
}

var FILE = require("file");
var OS = require("os");
var OBJJ = require("objective-j");

exports.run = function(args) {
    // TODO: non-REPL
    
    args.shift();
    
    print("args="+args)
    
    if (args.length) {
        require(FILE.absolute(args[0]));
        return;
    }
    
    while (true)
    {
        try {
            system.stdout.write("capprb> ").flush();

            var result = exports.ruby_eval(require("readline").readline());

            if (result !== undefined)
                print(result);
                
        } catch (e) {
            print(e);
        }
        
        require("browser/timeout").serviceTimeouts();
    }
}

// executes the ruby2objj Ruby program to convert from Ruby to Objective-J.
// eventually this will hopefully be replaced by a JavaScript program.
exports.ruby2objj = function(code) {
    var ruby2objjPath = FILE.path(module.path).dirname().dirname().join("bin", "ruby2objj");
    
    var ruby2objj = OS.popen([ruby2objjPath]);
    
    ruby2objj.stdin.write(code).flush().close();
    
    if (ruby2objj.wait() !== 0)
        throw new Error("ruby2objj compiler error");
    
    return ruby2objj.stdout.read();
}

// these two functions are equivalent to objective-j's objj_eval/make_narwhal_factory.
// implemented as a call to ruby2objj and objj_eval/make_narwhal_factory
exports.ruby_eval = function(code) {
    init();
    
    return OBJJ.objj_eval(exports.ruby2objj(code))
}
exports.make_narwhal_factory = function(code, path) {
    init();
    
    return OBJJ.make_narwhal_factory(exports.ruby2objj(code), path);
}

// must import CappRuby.j once
var init = function() {
    OBJJ.objj_eval("@import <CappRuby/CappRuby.j>");
    
    // make sure it's only done once
    init = function(){}
}
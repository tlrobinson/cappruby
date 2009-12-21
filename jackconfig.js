var FILE = require("file");
var JACK = require("jack");

var appPath = !system.args[1] ?
    FILE.path(module.path).dirname().join("TestApp") :
    FILE.absolute(system.args[1]);

system.stderr.print("Starting up CappRuby server with root: " + appPath);

exports.app = JACK.Cascade([
    require("cappruby/server").Server(appPath),
    JACK.File(appPath)
]);

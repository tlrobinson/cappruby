var cappruby = null;

function CappRubyLoader() {
    var loader = {};
    var factories = {};
    
    loader.reload = function(topId, path) {
        if (!cappruby) cappruby = require("cappruby");
        
        //print("loading objective-j: " + topId + " (" + path + ")");
        factories[topId] = cappruby.make_narwhal_factory(system.fs.read(path), path);
    }
    
    loader.load = function(topId, path) {
        if (!factories.hasOwnProperty(topId))
            loader.reload(topId, path);
        return factories[topId];
    }
    
    return loader;
};

require.loader.loaders.unshift([".rb", CappRubyLoader()]);

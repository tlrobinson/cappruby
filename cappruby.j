puts = print;

function rb_msgSend(/*id*/ aReceiver, /*SEL*/ aSelector)
{
    // FIXME: for Ruby use a NilClass, CPNull?
    if (aReceiver == nil)
        return nil;
    
    // Objective-J
    var recieverClass = aReceiver.isa;
    if (recieverClass) {
        if (!(recieverClass.info & CLS_INITIALIZED))
            _class_initialize(recieverClass);

        if (recieverClass.method_dtable[aSelector]) {
            return recieverClass.method_dtable[aSelector].method_imp.apply(aReceiver, arguments);
        }
        else
        {
            var newSelector = aSelector.replace("_", ":"),
                method = recieverClass.method_dtable[newSelector];
            if (method) {
                // cache the method so we don't have to do this every time.
                // FIXME: might not be "safe"?
                recieverClass.method_dtable[aSelector] = method;
                
                return method.method_imp.apply(aReceiver, arguments);
            }
            else {
                return _objj_forward.method_imp.apply(aReceiver, arguments);
            }
        }        
    }
    
    // JavaScript
    var property = aReceiver[aSelector];
    if (property) {
        // if it's a function, call  it and return the result. otherwise just return it.
        // TODO: figure out if there's better logic than this
        if (typeof property == "function")
            return property.apply(aReceiver, Array.prototype.slice.call(arguments, 2));
        else
            return property;
    }
    
    // return undefined?
}

@implementation CPObject (CappRuby)

+ (CPArray)ancestors
{
    var ancestors = [],
        klass = self;   
    while (klass)
    {
        ancestors.push(klass);
        klass = klass.super_class;
    }
    return ancestors;
}

@end

@import <Foundation/Foundation.j>

@import "Array.j"
@import "Number.j"
@import "Object.j"
@import "String.j"

// TODO: better way of defining selectors with characters invalid in Obj-J but valid in Ruby

puts = alert;

window._rbNoBlock = function() { throw new Error("no block given"); }
window._rbBlockGiven = function() { return true; }
window._rbBlockNotGiven = function() { return false; }

function rb_msgSend(aBlock, aReceiver, aSelector)
{
    // FIXME: for Ruby use a NilClass, CPNull?
    if (aReceiver == nil)
        return nil;
    
    var receiver = aReceiver,
        selector = aSelector;
            
    _rbBlock = aBlock;
    
    Array.prototype.shift.call(arguments);
    
    // Objective-J
    var receiverClass = receiver.isa;
    if (receiverClass) {
        if (!(receiverClass.info & CLS_INITIALIZED))
            _class_initialize(receiverClass);

        if (receiverClass.method_dtable[selector]) {
            return receiverClass.method_dtable[selector].method_imp.apply(receiver, arguments);
        }
        else
        {
            var newSelector = selector.replace(/_/g, ":"),
                method = receiverClass.method_dtable[newSelector];
            if (method) {
                // cache the method so we don't have to do this every time.
                // FIXME: might not be "safe"?
                receiverClass.method_dtable[selector] = method;
                return method.method_imp.apply(receiver, arguments);
            }
            else {
                newSelector += ":";
                method = receiverClass.method_dtable[newSelector];
                if (method) {
                    receiverClass.method_dtable[selector] = method;
                    return method.method_imp.apply(receiver, arguments);
                }
                else
                    return _objj_forward.method_imp.apply(receiver, arguments);
            }
        }        
    }
    
    // JavaScript
    var property = receiver[selector];
    if (property) {
        // if it's a function, call  it and return the result. otherwise just return it.
        // TODO: figure out if there's better logic than this
        if (typeof property == "function")
            return property.apply(receiver, Array.prototype.slice.call(arguments, 2));

        var n = selector.length - 1;
        if (selector.charAt(n) == "=")
            return receiver[selector.substring(0,n)] = arguments[2];
            
        return property;
    }
    
    // return undefined?
}

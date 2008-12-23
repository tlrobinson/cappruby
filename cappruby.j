@import <Foundation/Foundation.j>

window._rbNoBlock = function() { throw new Error("no block given"); }

@implementation CPArray (Ruby)

- (CPArray)map
{
    var _rbYield=window._rbBlock||window._rbNoBlock; // FIXME: how? needed in Obj-J method defs that use yield.
    
    var result = [];
    for (var i = 0; i < self.length; i++)
        result.push(_rbYield(self[i]));
    return result;
}

- (void)each
{
    [self map];
}

@end


@implementation CPObject (Ruby)

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

class_addMethods(CPString,[
    new objj_method(sel_getUid("+"),    function(self,_cmd,other){with(self){ return self + other; }})
]);

class_addMethods(CPNumber,[
    new objj_method(sel_getUid("%"),    function(self,_cmd,other){with(self){ return self % other; }}),
    new objj_method(sel_getUid("&"),    function(self,_cmd,other){with(self){ return self & other; }}),
    new objj_method(sel_getUid("*"),    function(self,_cmd,other){with(self){ return self * other; }}),
    new objj_method(sel_getUid("**"),   function(self,_cmd,other){with(self){ return Math.pow(self, other); }}),
    new objj_method(sel_getUid("+"),    function(self,_cmd,other){with(self){ return self + other; }}),
    new objj_method(sel_getUid("-"),    function(self,_cmd,other){with(self){ return self - other; }}),
    new objj_method(sel_getUid("/"),    function(self,_cmd,other){with(self){ return self / other; }}),
    new objj_method(sel_getUid("<"),    function(self,_cmd,other){with(self){ return self < other; }}),
    new objj_method(sel_getUid("<<"),   function(self,_cmd,other){with(self){ return self << other; }}),
    new objj_method(sel_getUid("<="),   function(self,_cmd,other){with(self){ return self <= other; }}),
    new objj_method(sel_getUid("<=>"),  function(self,_cmd,other){with(self){ return self === other ? 0 : nil; }}),
    new objj_method(sel_getUid("=="),   function(self,_cmd,other){with(self){ return self === other; }}),
    new objj_method(sel_getUid(">"),    function(self,_cmd,other){with(self){ return self > other; }}),
    new objj_method(sel_getUid(">="),   function(self,_cmd,other){with(self){ return self >= other; }}),
    new objj_method(sel_getUid(">>"),   function(self,_cmd,other){with(self){ return self >> other; }}),
    new objj_method(sel_getUid("[]"),   function(self,_cmd,other){with(self){ return (self >> other) & 0x01; }}),
    new objj_method(sel_getUid("^"),    function(self,_cmd,other){with(self){ return self ^ other; }}),
    new objj_method(sel_getUid("abs"),  function(self,_cmd)      {with(self){ return Math.abs(self); }}),
    //new objj_method(sel_getUid("dclone"),    function(self,_cmd,other){with(self){ return self - other; }}),
    new objj_method(sel_getUid("div"),  function(self,_cmd,other){with(self){ return self / other; }}),
    new objj_method(sel_getUid("divmod"),function(self,_cmd,other){with(self){ return [FLOOR(self / other),self % other]; }}), // FIXME (no integeters?)
    //new objj_method(sel_getUid("id2name"),function(self,_cmd,other){with(self){ return self % other; }}),
    new objj_method(sel_getUid("modulo"),function(self,_cmd,other){with(self){ return self % other; }}),
    //new objj_method(sel_getUid("power!"),function(self,_cmd,other){with(self){ return self % other; }}),
    //new objj_method(sel_getUid("quo"),function(self,_cmd,other){with(self){ return self % other; }}),
    //new objj_method(sel_getUid("rdiv"),function(self,_cmd,other){with(self){ return self % other; }}),
    //new objj_method(sel_getUid("rpower"),function(self,_cmd,other){with(self){ return self % other; }}),
    //new objj_method(sel_getUid("size"), function(self,_cmd)      {with(self){ return self; }}),
    //new objj_method(sel_getUid("to_f"), function(self,_cmd)      {with(self){ return self; }}), // NOP?
    new objj_method(sel_getUid("to_s"), function(self,_cmd)      {with(self){ return self.toString(); }}),
    //new objj_method(sel_getUid("to_sym"),function(self,_cmd)      {with(self){ return self; }}),
    new objj_method(sel_getUid("zero?"),function(self,_cmd)      {with(self){ return self === 0; }}),
    new objj_method(sel_getUid("|"),    function(self,_cmd,other){with(self){ return self | other; }}),
    new objj_method(sel_getUid("~"),    function(self,_cmd)      {with(self){ return ~self; }})
]);

puts = alert;

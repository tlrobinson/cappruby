@import <Foundation/CPObject.j>

@implementation Module : CPObject
{
    
}

@end


class_addMethods(Module,[
    new objj_method(sel_getUid("new"), function(self,_cmd,other){with(self){
        var _rbYield=_rbBlock||_rbNoBlock,
            block_given_=_rbBlock?_rbBlockGiven:_rbBlockNotGiven;
        
        var mod = {};
        block.apply(mod, []);
        return mod;
        
        return self + other; }
    })
]);
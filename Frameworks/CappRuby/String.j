@import <Foundation/CPString.j>

class_addMethods(CPString, [

    // FIXME: proper error handling
    
    new objj_method(sel_getUid("+"), function(self, _cmd, other) {
        return self + other;
    }),
    
    new objj_method(sel_getUid("*"), function(self, _cmd, n) {
        return Array(n + 1).join(self);
    })

]);

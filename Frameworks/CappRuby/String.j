@import <Foundation/CPString.j>

class_addMethods(CPString,[
    new objj_method(sel_getUid("+"),    function(self,_cmd,other){with(self){ return self + other; }})
]);
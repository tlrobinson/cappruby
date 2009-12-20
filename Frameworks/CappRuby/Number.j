@import <Foundation/CPNumber.j>

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
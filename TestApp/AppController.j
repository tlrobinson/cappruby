/*
[:block,
 [:fcall, :import_lib, [:array, [:str, "Foundation/CPObject.j"]]],
 [:class,
  :AppController,
  [:const, :CPObject],
  [:scope,
   [:defn,
    :applicationDidFinishLaunching_,
    [:scope,
     [:block,
      [:args, :aNotification],
      [:lasgn,
       :theWindow,
       [:call,
        [:call, [:const, :CPWindow], :alloc],
        :initWithContentRect_styleMask,
        [:array,
         [:fcall, :CGRectMakeZero],
         [:const, :CPBorderlessBridgeWindowMask]]]],
      [:lasgn, :contentView, [:call, [:lvar, :theWindow], :contentView]],
      [:lasgn,
       :label,
       [:call,
        [:call, [:const, :CPTextField], :alloc],
        :initWithFrame,
        [:array, [:fcall, :CGRectMakeZero]]]],
      [:call,
       [:lvar, :label],
       :setStringValue,
       [:array, [:str, "Hello World!"]]],
      [:call,
       [:lvar, :label],
       :setFont,
       [:array,
        [:call,
         [:const, :CPFont],
         :boldSystemFontOfSize,
         [:array, [:lit, 24.0]]]]],
      [:call, [:lvar, :label], :sizeToFit],
      [:call,
       [:lvar, :label],
       :setAutoresizingMask,
       [:array,
        [:call,
         [:call,
          [:call,
           [:const, :CPViewMinXMargin],
           :|,
           [:array, [:const, :CPViewMaxXMargin]]],
          :|,
          [:array, [:const, :CPViewMinYMargin]]],
         :|,
         [:array, [:const, :CPViewMaxYMargin]]]]],
      [:call,
       [:lvar, :label],
       :setFrameOrigin,
       [:array,
        [:fcall,
         :CGPointMake,
         [:array,
          [:call,
           [:call,
            [:fcall,
             :CGRectGetWidth,
             [:array, [:call, [:lvar, :contentView], :bounds]]],
            :-,
            [:array,
             [:fcall,
              :CGRectGetWidth,
              [:array, [:call, [:lvar, :label], :frame]]]]],
           :/,
           [:array, [:lit, 2.0]]],
          [:call,
           [:call,
            [:fcall,
             :CGRectGetHeight,
             [:array, [:call, [:lvar, :contentView], :bounds]]],
            :-,
            [:array,
             [:fcall,
              :CGRectGetHeight,
              [:array, [:call, [:lvar, :label], :frame]]]]],
           :/,
           [:array, [:lit, 2.0]]]]]]],
      [:call, [:lvar, :contentView], :addSubview, [:array, [:lvar, :label]]],
      [:call, [:lvar, :theWindow], :orderFront, [:array, [:self]]],
      [:call, [:const, :CPMenu], :setMenuBarVisible, [:array, [:true]]]]]]]]]
*/
@import <Foundation/CPObject.j>;
(function(){
var _rbClassVars={};
var the_class=objj_allocateClassPair(CPObject,"AppController"),
meta_class=the_class.isa;
objj_registerClassPair(the_class);
objj_addClassForBundle(the_class,objj_getBundleWithPath(OBJJ_CURRENT_BUNDLE.path));
class_addMethods(the_class,[
new objj_method(sel_getUid("applicationDidFinishLaunching:"),function $_AppController__applicationDidFinishLaunching_(self,_cmd,aNotification){with(self){
var _rbYield=window._rbBlock||window._rbNoBlock;
var theWindow=rb_msgSend(null,rb_msgSend(null,CPWindow,"alloc"),"initWithContentRect_styleMask",CGRectMakeZero(),CPBorderlessBridgeWindowMask);
var contentView=rb_msgSend(null,theWindow,"contentView");
var label=rb_msgSend(null,rb_msgSend(null,CPTextField,"alloc"),"initWithFrame",CGRectMakeZero());
rb_msgSend(null,label,"setStringValue","Hello World!");
rb_msgSend(null,label,"setFont",rb_msgSend(null,CPFont,"boldSystemFontOfSize",24.0));
rb_msgSend(null,label,"sizeToFit");
rb_msgSend(null,label,"setAutoresizingMask",rb_msgSend(null,rb_msgSend(null,rb_msgSend(null,CPViewMinXMargin,"|",CPViewMaxXMargin),"|",CPViewMinYMargin),"|",CPViewMaxYMargin));
rb_msgSend(null,label,"setFrameOrigin",CGPointMake(rb_msgSend(null,rb_msgSend(null,CGRectGetWidth(rb_msgSend(null,contentView,"bounds")),"-",CGRectGetWidth(rb_msgSend(null,label,"frame"))),"/",2.0),rb_msgSend(null,rb_msgSend(null,CGRectGetHeight(rb_msgSend(null,contentView,"bounds")),"-",CGRectGetHeight(rb_msgSend(null,label,"frame"))),"/",2.0)));
rb_msgSend(null,contentView,"addSubview",label);
rb_msgSend(null,theWindow,"orderFront");
rb_msgSend(null,CPMenu,"setMenuBarVisible",true);
}})]);
})();

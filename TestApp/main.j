/*
[:block,
 [:fcall, :import_lib, [:array, [:str, "Foundation/Foundation.j"]]],
 [:fcall, :import_lib, [:array, [:str, "AppKit/AppKit.j"]]],
 [:fcall, :import, [:array, [:str, "cappruby.j"]]],
 [:fcall, :import, [:array, [:str, "AppController.j"]]],
 [:defn,
  :main,
  [:scope,
   [:block,
    [:args, :args, :namedArgs],
    [:fcall,
     :CPApplicationMain,
     [:array, [:lvar, :args], [:lvar, :namedArgs]]]]]]]
*/
@import <Foundation/Foundation.j>;
@import <AppKit/AppKit.j>;
@import "cappruby.j";
@import "AppController.j";
main=function(args,namedArgs){
    var _rbYield=window._rbBlock||window._rbNoBlock;
    CPApplicationMain(args,namedArgs);
};

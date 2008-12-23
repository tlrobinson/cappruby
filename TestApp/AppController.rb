# 
# AppController.rb
# 
# Created by __Me__ on __Date__.
# Copyright 2008 __MyCompanyName__. All rights reserved.
# 

import_lib "Foundation/CPObject.j"


class AppController < CPObject

  def applicationDidFinishLaunching_(aNotification)

    theWindow = CPWindow.alloc.initWithContentRect_styleMask(CGRectMakeZero(), CPBorderlessBridgeWindowMask)
    contentView = theWindow.contentView

    label = CPTextField.alloc.initWithFrame(CGRectMakeZero())
    
    label.setStringValue("Hello World!")
    label.setFont(CPFont.boldSystemFontOfSize(24.0))
    
    label.sizeToFit
    
    label.setAutoresizingMask(CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin)
    label.setFrameOrigin(CGPointMake((CGRectGetWidth(contentView.bounds) - CGRectGetWidth(label.frame)) / 2.0, (CGRectGetHeight(contentView.bounds) - CGRectGetHeight(label.frame)) / 2.0))
    
    contentView.addSubview(label)
    
    theWindow.orderFront(self)
    
    #// Uncomment the following line to turn on the standard menu bar.
    CPMenu.setMenuBarVisible(true)
  end

end

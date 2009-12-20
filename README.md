CappRuby
========

An experimental implementation of the Ruby language on top of the [Objective-J](http://cappuccino.org) / JavaScript runtime.

It is currently *very* incomplete. Many language features and the vast majority of the standard library are not implemented.


Requirements
------------
    
- Ruby (1.8?)
- ParseTree gem


Instructions
------------

To see a simple example of the compiler in action run:

    bin/ruby2objj TestApp/main.rb

OR

    cat TestApp/main.rb | bin/ruby2objj

The output can of course be concatenated to a file:

    bin/ruby2objj TestApp/main.rb > TestApp/main.j


To run TestApp using the Rack server, ensure that the "Frameworks" directory contains the Cappuccino frameworks (assumes the Cappuccino tools are installed):

    capp gen -f TestApp


Then run:

    ./config.ru

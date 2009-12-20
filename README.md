CappRuby
========

An experimental implementation of the Ruby language on top of the [Objective-J](http://cappuccino.org) runtime / JavaScript.

It is currently *very* incomplete. Many language features and the vast majority of the standard library are not implemented.

Inspired by MacRuby (though far less cool or useful).


Requirements
------------

- Objective-J and Cappuccino
- Ruby (1.8?)
- ParseTree gem
- Narwhal (for "cappruby" command)


Instructions
------------

### Compiler

To see a simple example of the compiler in action run:

    bin/ruby2objj TestApp/main.rb

OR

    cat TestApp/main.rb | bin/ruby2objj

The output can of course be concatenated to a file:

    bin/ruby2objj TestApp/main.rb > TestApp/main.j


### Server

To run TestApp using the Rack server, ensure that the "Frameworks" directory contains the Cappuccino frameworks (assumes the Cappuccino tools are installed):

    capp gen -f TestApp


Then run:

    ./config.ru


### Command-line and Narwhal integration

To run the `cappruby` command line REPL make sure cappruby was installed via tusk, or you have added it's "bin" to your PATH.

    ~/git/cappruby $ cappruby
    capprb> puts 'hello world'
    hello world
    capprb>

Alternatively, run from within narwhal:

    ~/git/cappruby $ narwhal
    > require("cappruby").run()
    capprb> puts 'hello world'
    hello world
    capprb>

Run simple Ruby files using Narwhal:

    ~/git/cappruby $ narwhal test.rb
    hello world

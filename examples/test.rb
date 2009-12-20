#!/usr/bin/env cappruby

puts 'hello world!'

class Foo
  def self.baz(someArg)
    puts "class method: " + someArg
  end
  
  def bar(someArg)
    puts "instance method: " + someArg
  end
end

f = Foo.new
f.bar "blah"

Foo.baz "buzz"

#[1,2,3].each do |x|
#  puts x.to_s
#end

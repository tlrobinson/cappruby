#!/usr/bin/env rackup

require "json"
require "ruby2objj"

class Ruby2ObjjServer
  
  def initialize(root)
    @root = root
  end
  
  def call(env)
    if env['PATH_INFO'] =~ /\.rb$/
      source = File.read(File.join(@root, env['PATH_INFO']))
      sexp = ParseTree.translate(source)

      puts "/*"
      pp sexp
      puts "*/"

      puts "\n/*"
      unifier = Unifier.new
      #unifier.processors.each do |p|
      #  p.unsupported.delete :cfunc # HACK
      #end
      sexp = unifier.process(sexp)
      pp sexp
      puts "*/"

      result = Ruby2Objj.new.process(sexp)
      
      puts result
      
      [200, {"Content-Type" => "application/javascript"}, [result]]
    else
      [404, {"Content-Type" => "text/plain"}, ["Not found"]]
    end
  end
end

use Rack::CommonLogger
use Rack::ShowExceptions
use Rack::ShowStatus
# use Rack::Lint
# use Rack::ContentLength

puts "[#{ARGV[1]}]"

run Rack::Cascade.new([
  Ruby2ObjjServer.new(ARGV[1]),
  Rack::File.new(ARGV[1])
])

#run Rack::File.new(ARGV[1])

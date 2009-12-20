require 'cappruby/compiler'

require 'parse_tree'
require 'unified_ruby'
require 'pp'
require 'json'

module CappRuby
  class Server
    
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

        result = Compiler.new.process(sexp)
      
        puts result
      
        [200, {"Content-Type" => "application/javascript"}, [result]]
      else
        [404, {"Content-Type" => "text/plain"}, ["Not found"]]
      end
    end
    
  end
end

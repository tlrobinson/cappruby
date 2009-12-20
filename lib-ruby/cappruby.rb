require 'cappruby/compiler'
require 'cappruby/server'

require 'parse_tree'
require 'unified_ruby'
require 'pp'

module CappRuby
  
  def self.ruby2objj(args)
    if args.empty? or args[0] == '-'
      source = STDIN.read
    else
      source = File.read(args[0])
    end
    
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

    puts Compiler.new.process(sexp)
    
  end
  
end

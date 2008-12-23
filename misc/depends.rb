#!/usr/bin/ruby -w

old_classes = []; new_classes = []

require 'pp'
require 'parse_tree'
require 'sexp_processor'

ObjectSpace.each_object(Module) { |klass| old_classes << klass }

class DependencyAnalyzer < SexpProcessor

  attr_reader :dependencies
  attr_accessor :current_class

  def initialize
    super
    self.auto_shift_type = true
    @dependencies = Hash.new { |h,k| h[k] = [] }
    @current_method = nil
    @current_class = nil
  end

  def self.process(*klasses)
    analyzer = self.new
    klasses.each do |start_klass|
      analyzer.current_class = start_klass
      analyzer.process(ParseTree.new.parse_tree(start_klass))
    end

    deps = analyzer.dependencies
    deps.keys.sort.each do |dep_to|
      dep_from = deps[dep_to]
      puts "#{dep_to} referenced by:\n  #{dep_from.uniq.sort.join("\n  ")}"
    end
  end

  def process_defn(exp)
    name = exp.shift
    @current_method = name
    return s(:defn, name, process(exp.shift), process(exp.shift))
  end

  def process_const(exp)
    name = exp.shift
    const = "#{@current_class}.#{@current_method}"
    is_class = ! (Object.const_get(name) rescue nil).nil?
    @dependencies[name] << const if is_class
    return s(:const, name)
  end
end

if __FILE__ == $0 then
  ARGV.each { |name| require name }
  ObjectSpace.each_object(Module) { |klass| new_classes << klass }
  
  #puts old_classes
  puts (new_classes - old_classes)
  DependencyAnalyzer.process(*(new_classes - old_classes))
end

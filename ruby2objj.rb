#!/usr/bin/ruby

require "parse_tree"
require "pp"
require "unified_ruby"

#$DEBUG = true

class Ruby2Objj < SexpProcessor
  
  def initialize
    super
    @indent = "  "
    self.expected = String
    self.auto_shift_type = true
    self.strict = true
    self.require_empty = false
    self.warn_on_default = true
    self.default_method = "default_method"
  end

  def process_and(exp)    "(" + process(exp[0]) + ")&&(" + process(exp[1]) + ")" end
  def process_or(exp)     "(" + process(exp[0]) + ")||(" + process(exp[1]) + ")" end
  def process_not(exp)    "!(" + process(exp[0]) + ")" end
    
  def process_true(exp)   "true" end
  def process_false(exp)  "false" end
  
  def process_str(exp)    exp[0].dump end
  
  def process_lit(exp)    exp[0].to_s end
  def process_const(exp)  exp[0].to_s end
  def process_lvar(exp)   exp[0].to_s end

  def process_array(exp)
    "[" + process_array_raw(exp).join(",") + "]"
  end

  def process_array_raw(exp)
    exp.map { |element| process(element) }
  end

  def process_lasgn(exp)
    name, value = exp
    "var " + name.to_s + "=" + process(value)
  end
  
  def process_block(exp)
    exp.map { |statement| process(statement) + ";" }.join("\n")
  end
  
  def process_scope(exp)
    process(exp[0])
  end
  
  def process_fcall(exp)
    name, args = exp
    if args
      return name.to_s+"("+process_array_raw(args[1..-1]).join(",")+")"
    else
      return name.to_s+"();"
    end
  end
  
  # FIXME: not exactly sure what "vcall" is supposed to do
  def process_vcall(exp)
    exp[0].to_s
  end
  
  def process_defn(exp)
    name, scope = exp
    
    type, block = scope
    throw "*** expected :scope" if type != :scope
    
    type, args = block[0..1]
    throw "*** expected :block" if type != :block
    
    statements = block[2..-1].map { |statement| process(statement) + ";" }
    # FIXME: auto-return the last statement?
    
    "var " + name.to_s + "=function("+args[1..-1].map{|arg| arg.to_s }.join(",")+"){\n" + indent(statements.join("\n")) + "\n}"
  end

  def process_defn_instance(exp, klass)
      name, scope = exp

      type, block = scope
      throw "*** expected :scope" if type != :scope

      type, args = block[0..1]
      throw "*** expected :block" if type != :block

      statements = block[2..-1].map { |statement| process(statement) + ";" }
      # FIXME: auto-return the last statement?

      selector = name.to_s
      arguments = args[1..-1].map{|arg| arg.to_s }.join(",")
      arguments = ","+arguments if arguments.length > 0
      method_implementation = indent(statements.join("\n"))
      
      func_name = "$_"+klass.to_s.gsub(/[^a-zA-Z0-9_]/, "_")+"__"+selector.gsub(/[^a-zA-Z0-9_]/, "_")
      
      inst_method = ""
      inst_method << "new objj_method(sel_getUid(" + selector.dump + "),function "+func_name+"(self,_cmd" + arguments + "){\n"
      inst_method << "with(self){\n"
      inst_method << method_implementation
      inst_method << "\n}})"
  end
  
  def process_return(exp)
    "return " + process(exp[0]) + ";"
  end
  
  def process_call(exp)
    obj, msg, args = exp
    
    if args
      arg_string = "," + process_array_raw(args[1..-1]).join(",")
    else
      arg_string = ""
    end
    
    "rb_msgSend("+process(obj)+","+msg.to_s.dump+arg_string+")"
  end
  
  def process_if(exp)
    # FIXME optimize "else if"
    condition, block, else_block = exp
    
    result = "if("+process(condition)+"){\n" + indent(process(block)) + "\n}"
    unless else_block.nil?
      result << "else{\n" + indent(process(else_block)) + "\n}"
    end
    result
  end
  
  def process_class(exp)
    klass, superKlass, scope = exp
    
    class_vars        = []
    instance_vars     = []
    instance_methods  = []
    class_methods     = []
    
    type, block = scope
    throw "*** expected :scope" if type != :scope

    type, args = block[0..1]
    throw "*** expected :block" if type != :block

    block[1..-1].each do |statement|
      case statement[0]
        when :defn then
          instance_methods << process_defn_instance(statement[1..-1], klass)
        when :defs then
          class_methods << process_defn_instance(statement[2..-1], klass)
        when :iasgn then
          instance_vars << process_iasgn_decl(statement[1..-1])
        when :cvdecl then
          class_vars << process(statement)
        else
          warn "unsupported in class: " + statement[0]
          #process(statement)
        end
    end
    
    cls = ""
    cls << "(function(){\n"
    
    cls << "var _rbClassVars={};\n"
    cls << class_vars.join(";\n") + ";\n" unless class_vars.empty?
    
    cls << "var the_class=objj_allocateClassPair(" + process(superKlass) + "," + klass.to_s.dump + "),"
    cls << "meta_class=the_class.isa;\n"
    
    cls << "class_addIvars(the_class,[" + instance_vars.join(",") + "]);\n" unless instance_vars.empty?
    
    cls << "objj_registerClassPair(the_class);\n"
    cls << "objj_addClassForBundle(the_class,objj_getBundleWithPath(OBJJ_CURRENT_BUNDLE.path));\n"
    
    cls << "class_addMethods(the_class,[\n" + instance_methods.join(",\n") + "]);\n" unless instance_methods.empty?
    cls << "class_addMethods(meta_class,[\n" + class_methods.join(",\n") + "]);\n" unless class_methods.empty?
    
    cls << "})()"
    
    cls
  end
  
  def process_iasgn_decl(exp)
    "new objj_ivar(" + convertVarName(exp[0].to_s).dump + ",null,"+process(exp[1])+")"
  end
  
  def process_cvdecl(exp)
    "_rbClassVars[" + convertVarName(exp[0].to_s).dump + "]=" + process(exp[1])
  end

  def process_cvasgn(exp)
    "_rbClassVars[" + convertVarName(exp[0].to_s).dump + "]=" + process(exp[1])
  end
  
  def process_cvar(exp)
    "_rbClassVars[" + convertVarName(exp[0].to_s).dump + "]"
  end
  
  def process_iasgn(exp)
    "self[" + convertVarName(exp[0].to_s).dump + "]=" + process(exp[1])
  end

  def process_ivar(exp)
    "self[" + convertVarName(exp[0].to_s).dump + "]"
  end
  
  def default_method(exp)
    ""
  end
  
  def convertVarName(varName)
    #varName.gsub(/[^a-zA-Z0-9_]/, "_")
    varName
  end
  
  def indent(s)
    s.to_s.split(/\n/).map{|line| @indent + line}.join("\n")
  end
end

source = File.read(ARGV[0])
sexp = ParseTree.translate(source)

puts "/*"
pp sexp
puts "*/"

#unifier = Unifier.new
#unifier.processors.each do |p|
#  p.unsupported.delete :cfunc # HACK
#end
#sexp = unifier.process(sexp)
#pp sexp

puts '@import <Foundation/Foundation.j>'
puts '@import "cappruby.j"'

puts Ruby2Objj.new.process(sexp)

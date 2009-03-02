#!/usr/bin/ruby

require "rubygems"
require "parse_tree"
require "pp"
require "unified_ruby"

#$DEBUG = true

# TODO: optimize by only adding this preamble to methods that actually might call "yield"
RbYield = "_rbYield" # "yield" is apparently a reserved
RbBlockGiven = "block_given_"
RbFunctionPreamble =  "var #{RbYield}=window._rbBlock||window._rbNoBlock,\n"+
                      "    #{RbBlockGiven}=window._rbBlock?_rbBlockGiven:_rbBlockNotGiven;\n"

class Ruby2Objj < SexpProcessor
  
  def initialize
    super
    @indent = "    "
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
  
  def process_lit(exp)
    case exp[0].class.to_s
      when "Symbol" then
        exp[0].to_s.dump # FIXME: what to do with symbols?
      else
        exp[0].to_s
      end
    else
  end
  
  def process_lvar(exp)   exp[0].to_s end
  def process_gvar(exp)   "window[#{exp[0].to_s.dump}]" end
  def process_const(exp)  "window[#{exp[0].to_s.dump}]" end

  # local assigmnent
  def process_lasgn(exp)
    name, value = exp
    if value
      "var #{name.to_s}=#{process(value)}"
    else
      # for unified ruby block args.
      name.to_s
    end
  end
  
  # global assignment
  def process_gasgn(exp)
    name, value = exp
    if value
      # FIXME: use something other than "window" as root scope?
      "window[#{name.to_s.dump}]=#{process(value)}"
    else
      ""
    end
  end
  
  # constant declaration
  def process_cdecl(exp)
    name, value = exp
    if value
      # TODO: check to make sure it hasn't already been defined, throw a warning
      "window[#{name.to_s.dump}]=#{process(value)}"
    else
      ""
    end
  end

  def process_array(exp)
    "[" + exp.map { |element| process(element) }.join(",") + "]"
  end
  
  def process_block(exp)
    # FIXME: auto-return the last statement of blocks somehow?
    exp.map { |statement| process(statement) + ";" }.join("\n")
  end
  
  def process_scope(exp)
    process(exp[0])
  end
  
  def process_arglist(exp)
    exp.map { |arg| process(arg) }.join(",")
  end
  
  def process_args(exp)
    exp.map { |arg| arg.to_s }.join(",")
  end
  
  def process_fcall(exp, block=nil)
    name, args = exp
    
    name = name.to_s
    arguments = process(args)
    
    # FIXME: kinda hacky? needed unless we want to do synchronous imports
    if name == "import"
      "@import #{args[0][0].dump}"
    elsif name == "import_lib"
      "@import <#{args[0][0]}>"
    else
      name.gsub!(/[^_a-zA-Z0-9]/, "_")
      block ||= "null"
      "(((_rbBlock=#{block})&&false)||#{name}(#{arguments}))"
    end
  end
  
  # FIXME: not exactly sure what "vcall" is supposed to do
  def process_vcall(exp)
    exp[0].to_s
  end
  
  def process_defn(exp)
    name, args, scope = exp
    
    type, block = scope
    throw "*** expected :scope" if type != :scope
    
    type = block[0]
    throw "*** expected :block" if type != :block
    
    # FIXME: better encoding of disallowed characters to prevent collisions?
    name = name.to_s.gsub(/[^_a-zA-Z0-9]/, "_")
    arguments = process(args)
    
    method = "function(#{arguments}){\n"
    method << indent(RbFunctionPreamble)
    method << indent(process(block))
    method << "\n}"
    
    "#{name}=#{method}"
  end

  def process_defn_instance(exp, klass)
      name, args, scope = exp

      type, block = scope
      throw "*** expected :scope" if type != :scope

      type = block[0]
      throw "*** expected :block" if type != :block

      selector = name.to_s.gsub(/_/, ":")
      
      arguments = process(args)
      
      # for debug purposes we give the method a name, but it could be anonymous (i.e. make this an empty string)
      method_name = " $_"+klass.to_s.gsub(/[^a-zA-Z0-9_]/, "_")+"__"+selector.gsub(/[^a-zA-Z0-9_]/, "_")
      
      if arguments.length > 0
        method = "function#{method_name}(self,_cmd,#{arguments}){with(self){\n"
      else
        method = "function#{method_name}(self,_cmd){with(self){\n"
      end
      method << indent(RbFunctionPreamble)
      method << indent(process(block))
      method << "\n}}"
      
      "new objj_method(sel_getUid(#{selector.dump}),#{method})"
  end
  
  def process_return(exp)
    "return " + process(exp[0])
  end
  
  def process_yield(exp)
    arguments = process_arglist(exp)
    
    "#{RbYield}(#{arguments})"
  end
  
  def process_call(exp, block=nil)
    object, selector, arguments = exp
    
    if (object.nil?)
      process_fcall(exp[1..-1], block)
    else
      block ||= "null"
      object = process(object)
      selector = selector.to_s.dump
      arguments = process(arguments)
      
      if arguments && arguments.length > 0
        "rb_msgSend(#{block},#{object},#{selector},#{arguments})"
      else
        "rb_msgSend(#{block},#{object},#{selector})"
      end
#      rb_msgSend_helper(block, process(object), selector.to_s, process(arguments))
    end
  end
  
#  def rb_msgSend_helper(block, object, selector, arguments)
#    selector = selector.dump
#    
#    if arguments && arguments.length > 0
#      "rb_msgSend(#{block},#{object},#{selector},#{arguments})"
#    else
#      "rb_msgSend(#{block},#{object},#{selector})"
#    end
#  end
  
  def process_iter(exp)
    call, block_args, block = exp
    
    arguments = process(block_args) || ""
    
    method = "function(#{arguments}){\n"
    method << indent(RbFunctionPreamble)
    method << indent(process(block))
    method << "\n}"
    
    process_call(call[1..-1], method)
    #if call[0] == :fcall
    #  # kind of a big hack so that we set _rbBlock without breaking nested calls, etc
    #  process_fcall(call, method)
    #  #"(((window._rbBlock=#{method})&&false)||#{process(call)})"
    #elsif call[0] == :call
    #  call_sym, object, selector, args = call
    #  rb_msgSend_helper(method, process(object), selector.to_s, process(args))
    #else
    #  throw "*** oh noes!"
    #end
  end
  
  def process_masgn(exp)
    array, unknown = exp
    array[1..-1].map { |element| process(element) }.join(",")
  end
  
  def process_dasgn_curr(exp)
    exp[0].to_s
  end
  
  def process_attrasgn(exp)
    process_call(exp)
  end
  
  def process_if(exp)
    # FIXME optimize "else if"?
    condition, block, else_block = exp
    
    result = "if("+process(condition)+"){" + (block.nil? ? "" : ("\n" + process(block) + "\n")) + "}"
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
    throw "*** expected :scope, got #{type.to_s}" if type != :scope

    type = block[0]
    if type == :block
      statements = block[1..-1]
    else
      statements = [block]
    end

    statements.each do |statement|
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
    
    class_string = klass.to_s.dump
    super_class = process(superKlass) || "CPObject"
    
    cls = ""
    cls << "(function(){\n"
    
    cls << "var _rbClassVars={};\n"
    cls << class_vars.join(";\n") + ";\n" unless class_vars.empty?
    
    cls << "var the_class=objj_allocateClassPair(#{super_class},#{class_string}),\n"
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
  
  def process_dvar(exp)
    exp[0].to_s
  end
  
  def process_self(exp)
    "self"
  end
  
  #def process_defs(exp)
  #end
  
  def default_method(exp)
    ""
  end
  
  def convertVarName(varName)
    #varName.gsub(/[^a-zA-Z0-9_]/, "_")
    varName
  end
  
  def indent(s)
    s #s.to_s.split(/\n[^$]/).map{|line| @indent + line}.join("\n")
  end
end

if __FILE__ == $0
  
  source = File.read(ARGV[0])
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

  puts Ruby2Objj.new.process(sexp)

end
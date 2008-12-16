require "parse_tree"
require "pp"

def compile(tree)
  if (tree.class == Array)
    type = tree[0]
    return case type
      when :args
        ""
      when :lvar
        tree[1].to_s
      when :block
        compile_block(tree)
      when :fcall
        compile_fcall(tree)
      when :array
        compile_array(tree)
      when :lit
        compile_lit(tree)
      when :str
        compile_str(tree)
      when :defn
        compile_defn(tree)
      when :scope
        compile_scope(tree)
      when :lasgn
        compile_lasgn(tree)
      else
        throw "*** unknown type: " + type.to_s
    end
  end
end

def compile_block(block)
  type = block[0]
  statements = block[1..-1]
  throw "*** expected :block" unless type == :block

  statements.map{|statement| compile(statement) }.join("\n")
end

def compile_scope(scope)
  type, block = scope
  throw "*** expected :scope" unless type == :scope
  
  compile(block)
end

def compile_defn(defn)
  type, name, scope = defn
  throw "*** expected :defn" unless type == :defn
  
  type, block = scope
  throw "*** expected :scope" unless type == :scope
  
  type, args = block[0..1]
  throw "*** expected :block" unless type == :block
  
  body = compile_block(block)
  
  name.to_s + " = function("+args[1..-1].map{|arg| arg.to_s }.join(",")+"){" + body + "\n}"
end

def compile_lasgn(lasgn)
  type, name, value = lasgn
  throw "*** expected :lasgn" unless type == :lasgn
  
  "var " + name.to_s + "=" + compile(value) + ";"
end

def compile_fcall(fcall)
  type, name, args = fcall
  throw "*** expected :fcall" unless type == :fcall
  
  if args
    return name.to_s+"("+compile_array_raw(args).join(",")+");"
  else
    return name.to_s+"();"
  end
end

def compile_array(array)
   "[" + compile_array_raw(array).join(",") + "]"
end

def compile_array_raw(array)
  type = array[0]
  args = array[1..-1]
  throw "*** expected :array" unless type == :array
  
  args.map{|arg| compile(arg) }
end

def compile_lit(lit)
  type, literal = lit
  throw "*** expected :lit" unless type == :lit
  
  literal.to_s
end

def compile_str(str)
  type, string = str
  throw "*** expected :str" unless type == :str

  string.dump
end

source = File.read(ARGV[0])
sexp_array = ParseTree.translate(source)

puts "/*"
pp sexp_array
puts "*/"

puts "puts = print;"

puts (compile sexp_array)
require 'rubygems'
require 'parse_tree'
require 'pp'

# This code is evil
# Please avert your eyes right now
# Dark side this leads to

class Ruby2Java < SexpProcessor
  def initialize
    super
    @indent = "  "
    self.auto_shift_type = true
    self.strict = true
    self.expected = String
    #@unsupported_checked = false
    #@warn_on_default = true
    @require_empty = false
    # self.debug[:defn] = /zsuper/
  end

  def self.translate(klass)
    sexp = ParseTree.new.parse_tree(klass).first
    Ruby2Java.new.process(sexp)
  end

  def process_class(exp)
    "public class #{exp.shift} {\n #{next_token(exp, true)} \n}"
  end

  def process_const(exp)
    "extends #{exp.shift}" 
  end

  def process_defs(exp)
    rv = "public #{method_sig(exp)} #{method_name(exp)}"
    return rv
  end

  def method_sig(exp)
    if exp[0].first == :self
      exp.shift
      "static void"
    end
  end
  
  def method_name(exp)
    name = exp.shift
    "#{name}(String argv[]) {\n#{method_body(exp)}\n }"
  end
  
  def method_body(exp)
    # Look, you get the point right? :-D
    exp = exp.first.last.last#.last.last.last
    process(exp)
  end

  def process_fcall(exp)
    process_puts(exp)
  end

  def process_puts(exp)
    if exp.first == :puts
      "   System.out.println(\"#{process(exp.last)}\");"
    end
  end
  
  def process_array(exp)
    process(exp.shift)
  end
  
  def process_str(exp)
    exp.first
  end
  

  def next_token(exp, is_class = false)
    if is_class
      const = exp.shift
      process(const) 
    end
    process(exp.first)
  end

  def dump(exp)
    puts "======"
    pp exp
    puts "======"
  end
end



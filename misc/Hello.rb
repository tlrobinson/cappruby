puts CPObject.alloc.init
puts CPObject.ancestors
puts CPMutableArray.ancestors

window.print("asdf")
print("asdf")

asdf = 123

def func(arg3)
  1+1
end

class Hello < CPObject
  @@sides = 10
  @sides = 123
  
  def instMeth(arg1)
    @@sides
    @@sides=1234
  end

    def blahMeth(arg1)
      puts @@sides
      @sides
    end
  
  def self.clsMeth(arg2)
    @@sides=99
    puts arg2
    return @@sides
  end
end

a = Hello.new
puts a.blahMeth
puts "Asdf"

puts (Hello.clsMeth 10)
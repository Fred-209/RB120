class MinilangError < StandardError; end
  
class Minilang
  attr_reader :stack
  
  def initialize(command_string)
    @register = 0
    @command_list = command_string.split
    @stack = []
  end

  def eval
    command_list.each do |command|
      case command
      when command.to_i.to_s then replace_register(command)
      when 'PUSH' then push
      when 'ADD' then add
      when 'SUB' then subtract
      when 'MULT' then multiply
      when 'DIV' then divide
      when 'MOD' then modulo
      when 'POP' then pop
      when 'PRINT' then print_register
      else
        raise MinilangError.new("'#{command}' is not a command Minilang understands") 
      end
    end
  end

  private

  attr_reader :command_list
  attr_accessor :register, :stack

  def replace_register(num)
    @register = num.to_i
  end

  def push
    stack << register
  end

  def add
    self.register += pop_stack
  end

  def subtract
    self.register -= pop_stack
  end

  def multiply
    self.register *= pop_stack
  end

  def divide
    self.register /= pop_stack
  end

  def modulo
    self.register %= pop_stack
  end
  
  def pop
    self.register = pop_stack
  end

  def print_register
    puts register
  end

  def pop_stack
    raise MinilangError.new('Empty Stack!') if stack.empty?
    stack.pop
  end
end



Minilang.new('PRINT').eval
# 0

Minilang.new('5 PUSH 3 MULT PRINT').eval
# 15

Minilang.new('5 PRINT PUSH 3 PRINT ADD PRINT').eval
# 5
# 3
# 8

Minilang.new('5 PUSH 10 PRINT POP PRINT').eval
# 10
# 5

# Minilang.new('5 PUSH POP POP PRINT').eval
# Empty stack!

Minilang.new('3 PUSH PUSH 7 DIV MULT PRINT ').eval
# 6

Minilang.new('4 PUSH PUSH 7 MOD MULT PRINT ').eval
# 12

# Minilang.new('-3 PUSH 5 XSUB PRINT').eval
# Invalid token: XSUB

Minilang.new('-3 PUSH 5 SUB PRINT').eval
# 8

Minilang.new('6 PUSH').eval
# (nothing printed; no PRINT commands)



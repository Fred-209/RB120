=begin
UUsing the code from the previous exercise, move the greeting from the 
#initialize method to an instance method named #greet that prints a greeting when invoked.

*Input*: 

*Output*: 

*Explicit and inferred rules*


**Examples/Test Cases**

*Edge Cases*:

**Data Structure**


**Algorithm**

*High level thought process / brainstorming ideas


*Lower level steps of implementation*

=end

class Cat

  def initialize(name)
    @name  = name
  end

  def greet
    puts "Hello! My ny name is #{@name}"
  end
end

kitty = Cat.new('Sophie').greet
kitty.greet
=begin
Using the code from the previous exercise, replace the getter and setter methods using Ruby shorthand.

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
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def greet
    puts "Hello! My name is #{name}!"
  end
end

kitty = Cat.new('Sophie')
kitty.greet
kitty.name = 'Luna'
kitty.greet
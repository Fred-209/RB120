=begin

Using the following code, create a class named Cat that prints a greeting when #greet is invoked. 
The greeting should include the name and color of the cat. Use a constant to define the color.


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
  COLOR = 'purple'
  
  attr_accessor :name

  def initialize(name)
    self.name = name
  end

  def greet
    puts "Hello! My name is #{name} and I'm a #{COLOR} cat!"
  end
end

kitty = Cat.new('Sophie')
kitty.greet

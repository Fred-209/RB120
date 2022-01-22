=begin
Using the code from the previous exercise, add a getter method named #name and 
invoke it in place of @name in #greet.

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
  attr_reader :name
  
  def initialize(name)
    @name  = name
  end
  
  def greet
    puts "Hello! My ny name is #{name}"
  end
end

kitty = Cat.new('Sophie')
kitty.greet
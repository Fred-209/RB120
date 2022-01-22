=begin
Using the code from the previous exercise, add a parameter to #initialize that
 provides a name for the Cat object. Use an instance variable to print a
  greeting with the provided name. (You can remove the code that displays I'm 
    a cat!.)

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
    puts "Hello! My ny name is #{@name}"
  end

  
end

kitty = Cat.new('Sophie')
kitty.name
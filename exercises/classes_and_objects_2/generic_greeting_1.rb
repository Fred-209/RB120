=begin

Modify the following code so that Hello! I'm a cat! is printed when Cat.generic_greeting is invoked.

Copy Code
class Cat
end

Cat.generic_greeting
Expected output:

Copy Code
Hello! I'm a cat!

*Input*: 

*Output*: 

*Explicit and inferred rules*


**Examples/Test Cases**

*Edge Cases*:

**Data Structure**


**Algorithm**

*High level thought process / brainstorming ideas


*Lower level steps of implementation*

Further Exploration
What happens if you run kitty.class.generic_greeting? Can you explain this result?

=end

class Cat
  def self.generic_greeting
    puts "Hello! I'm a cat!"
  end
end

Cat.generic_greeting
kitty = Cat.new
kitty.class.generic_greeting

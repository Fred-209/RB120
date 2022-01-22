=begin

sing the following code, add a method named share_secret that prints the value
 of @secret when invoked.

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

class Person
  attr_writer :secret

  def share_secret
    puts secret
  end
  
  private

  attr_reader :secret
end

person1 = Person.new
person1.secret = 'Shh.. this is a secret!'
person1.share_secret
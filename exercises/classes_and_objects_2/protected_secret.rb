=begin

Using the following code, add an instance method named compare_secret that compares the value of 
@secret from person1 with the value of @secret from person2.

*Input*: string

*Output*: boolean

*Explicit and inferred rules*
- add instance method called `compare_secret` 
  - this is added to the Person class
  - This method should compare the value of calling object with string passed in as an arguemnt, 
  for equality
  - return true if equal, false otherwise
- the @secret getter method is protected, so therefor can't be called from outside 
of the class
- this meanas compare secret needs to be a public method that references the protected `secret` getter 
method

**Examples/Test Cases**

*Edge Cases*:

**Data Structure**


**Algorithm**

*High level thought process / brainstorming ideas


*Lower level steps of implementation*

=end

class Person
  attr_writer :secret

  def compare_secret(other_person)
    secret == other_person.secret
  end

  protected

  attr_reader :secret
end

person1 = Person.new
person1.secret = 'Shh.. this is a secret!'

person2 = Person.new
person2.secret = 'Shh.. this is a different secret!'

puts person1.compare_secret(person2)
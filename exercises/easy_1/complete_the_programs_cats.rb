=begin

Consider the following program:

class Pet
  def initialize(name, age)
    @name = name
    @age = age
  end
end

class Cat < Pet
end

pudding = Cat.new('Pudding', 7, 'black and white')
butterscotch = Cat.new('Butterscotch', 10, 'tan and white')
puts pudding, butterscotch

Update this code so that when you run it, you see the following output:

My cat Pudding is 7 years old and has black and white fur.
My cat Butterscotch is 10 years old and has tan and white fur.

=end

# class Pet
#   def initialize(name, age)
#     @name = name
#     @age = age
#   end
# end

# class Cat < Pet
#   def initialize(name, age, color)
#     super(name, age)
#     @color = color
#   end

#   def to_s
#     "My cat #{@name} is #{@age} years old and has #{@color} fur."
#   end
  
# end

# pudding = Cat.new('Pudding', 7, 'black and white')
# butterscotch = Cat.new('Butterscotch', 10, 'tan and white')
# puts pudding, butterscotch


#Further Exploration

class Pet
  def initialize(name, age, color)
    @name = name
    @age = age
    @color = color
  end

  @test = 'this is a test'
end

class Cat < Pet
  # def initialize(name, age, color)
  #   super(name, age)
  #   @color = color
  # end

  def to_s
    "My cat #{@name} is #{@age} years old and has #{@color} fur."
  end
  
  def print_test
    puts 'hi'
    p @test
  end
end

pudding = Cat.new('Pudding', 7, 'black and white')
butterscotch = Cat.new('Butterscotch', 10, 'tan and white')
puts pudding, butterscotch
pudding.print_test
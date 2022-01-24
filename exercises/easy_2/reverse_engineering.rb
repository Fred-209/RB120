=begin

Write a class that will display:

ABC
xyz

When the following code is run: 

my_data = Transform.new('abc')
puts my_data.uppercase
puts Transform.lowercase('XYZ')

=end



class Transform
  attr_reader :letters

  def initialize(string)
    @letters = string
  end

  def uppercase
    letters.upcase
  end

  def self.lowercase(string)
    string.downcase
  end
end

my_data = Transform.new('abc')
puts my_data.uppercase
puts Transform.lowercase('XYZ')
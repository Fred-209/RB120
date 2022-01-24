=begin

Consider the following classes:

class Car
  attr_reader :make, :model

  def initialize(make, model)
    @make = make
    @model = model
  end

  def wheels
    4
  end

  def to_s
    "#{make} #{model}"
  end
end

class Motorcycle
  attr_reader :make, :model

  def initialize(make, model)
    @make = make
    @model = model
  end

  def wheels
    2
  end

  def to_s
    "#{make} #{model}"
  end
end

class Truck
  attr_reader :make, :model, :payload

  def initialize(make, model, payload)
    @make = make
    @model = model
    @payload = payload
  end

  def wheels
    6
  end

  def to_s
    "#{make} #{model}"
  end
end

Refactor these classes so they all use a common superclass, and inherit behavior as needed.


=end


class Vehicle
  @test = 5

  def initialize(make, model)
    @make = make
    @model = model
  end

   
  def to_s
    "#{make} #{model}"
  end
end

class Car < Vehicle
  def test
    @test
  end
end

# class Motorcycle < Vehicle
  
#   def wheels
#     2
#   end

# end

# class Truck < Vehicle
#   attr_reader :payload

#   def initialize(make, model, payload)
#     super(make, model)
#     @payload = payload
#   end

#   def wheels
#     6
#   end

# end

# my_truck = Truck.new('Chevy', 'Tahoe', 50)
# my_car = Car.new('Chevy', 'Volt')
# my_motorcycle = Motorcycle.new('Harley Davidson', 'shitrocket')

# p my_truck
# p my_car
# p my_motorcycle

my_car = Car.new('Chevy', 'Volt')
p my_car.test


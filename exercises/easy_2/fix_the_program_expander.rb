=begin
What is wrong with the following code? What fixes would you make?

class Expander
  def initialize(string)
    @string = string
  end

  def to_s
    self.expand(3)
  end

  private

  def expand(n)
    @string * n
  end
end

expander = Expander.new('xyz')
puts expander


=end

class Expander
  def initialize(string)
    @string = string
  end

  def to_s
    @string * 3
  end

  private

  # def expand(n)
  #   @string * n
  # end
end

expander = Expander.new('xyz')
puts expander
class GuessingGame

  def initialize(low_number, high_number)
    @secret_number = nil
    @guessing_range = (low_number..high_number)
    @range_size = high_number - low_number
    @range_low = low_number
    @range_high =  high_number
  end
  
  def play
    init_defaults

    loop do
      puts "You have #{guesses_remaining} guesses remaining."
      guess = ask_for_number
      self.guesses_remaining -= 1

      if guess > secret_number
        puts "Your guess is too high."
      elsif guess < secret_number
        puts "Your guess is too low."
      else
        self.winner = true
        puts "That's the number!"
        puts 
        puts "You won!"
      end
      puts
      break if winner || guesses_remaining == 0
    end
    puts "You have no more guesses. You lost!" unless winner
  end  

  private 

  attr_reader :secret_number, :range_size, :range_low, :range_high, :guessing_range
  attr_accessor :guesses_remaining, :winner
  
  def init_defaults
    @guesses_remaining = Math.log2(range_size).to_i + 1
    @secret_number = rand(guessing_range)
    @winner = false
  end

  def ask_for_number
    valid_input = guessing_range
    user_input = nil

    loop do 
      print "Enter a number between #{range_low} and #{range_high}: "
      user_input = gets.chomp.strip
      break if valid_input.include?(user_input.to_i)
      puts "Invalid guess. Enter a number between #{range_low} and #{range_high}: "
    end
    user_input.to_i
  end
end

game = GuessingGame.new(501, 1500)
game.play


    
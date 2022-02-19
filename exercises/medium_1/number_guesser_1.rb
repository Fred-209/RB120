class GuessingGame
  
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

  attr_reader :secret_number
  attr_accessor :guesses_remaining, :winner
  
  def init_defaults
    @guesses_remaining = 7
    @secret_number = rand(1..100)
    @winner = false
  end

  def ask_for_number
    valid_input = (1..100)
    user_input = nil

    loop do 
      print "Enter a number between 1-100: "
      user_input = gets.chomp.strip
      break if valid_input.include?(user_input.to_i)
      puts "Invalid guess. Enter a number between 1 and 100: "
    end
    user_input.to_i
  end
end

game = GuessingGame.new
game.play


    
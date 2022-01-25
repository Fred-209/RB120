=begin
Add some features to the RPS program in the previous assignment. 
- Keep score
  - first to 10 wins?
- Add Lizard and Spock move options
- Add a class for each move
- Keep track of a history of moves
- create some computer personalities


*Keeping Score*
- score would be a number
- fits as a state of a Player object
- common to all players
- needs to be incremented when a player wins
- initially is set to 0 on creation of a Player object
- needs a getter and a setter

=end

require 'pry'

class Player
  attr_accessor :move, :name, :score, :current_winner

  def initialize
    @score = 0
    @current_winner = false
    set_name
  end

  def current_winner?
    @current_winner == true
  end

  def increment_score!
    self.score += 1
  end
end

class Human < Player
  def set_name
    player_name = nil
    loop do
      puts "What's your name? "
      player_name = gets.chomp
      break unless player_name.strip.empty?
      puts 'Sorry, name cannot be empty.'
    end
    self.name = player_name
  end

  def choose
    choice = nil
    loop do
      puts 'Please choose rock, paper, scissors, lizard, or spock:'
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts 'That is not a valid choice. Please choose again.'
    end
    self.move = Move.convert_choice_to_class_name(choice).new
  end
end

class Computer < Player
  def set_name
    self.name = %w[R2D2 Hal Chappie Sonny Number_5].sample
  end

  def choose
    choice = Move::VALUES.sample
    self.move = Move.convert_choice_to_class_name(choice).new
  end
end


class Move
  attr_reader :wins_against_list, :value
  VALUES = %w[rock paper scissors lizard spock]

  def initialize(value)
    @value = value
  end

  def >(other_move)
    wins_against_list.include?(other_move.value)
  end

  def <(other_move)
    other_move.wins_against_list.include?(value)
  end

  def to_s
    @value
  end

  def self.convert_choice_to_class_name(choice)
    Object.const_get(choice.capitalize)
  end
end

class Paper < Move
  def initialize
    @value = 'paper'
    @wins_against_list = %w[rock spock]
  end
end

class Rock < Move
  def initialize
    @value = 'rock'
    @wins_against_list = %w[scissors lizard]
  end
end

class Scissors < Move
  def initialize
    @value = 'scissors'
    @wins_against_list = %w[paper lizard]
  end
end

class Lizard < Move
  def initialize
    @value = 'lizard'
    @wins_against_list = %w[spock paper]
  end
end

class Spock < Move
  def initialize
    @value = 'spock'
    @wins_against_list = %w[scissors rock]
  end
end

class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts 'Welcome to Rock, Paper, Scissors!'
  end

  def display_goodbye_message
    puts 'Thanks for playing Rock, Paper, Scissors. Goodbye!'
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}."
  end

  def determine_winner
    if human.move > computer.move
      human.current_winner = true
      human.increment_score!
    elsif human.move < computer.move
      computer.current_winner = true
      computer.increment_score!
    end
  end

  def display_winner
    if human.current_winner?
      puts "#{human.name} won the game!"
    elsif computer.current_winner?
      puts "#{computer.name} won the game!"
    else
      puts "It's a tie. Noone wins!"
    end
  end

  def display_score
    puts "#{human.name} has a score of #{human.score}"
    puts "#{computer.name} has a score of #{computer.score}"
  end

  def reset_winner
    if human.current_winner?
      human.current_winner = false
    else
      computer.current_winner = false
    end
  end

  def play_again?
    choice = nil
    loop do
      puts 'Would you like to play again? (y/n)'
      choice = gets.chomp
      break if %w[y n].include?(choice.downcase)
      puts "You must choose 'y' or 'n'. Try again."
    end

    choice == 'y'
  end

  def play
    display_welcome_message
    loop do
      human.choose
      computer.choose
      display_moves
      determine_winner
      display_winner
      display_score
      reset_winner
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play

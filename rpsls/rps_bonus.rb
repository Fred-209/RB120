# RPSLS Bonus Features - Launch School
=begin
- add in attack types for each Move subclass
- for each other 'weapon' that a weapon 'beats' , there are different keywords for this
- for instance: rock CRUSHES scissors and OBLITERATES scissors
- this should be determined when determine who won
=end
require 'yaml'
require 'colorize'
require 'abbrev'

class Player
  attr_reader :name, :score
  attr_accessor :move

  def initialize
    @score = 0
    @move_history = []
    set_name
  end

  def increment_score!
    self.score += 1
  end

  def display_move_history
    print "#{name}'s history of move choices: "
    puts move_history.map(&:capitalize).join(', ')
  end

  def update_move_history!(choice)
    move_history << choice
  end

  def reset_score
    self.score = 0
  end
  
  def clear_move_history
    self.move_history.clear
  end

  private

  attr_accessor :move_history
  attr_writer :name, :score

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
    puts "Please choose rock, paper, scissors, lizard, or spock: "
    loop do 
      choice = gets.chomp.downcase
      break if Move::ABBREVIATIONS.has_key?(choice)
      puts "That is not a valid choice."
      print "Please choose either Rock, Paper, Scissors, Lizard, or Spock: "
    end
    # choice = RPSGame.get_validated_input(Move::VALUES)
    choice = Move::ABBREVIATIONS[choice].to_sym
    self.move = Move.convert_to_class[choice.to_sym].new
    update_move_history!(choice)
    puts "#{name} chose #{move.value}!"
  end
end

class Computer < Player
  def set_name
    self.name = %w[R2D2 Hal Chappie Sonny Number_5].sample
  end

  def choose
    choice = Move::VALUES.sample.to_sym
    self.move = Move.convert_to_class[choice].new
    update_move_history!(choice)
    puts "#{name} chose #{move.value}!"
  end
end

class Move
  VALUES = %w[rock paper scissors lizard spock]
  ABBREVIATIONS = Abbrev.abbrev(VALUES)

  attr_reader :value

  def initialize(value)
    @value = value
  end

  def >(other_move)
    wins_against_list.include?(other_move.value)
  end

  def <(other_move)
    other_move.wins_against_list.include?(value)
  end

  def display_attack_style(other_move)
    puts "#{value.capitalize} #{attack_style[other_move.value.to_sym]} " \
          "#{other_move.value.capitalize}!!!"
  end

  def to_s
    @value
  end

  def self.convert_to_class
    {
      rock: Rock,
      paper: Paper,
      scissors: Scissors,
      lizard: Lizard,
      spock: Spock
    }
  end

  protected

  attr_reader :wins_against_list, :attack_style
end

class Paper < Move
  def initialize
    @value = 'paper'
    @wins_against_list = %w[rock spock]
    @attack_style = {
      rock: 'COVERS'.colorize(:light_yellow),
      spock: 'DISPROVES'.colorize(:light_magenta)
    }
  end
end

class Rock < Move
  def initialize
    @value = 'rock'
    @wins_against_list = %w[scissors lizard]
    @attack_style = {
      lizard: 'CRUSHES'.colorize(:light_yellow),
      scissors: 'OBLITERATES'.colorize(:magenta)
    }
  end
end

class Scissors < Move
  def initialize
    @value = 'scissors'
    @wins_against_list = %w[paper lizard]
    @attack_style = {
      paper: 'CUTS'.colorize(:light_red),
      lizard: 'DECAPITATES'.colorize(:red)
    }
  end
end

class Lizard < Move
  def initialize
    @value = 'lizard'
    @wins_against_list = %w[spock paper]
    @attack_style = {
      spock: 'POISONS'.colorize(:green),
      paper: 'EATS'.colorize(:light_white)
    }
  end
end

class Spock < Move
  def initialize
    @value = 'spock'
    @wins_against_list = %w[scissors rock]
    @attack_style = {
      rock: 'VAPORIZES'.colorize(:cyan),
      scissors: 'SMASHES'.colorize(:yellow)
    }
  end
end

class RPSGame
  
  DISPLAY_MESSAGES = YAML.load_file('rpsls.yml')

  def initialize
    display_welcome_message
    @human = Human.new
    @computer = Computer.new
    @rounds_played = 0
  end

  def play
    loop do
      players_choose_moves
      determine_round_winner
      next unless overall_game_winner?
      display_score
      congratulate_winner
      reset_game!
      break unless play_again?
    end
    display_goodbye_message
  end
  
  private 

  attr_accessor :human, :computer, :rounds_played

  def clear_screen
    system('clear')
  end

  def display_welcome_message
    clear_screen
    puts DISPLAY_MESSAGES['intro_graphic'].colorize(:cyan)
    puts DISPLAY_MESSAGES['intro_text']
  end

  def players_choose_moves
    human.choose
    computer.choose
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}."
  end

  def determine_round_winner
    round_winner = nil

    if human.move > computer.move
      round_winner = human
      human.move.display_attack_style(computer.move)
    elsif human.move < computer.move
      round_winner = computer
      computer.move.display_attack_style(human.move)
    end
    
    round_winner&.increment_score!

    increment_rounds_played!
    display_round_winner(round_winner)
  end

  def increment_rounds_played!
    self.rounds_played += 1
  end

  def display_round_winner(winner)
    
    human.display_move_history
    computer.display_move_history

    if winner
      puts "#{winner.name} won this round!"
    else
      puts "It's a tie. Noone wins this round!"
    end
    puts "There have been #{rounds_played} rounds played so far."
    gets
  end

  def overall_game_winner?
    human.score >= 3 || computer.score >= 3
  end

  def display_score
    puts "#{human.name} has a score of #{human.score}"
    puts "#{computer.name} has a score of #{computer.score}"
  end

  def congratulate_winner
    overall_winner = [human, computer].max_by(&:score)
    puts "Congratulations #{overall_winner.name}! You win the game!"
  end

  def reset_game!
    [human, computer].each do |player|
      player.reset_score
      player.clear_move_history
    end
    self.rounds_played = 0
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

  def display_goodbye_message
    puts DISPLAY_MESSAGES['outro'].colorize(:light_cyan)
  end

  
  
end

RPSGame.new.play

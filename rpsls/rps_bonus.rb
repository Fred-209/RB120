# RPSLS Bonus Features - Launch School

require 'yaml'
require 'colorize'
require 'abbrev'

DISPLAY_MESSAGES = YAML.load_file('rpsls.yml')
WINNING_SCORE = 3
PROMPT = ' => '

COLORS = %i[
  light_black
  red
  light_red
  green
  light_green
  yellow
  light_yellow
  light_blue
  magenta
  light_magenta
  cyan
  light_cyan
  default
]

class Player
  attr_reader :name, :score, :move_history
  attr_accessor :move

  def initialize
    @score = 0
    @move_history = []
    @name = set_name!
  end

  def increment_score!
    self.score += 1
  end

  def update_move_history!(choice)
    move_history << choice
  end

  def reset_score!
    self.score = 0
  end

  def clear_move_history!
    move_history.clear
  end

  def to_s
    points = 'Points Scored:'.colorize(:green)
    moves = 'Moves:'.colorize(:light_cyan)
    "#{colored_name} -- #{points} #{score} #{moves} #{formatted_move_history}"
  end

  

  private

  def set_name!
    nil
  end

  def colored_name
    name.colorize(:yellow)
  end

  def formatted_move_history
    move_history.map(&:capitalize).join(', ')
  end
  
  attr_writer :name, :score, :move_history
end

class Human < Player
  def choose_move
    choice = Move::ABBREVIATIONS[move_choice_input]
    self.move = Move.convert_to_class[choice.to_sym].new
    update_move_history!(choice)
    puts
    puts "#{name} chose #{move.value.capitalize}!"
  end

  private

  def set_name!
    player_name = nil
    loop do
      print "What's your name?#{PROMPT}"
      player_name = gets.chomp
      break unless player_name.strip.empty?
      puts "Your name can't be blank. Enter it again#{PROMPT}"
    end
    puts "Hello, #{player_name}!"
    self.name = player_name
  end

  def move_choice_input
    choice = nil
    puts 'What do you choose as your move this round?'
    print "Choices are Rock, Paper, Scissors, Lizard, or Spock:#{PROMPT}"
    loop do
      choice = gets.chomp.downcase
      break if Move::ABBREVIATIONS.key?(choice)
      puts 'That is not a valid choice. Try again'
      print "Please choose Rock, Paper, Scissors, Lizard, or Spock:#{PROMPT}"
    end
    choice
  end
end

class Computer < Player
  def choose_move
    choice = Move::VALUES.sample.to_sym
    self.move = Move.convert_to_class[choice].new
    update_move_history!(choice)
    puts "#{name} chose #{move.value.capitalize}!"
  end

  private

  def set_name!
    self.name = %w[R2D2 Hal Chappie Sonny Number_5].sample
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
  def initialize
    display_welcome_message
    @human = Human.new
    @computer = Computer.new
    @round_winner = nil
    @rounds_played = 0
  end

  def play
    loop do
      players_choose_moves
      determine_round_winner
      update_game!
      next unless overall_game_winner?
      congratulate_winner
      reset_game!
      break unless play_again?
    end
    display_goodbye_message
  end

  private

  attr_accessor :human, :computer, :rounds_played, :round_winner

  def clear_screen
    system('clear')
  end

  def display_welcome_message
    clear_screen
    display_title_graphic
    display_intro_text
  end

  def players_choose_moves
    clear_screen
    display_title_graphic
    display_stats_banner
    human.choose_move
    computer.choose_move
  end

  def determine_round_winner
    human_move = human.move
    computer_move = computer.move

    if human_move > computer_move
      self.round_winner = human
      human_move.display_attack_style(computer_move)
    elsif human_move < computer_move
      self.round_winner = computer
      computer_move.display_attack_style(human_move)
    end
  end

  def update_game!
    increment_rounds_played!
    round_winner&.increment_score!
    display_round_winner
    self.round_winner = nil
  end

  def increment_rounds_played!
    self.rounds_played += 1
  end

  def display_round_winner
    puts
    if round_winner
      puts "#{round_winner.name} won this round!"
    else
      puts "It's a tie. Noone wins this round!"
    end
    puts "There have been #{rounds_played} rounds played so far."
    puts 'Press enter to continue...'
    gets
  end

  def overall_game_winner?
    human.score >= WINNING_SCORE || computer.score >= WINNING_SCORE
  end

  def congratulate_winner
    overall_winner = [human, computer].max_by(&:score)
    color_congrats =
      %w[C o n g r a t u l a t i o n s].map do |letter|
        letter.colorize(COLORS.sample)
      end.join
    clear_screen
    display_title_graphic
    display_stats_banner
    puts "#{color_congrats} #{overall_winner.name}! You win the game!"
  end

  def reset_game!
    [human, computer].each do |player|
      player.reset_score!
      player.clear_move_history!
    end
    self.round_winner = nil
    self.rounds_played = 0
  end

  def play_again?
    valid_choices = /^(y|n|yes|no)$/i
    choice = nil
    loop do
      print "Would you like to play again? (y/n)#{PROMPT}"
      choice = gets.chomp
      break if valid_choices.match?(choice.downcase)
      puts "You must choose 'y' or 'n'. Try again."
    end

    %w[y yes].include?(choice.downcase)
  end

  def display_title_graphic
    puts DISPLAY_MESSAGES['title_graphic'].colorize(:light_cyan)
  end

  def display_intro_text
    puts DISPLAY_MESSAGES['intro_text']
  end

  def display_stats_banner
    puts format(
      DISPLAY_MESSAGES['stats_banner'],
      human_stats: human.to_s.center(120),
      computer_stats: computer.to_s.center(120)
    )
  end

  def display_goodbye_message
    clear_screen
    puts DISPLAY_MESSAGES['outro'].colorize(:light_cyan)
  end
end

RPSGame.new.play

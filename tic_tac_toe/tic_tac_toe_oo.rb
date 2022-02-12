=begin
Description: Create a OO style Tic Tac Toe game. 

It's a board game that is played with multiple players. Each player takes a turn 
marking a board (grid of squares) with their chosen symbol. The first player to fill a 
row completely with their symbol wins the game. 

Nouns: game, board, players, grid, square, symbol, row, turn
Verb: takes, mark

GameEngine
- Board
- Players
- game flow (play)
- game stats such as rounds won, current round winner, ties, score, etc
- reset all the game stats
- play again


Board
- layout (display?)
- points to win? 
- size
- available squares
- winning combos
- total squares
- max players
- Actions: 
  - create empty board layout?
  - mark a square that Player chose

Player
- has a symbol
- has a color 
- has a name
- has a score
- either human or AI computer opponent
- If computer, has an AI
- Actions: 
  - choose a square

Human < Player
Actions:
  - gets name choice input
  - gets color choice input

Computer < Player
- AI personality choice
  - this is difficulty choice


Square
- Has a:
  - square number ?
  - symbol replaces visual layout square is marked
  - some sort of visual representation?
- Actions:
  - can be marked with a symbol
  - can be unmarked with a symbol? (upon reset game)
  - unmarked symbol is the 

- can be marked with a symbol
- maybe Symbol as a collaborator object


Symbol
- can be a X or O (or triangle, square, )
- has a visual representation of itself

Turn

=end
require 'pry'
require 'colorize'
require 'yaml'
require 'abbrev'

MESSAGES = YAML.load_file('tic_tac_toe_oo.yml')
PROMPT = ' => '

X_MARKER = [
  [' ', ' ', ' ', ' ', ' ', ' ', ' '],
  [' ', 'X', ' ', ' ', ' ', 'X', ' '],
  [' ', ' ', 'X', ' ', 'X', ' ', ' '],
  [' ', ' ', ' ', 'X', ' ', ' ', ' '],
  [' ', ' ', 'X', ' ', 'X', ' ', ' '],
  [' ', 'X', ' ', ' ', ' ', 'X', ' '],
  [' ', ' ', ' ', ' ', ' ', ' ', ' ']
]

O_MARKER = [
  [' ', ' ', ' ', ' ', ' ', ' ', ' '],
  [' ', ' ', 'O', 'O', 'O', ' ', ' '],
  [' ', 'O', ' ', ' ', ' ', 'O', ' '],
  [' ', 'O', ' ', ' ', ' ', 'O', ' '],
  [' ', 'O', ' ', ' ', ' ', 'O', ' '],
  [' ', ' ', 'O', 'O', 'O', ' ', ' '],
  [' ', ' ', ' ', ' ', ' ', ' ', ' ']
]

TRIANGLE_MARKER = [
  [' ', ' ', ' ', ' ', ' ', ' ', ' '],
  [' ', ' ', ' ', '∆', ' ', ' ', ' '],
  [' ', ' ', ' ', ' ', ' ', ' ', ' '],
  [' ', ' ', '∆', ' ', '∆', ' ', ' '],
  [' ', ' ', ' ', ' ', ' ', ' ', ' '],
  [' ', '∆', ' ', '∆', ' ', '∆', ' '],
  [' ', ' ', ' ', ' ', ' ', ' ', ' ']
]

SQUARE_MARKER = [
  [' ', ' ', ' ', ' ', ' ', ' ', ' '],
  [' ', '⌂', '⌂', '⌂', '⌂', '⌂', ' '],
  [' ', '⌂', ' ', ' ', ' ', '⌂', ' '],
  [' ', '⌂', ' ', ' ', ' ', '⌂', ' '],
  [' ', '⌂', ' ', ' ', ' ', '⌂', ' '],
  [' ', '⌂', '⌂', '⌂', '⌂', '⌂', ' '],
  [' ', ' ', ' ', ' ', ' ', ' ', ' ']
]

PLUS_MARKER = [
  [' ', ' ', ' ', ' ', ' ', ' ', ' '],
  [' ', ' ', ' ', ' ', ' ', ' ', ' '],
  [' ', ' ', ' ', '+', ' ', ' ', ' '],
  [' ', ' ', '+', '+', '+', ' ', ' '],
  [' ', ' ', ' ', '+', ' ', ' ', ' '],
  [' ', ' ', ' ', ' ', ' ', ' ', ' '],
  [' ', ' ', ' ', ' ', ' ', ' ', ' ']
]

COMPUTER_OPPONENTS = {
  Bobby: {
    name: 'Bobby',
    color: :light_green,
    difficulty: 1
  },
  Maude: {
    name: 'Maude',
    color: :light_magenta,
    difficulty: 2
  },
  Hans: {
    name: 'Hans',
    color: :light_cyan,
    difficulty: 2
  },
  Ryuk: {
    name: 'Ryuk',
    color: :light_yellow,
    difficulty: 3
  },
  Player_456: {
    name: 'Player_456',
    color: :light_white,
    difficulty: 3
  }
}

SYMBOL_MARKERS_MAP = {
  'x' => X_MARKER,
  'o' => O_MARKER,
  'triangle' => TRIANGLE_MARKER,
  'square' => SQUARE_MARKER,
  'plus_sign' => PLUS_MARKER
}

module TTTUtils # requires colorize gem 

  def build_regexp_pattern(string_array, abbreviations)
    return /\w+/ if string_array.empty?
    abbreviations = abbreviations.keys.join('|').prepend('^(') << (')$')
    Regexp.new(abbreviations, 'ignore case')
  end

  
  def display_input_prompt(message)
    print message.colorize(:light_cyan) + PROMPT.colorize(:light_magenta)
  end


  def display_thinking_animation(phrase, wait_time)
    print phrase
    5.times do
      print '.'
      sleep wait_time
    end
    puts
    puts
  end

  def get_validated_input(valid_input)
    abbreviations = Abbrev.abbrev(valid_input.map(&:downcase))
    valid_pattern = build_regexp_pattern(valid_input, abbreviations)
    
    user_input = ''
    loop do
      user_input = gets.chomp.strip
      break if valid_pattern.match?(user_input.downcase)
      puts "That's not a valid choice. Try again."
      puts "Choices are [#{valid_input.join(', ')}]: "
    end
    abbreviations[user_input.downcase] || user_input
  end

  
  def delay_screen(seconds_delay, message = nil)
    puts message if message
    sleep(seconds_delay)
  end

  def pause_screen
    display_input_prompt('Press enter to continue')
    gets
  end

  def clear_screen
    system('clear')
  end
end

class TTTGame 
  # tracking board, number of players, scores of players (for multi-rounds)
  # player turn order, 
  include TTTUtils
  attr_accessor :number_of_players, :player_scores, :turn_order, :round_winner, 
                :game_board, :players, :board, :tied_game 
  
  def initialize
    @board = nil
    @players = nil
    @speed_game = nil
    @number_of_players = nil
    @turn_order = nil
    @play_a_series = nil
    @points_needed_to_win = nil
    @rounds_played = 0
    @tie_game_count = 0
    @tied_game = false
    @round_winner = nil
    @game_winner = nil
  end

  def play
    first_run = true

    loop do 
      clear_screen
      display_welcome_screen if first_run

      setup_game_options
      play_a_series ? play_series_of_games : play_single_game
      game_winner ? congratulate_winner : display_tie_game_message

      first_run = false
      reset_available_player_options!
      break unless play_again?
    end

    display_goodbye_message  
  end

  private

  attr_accessor :points_needed_to_win

  def setup_game_options
    self.board = Board.new
    self.players = setup_players(board.all_winning_combos)
    self.speed_game = play_speed_game? if all_players_are_computers?
    self.number_of_players = players.count
    self.turn_order = choose_turn_order
    self.play_a_series = single_game_or_series?
    self.points_needed_to_win = play_a_series ? choose_points_needed_to_win : 1
  end

  attr_accessor :speed_game, :game_winner, :play_a_series

  def all_players_are_computers?
    players.all? { |player| player.class == Computer}
  end

  def choose_points_needed_to_win
    puts MESSAGES['choose_points_needed_to_win']
    display_input_prompt('Enter [2, 3, 4, 5, 6, 7, 8 , 9, or 10]')
    points = get_validated_input(%w[2 3 4 5 6 7 8 9 10])

    delay_screen(1.5, "You chose to play until someone scores #{points} points.")
    points.to_i
  end

  def choose_number_of_players(max_players)
    clear_screen
    puts MESSAGES['choose_number_of_players'] % [max_players.to_s.colorize(:red)]
    valid_num_player_choices = (2..max_players).map(&:to_s)
    display_input_prompt('Enter the number of players: ')
    num_players = get_validated_input(valid_num_player_choices)
    puts "#{num_players} players will be playing this time!"
    pause_screen
    num_players.to_i
  end

  def choose_player_type(player_number)
    clear_screen

    if Player.available_computer_opponents.empty?
      puts MESSAGES['no_computer_opponents_left']
      return 'human'
    end
    
    puts "Do you want player #{player_number} to be a human or computer player?"
    display_input_prompt("Type 'h' for human or 'c' for computer")
    get_validated_input(%w[human computer])
  end

  def single_game_or_series?
    puts MESSAGES['single_game_or_series']
    display_input_prompt("Type 'series' or 'single':")
    choice = get_validated_input(%w[series single])

    if choice == 'single'
      delay_screen(1.5, "You chose to play a single game.")
    else
      delay_screen(1.5, "You chose to play a series of games.")
    end
    choice == 'series'
  end

  def choose_turn_order
    puts
    puts MESSAGES['turn_order_choices']
    display_input_prompt('Which do you choose [1, 2, or 3]?')
    turn_order_menu_choice = get_validated_input(%w[1 2 3])

    turn_order = create_turn_order_from_choice!(turn_order_menu_choice)
    display_turn_order(turn_order)
    turn_order
  end

  def choose_who_goes_first
    players.each_with_index do |player, idx|
      puts "#{idx + 1}. #{player.name}"
    end

    display_input_prompt("Choose [#{(1...number_of_players).to_a.join(', ')} or ")
    display_input_prompt("#{number_of_players}]")
    user_pick = get_validated_input((1..number_of_players).to_a.map(&:to_s))
    players[user_pick.to_i - 1]
  end

  def create_turn_order_from_choice!(choice)
    case choice
    when '1' 
      players
    when '2'
      players.shuffle
    when '3'
      first_player = choose_who_goes_first
      other_players = players - [first_player]
      [first_player] + other_players
    end
  end

  def congratulate_winner
    winner = game_winner.name.colorize(game_winner.color)
    puts
    puts "Congratulations #{winner}!".center(80)
    puts 'You won the game!'.colorize(:light_cyan).center(80)
    puts 
  end

  def display_goodbye_message
    clear_screen
    puts MESSAGES['goodbye'].colorize(:light_cyan).center(80)
  end

  def display_non_speed_game_messages
    puts "Looks like a tie this round! Noone scores." if tied_game
    puts "#{round_winner.name} won this round!"
    puts "Here's the score so far:"
    display_score_recap
  end

  def display_score_recap
    players.each do |player|
      print "#{player.name.colorize(player.color)}:"
      puts player.points_scored
    end
    puts "Tie games: #{tie_game_count}"
    pause_screen
  end

  def display_speed_game_recap
    puts 
    puts "It took #{game_winner.name} #{rounds_played} rounds to win!"
    puts
    puts "Final Scores are: "
    display_score_recap
  end

  def display_tie_game_message
    puts MESSAGES['tie_game']
  end

  def display_turn_order(turn_order)
    puts ''
    puts 'The turn order will be '
    puts ''
    turn_order.each { |player| puts player.name.colorize(player.color) }
    puts ''
    pause_screen
  end

  def display_welcome_screen
    clear_screen
    puts "Welcome to Tic Tac Toe!".colorize(:light_cyan).center(80)
    puts MESSAGES['welcome_message']
  end
  
  def play_round
    players.cycle do |player|
      player.take_turn
      update_all_players_winning_combos_left!(player.square_choice)
      if player.won_round?
        self.round_winner = player
        player.points_scored += 1
      elsif tied_game?
        self.tied_game = true
      end
      break if round_winner || tied_game
    end
  end

  def play_series_of_games
    play_rounds_until_game_winner
    puts "#{game_winner.name} scored #{points_needed_to_win} points!"
    display_speed_game_recap if speed_game

    self.play_a_series = false
    self.speed_game = false
    self.rounds_played = 0
    pause_screen
  end

  def play_single_game
    play_round
    self.game_winner = round_winner
  end


  def play_rounds_until_game_winner
    clear_screen
    display_thinking_animation('Calculating winner...', 0.2) if speed_game
    
    until game_winner
      play_round
      update_game_from_round_results!
      display_non_speed_game_messages unless speed_game
      board.reset_for_new_round!
      reset_players_for_new_round!
    end
  end

  def play_speed_game?
    puts MESSAGES['speed_game']
    display_input_prompt('Speed game? [y or n]')
    choice = get_validated_input(%w[y n])

  if choice == 'y'
    delay_screen(1, 'You chose to run a speed game(s).')
  else
    delay_screen(1, 'You chose not to run a speed game(s).')
  end
  
  choice == 'y'
  end

  def reset_available_player_options!
    Player.available_symbols = %w[x o triangle square plus_sign]
    Player.available_colors = %i[blue red cyan magenta yellow white]
    Player.available_computer_opponents = COMPUTER_OPPONENTS.keys
  end
  
  def reset_players_for_new_round!
    players.each do |player|
      player.erase_turn_history!
      player.reset_winning_combos_left!
    end
  end

  def play_again?
    display_input_prompt('Do you want to play again?')
    choice = get_validated_input(%w[y n])
    choice.downcase == 'y'
  end

  def set_shared_player_defaults!
    
  end

  def setup_players(winning_board_combos)
    players = []
    max_players = board.max_players
    num_players = max_players == 2 ? 2 : choose_number_of_players(max_players)
    set_shared_player_defaults!

    num_players.times do |player_number|
      player_type = choose_player_type(player_number + 1)
      if player_type == 'human'
        players << Human.new(player_number + 1, board)
      else
        players << Computer.new(player_number + 1, board)
      end
    end
    players
  end

  def tied_game?
    num_players_that_can_win = number_of_players

    players.each do |player|
      num_players_that_can_win -=1 if player.winning_combos_left.empty?
    end
    num_players_that_can_win.zero?
  end

  def update_all_players_winning_combos_left!(square)
    players.each do |player|
      player.winning_combos_left.each do |combo|
        combo.delete(square)
      end
    end
  end

  def update_game_from_round_results!
    self.rounds_played += 1
    self.tie_game_count += 1 if tied_game
    if round_winner&.points_scored >= points_needed_to_win
      self.game_winner = round_winner
      round_winner.game_wins += 1
    end
  end

end 
 


class Board
  include TTTUtils
  attr_reader :max_players, :all_winning_combos, :available_squares
  
  def initialize
    @size = choose_size
    @all_winning_combos = determine_winning_square_combos
    @total_squares = @size ** 2
    @available_squares = (1..@total_squares).to_a
    @max_players = calculate_max_players
    @grid = create_grid
  end

  def display
    board_size = size

    num_rows = board_size
    num_squares_per_row = board_size
    first_sq_in_row = 1
    last_sq_in_row = size

    num_rows.times do 
      display_all_lines_in_row_of_squares(first_sq_in_row, last_sq_in_row)
      display_row_separator unless last_row?(last_sq_in_row)
      first_sq_in_row += num_squares_per_row
      last_sq_in_row += num_squares_per_row
    end
    puts ''
  end

  def reset_for_new_round!
    self.available_squares = (1..total_squares).to_a
    self.grid = create_grid
    self.round_winner = nil
    self.tied_game = false
  end

  def to_s
    self.display
  end
  
   def update_grid!(square_number,symbol, color)
    grid[square_number].update_contents!(symbol, color)
    available_squares.delete(square_number)
  end

  private
  
  attr_accessor :size
  attr_reader :total_squares, :grid
  attr_writer :available_squares

  def create_grid
    (1..total_squares).each_with_object({}) do |square_number, squares_grid|
      squares_grid[square_number] = Square.new(square_number)
    end
  end

  def calculate_diagonal_winning_combos
    left_to_right_diagonal = ((1..size**2).step(size + 1)).to_a
    right_to_left_diagonal =
      ((size..((size**2) - (size - 1))).step(size - 1)).to_a
    [left_to_right_diagonal, right_to_left_diagonal]
  end

  def calculate_horizontal_winning_combos
    winning_combos = []
    first_square = 1
    last_square = size
  
    until last_square > (size ** 2)
      winning_combos.push((first_square..last_square).to_a)
      first_square += size
      last_square += size
    end
    winning_combos
  end

  def calculate_max_players
    case size
      when 3, 4
        2
      when 5..7
        3
      when 8, 9
        4
      else
        5
    end
  end

  def calculate_vertical_winning_combos
    winning_combos = []
    first_square = 1
    last_square = (size ** 2) - (size - 1)
  
    until last_square > size ** 2
      winning_combos.push(((first_square..last_square).step(size)).to_a)
      first_square += 1
      last_square += 1
    end
    winning_combos
  end

  def choose_size
    valid_board_sizes = %w[3 4 5 6 7 8 9 10]
    display_size_message
    display_input_prompt('Enter your board size choice [3 - 10]')
    board_size = get_validated_input(valid_board_sizes)
    
    puts ''
    delay_screen(1.5, "You chose a #{board_size}x#{board_size} board size.")
    board_size.to_i
  end

  def determine_winning_square_combos
    horizontal_combos = calculate_horizontal_winning_combos
    vertical_combos = calculate_vertical_winning_combos
    diagonal_combos = calculate_diagonal_winning_combos
  
    horizontal_combos + vertical_combos + diagonal_combos
  end

  def display_all_lines_in_row_of_squares(first_square, last_square)
    # middle squares are all squares in a row except the first and last square
    line_number = 0
    middle_squares_range = ((first_square + 1)...last_square)

    until line_number > 6
      temp_line =
        grid[first_square][line_number].join + '|'.colorize(:yellow)
      middle_squares_range.each do |square_number|
        temp_line +=
          grid[square_number][line_number].join + '|'.colorize(:yellow)
      end
      temp_line += grid[last_square][line_number].join
      print temp_line
      puts
      line_number += 1
    end
  end

  def display_row_separator
    num_squares_per_row = size
    row_separator = '-------'.colorize(:yellow) + '+'.colorize(:red)
    row_separator_last_square = '-------'.colorize(:yellow)
  
    puts(
      (row_separator * (num_squares_per_row - 1)) +
        row_separator_last_square
    )
  end

  def display_size_message
    puts MESSAGES['board_size_message']
  end

  def last_row?(last_sq_in_row)
    last_sq_in_row == total_squares
  end
  
end

class Square
  def initialize(square_number)
    @number = square_number
    @contents = create_contents
  end

  def [](line)
    contents[line]
  end

  def update_contents!(symbol, color)
    self.contents = 
      symbol.map do |row|
        row.map { |char| char.colorize(color)}
      end
  end
  
  private
  attr_accessor :center, :contents
  attr_reader :number

  def create_contents
    layout = []

    7.times do 
      if number < 10 
        layout << [' ', ' ', ' ', ' ', ' ', ' ', ' ']
      elsif number << 100 
        layout << [' ', ' ', ' ', '  ', ' ', ' ']
      else
        layout << [' ', ' ', ' ', '   ', ' ']
      end
    end

    #label center of square with square number
    layout[3][3] = number
    layout
  end
end

class Player
  include TTTUtils
  attr_accessor  :turn_history, :name, :symbol, :color, 
                 :player_number, :square_choice, :winning_combos_left, 
                 :points_scored
  attr_reader :board

  @@available_symbols = %w[x o triangle square plus_sign]
  @@available_colors = %i[blue red cyan magenta yellow white]
  @@available_computer_opponents = COMPUTER_OPPONENTS.keys

  def initialize(player_number, board)
    @board = board
    @player_number = player_number
    @name = choose_name!.capitalize
    @symbol = choose_symbol!
    @color = choose_color!
    @winning_combos_left = Marshal.load(Marshal.dump(board.all_winning_combos))
    @square_choice = nil
    @turn_history = []
    @points_scored = 0
    @game_wins = 0
  end

  def self.available_symbols
    @@available_symbols
  end

  def self.available_symbols=(symbols)
    @@available_symbols = symbols
  end

  def self.available_colors
    @@available_colors
  end

  def self.available_colors=(colors_list)
    @@available_colors = colors_list
  end

  def self.available_computer_opponents
    @@available_computer_opponents
  end

  def self.available_computer_opponents=(value)
    @@available_computer_opponents = value
  end

  def erase_turn_history!
    self.turn_history = []
  end

  def take_turn
    self.square_choice = choose_square_to_mark
    update_turn_history!
    board.update_grid!(square_choice, symbol, color)
    
    clear_screen
    board.display
    puts "#{name} chose to mark square #{square_choice}!"
    pause_screen
  end

  def choose_square_to_mark
    nil
  end

  def won_round?
    board.all_winning_combos.any? { |combo| (combo.difference(turn_history)).empty?}
  end

  private

  attr_reader :position

  def update_turn_history!
    turn_history << square_choice
  end

  def reset_winning_combos_left!
    self.winning_combos_left = 
      Marshal.load(Marshal.dump(board.all_winning_combos))
  end
end

class Human < Player
    
  private
  

  def choose_name!
    display_input_prompt("What's the name of player #{position}?")
    name = get_validated_input([])
    delay_screen(1.5, "Hello, #{name}!")
    name
  end

  def choose_symbol!
    clear_screen
    avail_symbols_formatted = Player.available_symbols.map(&:capitalize).join(', ')
    puts MESSAGES['available_symbol_markers'] % [avail_symbols_formatted]
    display_input_prompt('Please enter your choice')
    symbol = get_validated_input(@@available_symbols)
    Player.available_symbols.delete(symbol)
    SYMBOL_MARKERS_MAP[symbol]
  end

  def choose_color!
     available_colors = Player.available_colors.map{ |color| color.to_s.capitalize}
    
    puts 'What color do you want your symbol marker to be?'
    puts "Available choices are: [#{available_colors.join(', ')}]"
    display_input_prompt('Enter your choice')
    color_choice = get_validated_input(available_colors)
    Player.available_colors.delete(color_choice.to_sym)
    
    delay_screen(1, "#{self.name} chose #{color_choice} as their color.")
    color_choice.to_sym
  end

  def choose_square_to_mark
    valid_squares = board.available_squares.map(&:to_s)

    clear_screen
    board.display
    puts "Look at the board above and choose a square number."
    display_input_prompt("Which square do you want to mark, #{name}?")
    get_validated_input(valid_squares).to_i
  end


end

class Computer < Player

  private

  def choose_name!
    opponents_list = Player.available_computer_opponents.map(&:to_s)
    if randomly_choose_opponent?(opponents_list)
      opponent = random_opponent(opponents_list)
    else
      opponent = pick_opponent(opponents_list)
    end
    Player.available_computer_opponents.delete(opponent.to_sym)
    opponent
  end

  def choose_symbol!
    symbol = Player.available_symbols.sample
    Player.available_symbols.delete(symbol)
    symbol
  end

  def choose_color!
    COMPUTER_OPPONENTS[name.to_sym][:color]
  end

  def pick_opponent(opponents_list)
    puts  MESSAGES['pick_opponent'] % opponents_list.join(', ')
    display_input_prompt('Type in their name exactly as spelled')
    computer_opponent = get_validated_input(opponents_list).capitalize
    name_color = COMPUTER_OPPONENTS[computer_opponent.to_sym][:color]
    puts "You picked #{computer_opponent.colorize(name_color)}!"
    puts
    delay_screen(1.5)
    computer_opponent
  end

  def random_opponent(opponents_list)
    puts 'You chose to randomly pick a computer opponent.'
    computer_opponent = opponents_list.sample
    name_color = COMPUTER_OPPONENTS[computer_opponent.to_sym][:color]
    display_thinking_animation('Randomly choosing', 0.3)
    puts "Looks like #{computer_opponent.colorize(name_color)} was chosen!"
    puts
    delay_screen(1.5)
    computer_opponent
  end

  def randomly_choose_opponent?(opponents_list)
    puts
    puts "Player #{player_number} will be a computer opponent."
    print 'Available computer opponents left are '
    puts "[#{opponents_list.join(', ')}]"
    puts 'Do you want to choose the opponent or have it randomly picked for you?'
    display_input_prompt(
      "Type 'C' to (C)hoose an opponent or 'R' to have it " \
        '(R)andomly assigned'
    )

    get_validated_input(%w[c r]).downcase == 'r'
  end
end


game = TTTGame.new
game.play

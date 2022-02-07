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
    colors: {
      name_color: :light_green,
      symbol_color: :light_green
    },
    difficulty: 1
  },
  Maude: {
    name: 'Maude',
    colors: {
      name_color: :light_magenta,
      symbol_color: :light_magenta
    },
    difficulty: 2
  },
  Hans: {
    name: 'Hans',
    colors: {
      name_color: :light_cyan,
      symbol_color: :light_cyan
    },
    difficulty: 2
  },
  Ryuk: {
    name: 'Ryuk',
    colors: {
      name_color: :light_yellow,
      symbol_color: :light_yellow
    },
    difficulty: 3
  },
  Player_456: {
    name: 'Player_456',
    colors: {
      name_color: :light_white,
      symbol_color: :light_white
    },
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

module TTTUtils

  def get_validated_input(valid_input)
    abbreviations = Abbrev.abbrev(valid_input.map(&:downcase))
    valid_pattern = build_regexp_pattern(valid_input, abbreviations)
    
    user_input = ''
    loop do
      user_input = gets.chomp.downcase.strip
      break if valid_pattern.match?(user_input)
      puts "That's not a valid choice. Try again."
      puts "Choices are [#{valid_input.join(', ')}]: "
    end
    abbreviations[user_input] || user_input
  end

  def build_regexp_pattern(string_array, abbreviations)
    return /\w+/ if string_array.empty?
    abbreviations = abbreviations.keys.join('|').prepend('^(') << (')$')
    Regexp.new(abbreviations, 'ignore case')
  end

  def display_input_prompt(message)
    print message.colorize(:light_cyan) + PROMPT.colorize(:light_magenta)
  end

  def pause_screen
    display_input_prompt('Press enter to continue')
    gets
  end

  def clear_screen
    system('clear')
  end
end

class TTTEngine 
  # tracking board, number of players, scores of players (for multi-rounds)
  # player turn order, 
  include TTTUtils
  attr_accessor :num_players, :player_scores, :turn_order, :round_winner, 
                :game_board, :players, :board, :available_computer_opponents
  
  def initialize
    @board = Board.new
    @available_computer_opponents = COMPUTER_OPPONENTS.keys
    @players = setup_players(@board.all_winning_combos)
    @rounds_played = 0
    @tie_game_count = 0
    @round_winner = nil
    @game_winner = nil
    @play_a_series = false
    @speed_game = false
    @points_to_win = 0
  end

  def play

    clear_screen
    display_welcome_screen
    loop do 
      choose_turn_order
      puts board
      players_take_turns until round_winner? || board_full?
      
      update_player_score
      congratulate_winner
      reset_game!
      break unless play_again?
    end
    display_goodbye_message  
   
  end

  private

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

    if available_computer_opponents.empty?
      puts MESSAGES['no_computer_opponents_left']
      return 'human'
    end
    
    puts "Do you want player #{player_number} to be a human or computer player?"
    display_input_prompt("Type 'h' for human or 'c' for computer")
    get_validated_input(%w[human computer])
  end

  def display_welcome_screen
    clear_screen
    puts "Welcome to Tic Tac Toe!".colorize(:light_cyan).center(80)
    puts MESSAGES['welcome_message']
  end
  
  def players_take_turns
    current_player = turn_order.first
    current_player.take_turn
    turn_order.rotate!
  end

  def round_winner?
    !!round_winner
  end


  def board_full?
    game_board.full?
  end

  

  def setup_players(winning_board_combos)
    players = []
    max_players = board.max_players
    num_players = max_players == 2 ? 2 : choose_number_of_players(max_players)
    num_players.times do |player_number|
      player_type = choose_player_type(player_number + 1)
      if player_type == 'human'
        players << Human.new(player_number + 1, winning_board_combos)
      else
        players << Computer.new(player_number + 1, winning_board_combos)
      end
    end
    players
  end

end 
 


class Board
  include TTTUtils
  attr_reader :max_players, :all_winning_combos
  
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

  def to_s
    self.display
  end
  
  def update!(square_number, symbol)
    grid[square_number] = symbol
    available_squares.delete(square_number)
  end


  def full?
    # is every square on the board filled? - true or false
  end

  private
  
  attr_accessor :size, :available_squares
  attr_reader :total_squares, :grid

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
    puts "You chose a #{board_size}x#{board_size} board size."
    pause_screen
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

  def []=()
  end
  
  private
  attr_accessor :center
  attr_reader :number, :contents

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
  attr_accessor :square_choice_to_mark, :turn_history, :name, :symbol, :color

  @@available_symbols = %w[x o triangle square plus_sign]
  @@available_colors = %i[blue red cyan magenta yellow white]

  def initialize(player_number, winning_board_combos)
    @name = choose_name.capitalize
    @symbol = choose_symbol!
    @color = choose_color!
    @position = player_number
    @winning_combos_left = Marshal.load(Marshal.dump(winning_board_combos))
    @turn_history = []
    @points_scored = 0
    @game_wins = 0
  end

  def take_turn
    self.square_choice = choose_square_to_mark
    mark_square(square_choice)
  end

  def choose_square_to_mark

  end

  def mark_square(square_choice)
    # marks square_number with player's symbol
  end

  private

  
  attr_reader :position

end

class Human < Player
    
  private
  

  def choose_name
    display_input_prompt("What's the name of player #{position}?")
    get_validated_input([])
  end

  def choose_symbol!
    clear_screen
    avail_symbols_formatted = @@available_symbols.map(&:capitalize).join(', ')
    puts MESSAGES['available_symbol_markers'] % [avail_symbols_formatted]
    display_input_prompt('Please enter your choice')
    symbol = get_validated_input(@@available_symbols)
    @@available_symbols.delete(symbol)
    SYMBOL_MARKERS_MAP[symbol]
  end

  def choose_color!
     available_colors = @@available_colors.map{ |color| color.to_s.capitalize}
    
    puts 'What color do you want your symbol marker to be?'
    puts "Available choices are: [#{available_colors.join(', ')}]"
    display_input_prompt('Enter your choice')
    color_choice = get_validated_input(available_colors)
    @@available_colors.delete(color_choice.to_sym)
    print "#{self.name} chose #{color_choice} as their color." 
    
    pause_screen
    color_choice.to_sym
  end
end

class Computer < Player
end

game = TTTEngine.new
game.play
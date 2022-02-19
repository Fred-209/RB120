# Tic Tac Toe OO Rework

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
      print "Choices are [#{valid_input.join(', ')}]: "
    end
    abbreviations[user_input.downcase] || user_input
  end

  def delay_screen(seconds_delay, message = nil)
    print message if message
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
  include TTTUtils
  attr_accessor :number_of_players,
                :player_scores,
                :turn_order,
                :round_winner,
                :game_board,
                :players,
                :board,
                :tied_game

  def initialize
    @first_run = true
    @board = nil
    @players = nil
    @speed_game = nil
    @number_of_players = nil
    @turn_order = nil
    @series_game = nil
    @points_needed_to_win = nil
    @rounds_played = 0
    @tie_game_count = 0
    @tied_game = false
    @round_winner = nil
    @game_winner = nil
  end

  def play
    loop do
      clear_screen
      display_welcome_screen if first_run

      setup_game_options
      series_game ? play_series_of_games : play_single_game
      game_winner ? congratulate_winner : display_tie_game_message

      self.first_run = false

      reset_game_stats!
      break unless play_again?
    end

    display_goodbye_message
  end

  private

  attr_accessor :points_needed_to_win,
                :first_run,
                :rounds_played,
                :tie_game_count,
                :speed_game,
                :game_winner,
                :series_game

  def setup_game_options
    self.board = Board.new
    self.players = setup_players(board.all_winning_combos)
    self.speed_game = play_speed_game? if all_players_are_computers?
    self.number_of_players = players.count
    self.turn_order = choose_turn_order
    self.series_game = play_a_series?
    self.points_needed_to_win = series_game ? choose_points_needed_to_win : 1
  end

  def all_players_are_computers?
    players.all? { |player| player.class == Computer }
  end

  def choose_points_needed_to_win
    puts MESSAGES['choose_points_needed_to_win']
    display_input_prompt('Enter [2, 3, 4, 5, 6, 7, 8 , 9, or 10]')
    points = get_validated_input(%w[2 3 4 5 6 7 8 9 10])

    delay_screen(
      1.5,
      "You chose to play until someone scores #{points} points."
    )
    points.to_i
  end

  def choose_number_of_players(max_players)
    clear_screen
    puts format(MESSAGES['choose_number_of_players'], max_players.to_s.colorize(:red))
    valid_num_player_choices = (2..max_players).map(&:to_s)
    display_input_prompt('Enter the number of players: ')
    num_players = get_validated_input(valid_num_player_choices)
    delay_screen(0.8, "#{num_players} players will be playing this time!")
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

  def choose_turn_order
    return '1' if speed_game
    puts
    puts MESSAGES['turn_order_choices']
    display_input_prompt('Which do you choose [1, 2, or 3]?')
    turn_order_menu_choice = get_validated_input(%w[1 2 3])

    turn_order = create_turn_order_from_choice!(turn_order_menu_choice)
    display_turn_order(turn_order)
    turn_order
  end

  def choose_who_goes_first
    players.each_with_index { |player, idx| puts "#{idx + 1}. #{player.name}" }

    display_input_prompt(
      "Choose [#{(1...number_of_players).to_a.join(', ')} or "
    )
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
    board.display if speed_game && !series_game
    winner = game_winner.name.colorize(game_winner.color)
    puts
    puts "Congratulations #{winner}!".center(80)
    puts 'You won the game!'.colorize(:light_cyan).center(80)
    puts
  end

  def display_goodbye_message
    puts MESSAGES['goodbye'].colorize(:light_cyan).center(80)
  end

  def display_non_speed_game_messages
    puts
    puts 'Looks like a tie this round! Noone scores.' if tied_game
    puts "#{round_winner.name} won this round!" if round_winner
    puts "Here's the score so far: "
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
    puts 'Final Scores are: '
    display_score_recap
  end

  def display_tie_game_message
    board.display if speed_game
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
    puts 'Welcome to Tic Tac Toe!'.colorize(:light_cyan).center(80)
    puts MESSAGES['welcome_message']
  end

  def play_again?
    display_input_prompt('Do you want to play again?')
    choice = get_validated_input(%w[y n])
    choice.downcase == 'y'
  end

  def play_round
    players.cycle do |player|
      player.take_turn(speed_game)
      update_all_players_winning_combos_left!
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
    puts "#{game_winner.name} scored #{points_needed_to_win} points to win " \
           'the series!'
    display_speed_game_recap if speed_game
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
      reset_for_new_round! unless game_winner
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

  def reset_for_new_round!
    board.reset_for_new_round!
    reset_players_for_new_round!
    self.round_winner = nil
    self.tied_game = false
  end

  def reset_game_stats!
    self.round_winner = nil
    self.game_winner = nil
    self.series_game = false
    self.speed_game = false
    self.rounds_played = 0
  end

  def reset_players_for_new_round!
    players.each(&:reset_for_new_round!)
  end

  def set_shared_player_defaults!
    Player.available_symbols = %w[x o triangle square plus_sign]
    Player.available_colors = %i[blue red cyan magenta yellow white]
    Player.available_computer_opponents = COMPUTER_OPPONENTS.keys
  end

  def play_a_series?
    puts MESSAGES['play_a_series']
    display_input_prompt('Type 1 for Series or 2 for Single:')
    choice = get_validated_input(%w[1 2])

    if choice == '2'
      delay_screen(1.5, 'You chose to play a single game.')
    else
      delay_screen(1.5, 'You chose to play a series of games.')
    end
    puts
    choice == '1'
  end

  def setup_players(_winning_board_combos)
    players = []
    max_players = board.max_players
    num_players = max_players == 2 ? 2 : choose_number_of_players(max_players)
    set_shared_player_defaults!

    num_players.times do |player_number|
      player_type = choose_player_type(player_number + 1)
      players << if player_type == 'human'
                   Human.new(player_number + 1, board, players)
                 else
                   Computer.new(player_number + 1, board, players)
                 end
    end
    players
  end

  def tied_game?
    num_players_that_can_win = number_of_players

    players.each do |player|
      num_players_that_can_win -= 1 if player.winning_combos_left.flatten.empty?
    end
    num_players_that_can_win.zero?
  end

  def update_all_players_winning_combos_left!
    players.each do |player|
      viable_combos = player.winning_combos_left
      other_players = players.reject { |other_player| other_player == player }
      other_players.each do |other_player|
        turn_history = other_player.turn_history
        viable_combos.clone.each do |combo|
          viable_combos.delete(combo) if !(combo & turn_history).empty?
        end
      end
    end
  end

  def update_game_from_round_results!
    self.rounds_played += 1
    self.tie_game_count += 1 if tied_game
    if round_winner && round_winner.points_scored >= points_needed_to_win
      self.game_winner = round_winner
      round_winner.game_wins += 1
    end
  end
end

class Board
  include TTTUtils
  attr_reader :max_players,
              :all_winning_combos,
              :available_squares,
              :total_squares,
              :size

  def initialize
    @size = choose_size
    @all_winning_combos = determine_winning_square_combos
    @total_squares = @size**2
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
  end

  def to_s
    display
  end

  def update_grid!(square_number, symbol, color)
    grid[square_number].update_contents!(symbol, color)
    available_squares.delete(square_number)
  end

  private

  attr_accessor :grid
  attr_writer :available_squares, :size

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

    until last_square > (size**2)
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
    last_square = (size**2) - (size - 1)

    until last_square > size**2
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
    delay_screen(1, "You chose a #{board_size}x#{board_size} board size.")
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
      temp_line = grid[first_square][line_number].join + '|'.colorize(:yellow)
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
      (row_separator * (num_squares_per_row - 1)) + row_separator_last_square
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
    self.contents = symbol.map { |row| row.map { |char| char.colorize(color) } }
  end

  private

  attr_accessor :center, :contents
  attr_reader :number

  def create_contents
    layout = []

    7.times do
      layout << if number < 10
                  [' ', ' ', ' ', ' ', ' ', ' ', ' ']
                elsif number << 100
                  [' ', ' ', ' ', '  ', ' ', ' ']
                else
                  [' ', ' ', ' ', '   ', ' ']
                end
    end

    # label center of square with square number
    layout[3][3] = number
    layout
  end
end

class Player
  include TTTUtils
  attr_accessor :turn_history,
                :name,
                :symbol,
                :color,
                :player_number,
                :square_choice,
                :winning_combos_left,
                :points_scored,
                :game_wins
  attr_reader :board

  def initialize(player_number, board, players_list)
    @board = board
    @player_number = player_number
    @name = choose_name!.capitalize
    @symbol = choose_symbol!
    @color = choose_color!
    @winning_combos_left = Marshal.load(Marshal.dump(board.all_winning_combos))
    @players_list = players_list
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

  def reset_for_new_round!
    erase_turn_history!
    reset_winning_combos_left!
  end

  def take_turn(speed_game)
    self.square_choice = choose_square_to_mark
    update_turn_history!
    board.update_grid!(square_choice, symbol, color)

    unless speed_game
      display_thinking_animation("#{name} is thinking", 0.2)
      clear_screen
      board.display
      puts "#{name} chose to mark square #{square_choice}!"
      pause_screen
    end
  end

  def choose_square_to_mark
    nil
  end

  def won_round?
    board.all_winning_combos.any? do |combo|
      (combo.difference(turn_history)).empty?
    end
  end

  private

  attr_reader :position, :players_list

  def erase_turn_history!
    self.turn_history = []
  end

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
    puts "Hello, #{name}!"
    puts
    name
  end

  def choose_symbol!
    avail_symbols_formatted =
      Player.available_symbols.map(&:capitalize).join(', ')
    puts format(MESSAGES['available_symbol_markers'], avail_symbols_formatted)
    display_input_prompt('Please enter your choice')
    symbol = get_validated_input(@@available_symbols)
    Player.available_symbols.delete(symbol)
    SYMBOL_MARKERS_MAP[symbol]
  end

  def choose_color!
    available_colors =
      Player.available_colors.map { |color| color.to_s.capitalize }

    puts 'What color do you want your symbol marker to be?'
    puts "Available choices are: [#{available_colors.join(', ')}]"
    display_input_prompt('Enter your choice')
    color_choice = get_validated_input(available_colors)
    Player.available_colors.delete(color_choice.to_sym)

    puts("#{name} chose #{color_choice} as their color.")
    color_choice.to_sym
  end

  def choose_square_to_mark
    valid_squares = board.available_squares.map(&:to_s)

    clear_screen
    board.display
    puts 'Look at the board above and choose a square number.'
    display_input_prompt("Which square do you want to mark, #{name}?")
    get_validated_input(valid_squares).to_i
  end
end

class Computer < Player
  def initialize(player_number, board, other_players)
    super
    @difficulty_level = COMPUTER_OPPONENTS[name.to_sym][:difficulty]
    @intelligence_score = nil
  end

  private

  attr_reader :difficulty_level
  attr_accessor :intelligence_score

  def choose_name!
    opponents_list = Player.available_computer_opponents.map(&:to_s)
    opponent = if randomly_choose_opponent?(opponents_list)
                 random_opponent(opponents_list)
               else
                 pick_opponent(opponents_list)
               end
    Player.available_computer_opponents.delete(opponent.to_sym)
    opponent
  end

  def choose_symbol!
    symbol = Player.available_symbols.sample
    Player.available_symbols.delete(symbol)
    SYMBOL_MARKERS_MAP[symbol]
  end

  def choose_color!
    COMPUTER_OPPONENTS[name.to_sym][:color]
  end

  def choose_square_to_mark
    self.intelligence_score = rand(1..10)
    possible_winning_square = find_other_players_winning_square

    case difficulty_level
    when 1
      choose_level_1_ai_square(possible_winning_square)
    when 2
      choose_level_2_ai_square(possible_winning_square)
    when 3
      choose_level_3_ai_square(possible_winning_square)
    end
  end

  def choose_level_1_ai_square(possible_winning_square)
    square_choice = possible_winning_square if intelligence_score > 8
    square_choice || random_available_square
  end

  def choose_level_2_ai_square(possible_winning_square)
    if turn_history.empty?
      choose_middle_or_corner_square
    elsif intelligence_score > 7 && possible_winning_square
      possible_winning_square
    else
      random_available_square
    end
  end

  def choose_level_3_ai_square(possible_winning_square)
    closest_combo = winning_combos_left.min_by(&:size)
    num_squares_to_win = if closest_combo
                           closest_combo.size
                         else
                           0
                         end

    # num_squares_to_win = closest_combo ? closest_combo.size : 0

    return random_available_square if intelligence_score < 3
    return choose_middle_or_corner_square if turn_history.empty?
    return closest_combo.first if num_squares_to_win == 1
    return possible_winning_square if possible_winning_square
    return closest_combo.sample if closest_combo

    random_available_square
  end

  def choose_middle_or_corner_square
    middle_square = (board.total_squares / 2) + 1
    corner_squares = determine_corner_squares
    return middle_square if board.available_squares.include?(middle_square)

    if board.available_squares.any? { |square| corner_squares.include?(square) }
      common_squares = (board.available_squares & corner_squares)
      common_squares.sample
    else
      random_available_square
    end
  end

  def find_other_players_winning_square
    board.all_winning_combos.each do |combo|
      players_list.each do |player|
        next if name == player.name

        squares_to_win = combo.difference(turn_history)
        if squares_to_win.size == 1 &&
           board.available_squares.include?(squares_to_win[0])
          return squares_to_win.first
        end
      end
    end
    nil
  end

  def determine_corner_squares
    nw_corner_square = 1
    ne_corner_square = board.size
    sw_corner_square = board.total_squares - board.size
    se_corner_square = board.total_squares
    [nw_corner_square, ne_corner_square, sw_corner_square, se_corner_square]
  end

  def pick_opponent(opponents_list)
    puts MESSAGES['pick_opponent'] % opponents_list.join(', ')
    display_input_prompt('Type in their name exactly as spelled')
    computer_opponent = get_validated_input(opponents_list).capitalize
    name_color = COMPUTER_OPPONENTS[computer_opponent.to_sym][:color]
    puts "You picked #{computer_opponent.colorize(name_color)}!"
    puts
    delay_screen(1.5)
    computer_opponent
  end

  def random_available_square
    board.available_squares.sample
  end

  def random_opponent(opponents_list)
    puts 'You chose to randomly pick a computer opponent.'
    computer_opponent = opponents_list.sample
    name_color = COMPUTER_OPPONENTS[computer_opponent.to_sym][:color]
    display_thinking_animation('Randomly choosing', 0.3)
    puts "Looks like #{computer_opponent.colorize(name_color)} was chosen!"
    delay_screen(1)
    computer_opponent
  end

  def randomly_choose_opponent?(opponents_list)
    puts
    puts "Player #{player_number} will be a computer opponent."
    print 'Available computer opponents left are '
    puts "[#{opponents_list.join(', ')}]"
    puts 'Do you want to choose the opponent or have it randomly picked for '
    puts 'you?'
    display_input_prompt(
      "Type 'C' to (C)hoose an opponent or 'R' to have it " \
        '(R)andomly assigned'
    )

    get_validated_input(%w[c r]).downcase == 'r'
  end
end

game = TTTGame.new
game.play

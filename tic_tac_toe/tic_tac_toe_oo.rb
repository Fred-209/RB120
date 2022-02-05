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
- grid of X by X squares
- visual layout
  - rows and columns of squares
- which squares are marked and which aren't 
  - tracking which player's symbol is marked for the marked square

Player
- has a symbol
- has a color 
- has a name
- has a score
- either human or AI computer opponent
- If computer, has an AI
- Actions: 
  - marks a square

Square
- Has a:
  - empty or symbol marking in it
  - some sort of visual representation?
- Actions:
  - can be marked with a symbol
  - can be unmarked with a symbol? (upon reset game)


- can be marked with a symbol
- maybe Symbol as a collaborator object


Symbol
- can be a X or O (or triangle, square, )
- has a visual representation of itself

Turn

=end

class TTTEngine
  # tracking board, number of players, scores of players (for multi-rounds)
  # player turn order, 
  def play
    attr_accessor :num_players, :player_scores, :turn_order, :round_winner, :game_board
    
    display_welcome_message
    loop do 
      initialize_board # size
      setup_players # names, colors, symbol choice, AI or Human
      choose_turn_order
      display_board
      players_take_turns until round_winner? || board_full?
      
      update_player_score
      congratulate_winner
      reset_game!
      break unless play_again?
    end
    display_goodbye_message  

    # initial game setup
      # - display welcome message
      # - board init
        # - choose size
      # - players setup
        # - names, human or computer, number of players, colors , symbol
    # - choose turn order
    # - loop until someone wins or board is full (tie)
      # - player takes a turn (marks a square)
      # - check to see if this player won or if board is full
      # - move onto next player in player order
    # - update player scores
    # - congratulate winner
    #  - ask if want to play again
      # - yes: 
        # - reset player scores
        # - back to initial game setup
      # - no: 
        # - break out of GameEngine loop
    
    
  end

  def players_take_turns
    current_player = turn_order.first
    current_player.take_turn
    turn_order.rotate!
  end

  def round_winner?
    !!round_winner
  end
end

  def board_full?
    game_board.full?
  end

class Board
  def initialize

  end

  def full?
    # is every square on the board filled? - true or false
  end
end

class Square
  def initialize
    # status to keep track of this square's current symbol, or empty
  end
end

class Player
  attr_accessor :square_choice_to_mark

  def initialize
    # name, chosen symbol, human or computer player_type
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
end

class Human < Player
end

class Computer < Player
end

game = TTTEngine.new
game.play
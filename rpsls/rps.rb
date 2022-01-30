class Move
  VALUES = %w[rock paper scissors]

  def initialize(value)
    @value = value
  end

  def scissors?
    @value == 'scissors'
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def >(other_move)
    if rock?
      other_move.scissors?
    elsif paper?
      other_move.rock?
    elsif scissors?
      other_move.paper?
    end
  end

  def <(other_move)
    if rock?
      other_move.paper?
    elsif paper?
      other_move.scissors?
    elsif scissors?
      other_move.rock?
    end
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name

  def initialize
    set_name
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
      puts 'Please choose rock, paper, or scissors:'
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts 'That is not a valid choice. Please choose again.'
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = %w[R2D2 Hal Chappie Sonny Number_5].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
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

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
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
      display_winner
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play

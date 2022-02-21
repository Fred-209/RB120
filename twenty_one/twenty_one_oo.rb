# frozen_string_literal: true

# Twenty One
#
# Twenty-One is a card game consisting of a dealer and a player, where the participants
#  try to get as close to 21 as possible without going over.
#
# Here is an overview of the game:
# - Both participants are initially dealt 2 cards from a 52-card deck.
# - The player takes the first turn, and can "hit" or "stay".
# - If the player busts, he loses. If he stays, it's the dealer's turn.
# - The dealer must hit until his cards add up to at least 17.
# - If he busts, the player wins. If both player and dealer stays, then the highest total wins.
# - If both totals are equal, then it's a tie, and nobody wins.
#
#
# Nouns: card, game, dealer, player, participants, deck, total
# Verbs: takes turn, hit, stay, busts
#
# Player
# - hit
# - stay
# - busted?
# - total
# Dealer
# - hit
# - stay
# - busted?
# - total
# - deal (should this be here, or in Deck?)
# Participant
# Deck
# - deal (should this be here, or in Dealer?)
# Card
# Game
# - start
#

require 'pry'
require 'yaml'
require 'abbrev'



module Utils # requires abbrev
  PROMPT = ' => '

  def build_regexp_pattern(string_array, abbreviations)
    return /\w+/ if string_array.empty?

    abbreviations = abbreviations.keys.join('|').prepend('^(') << ')$'
    Regexp.new(abbreviations, 'ignore case')
  end

  def display_input_prompt(message)
    print message + PROMPT
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

class TwentyOne
  include Utils

  MESSAGES = YAML.load_file('twenty_one_oo.yml')
  BUST_THRESHOLD = 21

  def initialize
    first_run = true
    display_welcome if first_run
    @points_to_win = choose_points_to_win
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
    @rounds_played = 0
    @tie_games = 0
  end

  def start
    loop do
      deal_starting_hands
      play_game until game_winner?
      break
      # player_takes_turn
      # dealer_takes_turn

      # show_initial_cards
      # player_turn
      # dealer_turn
      # show_result
    end
  end

  private

  attr_accessor :deck, :player, :dealer, :rounds_played, :tie_games, :first_run,
                :points_to_win

  def choose_points_to_win
    print MESSAGES['play_multiple_rounds']
    print "Type 's' for single game or 'm' for multiple games #{PROMPT}"
    get_validated_input(%w[s m]) == 's' ? 1 : 3
  end

  def choose_to_stay_hand?
    print format(MESSAGES['draw_or_stay'], PROMPT)
    get_validated_input(%w[stay draw]) == 'stay'
  end

  def deal_card_to_participant(participant)
    card = deck.deal_card
    card.face_down = true if participant.hand.empty? &&
                             participant.class == Dealer
    participant.hand.add_card(card)
    puts "#{participant.name} was dealt a #{card}."
    puts
    participant.hand.display
  end

  def display_turn_recap(participant)
    clear_screen
    puts 'Turn Recap'
    puts
    participant.show_hand
    puts format(
      MESSAGES['participant_staying'], participant.name, participant.hand_value
    )
      
    pause_screen
  end

  def deal_starting_hands
    clear_screen
    deck.shuffle(hide_animation: false)

    2.times do
      [player, dealer].each do |participant|
        deal_card_to_participant(participant)
        puts
        sleep (1.25)
      end
    end
  end

  def display_welcome
    clear_screen
    puts MESSAGES['welcome_banner']
    puts MESSAGES['welcome_message']
  end

  def game_winner?
    player.points >= points_to_win || dealer.points >= points_to_win
  end

  def play_game
    clear_screen
    self.rounds_played += 1
    if playing_multiple_games? 
      puts "Starting round #{rounds_played}"
    else 
      puts "Playing Single Game"
    end
    player_takes_turn
    # dealer_takes_turn unless player.busted?
    # dealer_takes_turn unless player.busted?
  end

  def player_takes_turn
    loop do
      show_all_hands
      puts format(MESSAGES['hand_display'], player.name, player.hand_value)
      if choose_to_stay_hand?
        player.stay_hand!
        break
      end
      deal_card_to_participant(player)
      sleep 1.25
      break if player.busted?
    end
    display_turn_recap unless player.busted?
  end

  def playing_multiple_games?
    points_to_win > 1
  end

  def reset
    self.first_run = false
    self.rounds_played = 0
    self.tie_games = 0
  end

  def show_all_hands
    dealer.show_hand
    player.show_hand
  end
end

class Participant
  include Utils
  attr_reader :name, :hand
  attr_accessor :points

  def initialize
    @name = assign_name
    @hand = Hand.new
    @stay = false
    @points = 0
  end

  def stay?
    stay == true
  end

  def stay_hand!
    self.stay = true
  end

  def busted?
    hand_value > TwentyOne::BUST_THRESHOLD
  end

  def show_hand(show_face_down_card: false)
    hand.display(show_face_down_card: false)
  end

  def hand_value
    hand.cards_value
  end

  private

  attr_writer :name
  attr_accessor :busted, :stay
end

class Player < Participant

  private

  def assign_name
    print "What's your name?: "
    name = get_validated_input([])
    puts
    puts "Ready to play some 21, #{name}?"
    delay_screen(1)
    name
  end
end

class Dealer < Participant
  DEALER_NAMES = %w[Dealer].freeze

  private

  def assign_name
    DEALER_NAMES.sample
  end
end

class Deck
  def initialize
    @cards = create_deck
  end

  def shuffle(hide_animation: true)
    display_shuffle_animation unless hide_animation
    cards.shuffle!
  end

  def deal_card
    cards.pop
  end

  def count
    "There are #{cards.count} cards left in the deck."
  end

  private

  attr_reader :cards

  def create_deck
    Card::SUITS.product(Card::FACES).each_with_object([]) do |(suit, face), deck|
      deck << Card.new(suit, face)
    end
  end

  def display_shuffle_animation
    print 'Shuffling deck....'
    %w[| / - \\].cycle(3) do |piece|
      print piece
      sleep 0.15
      print "\b"
    end
    puts 'Ready to deal!'
    puts
  end
end

class Card
  FACES = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze
  FACES_EXPANDED = { 'J' => 'Jack', 'Q' => 'Queen', 'K' => 'King',
                     'A' => 'Ace' }.freeze
  SUITS = %w[♥ ♠ ♦ ♣].freeze
  SUITS_EXPANDED = { '♥' => 'Hearts', '♠' => 'Spades', '♦' => 'Diamonds',
                     '♣' => 'Clubs' }.freeze
  FACE_VALUES = { 'J' => 10, 'Q' => 10, 'K' => 10, 'A' => 1 }.freeze
  TOP_OF_CARD_GRAPHIC = "┏━━━━━━━━━┓"
  UPPER_CARD_LABEL_GRAPHIC = ('┃' + '%-9.9s' + '┃')
  MID_CARD_GRAPHIC = "┃         ┃"
  MIDDLE_CARD_LABEL_GRAPHIC = ('┃' + '%s'.center(10) + '┃')
  LOWER_CARD_LABEL_GRAPHIC = ('┃' + '%9.9s' + '┃')
  BOTTOM_OF_CARD_GRAPHIC = "┗━━━━━━━━━┛"

  attr_reader :face, :suit, :value
  attr_accessor :face_down

  def initialize(suit, face)
    @suit = suit
    @face = face
    @value = FACE_VALUES.fetch(face, face.to_i)
    @face_down = false
  end

  def to_s
    if face_down
      'card face down'
    else
      "#{FACES_EXPANDED.fetch(face, face)} of #{SUITS_EXPANDED[suit]}"
    end
  end
end

class Hand
  include Comparable

  def initialize
    @cards = []
  end

  def add_card(card)
    cards << card
  end

  def card_count
    cards.count
  end

  def cards_value
    cards.map(&:value).sum
  end

  def display(show_face_down_card: false)
    suits = suits_list
    faces = faces_list

    if cards.first.face_down
      unless show_face_down_card
        suits[0] = '#'
        faces[0] = '#'
      end
    end
    display_card_graphics(suits, faces)
  end

  def empty?
    cards.empty?
  end

  def remove_card(card)
    cards.delete(card)
  end

  

  # def [](index)
  #   cards[index]
  # end

  def <=>(other)
    cards_value <=> other.cards_value
  end

  private

  def display_card_graphics(suits, faces)
    display_upper_cards_section(faces)
    display_mid_cards_section(suits)
    display_bottom_cards_section(faces)
  end

  def display_bottom_cards_section(faces)
    print_card_label_line(Card::LOWER_CARD_LABEL_GRAPHIC, faces)
    puts
    puts Card::BOTTOM_OF_CARD_GRAPHIC * card_count
  end

  def display_mid_cards_section(suits)
    puts
    puts Card::MID_CARD_GRAPHIC * card_count
    print_card_label_line(Card::MIDDLE_CARD_LABEL_GRAPHIC, suits)
    puts
    puts Card::MID_CARD_GRAPHIC * card_count
  end

  def display_upper_cards_section(faces)
    puts Card::TOP_OF_CARD_GRAPHIC * card_count
    print_card_label_line(Card::UPPER_CARD_LABEL_GRAPHIC, faces)
  end

  def print_card_label_line(card_section, graphic)
    card_count.times do |count|
      print format(card_section, graphic[count])
    end
  end

  def faces_list
    cards.map(&:face)
  end

  def suits_list
    cards.map(&:suit)
  end

  attr_reader :cards
end

game = TwentyOne.new
game.start
pry.start



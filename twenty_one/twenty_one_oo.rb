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

MESSAGES = YAML.load_file('twenty_one_oo.yml')

module Utils # requires abbrev
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

class Game
  include Utils

  def initialize
    display_welcome
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
    @rounds_played = 0
    @tie_games = 0
  end

  def start
    loop do
      deal_starting_hands
      # player_takes_turn
      # dealer_takes_turn

      # show_initial_cards
      # player_turn
      # dealer_turn
      # show_result
    end
  end

  private

  attr_accessor :deck, :player, :dealer, :rounds_played, :tie_games

  def deal_card_to_participant(participant)
    card = deck.deal_card
    card.face_down = true if participant.hand.empty? &&
                             participant.class == Dealer
    participant.hand.add_card(card)
    puts "#{participant.name} was dealt a #{card}."
    puts
    display_hand(participant.hand)
  end

  def deal_starting_hands
    display_shuffle_deck_animation
    2.times do
      [player, dealer].each do |participant|
        deal_card_to_participant(participant)
        puts
        # display_card_graphics
      end
    end
  end

  def display_card_graphics(number_of_cards, suits, faces)
    puts Card::TOP_OF_CARD_GRAPHIC * number_of_cards
    puts Card::UPPER_CARD_LABEL_GRAPHIC * number_of_cards % faces
    puts Card::MIDDLE_CARD_LABEL_GRAPHIC * number_of_cards % suits
    puts Card::MID_CARD_GRAPHIC * number_of_cards
    puts Card::MID_CARD_GRAPHIC * number_of_cards
    puts Card::LOWER_CARD_LABEL_GRAPHIC * number_of_cards % faces
    puts Card::BOTTOM_OF_CARD_GRAPHIC * number_of_cards
  end

  def display_hand(hand, show_face_down_card: false)
    suits = hand.suits
    faces = hand.faces
    card_count = hand.card_count

    if hand[0].face_down
      unless show_face_down_card
        suits[0] = '#'
        faces[0] = '#'
      end
    end
    display_card_graphics(card_count, suits, faces)
  end

  def display_shuffle_deck_animation
    print 'Shuffling deck....'
    %w[| / - \\].cycle(3) do |piece|
      print piece
      sleep 0.15
      print "\b"
    end
    puts 'Ready to deal!'
  end

  def display_welcome
    puts 'Welcome to 21!'
  end
end

class Participant
  include Utils
  attr_reader :name, :hand

  def initialize
    @name = assign_name
    @hand = Hand.new
  end

  def stay; end

  def busted?; end

  def total; end

  private

  attr_writer :name
end

class Player < Participant
  private

  def assign_name
    print "What's your name?: "
    name = get_validated_input([])
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
    shuffle
  end

  def shuffle
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
end

class Card
  FACES = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze
  FACES_EXPANDED = { 'J' => 'Jack', 'Q' => 'Queen', 'K' => 'King',
                     'A' => 'Ace' }.freeze
  SUITS = %w[♥ ♠ ♦ ♣].freeze
  SUITS_EXPANDED = { '♥' => 'Hearts', '♠' => 'Spades', '♦' => 'Diamonds',
                     '♣' => 'Clubs' }.freeze
  FACE_VALUES = { 'J' => 10, 'Q' => 10, 'K' => 10, 'A' => 1 }.freeze
  TOP_OF_CARD_GRAPHIC = MESSAGES['top_card_line']
  UPPER_CARD_LABEL_GRAPHIC = ('┃' + '%-9.9s' + '┃')
  MID_CARD_GRAPHIC = MESSAGES['mid_card_line']
  MIDDLE_CARD_LABEL_GRAPHIC = ('┃' + '%s'.center(10) + '┃')
  LOWER_CARD_LABEL_GRAPHIC = ('┃' + '%9.9s' + '┃')
  BOTTOM_OF_CARD_GRAPHIC = MESSAGES['bottom_card_line']

  attr_reader :face, :suit
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

  def total
    # calculate total value of all cards in @cards
  end

  def add_card(card)
    cards << card
  end

  def card_count
    cards.count
  end

  def empty?
    cards.empty?
  end

  def faces
    cards.map(&:face)
  end

  def remove_card(card)
    cards.delete(card)
  end

  def suits
    cards.map(&:suit)
  end

  def [](index)
    cards[index]
  end

  def <=>(other)
    cards.total <=> other.cards.total
  end

  private

  attr_reader :cards
end

game = Game.new.start

# pry.start

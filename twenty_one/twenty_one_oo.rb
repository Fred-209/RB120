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

# module Utils
#   def build_regexp_pattern(string_array, abbreviations)
#     return /\w+/ if string_array.empty?
#     abbreviations = abbreviations.keys.join('|').prepend('^(') << (')$')
#     Regexp.new(abbreviations, 'ignore case')
#   end

#   def display_input_prompt(message)
#     print message.colorize(:light_cyan) + PROMPT
#   end

#   def display_thinking_animation(phrase, wait_time)
#     print phrase
#     5.times do
#       print '.'
#       sleep wait_time
#     end
#     puts
#     puts
#   end

#   def get_validated_input(valid_input)
#     abbreviations = Abbrev.abbrev(valid_input.map(&:downcase))
#     valid_pattern = build_regexp_pattern(valid_input, abbreviations)

#     user_input = ''
#     loop do
#       user_input = gets.chomp.strip
#       break if valid_pattern.match?(user_input.downcase)
#       puts "That's not a valid choice. Try again."
#       print "Choices are [#{valid_input.join(', ')}]: "
#     end
#     abbreviations[user_input.downcase] || user_input
#   end

#   def delay_screen(seconds_delay, message = nil)
#     print message if message
#     sleep(seconds_delay)
#   end

#   def pause_screen
#     display_input_prompt('Press enter to continue')
#     gets
#   end

#   def clear_screen
#     system('clear')
#   end
# end

require 'pry'

class Game
  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def start
    display_welcome
    deal_hands
    # show_initial_cards
    # player_turn
    # dealer_turn
    # show_result
  end

  private

  attr_accessor :deck, :player, :dealer

  def display_welcome
    puts 'Welcome to 21!'
  end

  def deal_hands
    2.times do
      [player, dealer].each do |participant|
        card = deck.deal_card

        if participant.hand.empty? && participant.class == Dealer
          card.face_down = true
        end

        participant.hand.add_card(card)
        puts "#{participant.name} was dealt a #{card}."
      end
    end


  end
end

class Participant

 attr_reader :name, :hand

  def initialize
    @name = prompt_for_name
    @hand = Hand.new
  end

  def stay; end

  def busted?; end

  def total; end


end

class Player < Participant
  
  private

  def prompt_for_name
    # ask player for name
    # validate input
    "Fred"
  end
end

class Dealer < Participant
  
  def initialize
    super
  end

  private 

  def prompt_for_name
    "Dealer"
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
  FACES_EXPANDED = {'J' => 'Jack', 'Q' => 'Queen', 'K' => 'King', 'A' => 'Ace'}
  SUITS = %w[♥ ♠ ♦ ♣].freeze
  SUITS_EXPANDED = {'♥' => 'Hearts', '♠' => 'Spades', '♦' => 'Diamonds', '♣' => 'Clubs'}
  FACE_VALUES = {'J' => 10, 'Q' => 10, 'K' => 10, 'A' => 1 }.freeze
  

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
      "card face down"
    else
      "#{FACES_EXPANDED.fetch(face, face)} of #{SUITS_EXPANDED[suit]}"
    end
  end
end

class Hand
  include Comparable

  attr_reader :cards

  def initialize
    @cards = []
  end

  def total
    #calculate total value of all cards in @cards
  end

  def empty?
    cards.empty?
  end

  def add_card(card)
    cards << card
  end

  def remove_card(card)
    cards.delete(card)
  end

  def <=>(other)
    cards.total <=> other.cards.total
  end
end

game = Game.new

pry.start

require 'pry'

class Deck
  RANKS = ((2..10).to_a + %w[Jack Queen King Ace]).freeze
  SUITS = %w[Hearts Clubs Diamonds Spades].freeze

  def initialize
    reset
  end

  def shuffle
    cards.shuffle!
  end

  def draw
    reset if cards.empty?
    cards.pop
  end

  private

  attr_accessor :cards

  def generate_cards
    card_pile = []
    RANKS.each do |rank|
      SUITS.each do |suit|
        card_pile << Card.new(rank, suit)
      end
    end
    @cards = card_pile
  end

  def reset
    generate_cards
    shuffle
  end
end

class Card
  include Comparable
  attr_reader :rank, :suit

  SUIT_VALUES = { 'Jack' => 11, 'Queen' => 12, 'King' => 13, 'Ace' => 14 }.freeze

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def value
    SUIT_VALUES.fetch(rank, rank)
  end

  def <=>(other_card)
    value <=> other_card.value
  end

  def to_s
    "#{rank} of #{suit}"
  end
end

# Include Card and Deck classes from the last two exercises.

class PokerHand
  attr_reader :hand

  def initialize(deck)
    @hand = draw_hand_from_deck(deck)
  end

  def print
    puts hand
  end

  def evaluate
    case
    when royal_flush?     then 'Royal flush'
    when straight_flush?  then 'Straight flush'
    when four_of_a_kind?  then 'Four of a kind'
    when full_house?      then 'Full house'
    when flush?           then 'Flush'
    when straight?        then 'Straight'
    when three_of_a_kind? then 'Three of a kind'
    when two_pair?        then 'Two pair'
    when pair?            then 'Pair'
    else                       'High card'
    end
  end

  private

  def draw_hand_from_deck(deck)
    cards = []
    5.times { cards << deck.draw}
    cards
  end

  def royal_flush?
    all_royal_values? && flush?
  end

  def all_royal_values?
    values.sort == [10, 11, 12, 13, 14]
  end

  def straight_flush?
    straight? && flush?
  end

  def four_of_a_kind?
    x_of_a_kind?(4)
  end

  def full_house?
    x_of_a_kind?(3) && x_of_a_kind?(2)
  end

  def flush?
    suits.uniq.count == 1
  end

  def straight?
    tally.values.all?(1) && (values.min + 4 == values.max)
  end

  def three_of_a_kind?
    x_of_a_kind?(3)
  end

  def two_pair?
    tally.values.select {|count| count == 2}.size == 2
  end

  def pair?
    x_of_a_kind?(2)
  end

  def suits
    hand.each_with_object([]) { |card, list| list << card.suit }
  end

  def values
    hand.each_with_object([]) { |card, list| list << card.value }
  end

  def tally
    values.tally
  end

  def x_of_a_kind?(x)
    tally.one? { |_, count| count == x }
  end
end



# hand = PokerHand.new(Deck.new)
# hand.print
# puts hand.evaluate

# # Danger danger danger: monkey
# # patching for testing purposes.
class Array
  alias_method :draw, :pop
end

# # Test that we can identify each PokerHand type.
hand = PokerHand.new([
  Card.new(10,      'Hearts'),
  Card.new('Ace',   'Hearts'),
  Card.new('Queen', 'Hearts'),
  Card.new('King',  'Hearts'),
  Card.new('Jack',  'Hearts')
])
puts hand.evaluate == 'Royal flush'

hand = PokerHand.new([
  Card.new(8,       'Clubs'),
  Card.new(9,       'Clubs'),
  Card.new('Queen', 'Clubs'),
  Card.new(10,      'Clubs'),
  Card.new('Jack',  'Clubs')
])
puts hand.evaluate == 'Straight flush'

hand = PokerHand.new([
  Card.new(3, 'Hearts'),
  Card.new(3, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(3, 'Spades'),
  Card.new(3, 'Diamonds')
])
puts hand.evaluate == 'Four of a kind'

hand = PokerHand.new([
  Card.new(3, 'Hearts'),
  Card.new(3, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(3, 'Spades'),
  Card.new(5, 'Hearts')
])
puts hand.evaluate == 'Full house'

hand = PokerHand.new([
  Card.new(10, 'Hearts'),
  Card.new('Ace', 'Hearts'),
  Card.new(2, 'Hearts'),
  Card.new('King', 'Hearts'),
  Card.new(3, 'Hearts')
])
puts hand.evaluate == 'Flush'

hand = PokerHand.new([
  Card.new(8,      'Clubs'),
  Card.new(9,      'Diamonds'),
  Card.new(10,     'Clubs'),
  Card.new(7,      'Hearts'),
  Card.new('Jack', 'Clubs')
])
puts hand.evaluate == 'Straight'


hand = PokerHand.new([
  Card.new('Queen', 'Clubs'),
  Card.new('King',  'Diamonds'),
  Card.new(10,      'Clubs'),
  Card.new('Ace',   'Hearts'),
  Card.new('Jack',  'Clubs')
])
puts hand.evaluate == 'Straight'

hand = PokerHand.new([
  Card.new(3, 'Hearts'),
  Card.new(3, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(3, 'Spades'),
  Card.new(6, 'Diamonds')
])
puts hand.evaluate == 'Three of a kind'

hand = PokerHand.new([
  Card.new(9, 'Hearts'),
  Card.new(9, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(8, 'Spades'),
  Card.new(5, 'Hearts')
])
puts hand.evaluate == 'Two pair'

hand = PokerHand.new([
  Card.new(2, 'Hearts'),
  Card.new(9, 'Clubs'),
  Card.new(5, 'Diamonds'),
  Card.new(9, 'Spades'),
  Card.new(3, 'Diamonds')
])
puts hand.evaluate == 'Pair'

hand = PokerHand.new([
  Card.new(2,      'Hearts'),
  Card.new('King', 'Clubs'),
  Card.new(5,      'Diamonds'),
  Card.new(9,      'Spades'),
  Card.new(3,      'Diamonds')
])
puts hand.evaluate == 'High card'


=begin
How would you modify our original solution to choose the best hand between two poker hands?

How would you modify our original solution to choose the best 5-card hand from a
 7-card poker hand?

I could create a hash that ranks each classification by number. SO royal flush is 
highest ranking, and High Card is the lowest. ONce I have that ranking number, 
the two numbers could be compared using < > symbols. 
I would need to either define these < > == methods or include Comparable in the 
PokerHand class, and define the <=> method 

OUTCOME_RANKINGS = {
  'Royal Flush' = 1,
  'Straight Flush' = 2,
  ...
  
}

=end
# frozen_string_literal: true

# class Card
#   include Comparable
#   attr_reader :rank, :suit

#   SUIT_VALUES = { 'Jack'  => 11, 'Queen' => 12, 'King'  => 13, 'Ace'  => 14 }

#   def initialize(rank, suit)
#     @rank = rank
#     @suit = suit
#   end

#   def value
#     SUIT_VALUES.fetch(rank, rank)
#   end
#   def <=>(other_card)
#     value <=> other_card.value
#   end

#   def to_s
#     "#{rank} of #{suit}"
#   end
# end

# further exploration
# modify the Card class so that if two cards have the same rank, then they are
# ranked by suit instead
# spades => hearts => clubs => diamonds

class Card
  include Comparable
  attr_reader :rank, :suit

  RANK_VALUES = { 'Jack' => 11, 'Queen' => 12, 'King' => 13, 'Ace' => 14 }.freeze
  SUIT_VALUES = { 'Spades' => 4, 'Hearts' => 3, 'Clubs' => 2, 'Diamonds' => 1 }.freeze

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def rank_value
    RANK_VALUES.fetch(rank, rank)
  end

  def suit_value
    SUIT_VALUES[suit]
  end

  def <=>(other)
    if rank_value == other.rank_value
      suit_value <=> other.suit_value
    else
      rank_value <=> other.rank_value
    end
  end

  def to_s
    "#{rank} of #{suit}"
  end
end

cards = [Card.new(2, 'Hearts'),
         Card.new(10, 'Diamonds'),
         Card.new('Ace', 'Clubs')]
puts cards
puts cards.min == Card.new(2, 'Hearts')
puts cards.max == Card.new('Ace', 'Clubs')

cards = [Card.new(5, 'Hearts')]
puts cards.min == Card.new(5, 'Hearts')
puts cards.max == Card.new(5, 'Hearts')

cards = [Card.new(4, 'Hearts'),
         Card.new(4, 'Diamonds'),
         Card.new(10, 'Clubs')]
puts cards.min.rank == 4
puts cards.max == Card.new(10, 'Clubs')

cards = [Card.new(7, 'Diamonds'),
         Card.new('Jack', 'Diamonds'),
         Card.new('Jack', 'Spades')]
puts cards.min #== Card.new(7, 'Diamonds')
puts cards.max # .rank == 'Jack'

cards = [Card.new(8, 'Diamonds'),
         Card.new(8, 'Clubs'),
         Card.new(8, 'Spades'),
         Card.new(7, 'Spades')]
puts cards.min
# puts cards.min.rank == 8
# puts cards.max.rank == 8

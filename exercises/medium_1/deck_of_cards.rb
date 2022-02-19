# frozen_string_literal: true

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

deck = Deck.new
drawn = []
52.times { drawn << deck.draw }

p drawn.count { |card| card.rank == 5 } == 4
p drawn.count { |card| card.suit == 'Hearts' } == 13

drawn2 = []
52.times { drawn2 << deck.draw }
p drawn != drawn2 # Almost always.

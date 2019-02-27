require_relative './card.rb'

class Deck
  attr_reader :deck
  DECK = %w[A 2 3 4 5 6 7 8 9 10 J Q K].product(%w[S C D H]).freeze

  def initialize
    @deck = make_cards
    @deck.shuffle!
  end

  def deal(num_cards)
    raise(ArgumentError, 'not enough cards') if num_cards > @deck.length
    @deck.slice!((0...num_cards))
  end

  private

  def make_cards
    DECK.map { |value| Card.new(value) }
  end
end

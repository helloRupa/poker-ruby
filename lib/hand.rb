# The logic of calculating pair, three-of-a-kind, two-pair, etc. goes here.
# Logic of which hand beats which would go here.
require 'set'

class Hand
  def self.two_pair?(cards)
    sorted = cards.sort_by { |card| rank(card) }
    pair?(sorted[0..2]) && pair?(sorted[2..-1])
  end

  def self.full_house?(cards)
    three_of_a_kind?(cards) && pair?(cards)
  end

  def self.straight_flush?(cards)
    straight?(cards) && flush?(cards)
  end

  def self.high_card(cards)
    ranks = cards.map { |card| rank_card(cards, card) }.sort!
    ranks[-1]
  end

  def self.pair?(cards)
    cards.any? { |card| rank_match_count(cards, card) == 2 }
  end

  def self.three_of_a_kind?(cards)
    cards[0..2].any? { |card| rank_match_count(cards, card) == 3 }
  end

  def self.four_of_a_kind?(cards)
    ranks = cards.map { |card| rank(card) }
    ranks.to_set.length == 2
  end

  def self.flush?(cards)
    suits = cards.map { |card| suit(card) }
    suits.to_set.length == 1
  end

  def self.straight?(cards)
    ranks = cards.map { |card| rank_card(cards, card, true) }.sort!
    prev_rank = ranks[0]
    ranks.each_with_index do |rank, idx|
      next if idx == 0
      return false unless rank - 1 == prev_rank
      prev_rank = rank
    end
    true
  end

  def self.rank(card)
    card.value[0]
  end

  def self.suit(card)
    card.value[1]
  end

  def self.rank_match_count(cards, card_to_match)
    cards.count { |card| rank(card) == rank(card_to_match) }
  end

  # def self.suit_match_count(cards, card_to_match)
  #   cards.count { |card| suit(card) == suit(card_to_match) }
  # end

  def self.ace_rank(cards, straight_check)
    return cards.any? { |card| rank(card) == '2' } ? 1 : 14 if straight_check
    14
  end

  def self.rank_card(cards, card, straight_check = false)
    case rank(card)
    when 'J' then 11
    when 'Q' then 12
    when 'K' then 13
    when 'A' then ace_rank(cards, straight_check)
    else rank(card).to_i
    end
  end
end

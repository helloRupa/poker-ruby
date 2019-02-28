require 'rspec'
require 'hand'

describe 'Hand' do
  let(:card1) { double('card1', value: nil) }
  let(:card2) { double('card2', value: nil) }
  let(:card3) { double('card3', value: nil) }
  let(:card4) { double('card4', value: nil) }
  let(:card5) { double('card5', value: nil) }
  subject(:hand) { [card1, card2, card3, card4, card5] }

  def make_hand(card_values)
    hand.each_with_index { |card, idx| allow(card).to receive(:value) { card_values[idx] } }
  end

  describe '::four_of_a_kind?' do
    it 'returns true when a hand contains 4 of the same rank' do
      make_hand([%w[J S], %w[J D], %w[J C], %w[J H], %w[5 H]])
      expect(Hand.four_of_a_kind?(hand)).to be(true)
    end

    it 'returns false when not 4 of a kind' do
      make_hand([%w[K S], %w[J D], %w[J C], %w[J H], %w[5 H]])
      expect(Hand.four_of_a_kind?(hand)).to be(false)
    end

    it 'returns false when hand contains 4 of same suit' do
      make_hand([%w[K S], %w[J S], %w[10 S], %w[9 S], %w[5 H]])
      expect(Hand.four_of_a_kind?(hand)).to be(false)
    end
  end

  describe '::flush?' do
    it 'returns true when hand contains all cards of same suit' do
      make_hand([%w[K S], %w[J S], %w[10 S], %w[9 S], %w[5 S]])
      expect(Hand.flush?(hand)).to be(true)
    end

    it 'returns false when hand contains cards of different suits' do
      make_hand([%w[K D], %w[J S], %w[10 S], %w[9 S], %w[5 S]])
      expect(Hand.flush?(hand)).to be(false)
    end
  end

  describe '::straight?' do
    it 'returns true when all cards increase rank consecutively' do
      make_hand([%w[3 D], %w[5 S], %w[7 S], %w[6 S], %w[4 S]])
      expect(Hand.straight?(hand)).to be(true)
    end

    it 'returns true when Ace is used as low card' do
      make_hand([%w[3 D], %w[5 S], %w[A S], %w[2 S], %w[4 S]])
      expect(Hand.straight?(hand)).to be(true)
    end

    it 'returns true when Ace is used as high card' do
      make_hand([%w[J D], %w[Q S], %w[K S], %w[A S], %w[10 S]])
      expect(Hand.straight?(hand)).to be(true)
    end

    it 'returns false when Ace is used between high and low cards' do
      make_hand([%w[J D], %w[Q S], %w[K S], %w[A S], %w[2 S]])
      expect(Hand.straight?(hand)).to be(false)
    end

    it 'returns false when cards are not consecutive ranks' do
      make_hand([%w[2 D], %w[5 S], %w[K S], %w[A S], %w[2 S]])
      expect(Hand.straight?(hand)).to be(false)
    end
  end

  describe '::three_of_a_kind?' do
    it 'returns true when hand contains 3 cards of same rank' do
      make_hand([%w[2 D], %w[2 S], %w[K S], %w[2 C], %w[3 D]])
      expect(Hand.three_of_a_kind?(hand)).to be(true)
    end

    it 'returns false when hand does not contain 3 cards of same rank' do
      make_hand([%w[2 D], %w[4 S], %w[K S], %w[2 C], %w[3 S]])
      expect(Hand.three_of_a_kind?(hand)).to be(false)
    end

    it 'returns false when hand contains > 3 cards of same rank' do
      make_hand([%w[2 D], %w[2 S], %w[K S], %w[2 C], %w[2 H]])
      expect(Hand.three_of_a_kind?(hand)).to be(false)
    end
  end

  describe '::pair?' do
    it 'returns true when hand contains pair of same rank' do
      make_hand([%w[2 D], %w[2 S], %w[K S], %w[5 C], %w[8 H]])
      expect(Hand.pair?(hand)).to be(true)
    end

    it 'returns false when there are no pairs of same rank' do
      make_hand([%w[2 D], %w[A S], %w[K S], %w[5 C], %w[8 H]])
      expect(Hand.pair?(hand)).to be(false)
    end

    it 'returns false when there is only a pair of matching suits' do
      make_hand([%w[2 D], %w[A S], %w[K S], %w[5 C], %w[8 H]])
      expect(Hand.pair?(hand)).to be(false)
    end
  end

  describe '::high_card' do
    it 'returns the highest ranking card rank as an integer' do
      make_hand([%w[2 D], %w[8 S], %w[K S], %w[5 C], %w[8 H]])
      expect(Hand.high_card(hand)).to eq(13)
    end

    it 'returns ace value when ace is highest' do
      make_hand([%w[2 D], %w[A S], %w[K S], %w[5 C], %w[8 H]])
      expect(Hand.high_card(hand)).to eq(14)
    end
  end

  describe '::straight_flush?' do
    it 'returns true when hand is both a straight and flush' do
      make_hand([%w[2 D], %w[3 D], %w[4 D], %w[5 D], %w[6 D]])
      expect(Hand.straight_flush?(hand)).to be(true)
    end

    it 'returns false when hand is only a flush' do
      make_hand([%w[10 D], %w[3 D], %w[4 D], %w[5 D], %w[6 D]])
      expect(Hand.straight_flush?(hand)).to be(false)
    end

    it 'returns false when hand is only a straight' do
      make_hand([%w[2 D], %w[3 D], %w[4 D], %w[5 D], %w[6 H]])
      expect(Hand.straight_flush?(hand)).to be(false)
    end
  end

  describe '::full_house?' do
    it 'returns true when hand has 3 of a kind and pair' do
      make_hand([%w[2 D], %w[2 S], %w[2 C], %w[5 D], %w[5 H]])
      expect(Hand.full_house?(hand)).to be(true)
    end

    it 'returns false when hand is only 3 of a kind' do
      make_hand([%w[10 D], %w[10 C], %w[10 S], %w[5 D], %w[6 D]])
      expect(Hand.full_house?(hand)).to be(false)
    end

    it 'returns false when hand is only a pair' do
      make_hand([%w[2 D], %w[2 H], %w[4 D], %w[5 D], %w[6 H]])
      expect(Hand.full_house?(hand)).to be(false)
    end
  end

  describe '::two_pair?' do
    it 'does not count the same pair twice' do
      make_hand([%w[2 D], %w[2 H], %w[4 D], %w[5 D], %w[6 H]])
      expect(Hand.two_pair?(hand)).to be(false)
    end

    it 'detects 2 distinct pairs' do
      make_hand([%w[2 D], %w[2 H], %w[4 D], %w[4 H], %w[6 H]])
      expect(Hand.two_pair?(hand)).to be(true)
    end

    it 'detects 2 distinct pairs when cards are out of order' do
      make_hand([%w[2 D], %w[3 H], %w[4 D], %w[2 H], %w[4 H]])
      expect(Hand.two_pair?(hand)).to be(true)
    end
  end
end

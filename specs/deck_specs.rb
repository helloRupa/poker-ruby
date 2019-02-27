require 'rspec'
require 'deck'

describe 'Deck' do
  subject(:deck) { Deck.new }
  let(:card_types) { %w[A 2 3 4 5 6 7 8 9 10 J Q K].product(%w[S C D H]) }

  describe '#initialize' do
    it 'creates a readable array deck' do
      expect(deck.deck).to be_an_instance_of(Array)
    end

    it 'creates an array deck of 52 cards' do
      expect(deck.deck.length).to eq(52)
    end

    let(:all_cards?) { deck.deck.all? { |card| card.is_a?(Card) } }
    it 'creates a deck of Cards' do
      expect(all_cards?).to be(true)
    end

    let(:valid_vals?) { deck.deck.all? { |card| card_types.include?(card.value) } }
    it 'creates a deck w/ only valid card types' do
      expect(valid_vals?).to be(true)
    end

    let(:shuffled?) { deck.deck.map(&:value) != card_types }
    it 'shuffles the cards' do
      expect(shuffled?).to be(true)
    end
  end

  describe '#deal' do
    it 'deals the specified number of cards' do
      expect(deck.deal(5).length).to eq(5)
    end

    it 'removes cards from the deck' do
      deck.deal(5)
      expect(deck.deck.length).to eq(47)
    end

    it 'allows all remaining cards to be dealt' do
      deck.deal(52)
      expect(deck.deck.length).to eq(0)
    end

    it 'raises ArgumentError if cards requested > cards left' do
      expect { deck.deal(58) }.to raise_error(ArgumentError, 'not enough cards')
    end
  end
end

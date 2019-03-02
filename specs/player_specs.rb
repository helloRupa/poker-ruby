require 'rspec'
require 'player'

describe 'Player' do
  subject(:p1) { Player.new('p1', 100, %w[2S 5D KH QS JC]) }

  describe '#initialize' do
    it 'sets the player name' do
      expect(p1.name).to eq('p1')
    end

    it 'sets the value of the purse' do
      expect(p1.purse).to eq(100)
    end

    it 'gives the player cards' do
      expect(p1.cards).to eq(%w[2S 5D KH QS JC])
    end

    it 'tracks the last pot payment the player made' do
      expect(p1.last_payment).to eq(0)
    end
  end

  describe '#bank' do
    it 'adds money to the purse' do
      p1.bank(100)
      expect(p1.purse).to eq(200)
    end

    it 'subtracts money from the purse' do
      p1.bank(-50)
      expect(p1.purse).to eq(50)
    end

    context 'when the amount subtracted is more than the purse' do
      it 'raises an ArgumentError' do
        expect { p1.bank(-200) }.to raise_error(ArgumentError, 'not enough money')
      end
    end
  end

  describe '#replace_cards' do
    it 'removes the correct cards' do
      p1.replace_cards([0, 1, 3], %w[10S JC 8D])
      expect(p1.cards.include?('2S')).to be(false)
      expect(p1.cards.include?('5D')).to be(false)
      expect(p1.cards.include?('QS')).to be(false)
    end

    it 'adds the new cards to the cards remaining' do
      p1.replace_cards([0, 1, 3], %w[10S JC 8D])
      expect(p1.cards).to eq(%w[KH JC 10S JC 8D])
    end

    it 'raises an ArgumentError if you add too many cards' do
      expect { p1.replace_cards([0], %w[10S 8D]) }.to raise_error(ArgumentError)
    end
  end

  describe '#input_call' do
    it 'allows a player to call' do
      allow(p1).to receive(:call_choice) { 'call' }
      expect(p1.input_call).to eq('call')
    end
  end

  describe '#input_raise' do
    it 'allows a player to call' do
      allow(p1).to receive(:raise_answer) { 20 }
      expect(p1.input_raise).to eq(20)
    end
  end

  describe '#input_cards_discard' do
    it 'allows a player to call' do
      allow(p1).to receive(:replace_choice) { [0, 2] }
      expect(p1.input_cards_discard).to eq([0, 2])
    end
  end
end

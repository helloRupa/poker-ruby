require 'rspec'
require 'card'

describe 'Card' do
  subject(:card) { Card.new(%w[2 D]) }
  
  describe '#initialize(value)' do
    it 'sets the readable card value' do
      expect(card.value).to eq(%w[2 D])
    end
  end

  context 'when using a card' do
    it 'does not allow value to be changed' do
      expect { card.value = '5H' }.to raise_error(NameError)
    end
  end

  describe '#to_s' do
    it 'returns a printable card value' do
      expect(card.to_s).to eq('2D')
    end
  end
end

require 'rspec'
require 'game'

# make attrs accessible for testing purposes only
class Game
  attr_accessor :players, :deck, :pot, :folded_players, :current_bet, :last_to_raise
end

describe 'Game' do
  subject(:game) { Game.new([['aaron', 500], ['baz', 500], ['cowbeans', 500]]) }
  let(:p1) { double('Player', name: 'p1', purse: 500, last_payment: 0, cards: %w[as ah ac ad 2s]) }
  let(:p2) { double('Player', name: 'p2', purse: 500, last_payment: 0, cards: %w[9s ah ac ad 2s]) }
  let(:p3) { double('Player', name: 'p3', purse: 500, last_payment: 0, cards: %w[7s ah ac ad 2s]) }

  describe '#initialize' do
    it 'creates a deck of cards' do
      expect(game.deck).to be_an_instance_of(Deck)
    end

    it 'sets the pot to 0' do
      expect(game.pot).to eq(0)
    end

    it 'creates an array of players' do
      expect(game.players).to be_an_instance_of(Array)
      expect(game.players[0]).to be_an_instance_of(Player)
    end

    it 'tracks folded players' do
      expect(game.folded_players).to eq([])
    end

    it 'tracks the current bet' do
      expect(game.current_bet).to eq(10)
    end

    it 'tracks the last player to raise' do
      expect(game.last_to_raise).to eq(nil)
    end
  end

  describe '#bet_round' do
    before(:each) do
      pay = [0, 0]
      game.players = [p1, p2]
      game.players.each_with_index do |p, idx|
        allow(p).to receive(:bank)
        allow(p).to receive(:last_payment=) do |amount|
          allow(p).to receive(:last_payment) { pay[idx] + amount }
        end
      end
    end

    context 'when all players see the first bet' do
      before(:each) do
        game.players.each do |p|
          allow(p).to receive(:input_call) { 'see' }
        end
        game.bet_round
      end

      it 'puts the correct amount of money in the pot' do
        expect(game.pot).to eq(game.current_bet * 2)
      end

      it 'subtracts money from the player purse' do
        expect(p1).to receive(:bank).with(-game.current_bet)
        game.bet_round
      end

      it 'does not fold the player if they have enough money' do
        expect(game.folded_players).to eq([])
      end

      it 'folds the player when they do not have enough money' do
        game.current_bet = 600
        game.bet_round
        expect(game.folded_players).to eq([p1])
      end

      it 'resets betting data' do
        expect(p1).to receive(:last_payment=).with(0)
        expect(p2).to receive(:last_payment=).with(0)
        game.bet_round
      end
    end

    context 'when a player folds' do
      before(:each) do
        allow(p1).to receive(:input_call) { 'see' }
        allow(p2).to receive(:input_call) { 'fold' }
        game.bet_round
      end

      it 'adds the player to folded_players' do
        expect(game.folded_players).to eq([p2])
      end

      it 'does not take their money' do
        expect(p2).to_not receive(:bank)
        game.bet_round
      end
    end

    context 'when player raises' do
      before(:each) do
        allow(p1).to receive(:input_call) { 'raise' }
        allow(p1).to receive(:input_raise) { 10 }
        allow(p2).to receive(:input_call) { 'see' }
      end

      it 'subtracts the correct amount from the player purse' do
        expect(p1).to receive(:bank).with(-(game.current_bet - p1.last_payment))
        expect(p2).to receive(:bank).with(-game.current_bet - 10)
        game.bet_round
      end

      it 'adds the correct amount to the pot' do
        game.bet_round
        expect(game.pot).to eq((game.current_bet + 10) * 2)
      end

      it 'adds the correct amount to the pot after two rounds' do
        game.bet_round
        allow(p1).to receive(:input_call) { 'see' }
        allow(p2).to receive(:input_call) { 'raise' }
        allow(p2).to receive(:input_raise) { 20 }
        game.bet_round
        expect(game.pot).to eq(100)
      end
    end
  end

  describe '#replace_round' do
    before(:each) do
      game.players = [p1]
    end

    it 'calls input_cards_discard on player' do
      allow(p1).to receive(:input_cards_discard) { 'none' }
      expect(p1).to receive(:input_cards_discard)
      game.replace_round
    end

    it 'does not replace any cards when the player chooses none' do
      allow(p1).to receive(:input_cards_discard) { 'none' }
      expect(p1).to_not receive(:replace_cards)
      game.replace_round
    end

    it 'replaces the selected cards' do
      final_cards = p1.cards
      allow(p1).to receive(:input_cards_discard) { [0, 1, 2] }
      expect(p1).to receive(:replace_cards).with([0, 1, 2], instance_of(Array)) do |choices, cards|
        final_cards = p1.cards[3..-1].concat(choices)
      end
      game.replace_round
      expect(final_cards).to_not eq(p1.cards)
    end
  end

  describe '#run' do
    def empty_hand
      Array.new(5).map { |_card| double('card', value: nil) }
    end

    def make_hand(hand, card_values)
      hand.each_with_index { |card, idx| allow(card).to receive(:value) { card_values[idx] } }
    end

    def fill_hands(players, hands_arr)
      players.each_with_index do |player, idx|
        allow(player).to receive(:cards) { make_hand(empty_hand, hands_arr[idx]) }
      end
    end

    it 'awards the pot to the winner' do
      hand1 = [%w[2 D], %w[3 D], %w[4 D], %w[5 D], %w[6 D]]
      hand2 = [%w[3 D], %w[5 S], %w[7 S], %w[6 S], %w[4 S]]
      game.players = [p1, p2, p3]
      game.players.each do |p|
        allow(p).to receive(:bank)
        allow(p).to receive(:last_payment=)
        allow(p).to receive(:input_call) { 'see' }
        allow(p).to receive(:input_cards_discard) { 'none' }
        allow(p).to receive(:replace_cards)
      end
      fill_hands(game.players, [hand1, hand2, hand2])
      expect(p1).to receive(:bank).with(60)
      game.run
    end
  end
end

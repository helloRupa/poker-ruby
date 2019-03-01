require 'rspec'
require 'hand'

describe 'Hand' do
  subject(:hand) { empty_hand }

  def empty_hand
    Array.new(5).map { |_card| double('card', value: nil) }
  end

  def make_hand(hand, card_values)
    hand.each_with_index { |card, idx| allow(card).to receive(:value) { card_values[idx] } }
  end

  describe '::winning_hand' do
    let(:straight_flush_low) { [%w[2 D], %w[3 D], %w[4 D], %w[5 D], %w[6 D]] }
    let(:straight_flush_high) { [%w[10 D], %w[J D], %w[Q D], %w[K D], %w[A D]] }
    let(:four_kind_low) { [%w[10 S], %w[10 D], %w[10 C], %w[10 H], %w[5 H]] }
    let(:four_kind_high) { [%w[J S], %w[J D], %w[J C], %w[J H], %w[6 H]] }
    let(:full_house_high) { [%w[K D], %w[K S], %w[K C], %w[5 D], %w[5 H]] }
    let(:full_house_low) { [%w[10 D], %w[10 S], %w[10 C], %w[5 D], %w[5 H]] }
    let(:straight) { [%w[3 D], %w[5 S], %w[7 S], %w[6 S], %w[4 S]] }
    let(:two_pair) { [%w[2 D], %w[3 H], %w[4 D], %w[2 H], %w[4 H]] }
    subject(:players) { %w[p1 p2 p3].map { |name| double(name, name: name) } }

    def fill_players(hands_arr)
      players.each_with_index do |player, idx|
        allow(player).to receive(:cards) { make_hand(empty_hand, hands_arr[idx]) }
      end
    end

    it 'chooses the highest combination as the winner' do
      fill_players([straight_flush_low, two_pair, straight])
      expect(Hand.winning_hand(players)).to eq(winners: [players[0]], hand: 'straight flush')
    end

    context 'when > 1 player w/ straight flush' do
      it 'chooses the highest rank' do
        fill_players([straight_flush_low, straight_flush_high, straight])
        expect(Hand.winning_hand(players)).to eq(winners: [players[1]], hand: 'straight flush')
      end

      it 'detects a full-on tie' do
        fill_players([straight_flush_low, straight_flush_high, straight_flush_high])
        expect(Hand.winning_hand(players)).to eq(winners: [players[1], players[2]], hand: 'straight flush')
      end
    end

    context 'when > 1 four of a kind' do
      it 'chooses the highest rank based on the matching 4' do
        fill_players([four_kind_low, four_kind_high, straight])
        expect(Hand.winning_hand(players)).to eq(winners: [players[1]], hand: 'four of a kind')
      end

      let(:kicker) { [%w[J S], %w[J D], %w[J C], %w[J H], %w[5 H]] }
      it 'chooses highest kicker when matching 4 tie' do
        fill_players([kicker, four_kind_high, straight])
        expect(Hand.winning_hand(players)).to eq(winners: [players[1]], hand: 'four of a kind')
      end

      it 'detects a full-on tie' do
        fill_players([four_kind_low, four_kind_high, four_kind_high])
        expect(Hand.winning_hand(players)).to eq(winners: [players[1], players[2]], hand: 'four of a kind')
      end
    end

    context 'when > 1 full house' do
      it 'chooses highest ranking triplet' do
        fill_players([full_house_low, straight, full_house_high])
        expect(Hand.winning_hand(players)).to eq(winners: [players[2]], hand: 'full house')
      end

      let(:full_house_pair) { [%w[10 D], %w[10 S], %w[10 C], %w[K D], %w[K H]] }
      it 'chooses highest ranking pair when triplets are equal rank' do
        fill_players([full_house_low, straight, full_house_pair])
        expect(Hand.winning_hand(players)).to eq(winners: [players[2]], hand: 'full house')
      end

      it 'detects a full-on tie' do
        fill_players([full_house_high, straight, full_house_high])
        expect(Hand.winning_hand(players)).to eq(winners: [players[0], players[2]], hand: 'full house')
      end
    end

    context 'when > 1 flush' do
      let(:flush_high) { [%w[K S], %w[J S], %w[10 S], %w[9 S], %w[5 S]] }
      let(:flush_almost_high) { [%w[K S], %w[J S], %w[10 S], %w[9 S], %w[4 S]] }
      let(:flush_med) { [%w[J S], %w[10 S], %w[8 S], %w[9 S], %w[5 S]] }
      let(:flush_low) { [%w[2 S], %w[3 S], %w[4 S], %w[7 S], %w[5 S]] }

      it 'chooses highest ranking flush' do
        fill_players([flush_low, flush_med, flush_high])
        expect(Hand.winning_hand(players)).to eq(winners: [players[2]], hand: 'flush')
      end

      it 'considers all cards when necessary' do
        fill_players([flush_low, flush_high, flush_almost_high])
        expect(Hand.winning_hand(players)).to eq(winners: [players[1]], hand: 'flush')
      end

      it 'detects a full-on tie' do
        fill_players([flush_low, flush_med, flush_med])
        expect(Hand.winning_hand(players)).to eq(winners: [players[1], players[2]], hand: 'flush')
      end
    end

    context 'when > 1 straight' do
      let(:straight_low) { [%w[3 D], %w[5 S], %w[2 S], %w[6 H], %w[4 S]] }
      let(:straight_high) { [%w[8 D], %w[5 S], %w[7 C], %w[6 S], %w[4 S]] }

      it 'chooses highest ranking hand' do
        fill_players([straight_low, straight, straight_high])
        expect(Hand.winning_hand(players)).to eq(winners: [players[2]], hand: 'straight')
      end

      it 'detects a full-on tie' do
        fill_players([straight_low, straight, straight])
        expect(Hand.winning_hand(players)).to eq(winners: [players[1], players[2]], hand: 'straight')
      end
    end

    context 'when > 1 three of a kind' do
      let(:three_kind_low) { [%w[3 D], %w[5 S], %w[3 S], %w[3 H], %w[4 S]] }
      let(:three_kind_high) { [%w[8 D], %w[8 S], %w[8 C], %w[6 S], %w[4 S]] }
      let(:three_kind_med) { [%w[3 D], %w[6 S], %w[3 S], %w[3 H], %w[4 S]] }

      it 'chooses highest ranking triplet' do
        fill_players([three_kind_low, three_kind_med, three_kind_high])
        expect(Hand.winning_hand(players)).to eq(winners: [players[2]], hand: 'three of a kind')
      end

      it 'chooses highest ranking first kicker for triplet tie' do
        fill_players([three_kind_low, three_kind_low, three_kind_med])
        expect(Hand.winning_hand(players)).to eq(winners: [players[2]], hand: 'three of a kind')
      end

      let(:kicker) { [%w[3 D], %w[2 H], %w[3 S], %w[3 H], %w[5 S]] }
      it 'chooses highest ranking 2nd kicker for 1st kicker tie' do
        fill_players([three_kind_low, kicker, kicker])
        expect(Hand.winning_hand(players)).to eq(winners: [players[0]], hand: 'three of a kind')
      end

      it 'detects a full-on tie' do
        fill_players([three_kind_low, three_kind_med, three_kind_med])
        expect(Hand.winning_hand(players)).to eq(winners: [players[1], players[2]], hand: 'three of a kind')
      end
    end

    context 'when > 1 two pair' do
      let(:two_pair_low) { [%w[3 D], %w[3 H], %w[2 D], %w[2 H], %w[4 H]] }
      let(:two_pair_high) { [%w[10 D], %w[10 H], %w[7 D], %w[7 H], %w[4 H]] }
      it 'chooses highest ranking pair' do
        fill_players([two_pair, two_pair_low, two_pair_high])
        expect(Hand.winning_hand(players)).to eq(winners: [players[2]], hand: 'two pair')
      end

      let(:two_pair_med) { [%w[10 D], %w[10 H], %w[6 D], %w[6 H], %w[4 H]] }
      it 'chooses highest ranking lower pair when highest pairs tie' do
        fill_players([two_pair_high, two_pair_low, two_pair_med])
        expect(Hand.winning_hand(players)).to eq(winners: [players[0]], hand: 'two pair')
      end

      let(:kicker) { [%w[10 D], %w[10 H], %w[7 D], %w[7 H], %w[3 H]] }
      it 'chooses highest ranking kicker when both pairs tie' do
        fill_players([two_pair_high, kicker, two_pair_med])
        expect(Hand.winning_hand(players)).to eq(winners: [players[0]], hand: 'two pair')
      end

      it 'detects a full-on tie' do
        fill_players([two_pair_high, two_pair_high, two_pair_low])
        expect(Hand.winning_hand(players)).to eq(winners: [players[0], players[1]], hand: 'two pair')
      end
    end

    context 'when > 1 pair' do
      let(:pair_low) { [%w[3 D], %w[3 H], %w[6 D], %w[5 H], %w[4 H]] }
      let(:pair_med) { [%w[7 D], %w[7 H], %w[6 D], %w[3 H], %w[2 H]] }
      let(:pair_high) { [%w[A D], %w[A H], %w[7 D], %w[5 H], %w[3 H]] }

      it 'chooses highest ranking pair' do
        fill_players([pair_med, pair_low, pair_high])
        expect(Hand.winning_hand(players)).to eq(winners: [players[2]], hand: 'pair')
      end

      let(:kicker) { [%w[A D], %w[A H], %w[7 D], %w[4 H], %w[3 H]] }
      it 'chooses highest ranking kicker when pairs tie' do
        fill_players([pair_high, kicker, pair_med])
        expect(Hand.winning_hand(players)).to eq(winners: [players[0]], hand: 'pair')
      end

      it 'detects a full-on tie' do
        fill_players([pair_high, pair_high, pair_low])
        expect(Hand.winning_hand(players)).to eq(winners: [players[0], players[1]], hand: 'pair')
      end
    end

    context 'high card' do
      let(:high_low) { [%w[2 D], %w[5 H], %w[6 D], %w[8 H], %w[9 H]] }
      let(:high_med) { [%w[3 D], %w[5 H], %w[7 D], %w[9 H], %w[10 H]] }
      let(:high_high) { [%w[6 D], %w[8 H], %w[10 D], %w[Q H], %w[A H]] }

      it 'chooses highest ranking hand' do
        fill_players([high_med, high_low, high_high])
        expect(Hand.winning_hand(players)).to eq(winners: [players[2]], hand: 'high card')
      end

      let(:kicker) { [%w[5 D], %w[8 H], %w[10 D], %w[Q H], %w[A H]] }
      it 'chooses highest ranking when some high cards match' do
        fill_players([kicker, high_high, high_med])
        expect(Hand.winning_hand(players)).to eq(winners: [players[1]], hand: 'high card')
      end

      it 'detects a full-on tie' do
        fill_players([high_high, high_high, high_low])
        expect(Hand.winning_hand(players)).to eq(winners: [players[0], players[1]], hand: 'high card')
      end
    end
  end
end

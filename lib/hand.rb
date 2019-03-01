# The logic of calculating pair, three-of-a-kind, two-pair, etc. goes here.
# Logic of which hand beats which

class Hand
  TESTS = %w[straight_flush? four_of_a_kind? full_house? flush? straight? three_of_a_kind? two_pair? pair?].freeze
  RANKS = { 'A' => 14, 'K' => 13, 'Q' => 12, 'J' => 11, '10' => 10, '9' => 9,
            '8' => 8, '7' => 7, '6' => 6, '5' => 5, '4' => 4, '3' => 3, '2' => 2 }.freeze

  private_class_method :new

  def self.winning_hand(players)
    hand = new(players)
    hand.highest_hand
  end

  def highest_hand
    return @win_data if @win_data[:winners].length == 1

    @poss_winners = @win_data[:winners]
    hand_type = @win_data[:hand]
    { winners: get_winners(hand_type), hand: hand_type }
  end

  private

  def initialize(players)
    @win_data = results(players)
  end

  def get_winners(hand_type)
    case hand_type
    when 'straight flush', 'straight' then straight_rank
    when 'flush', 'high card' then high_rank
    when 'four of a kind' then of_kind_ranks(4)
    when 'three of a kind' then of_kind_ranks(3)
    when 'pair' then of_kind_ranks(2)
    when 'full house' then full_house_rank
    when 'two pair' then two_pair_rank
    end
  end

  def full_house_rank
    winners = of_kind_ranks(3)
    return winners if winners.length == 1
    of_kind_ranks(2)
  end

  def of_kind_ranks(kind_num)
    ranked_hands = make_p_data
    ranked_hands.map! { |p_data| [p_data[0], kind_kickers(p_data[1], kind_num)] }
    winner_by_rank(ranked_hands)
  end

  def kind_kickers(ranked, num)
    copy = ranked.dup
    of_kind = copy.select { |rank| copy.count(rank) == num }[0]
    copy.delete(of_kind)
    [of_kind] + copy
  end

  def high_rank
    ranked_hands = make_p_data
    winner_by_rank(ranked_hands)
  end

  def winner_by_rank(ranked_hands)
    len = ranked_hands[0][1].length
    idx = 0

    while idx < len && ranked_hands.length != 1
      max_rank = ranked_hands.max_by { |p_data| p_data[1][idx] }[1][idx]
      ranked_hands.select! { |p_data| p_data[1][idx] == max_rank }
      idx += 1
    end

    ranked_hands.map { |p_data| p_data[0] }
  end

  def straight_rank
    # disregard ace, so compare 2nd highest card in each hand instead
    ranked_hands = make_p_data
    max_rank = ranked_hands.max_by { |p_data| p_data[1][1] }[1][1]
    ranked_hands.each_with_object([]) do |p_data, winners|
      winners << p_data[0] if p_data[1][1] == max_rank
    end
  end

  def two_pair_rank
    ranked_hands = make_p_data.map! { |p_data| [p_data[0], two_pair_ranks(p_data[1].dup)] }
    winner_by_rank(ranked_hands)
  end

  def two_pair_ranks(cards)
    pair1 = cards[0..2].select { |card| cards.count(card) == 2 }[0]
    pair2 = cards[2..-1].select { |card| cards.count(card) == 2 }[0]
    cards.reject! { |card| [pair1, pair2].include?(card) }
    [pair1, pair2].sort.reverse + cards
  end

  def results(players)
    TESTS.each do |method|
      poss_winners = players.select { |player| send(method, player.cards) }
      return { winners: poss_winners, hand: hand_name(method) } unless poss_winners.empty?
    end
    { winners: players, hand: 'high card' }
  end

  def hand_name(method_name)
    method_name.delete('?').gsub('_', ' ')
  end

  def make_p_data
    @poss_winners.map { |player| [player, sorted_num_ranks(player.cards)] }
  end

  def straight_flush?(cards)
    straight?(cards) && flush?(cards)
  end

  def four_of_a_kind?(cards)
    ranked = all_ranks(cards)
    of_a_kind?(ranked, 4)
  end

  def full_house?(cards)
    ranked = all_ranks(cards)
    of_a_kind?(ranked, 3) && of_a_kind?(ranked, 2)
  end

  def flush?(cards)
    s = suit(cards[0])
    cards.all? { |card| s == suit(card) }
  end

  def straight?(cards)
    ranked = sorted_num_ranks(cards)
    return false unless ranked.uniq.length == 5
    ranked = handle_ace(ranked)
    ranked[0] - ranked[-1] == 4
  end

  def three_of_a_kind?(cards)
    ranked = all_ranks(cards)
    of_a_kind?(ranked, 3)
  end

  def two_pair?(cards)
    ranked = sorted_num_ranks(cards)
    of_a_kind?(ranked[0..2], 2) && of_a_kind?(ranked[2..-1], 2)
  end

  def pair?(cards)
    ranked = all_ranks(cards)
    of_a_kind?(ranked, 2)
  end

  def of_a_kind?(ranked, num)
    ranked.any? { |card_val| ranked.count(card_val) == num }
  end

  def suit(card)
    card.value[1]
  end

  def rank(card)
    card.value[0]
  end

  def all_ranks(cards)
    cards.map { |card| rank(card) }
  end

  def sorted_num_ranks(cards)
    ranked = all_ranks(cards).map { |value| RANKS[value] }
    ranked.sort.reverse
  end

  def handle_ace(ranked)
    return ranked unless ranked.include?(14) && ranked.include?(2)
    ranked[1..-1] + [1]
  end
end

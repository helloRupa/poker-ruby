require_relative './player.rb'
require_relative './deck.rb'
require_relative './hand.rb'

class Game
  PLAYERS_MIN = 2
  PLAYERS_MAX = 5
  CARD_NUM = 5
  STARTING_BET = 10
  REPLACE_MAX = 3

  def initialize(players)
    @deck = Deck.new
    @pot = 0
    @players = make_players(players)
    @folded_players = []
    @current_bet = STARTING_BET
    @last_to_raise = nil
    @winners = []
  end

  def run
    welcome_msg
    loop do
      round
      reveal_round
      display_winners
      award_pot
      reset_run
      break unless funded? && play_again?
    end
    puts 'Not enough players have money to play again!' unless funded?
    puts 'Goodbye!'
  end

  def round
    bet_round
    return if one_player?
    replace_round
    bet_round
  end

  def bet_round
    first_round = true
    until @last_to_raise.nil? && !first_round
      place_bets(first_round)
      first_round = false
    end
    show_pot
    puts
    reset_bet_data
  end

  def replace_round
    @players.each do |player|
      next if folded?(player)
      show_cards(player)
      player_choice(player)
    end
  end

  def reveal_round
    @players.each do |player|
      next if folded?(player)
      show_cards(player)
    end
  end

  private

  def welcome_msg
    puts 'Welcome to Poker.'
    puts 'You can replace up to 3 of your cards in a round of play. Just select their indexes.'
    sleep(2)
  end

  def game_min
    STARTING_BET * 2
  end

  def reset_run
    @folded_players = []
    @deck = Deck.new
    @players.each do |player|
      next if player.purse < game_min
      player.replace_cards([0, 1, 2, 3, 4], @deck.deal(CARD_NUM))
    end
  end

  def funded?
    @players.select { |player| player.purse >= game_min }.length > 1
  end

  def play_again?
    puts
    puts 'Would you like to play again? (Y/N):'
    print '> '
    answer = gets.chomp.downcase
    puts
    %w[y yes yeah ok yea yah ya].include?(answer)
  end

  def award_pot
    amount = @pot / @winners.length
    @winners.each { |winner| winner.bank(amount) }
    @pot = 0
  end

  def display_winners
    win_data = Hand.winning_hand(unfolded_players)
    puts "Winning Hand: #{win_data[:hand]}"
    puts "Winner(s): #{win_data[:winners].map(&:name).join(', ')}"
    @winners = win_data[:winners]
  end

  def unfolded_players
    @players.reject { |player| folded?(player) }
  end

  def show_cards(player)
    puts "#{player.name}: #{player.cards.join(' ')}"
  end

  def folded?(player)
    @folded_players.include?(player)
  end

  def player_choice(player)
    choice = player.input_cards_discard
    return if choice == 'none'
    raise(ArgumentError, 'Choose 3 cards maximum!') unless choice.is_a?(Array) && 
                                                      choice.length <= REPLACE_MAX
    player.replace_cards(choice, @deck.deal(choice.length))
    show_cards(player)
    puts
  rescue ArgumentError => err
    puts err
    puts
    retry
  end

  def show_pot
    puts
    puts "Pot: #{@pot}"
  end

  def place_bets(first_round)
    @players.each do |player|
      last_to_raise_check(player)
      break if (@last_to_raise.nil? && !first_round) || one_player?
      display_bet_data(player)
      fold(player) if [amount_owed(player), @current_bet].any? { |amount| amount > player.purse }
      next if folded?(player)
      show_cards(player)
      bet_turn(player)
    end
  end

  def amount_owed(player)
    @current_bet - player.last_payment
  end

  def see(player)
    amount = amount_owed(player)
    player.bank(-amount)
    @pot += amount
    player.last_payment += amount
    # p "#{player.name}: last = #{player.last_payment}, amount = #{amount}"
  end

  def fold(player)
    @folded_players << player
    puts "#{player.name} folds!"
  end

  def call_raise(player)
    see(player)
    begin
      amount = player.input_raise
      @current_bet += amount
      see(player)
    rescue ArgumentError => err
      puts err
      @current_bet -= amount
      retry
    end
    @last_to_raise = player if amount > 0
  end

  def last_to_raise_check(player)
    return unless player == @last_to_raise
    @last_to_raise = nil
  end

  def bet_turn(player)
    response = player.input_call
    case response
    when 'see' then see(player)
    when 'fold' then fold(player)
    when 'raise' then call_raise(player)
    else raise(ArgumentError, 'Invalid option. Please try again (see, raise, fold)')
    end
  rescue ArgumentError => err
    puts err
    retry
  end

  def one_player?
    @folded_players.length == @players.length - 1
  end

  def display_bet_data(player)
    puts
    puts "Pot: #{@pot}"
    puts "Current bet: #{@current_bet}"
    puts "#{player.name} purse: #{player.purse}"
    puts
  end

  def reset_bet_data
    @current_bet = STARTING_BET
    @players.each { |player| player.last_payment = 0 }
  end

  def make_players(players)
    bad_player_num(players)
    player_objs = []
    players.each do |p_data|
      player_objs << Player.new(p_data[0], p_data[1], @deck.deal(CARD_NUM))
    end
    player_objs
  end

  def bad_player_num(players)
    return if players.length.between?(PLAYERS_MIN, PLAYERS_MAX)
    puts "Exiting program - you tried to add too many players. Max = #{PLAYERS_MAX}"
    exit(false)
  end
end

if $PROGRAM_NAME == __FILE__
  class Game
    attr_reader :pot
  end
  # game = Game.new([['aaa', 500], ['bbb', 500], ['ccc', 500]])
  game = Game.new([['aaa', 500], ['bbb', 500]])
  # game.bet_round
  game.run
end

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
  end

  def bet_round
    first_round = true
    until @last_to_raise.nil? && !first_round
      place_bets(first_round)
      first_round = false
      # break if @last_to_raise.nil?
    end
    show_pot
    reset_bet_data
  end

  private

  def show_pot
    puts
    puts "Pot: #{@pot}"
  end

  def place_bets(first_round)
    @players.each do |player|
      last_to_raise_check(player)
      break if (@last_to_raise.nil? && !first_round) || one_player?
      display_bet_data(player)
      fold(player) if amount_owed(player) > player.purse
      next if @folded_players.include?(player)
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
    p "#{player.name}: last = #{player.last_payment}, amount = #{amount}"
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
  game.bet_round
end

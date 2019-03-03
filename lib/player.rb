class Player
  attr_reader :name, :cards, :purse
  attr_accessor :last_payment

  def initialize(name, purse, cards)
    @name = name
    @purse = purse
    @cards = cards
    @last_payment = 0
  end

  def bank(amount)
    raise(ArgumentError, 'not enough money') if @purse + amount < 0
    @purse += amount
  end

  def input_cards_discard
    puts "#{@name}, which cards would you like to replace (max. 3)? (e.g. 0, 2, 4)"
    puts 'Or type none if you wish to keep all of your cards:'
    print '> '
    replace_choice
  rescue ArgumentError => err
    puts err
    retry
  end

  def replace_cards(indexes, new_cards)
    remove_cards(indexes)
    add_cards(new_cards)
  end

  def input_call
    puts "#{@name}, would you like to fold, see, or raise?"
    print '> '
    gets.chomp.downcase
  end

  def input_raise
    puts 'How much would you like to raise by?'
    print '> '
    raise_answer
  rescue ArgumentError => err
    puts err
    retry
  end

  private

  def raise_answer
    answer = gets.chomp
    raise(ArgumentError, 'Please input whole numbers only.') if answer.match(/^\d+$/).nil?
    answer.to_i.abs
  end

  def replace_choice
    choices = gets.chomp
    choices.delete!(' ')
    return 'none' if choices.downcase == 'none'
    choice_arr = choices.split(',')
    unless choice_arr.all? { |choice| choice.between?('0', '4') }
      raise(ArgumentError, 'Numbers 0 - 4 only, 3 choices max, or none')
    end
    choice_arr.map(&:to_i)
  end

  def remove_cards(indexes)
    cards_left = []
    @cards.each_with_index { |card, idx| cards_left << card unless indexes.include?(idx) }
    @cards = cards_left
  end

  def add_cards(new_cards)
    @cards += new_cards
  end
end

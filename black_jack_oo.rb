
require 'pry'


module Playable 
  def optimal_value
    opt_val = 0 #Is there another way to make opt_val available outside the scope ?
    loop do
      opt_val = 0
      self.cards.each do |card|
        opt_val += card.value
      end
      if opt_val > 21
        if cards.any? {|card| card.value == 11}
          cards[cards.rindex {|card| card.value == 11}].value = 1
        else
          bust
          break
        end
      else
        break
      end
    end
    opt_val
  end


  def deal_card(new_card)
    cards << new_card
  end

  def hit(new_card)
    cards << new_card
  end

  def stay
    self.final_situation = optimal_value
  end

  def blackjack?
    (optimal_value == 21) && (cards.length == 2)
  end

  def blackjack
    self.final_situation = 'blackjack'
  end

  def bust
    self.final_situation = "busted"
  end
end

## Cards & Deck TEST EFFECTUE

class Deck
  RANKS = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'Jack', 'Queen', 'King', 'Ace']
  COLORS = ['heart', 'diamonds', 'spades', 'clubs']

  attr_accessor :cards

  def initialize(n)
    @cards = []
    n.times do
      COLORS.each do |color|
        RANKS.each do |rank|
          if (rank.to_i > 1) && (rank.to_i < 10)
            value = rank
          elsif rank == 'Ace'
            value = 11
          else
            value = 10
          end
          @cards.push(Card.new(rank, color, value))
        end
      end
    end
    @cards.shuffle!
  end
end

class Card
  attr_reader :rank, :color, :value
  attr_writer :value

  def initialize(r, c, v)
    @rank = r
    @color = c
    @value = v
  end

  def to_s
    "#{rank} of #{color}"
  end 
end

### Participants

class Dealer
  include Playable

  attr_accessor :chips, :hand, :dealer_turn
  
  def initialize
    @name = 'Dealer'
    @chips = 1500
    @hand = DealerHand.new
    @dealer_turn = false
  end


  def display
    puts "\t\t----"
    puts "Dealer's hand: \n"
    if self.dealer_turn == false
      puts "\t#{hand.cards[0]}"
      puts "\thidden card"
      puts "\t=>Temporary value: #{hand.cards[0].value}"
    else
      hand.cards.each do |card|
        puts "\t#{card}"
      end
      if hand.final_situation == nil
        puts "\t=> Total value: #{hand.optimal_value}"
      else
        puts "\t=> Final situation: #{hand.final_situation}"
      end
    end
  end
end

class Player
  attr_accessor :chips, :betting_box
  attr_reader :name

  @@player_counter = 0

  def initialize
    @@player_counter += 1
    @name = ask_name
    @chips = 100
    @betting_box = BettingBox.new
  end

  def ask_name
    begin
      print "Player #{@@player_counter}, please enter your name: "
      name = gets.chomp
    end until (name != '') && (name.downcase != 'dealer')
    name
  end

  def bet
    amount = ask_bet
    self.chips -= amount
    betting_box.hand.bet = amount
  end

  def ask_bet
    begin
      system 'clear'
      puts "#{name}, you have #{chips} chips."
      puts "How many chips would you like to bet ? "
      answer = gets.chomp.to_i
    end until answer <= chips
    answer
  end

  def choice
    begin
      display_choices
      selection = gets.chomp.downcase
    end until choices.include?(selection)
    selection
  end

  def choices
    choices = ['hit', 'stay']
    if chips >= betting_box.hand.bet
      choices << 'double'
    end
    choices
  end

  def display_choices
    case choices.length
    when 2 then print 'hit or stay: '
    when 3 then print 'hit, stay or double: '
    end
  end

  def display
    puts "\t\t----"
    puts "#{name}'s hand: "
    puts "You have bet #{betting_box.hand.bet} chips."
    betting_box.hand.cards.each do |card|
      puts "\t#{card}"
    end
    if betting_box.hand.final_situation == nil
      puts "\t=> Total value: #{betting_box.hand.optimal_value}"
    else
      puts "\t=> Final situation: #{betting_box.hand.final_situation}"
    end
  end
end

# Necessary to Player class

class BettingBox # I used a betting box to facilitate the implementation of a split function
  include Playable

  attr_accessor :hand

  def initialize
    @hand = PlayerHand.new
  end
end

### Hands

class Hand
  include Playable

  attr_accessor :cards, :final_situation

  def initialize
    @cards = []
  end
end

class PlayerHand < Hand
  include Playable

  attr_accessor :bet

  def initialize
    super
    @bet = 0
  end
end

class DealerHand < Hand
  include Playable
end

class Game
  attr_accessor :deck, :players, :dealer

  def initialize
    @deck = Deck.new(4)
    @players = []
    @dealer = Dealer.new
    adding_players
  end

  ## Necessarry to instatiation

  def nb_of_players
    begin
      print 'Enter the number of players: '
      nb = gets.chomp.to_i
    end until (nb > 0) && (nb <= 9)
    nb
  end

  def adding_players
    nb_of_players.times {players.push(Player.new)}
  end

  ## Deal

  def deal_cards
    2.times do
      self.players.each {|player| player.betting_box.hand.deal_card(deck.cards.pop)}
      self.dealer.hand.deal_card(deck.cards.pop)
    end   
  end

  ## Turns
  def betting_phase
    players.each {|player| player.bet}
  end

  def players_turns
    players.each do |player|
      if player.betting_box.hand.bet > 0
        loop do
          display
          puts "#{player.name}'s turn."
          if player.betting_box.hand.blackjack?
            player.betting_box.hand.blackjack
            break
          elsif player.betting_box.hand.optimal_value == 21
            player.betting_box.hand.stay
            break
          else
            case player.choice
            when 'hit'
              player.betting_box.hand.hit(deck.cards.pop)
              if player.betting_box.hand.optimal_value > 21
                player.betting_box.hand.bust
                display
                sleep 2
                break
              end
            when 'stay'
              player.betting_box.hand.stay
              break
            when 'double'
              player.betting_box.hand.hit(deck.cards.pop)
              if player.betting_box.hand.optimal_value <= 21
                player.betting_box.hand.stay
              else
                player.betting_box.hand.bust
                display
                sleep 2
              end
              break
            end
          end
        end
      end
      display
      sleep 1
    end
  end

  def display
    system 'clear'
    players.each do |player|
      player.display
    end
    dealer.display
  end
    
  def dealer_turn
    dealer.dealer_turn = true
    loop do
      sleep 1
      display
      if dealer.hand.blackjack?
        dealer.hand.blackjack
        break
      elsif dealer.hand.optimal_value < 17
        dealer.hand.hit(deck.cards.pop)
      else
        if dealer.hand.optimal_value > 21
          dealer.hand.bust
        else
          dealer.hand.stay
        end
        break
      end
    end
    display
    sleep 1
  end

  def chip_distribution
    players.each do |player|
      case
      when player.betting_box.hand.final_situation == 'busted' then player_loses(player)
      when dealer.hand.final_situation == 'blackjack' then player_loses(player)
      when player.betting_box.hand.final_situation == 'blackjack' then player_wins(player)
      when dealer.hand.final_situation == 'busted' then player_wins(player)
      when player.betting_box.hand.final_situation > dealer.hand.final_situation then player_wins(player)
      else player_loses(player)
      end 
    end
  end

  def player_wins(player)
    coef = 0
    bet = player.betting_box.hand.bet
    if player.betting_box.hand.final_situation == 'blackjack'
      coef = 1.5
    else
      coef = 1
    end
    dealer.chips -= bet * coef
    player.betting_box.hand.bet = 0
    player.chips += bet * (1 + coef)
  end

  def player_loses(player)
    bet = player.betting_box.hand.bet
    player.betting_box.hand.bet = 0
    dealer.chips += bet
  end

  def reset_game
    players.delete_if {|player| player.chips == 0}
    
    players.each do |player| 
      player.betting_box.hand.cards = []
      player.betting_box.hand.final_situation = nil
    end
    
    dealer.hand.cards = []
    dealer.hand.final_situation = nil
    dealer.dealer_turn = false
  end

  def continue
    begin
      puts 'Do you want to continue ? (y/n)'
      answer = gets.chomp.downcase
    end until (answer == 'y') || (answer == 'n')
    answer
  end

  ## Play

  def start
    loop do
      betting_phase
      deal_cards
      display
      players_turns
      dealer_turn
      chip_distribution
      reset_game

      if (continue == 'n') || (players == [])
        break
      end
    end
  end
end

system 'clear'
game = Game.new
game.start

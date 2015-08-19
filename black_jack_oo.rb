#1 to 7 players face the dealer. a deck is composed with a certain amounts of decks. the deck is shuffled.
#Each card has a value and a color. cards within 2 and 9 are worth their number. an Ace is worth 1 or 11. the other cards are worth 10.
#the dealer deals 2 cards to each participant(including himself). the players cards are face up. One of the
#dealer s cards is face down. 

# The first player plays.
#   if the value of his cards is 21, he has a blackjack. His turn stops.
#   else he can choose
#     -if he has two cards with the same rank, he can split.
#     -else, he can either double || hit or stay
#       -if he doubles, he doubles his bet, 1 card is dealt to him, then the game stops.
#       -if he hit, 1 card is dealt to him
#       -if he stays, his turn stops
#          CHECK
#          => if he has reached 21, the turn stops
#          => elsif he is over 21
#               if he has no ace used as an 11, the game stops
#               if he has an ace used as an 11, if can be used as a 1
#                 if the total value is 21, the game stops
#                 elsif the total value is still over 21 the player is busted
#                 else the game continues
#          => else the game continues
# Then the second player...

# Once all the players have played, it's the delaer's turn
#   if he has 21 he has blackjack, the game stops
#   elsif he has betwin 16 and 20, the game stops
#   else he draws
#     if he has 
require 'pry'


class Card
  attr_reader :rank

  def initialize(r, c)
    @rank = r
    @color = c
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
    end until name != '' && name.downcase != 'dealer'
  name
  end
end

class Dealer
  attr_accessor :chips, :dealer_turn, :hand
  
  def initialize
    @name = 'Dealer'
    @chips = 1500
    @dealer_turn = false
    @hand = []
  end
end

class BettingBox
  attr_accessor :hand, :bet, :split_hand, :split_bet

  def initialize
    @hand = []
    @bet = 0
    @split_hand = [] 
    @split_bet = 0
# Am I compelled to instatiate the object with the split arguments, or can I instanciate them only if the player choses to split
  end

  def ask_bet 
    begin
      print "How many chips would you like to bet ? "
      answer = gets.chomp.to_i
    end until answer > 0
    answer
  end

  def play
    # self.hand
  end
end





class Game
  RANKS = ['Ace', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 'Jack', 'Queen', 'King']
  COLORS = ['heart', 'diamonds', 'spades', 'clubs']

  attr_accessor :deck, :players

  def initialize
    @deck = generate_deck
    @players = []
    @dealer = Dealer.new
    nb_of_players.times {@players.push(Player.new)}
  end

  def generate_deck
    deck = []
    1.times do #à modifier
      COLORS.each do |color|
        RANKS.each do |rank|
          deck.push(Card.new(rank, color))
        end
      end
    end
    deck.shuffle
  end

  def nb_of_players
    begin
      print 'Enter the number of players: '
      nb = gets.chomp.to_i
    end until (nb > 0) && (nb <= 9)
    nb
  end

  def deal_cards
    2.times do
      binding.pry
      self.players.each {|player| betting_box.hand.deal_a_card}
      self.dealer.hand.deal_a_card
    end   
  end

  def deal_a_card #To a hand
    deck.pop
  end

  def start
    self.deal_cards
  end
  #When ther are many methods in a class, what is the optimal way to organize them ?
end

game = Game.new
game.start
binding.pry


#DO NOT FORGET TO
# => Make a deck composed of 4 or 7 decks
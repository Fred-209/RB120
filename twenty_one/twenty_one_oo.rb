# frozen_string_literal: true

# Twenty One Game -- Object Oriented Version

require 'yaml'
require 'abbrev'

module Utils
  # requires abbrev
  PROMPT = ' => '

  def build_regexp_pattern(string_array, abbreviations)
    return /\w+/ if string_array.empty?

    abbreviations = abbreviations.keys.join('|').prepend('^(') << ')$'
    Regexp.new(abbreviations, 'ignore case')
  end

  def display_input_prompt(message)
    print message + PROMPT
  end

  def get_validated_input(valid_input)
    abbreviations = Abbrev.abbrev(valid_input.map(&:downcase))
    valid_pattern = build_regexp_pattern(valid_input, abbreviations)

    user_input = ''
    loop do
      user_input = gets.chomp.strip
      break if valid_pattern.match?(user_input.downcase)

      puts "That's not a valid choice. Try again."
      print "Choices are [#{valid_input.join(', ')}]: "
    end
    abbreviations[user_input.downcase] || user_input
  end

  def delay_screen(seconds_delay, message = nil)
    print message if message
    sleep(seconds_delay)
  end

  def pause_screen
    display_input_prompt('Press enter to continue')
    gets
  end

  def clear_screen
    system('clear')
  end
end

class TwentyOne
  include Utils

  MESSAGES = YAML.load_file('twenty_one_oo.yml')
  BUST_THRESHOLD = 21

  def initialize
    display_welcome
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
    @points_to_win = nil
    @rounds_played = 0
    @tie_games = 0
    @round_winner = nil
  end

  def start
    loop do
      choose_points_to_win!
      loop do
        play_game_round
        display_final_cards
        determine_round_winner
        round_winner? ? round_winner_updates! : tie_game_updates!
        break if game_winner?

        perform_new_round_procedures
      end
      congratulate_game_winner if game_winner?
      play_again? ? reset_game! : break
    end
    display_goodbye_message
  end

  private

  attr_accessor :deck, :player, :dealer, :rounds_played, :tie_games, :first_run,
                :points_to_win, :round_winner, :game_winner

  def choose_points_to_win!
    print MESSAGES['play_multiple_rounds']
    print "Type 's' for single game or 'm' for multiple games #{PROMPT}"
    self.points_to_win = get_validated_input(%w[s m]) == 's' ? 1 : 3
  end

  def choose_to_stay_hand?
    print format(MESSAGES['draw_or_stay'], PROMPT)
    get_validated_input(%w[stay draw]) == 'stay'
  end

  def congratulate_game_winner
    game_winner = [player, dealer].max_by(&:points)
    clear_screen
    puts format(MESSAGES['congratulate_game_winner'], game_winner.name)
  end

  def congratulate_round_winner
    clear_screen
    puts format(MESSAGES['congratulate_round_winner'], round_winner.name)
  end

  def determine_round_winner
    if someone_busted?
      self.round_winner = player.busted? ? dealer : player
      return
    end

    self.round_winner =
      case player.hand_score <=> dealer.hand_score
      when -1 then dealer
      when 1 then player
      end
  end

  def display_busted_message(busted_participant)
    name = busted_participant.name
    hand_score = busted_participant.hand_score

    clear_screen
    busted_participant.show_hand
    puts format(MESSAGES['busted_message'], hand_score, name)
    pause_screen
  end

  def deal_card_to_participant(participant)
    card = deck.deal_card
    card.face_down = true if participant.hand.empty? &&
                             participant.class == Dealer
    participant.hand.add_card(card)
    puts "#{participant.name} was dealt a #{card}."
    puts
    participant.hand.display
  end

  def deal_starting_hands
    deck.shuffle(hide_animation: false)

    2.times do
      [player, dealer].each do |participant|
        deal_card_to_participant(participant)
        puts
        delay_screen(1.25)
      end
    end
    pause_screen
  end

  def dealer_takes_turn
    loop do
      display_dealer_hand
      break if dealer.should_stay_hand?(player.hand_score)

      deal_card_to_participant(dealer)
      delay_screen(1.25)
      break if dealer.busted?
    end
    dealer.busted? ? display_busted_message(dealer) : display_turn_recap(dealer)
  end

  def display_dealer_hand
    clear_screen
    puts "Dealer's turn"
    puts
    dealer.show_hand
    puts
    delay_screen(1.25)
  end

  def display_final_cards
    clear_screen
    puts MESSAGES['final_card_results']
    dealer.show_hand(show_face_down_card: true)
    puts "Score: #{dealer.hand_score}"
    puts
    player.show_hand
    puts "Score: #{player.hand_score}"
    puts
    pause_screen
  end

  def display_game_stats
    puts format(MESSAGES['game_stats'], player.name, player.points, dealer.name,
                dealer.points, tie_games)
  end

  def display_goodbye_message
    puts MESSAGES['goodbye_message']
  end

  def display_player_hand
    clear_screen
    show_all_hands
    puts format(MESSAGES['hand_display'], player.name, player.hand_score)
  end

  def display_single_or_multiple_message
    if playing_multiple_rounds?
      puts "Starting round #{rounds_played}"
    else
      puts 'Playing Single Game'
    end
  end

  def display_tie_game_message
    clear_screen
    puts MESSAGES['tie_game']
  end

  def display_turn_recap(participant)
    clear_screen
    puts 'Turn Recap'
    puts
    participant.show_hand
    puts format(
      MESSAGES['participant_staying'], participant.name, participant.hand_score
    )

    pause_screen
  end

  def display_welcome
    clear_screen
    puts MESSAGES['welcome_banner']
    puts MESSAGES['welcome_message']
  end

  def game_winner?
    player.points >= points_to_win || dealer.points >= points_to_win
  end

  def perform_new_round_procedures(playing_again: false)
    display_game_stats unless playing_again
    reset_for_new_round!
    pause_screen unless playing_again
  end

  def play_again?
    print format(MESSAGES['play_again'], PROMPT)
    get_validated_input(%w[yes no]) == 'yes'
  end

  def play_game_round
    self.rounds_played += 1
    clear_screen
    display_single_or_multiple_message
    deal_starting_hands
    player_takes_turn
    dealer_takes_turn unless player.busted?
  end

  def increment_rounds_played!
    self.rounds_played += 1
  end

  def player_takes_turn
    loop do
      display_player_hand
      if choose_to_stay_hand?
        player.stay_hand!
        break
      end
      deal_card_to_participant(player)
      delay_screen(1.25)
      break if player.busted?
    end
    player.busted? ? display_busted_message(player) : display_turn_recap(player)
  end

  def playing_multiple_rounds?
    points_to_win > 1
  end

  def reset_for_new_round!
    self.round_winner = nil
    self.deck = Deck.new
    player.hand.clear
    dealer.hand.clear
  end

  def reset_game!
    perform_new_round_procedures(playing_again: true)
    self.rounds_played = 0
    player.points = 0
    dealer.points = 0
    clear_screen
  end

  def round_winner?
    round_winner != nil
  end

  def round_winner_updates!
    round_winner.points += 1
    congratulate_round_winner if playing_multiple_rounds?
  end

  def show_all_hands
    dealer.show_hand
    player.show_hand
  end

  def someone_busted?
    [player, dealer].any?(&:busted?)
  end

  def tie_game_updates!
    self.tie_games += 1
    display_tie_game_message
  end
end

class Participant
  include Utils
  attr_reader :name, :hand
  attr_accessor :points

  def initialize
    @name = assign_name
    @hand = Hand.new
    @stay = false
    @points = 0
  end

  def stay?
    stay == true
  end

  def stay_hand!
    self.stay = true
  end

  def busted?
    hand_score > TwentyOne::BUST_THRESHOLD
  end

  def show_hand(show_face_down_card: false)
    puts "#{name}'s hand"
    hand.display(show_face_down_card)
  end

  def hand_score
    hand.cards_total_value
  end

  private

  attr_writer :name
  attr_accessor :busted, :stay
end

class Player < Participant
  private

  def assign_name
    print "What's your name?: "
    name = get_validated_input([])
    puts
    puts "Ready to play some 21, #{name}?"
    delay_screen(1)
    name
  end
end

class Dealer < Participant
  DEALER_NAMES = %w[Dealer].freeze
  HIT_THRESHOLD = 17

  def should_stay_hand?(player_score)
    return false if hand_score < player_score

    hand_score >= HIT_THRESHOLD
  end

  private

  def assign_name
    DEALER_NAMES.sample
  end
end

class Deck
  include Utils

  def initialize
    @cards = create_deck
  end

  def shuffle(hide_animation: true)
    display_shuffle_animation unless hide_animation
    cards.shuffle!
  end

  def deal_card
    cards.pop
  end

  def count
    "There are #{cards.count} cards left in the deck."
  end

  private

  attr_reader :cards

  def create_deck
    Card::SUITS.product(Card::FACES).each_with_object([]) do |(suit, face), deck|
      deck << Card.new(suit, face)
    end
  end

  def display_shuffle_animation
    print 'Shuffling deck....'
    %w[| / - \\].cycle(3) do |piece|
      print piece
      delay_screen(0.15)
      print "\b"
    end
    puts 'Ready to deal!'
    puts
  end
end

class Card
  FACES = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze
  FACES_EXPANDED = { 'J' => 'Jack', 'Q' => 'Queen', 'K' => 'King',
                     'A' => 'Ace' }.freeze
  SUITS = %w[♥ ♠ ♦ ♣].freeze
  SUITS_EXPANDED = { '♥' => 'Hearts', '♠' => 'Spades', '♦' => 'Diamonds',
                     '♣' => 'Clubs' }.freeze
  FACE_VALUES = { 'J' => 10, 'Q' => 10, 'K' => 10, 'A' => 1 }.freeze
  TOP_OF_CARD_GRAPHIC = '┏━━━━━━━━━┓'
  UPPER_CARD_LABEL_GRAPHIC = ('┃' + '%-9.9s' + '┃')
  MID_CARD_GRAPHIC = '┃         ┃'
  MIDDLE_CARD_LABEL_GRAPHIC = ('┃' + '%s'.center(10) + '┃')
  LOWER_CARD_LABEL_GRAPHIC = ('┃' + '%9.9s' + '┃')
  BOTTOM_OF_CARD_GRAPHIC = '┗━━━━━━━━━┛'

  attr_reader :face, :suit, :value
  attr_accessor :face_down

  def initialize(suit, face)
    @suit = suit
    @face = face
    @value = FACE_VALUES.fetch(face, face.to_i)
    @face_down = false
  end

  def to_s
    if face_down
      'card face down'
    else
      "#{FACES_EXPANDED.fetch(face, face)} of #{SUITS_EXPANDED[suit]}"
    end
  end
end

class Hand
  def initialize
    @cards = []
  end

  def add_card(card)
    cards << card
  end

  def card_count
    cards.count
  end

  def cards_total_value
    aces_count = cards.count { |card| card.face == 'A' }
    hand_score = cards.map(&:value).sum
    aces_count.times do |_|
      hand_score += 10 if hand_score + 10 <= TwentyOne::BUST_THRESHOLD
    end
    hand_score
  end

  def clear
    self.cards = []
  end

  def display(show_face_down_card = false)
    suits = suits_list
    faces = faces_list

    if cards.first.face_down
      unless show_face_down_card
        suits[0] = '#'
        faces[0] = '#'
      end
    end
    display_card_graphics(suits, faces)
  end

  def empty?
    cards.empty?
  end

  private

  attr_accessor :cards

  def display_card_graphics(suits, faces)
    display_upper_cards_section(faces)
    display_mid_cards_section(suits)
    display_bottom_cards_section(faces)
  end

  def display_bottom_cards_section(faces)
    print_card_label_line(Card::LOWER_CARD_LABEL_GRAPHIC, faces)
    puts
    puts Card::BOTTOM_OF_CARD_GRAPHIC * card_count
  end

  def display_mid_cards_section(suits)
    puts
    puts Card::MID_CARD_GRAPHIC * card_count
    print_card_label_line(Card::MIDDLE_CARD_LABEL_GRAPHIC, suits)
    puts
    puts Card::MID_CARD_GRAPHIC * card_count
  end

  def display_upper_cards_section(faces)
    puts Card::TOP_OF_CARD_GRAPHIC * card_count
    print_card_label_line(Card::UPPER_CARD_LABEL_GRAPHIC, faces)
  end

  def print_card_label_line(card_section, graphic)
    card_count.times do |count|
      print format(card_section, graphic[count])
    end
  end

  def faces_list
    cards.map(&:face)
  end

  def suits_list
    cards.map(&:suit)
  end
end

TwentyOne.new.start

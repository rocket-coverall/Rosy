class Game

  def initialize player1, player2
    @players = []
    @players << player1
    @players << player2

    @turn_number = 1

    @phases = [:begin, :draw, :play, :battle, :end]

    @phase = 0

    @coiflip = 0

    @players_ready = [false, false]

  end

  def coinflip
    @coinflip
  end

  def players
    @players
  end

  def phase 
    @phases [@phase]
  end

  def next_phase
    return @phases[0] unless @phases [@phase+1]
    @phases [@phase+1]
    $global.log :next_phase, @phase
  end

  def next_turn!
    @turn_number += 1
    log :new_turn, @turn_number
  end

  def next_phase!
    @phase = 0 unless @phases [@phase+1]
    @phase += 1 if @phases[@phase+1]

    self.next_turn! if self.phase == :begin
  end

  def fight_sequence 
    r = [0,1].sample
#    r = 0
    @coinflip = r
    p = players[r]
    $global.log "COINFLIP: #{p.nick}"

    while (p.field.active_cards_left?)||(p.opponent.field.active_cards_left?) 
      c = p.field.next_card
      if c
        puts "PLAYING "+c.to_s+" FROM SLOT "+c.position.to_s+" OF PLAYER "+p.nick
        c.play
      end

      p = p.opponent
    end


  end

  def game_start

    # beginning of first turn
    r = [0,1].sample
    @coinflip = r

    p = players[r]

    $global.log :coinflip, r



    next_phase

    # draw step
    players[0].draw_to 5
    players[1].draw_to 5

    next_phase

#   time to play the fucking cards

    wait_for_players
  
  end

  def wait_for_players

    @players_ready=[false,false]

    @waiting = Thread.new do 
      sleep 30
      next_phase
      battle_phase
    end  
  end

  def both_players_ready
    @waiting.kill
    next_phase
    battle_phase
  end

  def battle_phase
    activate_cards
    unflip_cards
    fight_sequence

  end

  def unflip_cards
    $global.log :unflip_cards 
  end

  def activate_cards
    players[0].activate_cards
    players[1].activate_cards
  end

  def check_stuff
    @players.each do |player|
      player.field.followers.each do |slot|
        slot.destroy if slot.card.stats[:stamina]<1
      end
      player.hand.followers.each do |slot|
        slot.destroy if slot.card.stats[:stamina]<1
      end
      player.deck.followers.each do |slot|
        next if follower.card.stats[:stamina]>0
        slot.destroy
        player.deck.remove_empty
      end      

      if player.health < 1
        log :loss, player, :life
        return false
      end
    end

    return true

  end 

  def handle_command cmd, player, *param # CLIENT COMMAND HANDLING
    
  end

  def log event, *param
    puts event.to_s
  end

  def game_info
    s = "\n=====[GAME INFO]=====\n"
    s += "#{players[0].nick} #{players[1].nick}\n" 
    s += "#{players[0].health.to_s}HP #{players[1].health.to_s}HP\n"
    s += "\e[32m-FIELD-\e[0m\n"
    h = ""
    (0..4).each do |i|
      s += "#{players[0].field.slots[i]} #{players[1].field.slots[i]}\n"
      h += "#{players[0].hand.slots[i]} #{players[1].hand.slots[i]}\n" 
    end
    s += "\e[32m-HAND-\e[0m\n"
    s += h
    s

  end

end

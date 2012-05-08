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

    @stop_game_flag = false

  end

  def coinflip
    @coinflip
  end

  def wait_thread
    @waiting
  end

  def players
    @players
  end

  def phase 
    return @phases [@phase] unless @phase == :loss
    @phase
  end

  def next_phase
    return @phases[0] unless @phases [@phase+1]
    @phases [@phase+1]
  end

  def next_turn!
    @turn_number += 1
    log :new_turn, @turn_number
  end

  def next_phase!
    return false if @stop_game_flag
    @phase = 0 unless @phases [@phase+1]
    @phase += 1 if @phases[@phase+1]

    self.next_turn! if self.phase == :begin

    $global.log 'phase '+@phases[@phase].to_s
    true
  end

  def fight_sequence
    r = @coinflip
    p = players[r]
    $global.log "COINFLIP: #{p.nick}"

    while (p.field.active_cards_left?)||(p.opponent.field.active_cards_left?) 
      c = p.field.next_card
      if c
        puts "Active card #{c.to_s} in slot #{p.nick}.#{c.position.to_s}"
        c.play
      end

      p = p.opponent
    end


  end

  def stop_game
    @stop_game_flag = true
    @phase = :loss
  end

  def game_loss player, reason
    $global.log :loss, player, reason
    stop_game
    puts 'GAME LOSS ON TURN '+@turn_number.to_s
    puts game_info
  end

  def game_start

    # beginning of first turn

    r = [0,1].sample
    @coinflip = r

    p = players[r]

    $global.log :coinflip, r

    trigger_abilities :begin, p
    trigger_abilities :begin, p.opponent

    return true unless next_phase!

    # draw step
    players[0].f_draw_to 5
    players[1].f_draw_to 5

    return true unless next_phase!

#   time to play the fucking cards

    wait_for_players
  
  end

  def trigger_abilities event, player
    p = player
    p.character.run event, p
    p.field.slots.shuffle.each { |s| s.run(event, s) if s.card }
  end

  def wait_for_players
    
    @players_ready=[false,false]
    puts 'Waiting for players...'
    @waiting = Thread.new do
      sleep 30
      return true unless next_phase!
      battle_phase
    end
    
  end

  def both_players_ready
    return false unless @waiting
    @waiting.kill
    return true unless next_phase!
    battle_phase
  end

  def battle_phase

    @coinflip = [0,1].sample
    $global.log :coinflip, @coinflip

    activate_cards
    unflip_cards

    fight_sequence

    return true unless next_phase!
    turn_end
    
  end

  def turn_end
    trigger_abilities :end, players[@coinflip]
    trigger_abilities :end, players[@coinflip].opponent

    return true unless next_phase!
    turn_start
  end

  def turn_start
    trigger_abilities :begin, players[@coinflip]
    trigger_abilities :begin, players[@coinflip].opponent

    return true unless next_phase!
    draw_phase
  end

  def draw_phase
    players.each { |p| p.f_draw_to 5 }

    return true unless next_phase!
    action_phase
  end 

  def action_phase
    wait_for_players
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
        next if slot.card.stats[:stamina]>0
        slot.destroy
        player.deck.remove_empty
      end      

      if player.health < 1
        $global.game_loss player, :life
        return false
      end
    end

    return true

  end 

  def handle_command cmd, player, *param # CLIENT COMMAND HANDLING
    
  end

  def log event, *param
    puts '[LOG] '+event.to_s unless event==:draw
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

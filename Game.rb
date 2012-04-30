class Game

  def initialize player1, player2
    @players = []
    @players << player1
    @players << player2

    @turn_number = 1

    @phases = [:begin, :draw, :play, :battle, :end]

    @phase = 0

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

  def log event, *param
    puts event.to_s
  end

  def game_info
    s = "\n==========\n"
    @players.each do |player|
      s += "PLAYER: "+player.nick+" #{player.health} HP\n"
      s += "FIELD: \n"
      player.field.slots.each { |slot| s+= slot.to_s+"\n" }
      s += "\nHAND: \n"
      player.hand.slots.each { |slot| s+= slot.to_s+"\n" }
      s += "\n===========\n"
    end
  
    s

  end

end

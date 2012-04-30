class Player
  def initialize id, nick, deck, character
    @id = id
    @nick = nick
    @character = character
    @deck = deck

    @field = Field.new self

    @hand = Hand.new self

  end

  def deck
    @deck
  end

  def nick
    @nick
  end

  def deck= d
    @deck = d
  end

  def hand
    @hand
  end

  def hand= h
    @hand = h
  end

  def field 
    @field
  end

  def draw_to num=5

    num = num-(5-self.hand.room)

    puts num.to_s+' draw'

    return true unless num>=0

    return false unless self.deck.slots.length>0

    num = self.deck.slots.length if num > self.deck.slots.length

    (1..num).each do |i|
      self.hand.add self.deck.slots.shift.card
    end

    true

    puts 'drew'

    self.hand.slots.each { |s| puts s.to_s }

    $global.log :draw
    
  end

  def shuffle
    
    cards_moved = 0

    (1..5).each do |i|

      next unless self.hand.slots[i].card
    
      slot = self.hand.slots[i]
      slot.position = self.deck.slots.length + 1
      self.deck.slots << slot
      self.hand.slots[i].card = nil

      cards_moved += 1

    end

    self.draw_to cards_moved

    $global.log :shuffle, self, cards_moved

  end

  def opponent
   return $global.players[id^1]
  end

  def health
    @character.stats[:health]
  end

  def health= h
    @character.stats[:health] = h
  end

  def damage dmg, src, type
    @character.stats[:health] -= dmg
    $global.log :damage, dmg, {type: :character, player: @id}, src, type
  end

  

end

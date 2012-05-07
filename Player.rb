class Player
  def initialize id, nick, deck, character
    @id = id
    @nick = nick
    @character = character
    @deck = deck

    @field = Field.new self

    @hand = Hand.new self

    @data = {shuffles: 2}

  end

  def data
    @data
  end

  def deck
    @deck
  end

  def character
    @character
  end

  def use_shuffle
    if data[:shuffles]>0
      data[:shuffles]-=1
      shuffle
      return true
    else
      return false
    end
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

  def id
    @id
  end

  def hand= h
    @hand = h
  end

  def field 
    @field
  end

  def activate_cards
    field.activate_all
  end

  def play_from_hand position=1, force=false
    c = hand.slots[position].card
    s = c.stats[:size]
    return false if ((field.total_size+s)>10)and(not force)
    field.add c
    $global.log :card_played
    return true if position==4
    (position..3).each do |i|
      hand.slots[i].card = hand.slots[i+1].card
    end
    hand.slots[4].card = nil
    
  end

  def draw_to num=5

    num = num-(5-self.hand.room)

    return true unless num>=0

    return false unless self.deck.slots.length>0

    num = self.deck.slots.length if num > self.deck.slots.length

    (1..num).each do |i|
      self.hand.add self.deck.slots.shift.card
    end

    true

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

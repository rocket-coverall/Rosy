class Slot

  def initialize player, position
    @card = nil
    @player = player
    @position = position
    @enabled = false
  end

  def run script, *param
    card.run script, param
  end

  def position
    @position
  end

  def position= p
    @position = p
  end

  def card= card
    @card = card
  end

  def place card
    self.card= card
  end

  def enable
    @enabled = true
  end

  def disable
    @enabled = false
  end

  def type
    return :empty unless @card
    @card.info[:type]
  end

  def spell?
    self.type == :spell
  end

  def follower?
    self.type == :follower
  end

  def character?
    self.type == :character
  end

  def enabled? 
    @enabled
  end

  def active?
    self.enabled?
  end


  def empty?
    return true if card
    return false unless card
  end

  def activate
    self.enable
  end

  def deactivate
    self.disable
  end

  def card
    @card
  end

  def player
    @player
  end

  def opponent
    self.player.opponent
  end

  def play
    
    self.attack if self.follower?
    self.run :spell if self.spell?

    $global.check_stuff

  end

  def destroy
    
    self.player.damage self.card.stats[:size], self, :destroy

    self.card = nil

  end

  def attack b=false, t=nil

    return self.dirrect unless self.opponent.field.has_followers?

    esl = self.opponent.field.random_follower

    puts "ATK #{self.player.nick}.#{self.position.to_s} -> #{esl.player.nick}.#{esl.position.to_s}"
    
    self.run :attack, self, esl # launch "before attacking" abilities
    $global.check_stuff
    
    unless (esl.follower?)&&(self.follower?) # if any of the followers died
      self.deactivate unless b
      return true
    end
    
    esl.run :defence, self, esl # launch "before defending" abilities
    $global.check_stuff

    if (esl.follower?)&&(self.follower?) 
      dmg = self.card.stats[:attack]-esl.card.stats[:defence]
      esl.card.stats[:stamina] -= dmg
      $global.log :damage, dmg, {type: :follower, slot: esl}, self, :combat
    end

    $global.check_stuff


    unless(esl.follower?)&&(self.follower?)
      self.deactivate unless b
      return true
    end

    unless b # unless striking back
      esl.attack true, self # strike back
      self.deactivate # finally deactivate !
    end
    

  end

  def dirrect
    self.player.opponent.damage self.card.stats[:size], self, :direct
    self.deactivate
  end
  

  def to_s
    slot = self
    s = ''
    s += "["
    s += "(#{slot.card.stats[:size]}) #{slot.card.info[:id]}" if slot.card
    s += " #{slot.card.stats[:attack].to_s}/#{slot.card.stats[:defence].to_s}/#{slot.card.stats[:stamina].to_s}" if slot.follower?
    s += "]"
    
    s
    
  end


end

class Zone

  def initialize player, num=5
    @slots = []
    (1..num).each { |i| @slots+=[Slot.new(player, i)] } 
    @player = player
  end

  def activate_all
    @slots.each { |s| s.activate if s.card }  
  end
   

  def player
    @player
  end

  def opponent
    @player.opponent
  end

  def slots
    @slots
  end

  def size
    res = 0
    @slots.each { |s|  res+=s.card.stats[:size] if s.card }
    res
  end

  def spells
    spells = []
    @slots.each { |s| spells+=[s] if s.spell? }
    spells
  end

  def remove_empty
  
    slots.each do |slot| 
      slot = nil unless slot.card
    end

    slots.delete nil

    
  end

  def full_slots
    full_slots = []
    @slots.each { |s| full_slots << s unless s.empty? }
    full_slots
  end

  def total_size
    res = 0
    @slots.each { |s| res += s.card.stats[:size] if s.card }
    res
  end

  def followers
    followers = []
    @slots.each { |s| followers+=[s] if s.follower? }
    followers
  end

  def slots= s
    @slots= s
  end

  def slot n
    @slots[n]
  end

  def append card
    newslot = Slot.new self.player, self.slots.length+1
    newslot.card = card
    @slots << newslot
  end

  def add card
    @slots.each_with_index do |s,i| 
      unless s.card
        @slots[i].card = card
        return true
      end
    end

    return false
  end

  def room
    count = 0
    @slots.each { |s| count+=1 unless s.card }
    count
  end

  def to_s
    slot = self
    s = ''
    s += "["
    s += "(#{slot.card.stats[:size]}) #{slot.card.info[:id]}" if slot.card
    s += " #{slot.card.stats[:attack].to_s}/#{slot.card.stats[:defence].to_s}/#{slot.card.stats[:stamina].to_s}" if slot.follower?
    s += "]"

    s  

  end


end

class Hand < Zone

    

end

class Deck < Zone



end

class Grave < Zone



end

class Field < Zone

  def active_followers
    active_followers = []
    self.followers.each { |f| active_followers << f if f.active? }
    active_followers
  end

  def active_cards_left?
    not (self.active_spells + self.active_followers).empty?
  end

  def active_spells
    active_spells = []
    self.spells.each { |s| active_spells << s if s.active? }
    active_spells
  end

  def next_card

    sp = self.active_spells
    fo = self.active_followers
    
    a = fo
    a = sp unless sp.empty?
    
    return nil if a.empty?

    a.sample

  end

  def has_followers?
    not self.followers.empty?
  end

  def random_follower
    self.followers.sample
  end


 
end

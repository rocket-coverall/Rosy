class Ability
  def initialize id, text, &p
    @id = id
    @p = p
    @text = text
  end

  def run *params
    p.call params
  end

  def text
    @text
  end

end

class Abilities

  def initialize
    @abilities = {}
  end
  
  def add id, &p
    raise "Ability with id #{id} already exists" if @abilities.has_key? id
    @abilities[id] = p
  end

  def run id, *params
    raise "Called ability with id #{id} does not exist" unless @abilities.has_key? id
    @abilities[id].run params
  end

  def text id
    raise "Called ability with id #{id} does not exist" unless @abilities.has_key? id
    @abilities[id].text
  end

end

class Card

  def initialize d
    default = 
     {id: 0, type: :character, 
     stats: {attack: 0, defence: 0, stamina: 0, size:0, health:30},
     abilities: {attack: [], defence: [], start: [], end: [], spell: []}
     }
    data = default.merge d
    @info = {id: data[:id], type: data[:type]}
    @stats = data[:stats]
    @abilities = data[:abilities]
  end

  def stats
    @stats
  end

  def data
    e = {}
    stats_ = @stats.merge e
    info_ = @info.merge e
    abilities_ = @abilities.merge e
    {id: info_[:id], type: info_[:type], stats: stats_, abilities: abilities_}
  end

  def stats= s
    @stats = s
  end

  def info
    @info
  end

  def run script, *param
    return false unless @abilities[script]
    @abilities[script].each { |id| $abilities.run id, *param }
  end

end  

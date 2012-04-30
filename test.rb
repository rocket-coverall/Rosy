require './Ability.rb'
require './Card.rb'
require './Game.rb'
require './Player.rb'
require './Slot.rb'

h = {id: 1, type: :follower, stats: {attack: 5, defence:1, stamina: 5, size: 1}}

gamestarter = Card.new h

h = {id: 2}

rio = Card.new h


p1 = Player.new 1, 'nvm', nil, Card.new(rio.data)

d1 = Deck.new p1, 0


d1.append Card.new gamestarter.data
d1.append Card.new gamestarter.data
d1.append Card.new gamestarter.data
d1.append Card.new gamestarter.data

puts 'l'
puts d1.slots.length

p1.deck = d1

p2 = Player.new 2, 'frtt', nil, Card.new(rio.data)

d2 = Deck.new p2, 0
d2.append Card.new gamestarter.data
d2.append Card.new gamestarter.data

p2.deck = d2

$global = Game.new p1, p2

puts p1.deck.slots.length

p1.draw_to 5

p2.draw_to 5

puts 'game info'

puts $global.game_info

$global.players[1].hand.slots[1].card.stats[:stamina] = 0

$global.check_stuff

puts $global.game_info



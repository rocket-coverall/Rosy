require './Ability.rb'
require './Card.rb'
require './Game.rb'
require './Player.rb'
require './Slot.rb'

h = {id: 1, type: :follower, stats: {attack: 5, defence:1, stamina: 5, size: 1}}

gamestarter = Card.new h

h = {id: 2}

rio = Card.new h


p1 = Player.new 0, 'nvm', nil, Card.new(rio.data)

d1 = Deck.new p1, 0


d1.append Card.new gamestarter.data
d1.append Card.new gamestarter.data
d1.append Card.new gamestarter.data
d1.append Card.new gamestarter.data

p1.deck = d1

p2 = Player.new 1, 'frtt', nil, Card.new(rio.data)

d2 = Deck.new p2, 0
d2.append Card.new gamestarter.data
d2.append Card.new gamestarter.data

p2.deck = d2

$global = Game.new p1, p2


puts "GAME START"
$global.game_start


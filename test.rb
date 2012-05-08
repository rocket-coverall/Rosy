require './Ability.rb'
require './Card.rb'
require './Game.rb'
require './Player.rb'
require './Slot.rb'
STDOUT.sync = true
h = {id: 1, type: :follower, stats: {attack: 5, defence:1, stamina: 5, size: 1}}

gamestarter = Card.new h

h = {id: 2}

rio = Card.new h


p1 = Player.new 0, 'nvm', nil, Card.new(rio.data)

d1 = Deck.new p1, 0

30.times {d1.append Card.new gamestarter.data }

p1.deck = d1

p2 = Player.new 1, 'frtt', nil, Card.new(rio.data)

d2 = Deck.new p2, 0
30.times { d2.append Card.new gamestarter.data }


p2.deck = d2

puts 'game new'

$global = Game.new p1, p2


puts "GAME START"
begin
Thread.new { $global.game_start }

puts 'thread started'
sleep 1
print ">"
$a = gets.strip
while true
   if $a=="exit"
    puts 'stopping'
    $global.stop_game
    Process.exit!
   end
   if $a == "ready"
    $global.both_players_ready
   end
   if $a.split[0] == 'play'
    $global.players[$a.split[1].to_i].play_from_hand $a.split[2].to_i
   end
   if $a == "status"
    puts $global.game_info
   end
   print ">"
   $a = gets.strip
end
rescue Exception => e
puts 'rescue out of nowhere'
puts e.message
puts e.backtrace.inspect
end
puts 'cycle over'

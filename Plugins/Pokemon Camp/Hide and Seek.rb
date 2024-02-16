class Camping
	#as long as event name contains "Hiding_Spot", it will be chosen as a hiding spot by the player's pokemon
	def findHidingSpots
		@hidingSpots = []
		#get map events
		$game_map.events.values.each {|event|
			#if name contains "Hiding_Spot", add it to the list of available hiding spots, the array @hidingSpots
			@hidingSpots.push(event) if event.name.match(/Hiding_Spot/i)
		} #end of $game_map.events.values.each {|event|
	end
	
	def assignHidingSpots
		hidingSpotsAvailable = @hidingSpots.clone
		for i in 0...$PokemonGlobal.campers.length
			print "We need more hiding spots on this map" if hidingSpotsAvailable.length <= 0
			spotChosen = hidingSpotsAvailable.sample
			$PokemonGlobal.campers[i].hideAndSeekSpot = spotChosen
			$PokemonGlobal.campers[i].hideAndSeekFound = false
			hidingSpotsAvailable.delete(spotChosen)
		end #for i in 0...$PokemonGlobal.campers.length
		#print @hidingSpots
	end #def assignHidingSpots

	def self.checkHidingSpot(spotChecked)
		#print "checking if pkmn is hiding in #{spot}"
		
		#check all pokemon in the party, and if they haven't been found, check if this is their hiding spot
		for i in 0...$PokemonGlobal.campers.length
			#get the pokemon in the party
			pkmn = $PokemonGlobal.campers[i]
			next if pkmn.hideAndSeekFound
			if pkmn.hideAndSeekFound == false
				#is this $PokemonGlobal.campers[i]'s hiding spot event?
				if spotChecked == pkmn.hideAndSeekSpot
					self.foundPkmn(pkmn)
				end #if spotChecked == pkmn.hideAndSeekSpot
			end #if pkmn.hideAndSeekFound == false
		end #for i in 0...$PokemonGlobal.campers.length
	end #def checkHidingSpot
	
	def self.foundPkmn(pkmn)
		print "you found #{pkmn.name}!"
		pkmn.hideAndSeekFound = true
		self.leapOut(pkmn)
		#check how many pkmn are still hiding and end hide and seek round if none left hiding
		self.howManyLeft
	end #def self.foundPkmn(pkmn)
	
	def self.leapOut(pkmn)
		#get the event we just talked to
		hidingSpotEvent = $game_player.pbFacingEvent
		
		#set move route of corresponding camper event to move to hiding spot
		pkmn.campEvent.moveto(hidingSpotEvent.x, hidingSpotEvent.y)
		
		#get direction player is facing
		case $game_player.direction
		when 2 #down
			desiredX = $game_player.x
			desiredY = $game_player.y-1
		when 4 #left
			desiredX = $game_player.x+1
			desiredY = $game_player.y
		when 6 #right
			desiredX = $game_player.x-1
			desiredY = $game_player.y
		when 8 #up
			desiredX = $game_player.x
			desiredY = $game_player.y+1
		end #case $game_player.direction
		
		#try going behind player if it's passable
		#passable?(x, y, direction, strict=true)
		#if behind the player is not passable
		
		
		#$game_map.passable?(facing[1], facing[2], $game_player.direction, $game_player)
		#if !pkmn.campEvent.passable?(desiredX, desiredY, 2, true)
		if !$game_map.passable?(desiredX, desiredY, 2, pkmn.campEvent)
			#try to the left of the player
			desiredX = $game_player.x-1
			desiredY = $game_player.y
		end #if !pkmn.campEvent.passable? - behind player
		
		#if left of the player is not passable
		#if !pkmn.campEvent.passable?(desiredX, desiredY, 2, true)
		if !$game_map.passable?(desiredX, desiredY, 2, pkmn.campEvent)
			#try to the right of the player
			desiredX = $game_player.x+1
			desiredY = $game_player.y
		end #if !pkmn.campEvent.passable? - left of player
		
		#if right of the player is not passable
		#if !pkmn.campEvent.passable?(desiredX, desiredY, 2, true)
		if !$game_map.passable?(desiredX, desiredY, 2, pkmn.campEvent)
			#try below the player
			desiredX = $game_player.x
			desiredY = $game_player.y+1
		end #if !pkmn.campEvent.passable? - right of player
		
		#if below the player is not passable
		#if !pkmn.campEvent.passable?(desiredX, desiredY, 2, true)3
		if !$game_map.passable?(desiredX, desiredY, 2, pkmn.campEvent)
			#try above the player
			desiredX = $game_player.x
			desiredY = $game_player.y-1
		end #if !pkmn.campEvent.passable? - below player
		
		distanceX = (hidingSpotEvent.x - desiredX) * -1
		distanceY = (hidingSpotEvent.y - desiredY) * -1
		
		#make camper event jump from hiding spot to passable location
		pbMoveRoute(pkmn.campEvent, [
			PBMoveRoute::Jump, distanceX, distanceY
		])
	end #def self.leapOut(pkmn)
	
	def self.howManyLeft
		#check all pkmn in the party and see if any are still not found
		for i in 0...$PokemonGlobal.campers.length
			pkmn = $PokemonGlobal.campers[i]
			return if pkmn.hideAndSeekFound == false
		end #for i in 0...$Trainer.pokemon_count
		
		#say when we've found the whole team
		print "found them all!"
		EventHandlers.remove(:on_player_interact, :hideAndSeek_CheckSpot)
		self.goAgain
	end #def howManyLeft

	def self.goAgain
	end #goAgain

	def hideAndSeek
		findHidingSpots
		assignHidingSpots
	end #def hideAndSeek
	
	#on_player_interact with hiding spot
	EventHandlers.add(:on_player_interact, :hideAndSeek_CheckSpot, proc {
		facingEvent = $game_player.pbFacingEvent
		self.checkHidingSpot(facingEvent) if facingEvent && facingEvent.name.match(/Hiding_Spot/i)
	})

end #class Camping
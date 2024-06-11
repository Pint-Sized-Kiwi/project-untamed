#Track Setup
class CrustangRacing
	
	def self.detectInput
		Input.update
		
		#movement up and down
		#@trackBorderTopY
		#@trackBorderBottomY
		if Input.press?(Input::UP)
			@racerPlayer[:RacerSprite].y -= CrustangRacingSettings::BASE_STRAFE_SPEED if @racerPlayer[:RacerSprite].y > @trackBorderTopY
		elsif Input.press?(Input::DOWN)
			@racerPlayer[:RacerSprite].y += CrustangRacingSettings::BASE_STRAFE_SPEED if @racerPlayer[:RacerSprite].y < @trackBorderBottomY
		end
		
		#moves
		if Input.trigger?(CrustangRacingSettings::BOOST_BUTTON) && @racerPlayer[:BoostCooldownTimer] <= 0
			@sprites["boostButton"].frame = 1
			@racerPlayer[:CurrentSpeed] = CrustangRacingSettings::BOOST_SPEED
			@racerPlayer[:BoostTimer] = CrustangRacingSettings::BOOST_LENGTH_SECONDS * Graphics.frame_rate
			self.beginCooldown(@racerPlayer, 0)
			
			#give other racers temporary boost for testing purposes
			@racer1[:CurrentSpeed] = CrustangRacingSettings::BOOST_SPEED + 2
			@racer2[:CurrentSpeed] = CrustangRacingSettings::BOOST_SPEED - 2
			@racer3[:CurrentSpeed] = CrustangRacingSettings::BOOST_SPEED + 3
			
		end
		if Input.release?(CrustangRacingSettings::BOOST_BUTTON)
			@sprites["boostButton"].frame = 0
		end
		
	end #self.detectInput
	
	def self.updateOverlayText
		#Laps and Placement
		#@lapsAndPlaceOverlay
		#drawFormattedTextEx(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil, lineheight = 32)
		if @lastLapCount != @racerPlayer[:LapCount]
			@lastLapCount = @racerPlayer[:LapCount]
			@lapsAndPlaceOverlay.clear
		end
		drawFormattedTextEx(@lapsAndPlaceOverlay, 20, 8, Graphics.width, "Place: 4th", @overlayBaseColor, @overlayShadowColor)
		drawFormattedTextEx(@lapsAndPlaceOverlay, 20, 40, Graphics.width, "Lap: #{@lastLapCount}", @overlayBaseColor, @overlayShadowColor)
		
		#KPH
		if @lastCurrentSpeed != @racerPlayer[:CurrentSpeed].truncate(1).to_f
			#@lastCurrentSpeed = @racerPlayer[:CurrentSpeed].truncate(1).to_f      #draw with a decimal place
			@lastCurrentSpeed = @racerPlayer[:CurrentSpeed].floor     #draw with no decimal place
			@khpOverlay.clear
		end
		
		#drawFormattedTextEx(bitmap, x, y, width, text, baseColor = nil, shadowColor = nil, lineheight = 32)
		drawFormattedTextEx(@khpOverlay, 120, 45, Graphics.width, "KM/H: #{@lastCurrentSpeed*CrustangRacingSettings::KPH_MULTIPLIER}", @overlayBaseColor, @overlayShadowColor)
	end #def self.updateOverlayText
		
	def self.moveSpritesWithTrack
		#move sprites like the lap line, any obstacles, etc. along with the track as it passes by
		#lap line
		#@sprites["lapLine"].x -= @racerPlayer[:CurrentSpeed]
		#@sprites["lapLineCopy"].x -= @racerPlayer[:CurrentSpeed]
		
	end #def self.moveSpritesWithTrack
	
	def self.trackMovementUpdate #no need to modify
		@sprites["track1"].x -= @racerPlayer[:CurrentSpeed]
		@sprites["track2"].x -= @racerPlayer[:CurrentSpeed]
		
		#track image looping logic
		#if track2 is now on the screen, track2's X is now 0 or less, and track1's X is still < 0, move track1 to the end of track2 for a loop
		if @sprites["track2"].x <= 0 && @sprites["track1"].x < 0
			@sprites["track1"].x = @sprites["track2"].x
			#send track2 to the back of track1
			@sprites["track2"].x = @sprites["track1"].x + @sprites["track1"].width
		end
		
		#hotfix for track2 not being at the correct X
		if @sprites["track1"].x < @sprites["track1"].width - 500 #just a bullshit number not far from 0
			#move track2 to the end of track1 for good measure
			#YOU GET BACK THERE AT THE END RIGHT THIS INSTANT YOUNG SPRITE
			@sprites["track2"].x = @sprites["track1"].x + @sprites["track1"].width
		end
		
		#bottom of the tracks
		@sprites["track1Bottom"].x = @sprites["track1"].x
		@sprites["track2Bottom"].x = @sprites["track2"].x
		
		#lap line
		@sprites["lapLine"].x = @sprites["track1"].x + @lapLineStartingX
		@sprites["lapLineCopy"].x = @sprites["track2"].x + @lapLineStartingX		
	end #def trackMovementUpdate
	
	def self.checkForLap #################do I need to check if the racers come in contact with the copy lap line?
		#Lapping: true, LapCount: 0, CurrentPlacement: 1,
		###################################
		#============= Racer1 =============
		###################################
		if self.collides_with?(@racer1[:RacerSprite],@sprites["lapLine"]) && @racer1[:Lapping] != true
			@racer1[:LapCount] += 1
			@racer1[:Lapping] = true
		end
		@racer1[:Lapping] = false if !self.collides_with?(@racer1[:RacerSprite],@sprites["lapLine"])
		
		###################################
		#============= Racer2 =============
		###################################
		if self.collides_with?(@racer2[:RacerSprite],@sprites["lapLine"]) && @racer2[:Lapping] != true
			@racer2[:LapCount] += 1
			@racer2[:Lapping] = true
		end
		@racer2[:Lapping] = false if !self.collides_with?(@racer2[:RacerSprite],@sprites["lapLine"])
		
		###################################
		#============= Racer3 =============
		###################################
		if self.collides_with?(@racer3[:RacerSprite],@sprites["lapLine"]) && @racer3[:Lapping] != true
			@racer3[:LapCount] += 1
			@racer3[:Lapping] = true
		end
		@racer3[:Lapping] = false if !self.collides_with?(@racer3[:RacerSprite],@sprites["lapLine"])
		
		###################################
		#============= Player =============
		###################################
		#if the racer is touching the lap line and not currently 'lapping', add a lap to the racer's count
		if self.collides_with?(@racerPlayer[:RacerSprite],@sprites["lapLine"]) && @racerPlayer[:Lapping] != true
			@racerPlayer[:LapCount] += 1
			@racerPlayer[:Lapping] = true
			print "racer1 has gone #{@racer1[:LapCount]} laps, racer2 has gone #{@racer2[:LapCount]} laps, and racer3 has gone #{@racer3[:LapCount]} laps"
		end
		@racerPlayer[:Lapping] = false if !self.collides_with?(@racerPlayer[:RacerSprite],@sprites["lapLine"])
	end #def self.checkForLap
	
	def self.updateRacerPositionOnTrack
		#this is the position on the entire track, not the track overview
		###################################
		#============= Player =============
		###################################
		@racerPlayer[:PositionOnTrack] = @sprites["track1"].x.abs

		#calculate the position of the other racers differently than the player. It would involve their X and the X of the track
		###################################
		#============= Racer1 =============
		###################################
		@racer1[:PositionOnTrack] += @racer1[:CurrentSpeed].floor
		#reset position to near the beginning of the track when we get to the end of it
		if @racer1[:PositionOnTrack] > @sprites["track1"].width
			amountOverTrackLength = @racer1[:PositionOnTrack] - @sprites["track1"].width
			@racer1[:PositionOnTrack] = amountOverTrackLength
		end		
		
		###################################
		#============= Racer2 =============
		###################################
		@racer2[:PositionOnTrack] += @racer2[:CurrentSpeed].floor
		#reset position to near the beginning of the track when we get to the end of it
		if @racer2[:PositionOnTrack] > @sprites["track1"].width
			amountOverTrackLength = @racer2[:PositionOnTrack] - @sprites["track1"].width
			@racer2[:PositionOnTrack] = amountOverTrackLength
		end		
		
		###################################
		#============= Racer3 =============
		###################################
		@racer3[:PositionOnTrack] += @racer3[:CurrentSpeed].floor
		#reset position to near the beginning of the track when we get to the end of it
		if @racer3[:PositionOnTrack] > @sprites["track1"].width
			amountOverTrackLength = @racer3[:PositionOnTrack] - @sprites["track1"].width
			@racer3[:PositionOnTrack] = amountOverTrackLength
		end
	end #def self.updateRacerPositionOnTrack
	
	def self.updateRacerPositionOnScreen
		#this is the X on the screen, not the track or track overview
		###################################
		#============= Racer1 =============
		###################################
		#calculate normally based on track1's X
		@racer1[:RacerSprite].x = @sprites["track1"].x + @racerStartingX + @racer1[:PositionOnTrack]
		
		#keep the racer on screen if they reach track2 before we do
		#if track2 is on the screen, and the racer's position on the track is <= the width of track2, set the racer's position on the track relative to track2's x
		if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer1[:PositionOnTrack] <= @sprites["track2"].width
			#make the racer's X relative to track2's x
			@racer1[:RacerSprite].x = @sprites["track2"].x + @racerStartingX + @racer1[:PositionOnTrack]
		end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer1[:PositionOnTrack] <= @sprites["track2"].width
		
		#keep the racer on screen if we reach track2 before they do
		if @racer1[:RacerSprite].x > @sprites["track1"].width - @racer1[:RacerSprite].width
			@racer1[:RacerSprite].x -= @sprites["track1"].width
		end
		
		#if the racer's sprite is not on the screen, where is it?
		#print @racer1[:RacerSprite].x if !@racer1[:RacerSprite].x.between?(0-@racer1[:RacerSprite].width,Graphics.width-1)
		
		###################################
		#============= Racer2 =============
		###################################
		#calculate normally based on track1's X
		@racer2[:RacerSprite].x = @sprites["track1"].x + @racerStartingX + @racer2[:PositionOnTrack]
		
		#keep the racer on screen if they reach track2 before we do
		#if track2 is on the screen, and the racer's position on the track is <= the width of track2, set the racer's position on the track relative to track2's x
		if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer2[:PositionOnTrack] <= @sprites["track2"].width
			#make the racer's X relative to track2's x
			@racer2[:RacerSprite].x = @sprites["track2"].x + @racerStartingX + @racer2[:PositionOnTrack]
		end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer2[:PositionOnTrack] <= @sprites["track2"].width
		
		#keep the racer on screen if we reach track2 before they do
		if @racer2[:RacerSprite].x > @sprites["track1"].width - @racer2[:RacerSprite].width
			@racer2[:RacerSprite].x -= @sprites["track1"].width
		end
		
		###################################
		#============= Racer3 =============
		###################################
		#calculate normally based on track1's X
		@racer3[:RacerSprite].x = @sprites["track1"].x + @racerStartingX + @racer3[:PositionOnTrack]
		
		#keep the racer on screen if they reach track2 before we do
		#if track2 is on the screen, and the racer's position on the track is <= the width of track2, set the racer's position on the track relative to track2's x
		if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer3[:PositionOnTrack] <= @sprites["track2"].width
			#make the racer's X relative to track2's x
			@racer3[:RacerSprite].x = @sprites["track2"].x + @racerStartingX + @racer3[:PositionOnTrack]
		end #if @sprites["track2"].x.between?(1-@sprites["track2"].width,Graphics.width-1) && @racer3[:PositionOnTrack] <= @sprites["track2"].width
		
		#keep the racer on screen if we reach track2 before they do
		if @racer3[:RacerSprite].x > @sprites["track1"].width - @racer3[:RacerSprite].width
			@racer3[:RacerSprite].x -= @sprites["track1"].width
		end
	end #def self.updateRacerPositionOnTrack
	
	def self.accelerateDecelerate
		###################################
		#============= Racer1 =============
		###################################
		if @racer1[:CurrentSpeed].floor < @racer1[:DesiredSpeed]
			#accelerate
			@racer1[:CurrentSpeed] += @accelerationAmountPerFrame
		end
		
		#decelerate
		if @racer1[:CurrentSpeed].floor > @racer1[:DesiredSpeed] && @racer1[:BoostTimer] <= 0
			#decelerate
			@racer1[:CurrentSpeed] -= @decelerationAmountPerFrame
		end
		
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racer1[:CurrentSpeed].floor == @racer1[:DesiredSpeed]
			@racer1[:CurrentSpeed] = @racer1[:CurrentSpeed].floor
		end
		
		#update boost timers for racers
		@racer1[:BoostTimer] -= 1
		
		###################################
		#============= Racer2 =============
		###################################
		if @racer2[:CurrentSpeed].floor < @racer2[:DesiredSpeed]
			#accelerate
			@racer2[:CurrentSpeed] += @accelerationAmountPerFrame
		end
		
		#decelerate
		if @racer2[:CurrentSpeed].floor > @racer2[:DesiredSpeed] && @racer2[:BoostTimer] <= 0
			#decelerate
			@racer2[:CurrentSpeed] -= @decelerationAmountPerFrame
		end
		
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racer2[:CurrentSpeed].floor == @racer2[:DesiredSpeed]
			@racer2[:CurrentSpeed] = @racer2[:CurrentSpeed].floor
		end
		
		#update boost timers for racers
		@racer2[:BoostTimer] -= 1
		
		###################################
		#============= Racer3 =============
		###################################
		if @racer3[:CurrentSpeed].floor < @racer3[:DesiredSpeed]
			#accelerate
			@racer3[:CurrentSpeed] += @accelerationAmountPerFrame
		end
		
		#decelerate
		if @racer3[:CurrentSpeed].floor > @racer3[:DesiredSpeed] && @racer3[:BoostTimer] <= 0
			#decelerate
			@racer3[:CurrentSpeed] -= @decelerationAmountPerFrame
		end
		
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racer3[:CurrentSpeed].floor == @racer3[:DesiredSpeed]
			@racer3[:CurrentSpeed] = @racer3[:CurrentSpeed].floor
		end
		
		#update boost timers for racers
		@racer3[:BoostTimer] -= 1
		
		###################################
		#============= Player =============
		###################################
		if @racerPlayer[:CurrentSpeed].floor < @racerPlayer[:DesiredSpeed]
			#accelerate
			@racerPlayer[:CurrentSpeed] += @accelerationAmountPerFrame
		end
		
		#decelerate
		if @racerPlayer[:CurrentSpeed].floor > @racerPlayer[:DesiredSpeed] && @racerPlayer[:BoostTimer] <= 0
			#decelerate
			@racerPlayer[:CurrentSpeed] -= @decelerationAmountPerFrame
		end
		
		#after speeding up or slowing down, if the floor of the current speed is exactly the desired speed, set the current speed to its floor
		if @racerPlayer[:CurrentSpeed].floor == @racerPlayer[:DesiredSpeed]
			@racerPlayer[:CurrentSpeed] = @racerPlayer[:CurrentSpeed].floor
		end
		
		#update boost timers for racers
		@racerPlayer[:BoostTimer] -= 1
		
	end #def self.accelerateDecelerate
	
	def self.main
		self.setup
		self.setupRacerHashes
		self.drawContestants
		self.drawContestantsOnOverview
		self.drawMovesUI
		self.setMiscVariables
		
		loop do
			Graphics.update
			pbUpdateSpriteHash(@sprites)
			self.trackMovementUpdate #keep this as high up in the loop as possible below Graphics updates
			self.moveSpritesWithTrack
			self.updateRacerPositionOnTrack
			self.updateRacerPositionOnScreen
			self.trackOverviewMovementUpdate
			self.detectInput
			self.updateCooldownTimers
			self.accelerateDecelerate
			self.updateOverlayText
			self.checkForLap
		end
	end #def self.main
	
end #class CrustangRacing
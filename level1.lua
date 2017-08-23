-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()

--------------------------------------------	

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	local bounceCount = 0

	-- create a grey rectangle as the backdrop
	local background = display.newImageRect("sky3.jpg", screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0

	--display x/y input
	local spawnX = native.newTextField( screenW/2, -20, 50, 15 )
	spawnX.inputType = "number"
	local spawnY = native.newTextField( screenW/2, 0, 50, 15 )
    spawnY.inputType = "number"
    local spawnRotation = native.newTextField( screenW/2, 20, 50, 15 )
    spawnRotation.inputType = "number"

	local xVal = 0
	local yVal = 0
	local rotation = 0

	local function textListenerX(event)
		if (event.phase == "ended") then
		 	xVal = tonumber(event.target.text)
		end
	end

	local function textListenerY(event)
		if (event.phase == "ended") then
		 	yVal = tonumber(event.target.text)
		end
	end

	local function textListenerRotation(event)
		if (event.phase == "ended") then
		 	rotation = tonumber(event.target.text)
		end
	end

	spawnX:addEventListener( "userInput", textListenerX )
	spawnY:addEventListener( "userInput", textListenerY )
	spawnRotation:addEventListener( "userInput", textListenerRotation )


	--button to get values
	local widget = require( "widget" )
 
	-- Function to handle button events
	local function handleButtonEvent( event )
	 
	    if ( "ended" == event.phase ) then
	        if (rotation ~= 0) then
	        	local rect = display.newRect(math.random(10,screenW), screenH/2, xVal, yVal)
	        	rect.rotation = rotation;

	        	--generate random rect colors (TODO: different colors mean different densities later on)
	        	local randRed  = math.random(0,1)
	        	local randGreen  = math.random(0,1)
	        	local randBlue  = math.random(0,1)

	        	rect:setFillColor(randRed,randGreen,randBlue)
	        	sceneGroup:insert(rect)
	        	physics.addBody( rect, "static")
	        	function rect:touch( event )
				 if event.phase == "began" then
				  -- first we set the focus on the object
				  display.getCurrentStage():setFocus( self, event.id )
				  self.isFocus = true

				  -- then we store the original x and y position
				  self.markX = self.x
				  self.markY = self.y

				 elseif self.isFocus then

				  if event.phase == "moved" then
				   -- then drag our object
				   self.x = event.x - event.xStart + self.markX
				   self.y = event.y - event.yStart + self.markY
				  elseif event.phase == "ended" or event.phase == "cancelled" then
				   -- we end the movement by removing the focus from the object
				   display.getCurrentStage():setFocus( self, nil )
				   self.isFocus = false
				 end
				 end

				 -- return true so Corona knows that the touch event was handled properly
				 return true
				end

			rect:addEventListener("touch", rect )
	        end
	    end
	end
	 
	-- Create the widget
	local button1 = widget.newButton(
	    {
	        left = screenW/2-35,
	        top = 30,
	        id = "coordinateButton",
	        label = "Spawn!",
	        onEvent = handleButtonEvent,
		    emboss = true,
	        -- Properties for a rounded rectangle button
	        shape = "roundedRect",
	        width = 70,
	        height = 30,
	        cornerRadius = 2,
	        fillColor = { default={1,1,1,1}, over={1,0.1,0.7,0.4} },
	        strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
	        strokeWidth = 4
	    }
	)
	
	-- make a crate (off-screen), position it, and rotate slightly
	local crate = display.newCircle(90, 90, 20)
	crate.rotation = 0

	crate.fill = {type="image", filename="ball.png"}
	
	-- add physics to the crate
	physics.addBody( crate, { density=0.1, bounce=1, friction=0.5, radius=20} )
  crate.myName = "crate"
	
	-- create a grass object and add physics (with custom shape)
	local grass = display.newImageRect( "ground.png", screenW, 82 )
	grass.anchorX = 0
	grass.anchorY = 1
	grass.x, grass.y = 0, display.contentHeight

	--create left/right borders and add physics

	local leftBorder = display.newRect(0,screenH/2,1,screenH*2)
	physics.addBody(leftBorder, "static", {bounce=0.2,friction=0.3})

	local rightBorder = display.newRect(screenW,screenH/2,1,screenH*2)
	physics.addBody(rightBorder, "static", {bounce=0.2,friction=0.3})
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local grassShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	physics.addBody( grass, "static", { friction=0.8, shape=grassShape } )
	
	-- create a target to hit
	local target = display.newImage("tile.jpg")
	target.x = 3*display.contentWidth/4
	target.y = display.contentHeight/2
	physics.addBody(target, "static");
	target.myName = "target"
	
	local function onLocalCollision (self, event)
		
	end
	crate.collision = onLocalCollision
	crate:addEventListener("collision")

	local function animationHeartBeat(event)
		local vx,vy = crate:getLinearVelocity()
		if (math.abs(vy)<1) then
		 crate:setLinearVelocity( 0, -100 )
		end
	end
	timer.performWithDelay( 1000, animationHeartBeat)
	
	local function onTargetCollision (self, event)
		if ( event.phase == "ended" ) then
			spawnX:removeSelf( )
			spawnY:removeSelf( )
			spawnRotation:removeSelf( )

			composer.gotoScene( "win" )
		end
	end
	target.collision = onTargetCollision
	target:addEventListener("collision")
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( spawnX )
	sceneGroup:insert( spawnY )
	sceneGroup:insert( spawnRotation )
	sceneGroup:insert( button1 )
	sceneGroup:insert( grass)
	sceneGroup:insert( crate )
	sceneGroup:insert( target )
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		physics.stop()

		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = nil
	
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
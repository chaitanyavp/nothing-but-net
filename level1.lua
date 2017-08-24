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

	local spawnCount = 10

	-- create a grey rectangle as the backdrop
	local background = display.newImageRect("sky3.jpg", screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background.id = "background"

	--counter for lines spawned
	local spawnCounter = display.newText( tostring(spawnCount), screenW*0.80, screenH*0.1, system.nativefont,30 )

	local function lose()
		local options = {
			effect = "fromBottom",
			params = {
				stars = 0,
				score = 0,
				win = false
			}
		}

		composer.gotoScene( "win", options)
	end

	-- add a touch listener to draw line.
	local drawX, drawY
	local drawing = display.newGroup()

	local function onDrawingCollision(self, event)
		if ( event.phase == "ended" ) 
		and (event.other.myName == "crate") then

			if spawnCount == 0 then
				lose()
			else
				local xVel,yVel = event.other:getLinearVelocity()
				event.other:setLinearVelocity(xVel, 1.4*yVel)
				event.other:rotate(45)
			    spawnCount = spawnCount - 1
		    	spawnCounter.text = spawnCount
				drawing:removeSelf()
				drawing = display.newGroup()
				sceneGroup:insert(drawing)
			end
		end
	end

	local function onBackgroundTouch( event )
	    if ( event.phase == "began" ) then
	    	drawX = event.x
	    	drawY = event.y
	    elseif ( event.phase == "moved" ) then
	    	local rect = display.newRect(event.x,event.y,8,8)
	    	rect:setFillColor(0)
	    	physics.addBody( rect, "static")
	    	local line = display.newLine(drawX,drawY,event.x,event.y)
	    	line.strokeWidth = 10
	    	line:setStrokeColor(0)
	    	drawing:insert( rect )
			drawing:insert( line )
	    	drawX = event.x
	    	drawY = event.y
			rect.collision = onDrawingCollision
			rect:addEventListener("collision")
		end
	    return true
	end
	background:addEventListener( "touch", onBackgroundTouch )

	
	-- make a crate (off-screen), position it, and rotate slightly
	local crate = display.newCircle(90, 90, 20)
	crate.rotation = 10

	crate.fill = {type="image", filename="ball.png"}
	
	-- add physics to the crate
	physics.addBody( crate, { density=0.1, bounce=0.8, friction=0.5, radius=20} )
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
	local target = display.newImage("net.png")
	target.x = 3*screenW/4
	target.y = screenH/2
	physics.addBody(target, "static");
	target.myName = "target"
	
	local targetHitbox = display.newRect(3*screenW/4, screenH/2-(target.contentHeight/2), 
		3*target.contentWidth/4, target.contentHeight/4)
	targetHitbox:setFillColor(0,0,0,0)
	physics.addBody(targetHitbox, "static");
	targetHitbox.myName = "targetHitbox"

	local function animationHeartBeat(event)
		local vx,vy = crate:getLinearVelocity()
		if (math.abs(vy)<1) then
		 crate:setLinearVelocity( 0, -100 )
		end
	end
	timer.performWithDelay( 1000, animationHeartBeat)
	
	local function onTargetCollision (self, event)
		if ( event.phase == "ended" ) 
		and (event.other.myName == "crate") then
			local starCount
			if (spawnCount <= 1) then
				starCount = 3
			end
		    if (spawnCount == 2) then
				starCount = 2
			end
			if (spawnCount > 2) then 
				starCount = 1
			end
	 

			local options = {
				effect = "fromTop",
				params = {
					stars = starCount,
					score = spawnCount,
					win = true
				}
			}

			composer.gotoScene( "win", options)
		end
	end
	targetHitbox.collision = onTargetCollision
	targetHitbox:addEventListener("collision")

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( spawnCounter )
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
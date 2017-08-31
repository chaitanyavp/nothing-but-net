-----------------------------------------------------------------------------------------
--
-- level.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start();physics.pause()

--------------------------------------------	

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

--DECLARE STAR COUNT HERE:
local threeStarCondition
local twoStarCondition
local oneStarCondition
--Number of tries allowed
local spawnTries

local netX
local netY

local level

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	--INITIALIZE PARAMS:
	threeStarCondition = event.params.threeStarCondition
	twoStarCondition = event.params.twoStarCondition
	oneStarCondition = event.params.oneStarCondition
	spawnTries = event.params.spawnTries
	netX = event.params.netX
	netY = event.params.netY
	level = event.params.currentLevel
	obstacles = event.params.obstacles

	local sceneGroup = self.view

	local spawnCount = 10

	-- create a grey rectangle as the backdrop
	local background = display.newImageRect("images/sky3.jpg", screenW, screenH*1.5 )
	background.anchorX = 0
	background.anchorY = 0.1
	background.id = "background"

	--ball rest rectangle
	local rest = display.newImageRect("images/rest-texture.jpg",40,10)
	rest.x,rest.y = screenW*0.283,screenH*0.24
	physics.addBody(rest,"static")

	--counter for lines spawned
	local linesLeftString = display.newText("Lines Left: ", screenW*0.60, 0, system.nativefont,25 )

	local spawnCounter = display.newText(tostring(spawnCount), screenW*0.85, 0, system.nativefont,30 )
	spawnCounter:setTextColor(1,0.9,0)

	local function lose()
		local options = {
			effect = "fromBottom",
			params = {
				stars = 0,
				score = 0,
				win = false,
				currentLevel = level
			}
		}

		composer.gotoScene( "scenes.win", options)
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
			    spawnCount = spawnCount - 1
		    	spawnCounter.text = spawnCount
		    	if (spawnCount < spawnTries-threeStarCondition) then
		    		spawnCounter:setTextColor(0.8,0.8,0.8)
		    	end
		    	if (spawnCount < spawnTries-twoStarCondition) then
		    		spawnCounter:setTextColor(0.9,0.4,0.1)
		    	end


				drawing:removeSelf()
				drawing = display.newGroup()
				sceneGroup:insert(drawing)
			end
		end
	end

	local first = 0

	local function onBackgroundTouch( event )
	    if ( event.phase == "began" ) then
	    	drawX = event.x
	    	drawY = event.y
	    	if first == 0 then
	    	rest:removeSelf()
	    	first = 1
	    end
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
	crate:setFillColor(white)

	crate.fill = {type="image", filename="images/ball.png"}
	
	-- add physics to the crate
	physics.addBody( crate, { density=0.1, bounce=0.8, friction=0.5, radius=20} )
	crate.myName = "crate"
	
	-- create a grass object and add physics (with custom shape)
	local grass = display.newImageRect( "images/rest-texture.jpg", screenW, 82 )
	grass.anchorX = 0
	grass.anchorY = 0
	grass.x, grass.y = 0, display.contentHeight

	--create left/right borders and add physics

	local leftBorder = display.newRect(0,screenH/2,1,screenH*2)
	leftBorder:setFillColor(0,0,0,0)
	physics.addBody(leftBorder, "static", {bounce=0.2,friction=0.3})

	local rightBorder = display.newRect(screenW,screenH/2,1,screenH*2)
	rightBorder:setFillColor(0,0,0,0)
	physics.addBody(rightBorder, "static", {bounce=0.2,friction=0.3})
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local grassShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	physics.addBody( grass, "static", { friction=0.8, shape=grassShape } )
	
	-- create a target to hit
	local target = display.newImage("images/net.png")
	target.x = netX
	target.y = netY
	physics.addBody(target, "static");
	target.myName = "target"
	
	local targetHitbox = display.newRect(netX, netY-(target.contentHeight/2), 
		3*target.contentWidth/4, target.contentHeight/4)
	targetHitbox:setFillColor(0,0,0,0)
	physics.addBody(targetHitbox, "static");
	targetHitbox.myName = "targetHitbox"
	
	local function onTargetCollision (self, event)
		if ( event.phase == "ended" ) 
		and (event.other.myName == "crate") then
			local starCount
			if ((spawnTries-spawnCount) <= threeStarCondition) then
				starCount = 3
		    elseif ((spawnTries-spawnCount) == twoStarCondition) then
				starCount = 2
			elseif((spawnTries-spawnCount) >= oneStarCondition ) then 
				starCount = 1
			end

			local options = {
				effect = "fromTop",
				params = {
					stars = starCount,
					score = spawnCount,
					win = true,
					currentLevel = level
				}
			}

			composer.gotoScene( "scenes.win", options)
		end
	end
	targetHitbox.collision = onTargetCollision
	targetHitbox:addEventListener("collision")

	--restart level button
	local function restartLevel(event)
		if (event.phase == "ended") then
		composer.removeScene("scenes.levels.level"..level)
		drawing:removeSelf()
		crate:removeSelf()
		if first == 0 then 
			rest:removeSelf()
			first = -1
		end
		composer.removeScene("scenes.levels.static_level")
		composer.gotoScene( "scenes.levels.level"..level )
		end
		
		return true	-- indicates successful touch
	end

	--restart level button
	local restartButton = display.newImageRect("images/restart_game.png",20,20)
	restartButton.x = screenW*0.1
	restartButton.y = 0
	restartButton:addEventListener("touch",restartLevel)

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert(linesLeftString)
	sceneGroup:insert( rest )
	sceneGroup:insert( restartButton )
	sceneGroup:insert( spawnCounter )
	sceneGroup:insert( grass)
	sceneGroup:insert( crate )
	sceneGroup:insert( target )

		--add obstacles last
	for i, obstacle in ipairs(obstacles) do
		obstacleRect = display.newRect(obstacle[1],obstacle[2],obstacle[3],obstacle[4])
		obstacleRect:setFillColor(25,0,25,255)
		physics.addBody(obstacleRect, "static", {bounce=0.2,friction=0.3})
		sceneGroup:insert( obstacleRect )
	end

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
		timer.performWithDelay(3000,physics.start())
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
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = nil

	if rest then
		rest:removeSelf()
		rest = nil
	end
	
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
-----------------------------------------------------------------------------------------
--
-- win.lua
--
-----------------------------------------------------------------------------------------

--TODO: find way to pass level score, # of stars and current level number
--level score displayed on screen
--# of stars to display correct # of stars
--current level number to be able to know/proceed to next level

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local playBtn
local replayBtn
local menuBtn
--GET SCORE PASSED IN


function scene:create( event )
	local sceneGroup = self.view

	-- 'onRelease' event listener for playBtn
	local function onReplayBtnRelease()
		
		-- go to level1.lua scene
		--temp, change when level# passed
		composer.removeScene("scenes.levels.level"..event.params.currentLevel)
		composer.removeScene("scenes.levels.static_level")
		composer.removeScene("scenes.win")
		composer.gotoScene( "scenes.levels.level"..event.params.currentLevel,"fromBottom", 300 )
		
		return true	-- indicates successful touch
	end

	local function onNextBtnRelease()
		
		-- go to level1.lua scene
		--temp, change when level# passed
		composer.removeScene("scenes.levels.level"..event.params.currentLevel)
		composer.removeScene("scenes.levels.static_level")
		composer.removeScene("scenes.win")
		composer.gotoScene( "scenes.levels.level"..(1+event.params.currentLevel), "fromRight", 500 )
		
		return true	-- indicates successful touch
	end

	local function onMenuBtnRelease()
		
		-- go to menu.lua scene
		composer.removeScene("scenes.levels.level"..event.params.currentLevel)
		composer.removeScene("scenes.levels.static_level")
		composer.removeScene("scenes.win")
		composer.gotoScene( "scenes.menu", "fromLeft", 500 )
		
		return true	-- indicates successful touch
	end

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	-- create a grey rectangle as the backdrop
	local background = display.newImageRect( "images/background.png", display.actualContentWidth, display.actualContentHeight )
	background.x = display.contentWidth *0.5
	background.y = display.contentHeight *0.5
	--HOW THIS WORKS: black stars are rendered under gold, hide gold based on score passed in as parameter

	--Black stars (hide gold stars to see)

	local black_star1 = display.newImageRect( "images/black_star.png", 40, 45 )
	black_star1.x, black_star1.y = display.contentWidth *0.25, 50

	local black_star2 = display.newImageRect( "images/black_star.png", 40, 45 )
	black_star2.x, black_star2.y = display.contentWidth *0.50, 50

	local black_star3 = display.newImageRect( "images/black_star.png", 40, 45 )
	black_star3.x, black_star3.y = display.contentWidth *0.75, 50

	--inserting thus far to scene
	sceneGroup:insert( background )
	sceneGroup:insert( black_star1 )
	sceneGroup:insert( black_star2 )
	sceneGroup:insert( black_star3 )

	--Gold stars (shown by default)

	local function gold1()
		if (event.params.stars>=1) then
			local gold_star1 = display.newImageRect( "images/bronze_star.png", 60, 50 )
			gold_star1.x, gold_star1.y = display.contentWidth *0.25, 50
			sceneGroup:insert( gold_star1 )
		end 
	end

	timer.performWithDelay(1000,gold1)

	local function gold2()
		if (event.params.stars>=2) then
			local gold_star2 = display.newImageRect( "images/silver_star.png", 60, 50 )
			gold_star2.x, gold_star2.y = display.contentWidth *0.50, 50
			sceneGroup:insert( gold_star2 )
		end
	end
	
	timer.performWithDelay(1500,gold2)

	local function gold3()
		if (event.params.stars>=3) then
			local gold_star3 = display.newImageRect( "images/gold_star.png", 60, 50 )
			gold_star3.x, gold_star3.y = display.contentWidth *0.75, 50
			sceneGroup:insert( gold_star3 )
		end
	end
	timer.performWithDelay(2100,gold3)

	--score text
	local current_score = display.newText(event.params.score, display.contentWidth *0.5, display.contentHeight*0.3, system.nativeFont, 50 )
	
	-- create a widget button (which will loads level1.lua on release)
	playBtn = widget.newButton{
		label="Next Level",
		labelColor = { default={255}, over={128} },
		default="images/button.png",
		over="images/button-over.png",
		width=154, height=40,
		onRelease = onNextBtnRelease	-- event listener function
	}
	playBtn.x = display.contentWidth*0.5
	playBtn.y = display.contentHeight - 175


	-- create a widget button (which will loads level1.lua on release)
	replayBtn = widget.newButton{
		label="Play Again",
		labelColor = { default={255}, over={128} },
		default="images/button.png",
		over="images/button-over.png",
		width=154, height=40,
		onRelease = onReplayBtnRelease	-- event listener function
	}
	replayBtn.x = display.contentWidth*0.5
	replayBtn.y = display.contentHeight - 125

	-- create a widget button (which will loads level1.lua on release)
	menuBtn = widget.newButton{
		label="Main Menu",
		labelColor = { default={255}, over={128} },
		default="images/button.png",
		over="images/button-over.png",
		width=154, height=40,
		onRelease = onMenuBtnRelease	-- event listener function
	}
	menuBtn.x = display.contentWidth*0.5
	menuBtn.y = display.contentHeight - 75

	if event.params.win == false then
		playBtn.isVisible = false
		replayBtn.y = display.contentHeight - 150
		menuBtn.y = display.contentHeight - 100
	end
	
	-- all display objects must be inserted into group
	sceneGroup:insert( playBtn )
	sceneGroup:insert( replayBtn )
	sceneGroup:insert( menuBtn )
	sceneGroup:insert( current_score )

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
				score = event.params.score

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
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
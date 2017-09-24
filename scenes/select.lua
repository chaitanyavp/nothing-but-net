-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function mainMenuFunction()
	
	-- go to level1.lua scene
	composer.gotoScene( "scenes.menu", "fade", 500 )
	
	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local background = display.newImageRect( "images/background.png", display.contentWidth, display.contentHeight*1.5)
	background.anchorX = 0
	background.anchorY = 0.1
	sceneGroup:insert( background )

	-- create a widget button (which will loads level1.lua on release)
	mainMenu = widget.newButton{
		label="Main Menu",
		labelColor = { default={1,0,1}, over={128} },
		default="images/button.png",
		over="images/button-over.png",
		width=15, height=20,
		onRelease = mainMenuFunction	-- event listener function
	}
	mainMenu.x = display.contentWidth*0.5
	mainMenu.y = display.contentHeight - 30


	local shelfX = display.contentWidth/4
	local shelfY = display.contentHeight/5
	for i=0,8,1 do 
		local shelf = display.newImageRect( "images/shelf.png", 80, 80 )
		sceneGroup:insert( shelf )
		shelf.x = shelfX
		shelf.y = shelfY
		if (i+1)%3 == 0 then
			shelfX = display.contentWidth/4
			shelfY = shelfY + 70
		else
			shelfX = shelfX + display.contentWidth/4
		end
	end


	local level1 = widget.newButton{
		label="Level 1",
		labelColor = { default={128}, over={128} },
		width=15, height=20,
		onRelease = mainMenuFunction	-- event listener function
	}
	level1.x = display.contentWidth/4
	level1.y = display.contentHeight/5
	local level2 = widget.newButton{
		label="Level 2",
		labelColor = { default={128}, over={128} },
		width=15, height=20,
		onRelease = mainMenuFunction	-- event listener function
	}
	level2.x = display.contentWidth/2
	level2.y = display.contentHeight/5
	local level3 = widget.newButton{
		label="Level 3",
		labelColor = { default={128}, over={128} },
		width=15, height=20,
		onRelease = mainMenuFunction	-- event listener function
	}
	level3.x = 3*display.contentWidth/4
	level3.y = display.contentHeight/5
	local level4 = widget.newButton{
		label="Level 4",
		labelColor = { default={128}, over={128} },
		width=15, height=20,
		onRelease = mainMenuFunction	-- event listener function
	}
	level4.x = display.contentWidth/4
	level4.y = display.contentHeight/5 + 70
	local level5 = widget.newButton{
		label="Level 5",
		labelColor = { default={128}, over={128} },
		width=15, height=20,
		onRelease = mainMenuFunction	-- event listener function
	}
	level5.x = display.contentWidth/2
	level5.y = display.contentHeight/5 + 70
	local level6 = widget.newButton{
		label="Level 6",
		labelColor = { default={128}, over={128} },
		width=15, height=20,
		onRelease = mainMenuFunction	-- event listener function
	}
	level6.x = 3*display.contentWidth/4
	level6.y = display.contentHeight/5 + 70
	
	-- all display objects must be inserted into group
	

	sceneGroup:insert( level1)
	sceneGroup:insert( level2)
	sceneGroup:insert( level3)
	sceneGroup:insert( level4)
	sceneGroup:insert( level5)
	sceneGroup:insert( level6)

	sceneGroup:insert( mainMenu )
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
-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

--------------------------------------------	

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

function scene:create( event )
	local options = {
			effect = "fromRight",
			params = {
				threeStarCondition = 1,
				twoStarCondition = 2,
				oneStarCondition = 3,
				spawnTries = 10,
				netX = 3*screenW/4,
				netY = screenH/2,
				currentLevel = 1
			}
		}
	composer.gotoScene( "scenes.levels.static_level", options)
end


function scene:show( event )

end

function scene:hide( event )
	
end

function scene:destroy( event )

end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
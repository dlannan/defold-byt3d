------------------------------------------------------------------------------------------------------------

release       = "0"
subversion    = "001"

------------------------------------------------------------------------------------------------------------

require("byt3d/scripts/platform/setup")

------------------------------------------------------------------------------------------------------------
-- Window width
local WINwidth, WINheight, WINFullscreen = 1280, 720, 0

------------------------------------------------------------------------------------------------------------
-- Global because states need to use it themselves

gSmgr = require("byt3d/scripts/platform/statemanager")

------------------------------------------------------------------------------------------------------------
-- Require all the states we will use for the game

gSdisp 			= require("byt3d/scripts/states/common/display")
local Smain 	= require("byt3d/scripts/states/application/sample01")
--local Smain 	= require("scripts/states/application/sample02")

------------------------------------------------------------------------------------------------------------

gDir            = require("byt3d/scripts/utils/directory")

---- States
SobjMgr         = require("byt3d/scripts/states/common/object-manager")

------------------------------------------------------------------------------------------------------------
-- Register every state with the statemanager.

gSmgr:Init()
gSmgr:CreateState("Display", 		gSdisp)     -- This technically doesnt need to go to the statemanager
gSmgr:CreateState("MainApp",		Smain)

------------------------------------------------------------------------------------------------------------
-- Execute the statemanager loop
-- Exit only when all states have exited or expired.

local function Init() 
	-- Init folder system
	gDir:Init()

	-- Init display first
	gSdisp:Init(WINDOW_WIDTH, WINDOW_HEIGHT, WINFullscreen)
end 

------------------------------------------------------------------------------------------------------------

function Begin()
	gSdisp:Begin()

	SobjMgr:Begin()

	gSmgr:ChangeState("MainApp")
end

------------------------------------------------------------------------------------------------------------
-- Enter state manager loop

function RunFrame()
	
	if gSdisp:GetRunApp() and gSmgr:Run() then 

		local buttons 	= gSdisp:GetMouseButtons()
		local move 		= gSdisp:GetMouseMove()

		gSdisp:PreRender()
	    gSmgr:Update(move.x, move.y, buttons)

	    SobjMgr:Render()
		gSmgr:Render()
		
		-- This does a buffer flip.
		gSdisp:Flip()
		return 0
	else 
		return 1
	end
end 
------------------------------------------------------------------------------------------------------------

function Finish()
	SobjMgr:Finish()

	gSdisp:Finish()
	gDir:Finalize()
end 

------------------------------------------------------------------------------------------------------------

return {
	
	Init 		= Init,
	Begin 		= Begin,
	RunFrame 	= RunFrame,
	Finish 		= Finish,
}

------------------------------------------------------------------------------------------------------------

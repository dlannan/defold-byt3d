------------------------------------------------------------------------------------------------------------
-- State - Display
--
-- Decription: Setup the display for the device
-- 				Includes SDL initialisation
--				Includes EGL initialisation
--				Inlcudes Shader initialisation	

------------------------------------------------------------------------------------------------------------

require("byt3d/scripts/platform/wm")
require("byt3d/shaders/base")
	
------------------------------------------------------------------------------------------------------------

local SDisplay	= NewState()

------------------------------------------------------------------------------------------------------------

SDisplay.wm 				= nil
SDisplay.eglinfo			= nil

-- Some reasonable defaults.
SDisplay.WINwidth			= 640
SDisplay.WINheight			= 480
SDisplay.WINFullscreen		= 0

SDisplay.initComplete 		= false
SDisplay.runApp				= true

------------------------------------------------------------------------------------------------------------

function SDisplay:Init(wwidth, wheight, fs)
	
	SDisplay.WINwidth			= wwidth
	SDisplay.WINheight			= wheight
	SDisplay.WINFullscreen 		= fs
	self.initComplete = true
end

------------------------------------------------------------------------------------------------------------

function SDisplay:Begin()

	-- Assert that we have valid width and heights (simple protection)
	assert(self.initComplete == true, "Init function not called.")

	self.runApp 	= function() end 
    self.exitApp 	= function() end 
    self.flipApp 	= function() end

--	gl.glClearColor ( 0.0, 0.0, 0.0, 0.0 )
end

------------------------------------------------------------------------------------------------------------

function SDisplay:Update(mx, my, buttons)

    -- This actually generates/gets mouse position and buttons.
	-- Push them into SDisplay
	self.runApp()
end

------------------------------------------------------------------------------------------------------------

function SDisplay:PreRender()

	-- No need for clear when BG is being written
    -- TODO: Make this an optional call (no real need for it)
	gl.glClear( bit.bor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT ) )
end

------------------------------------------------------------------------------------------------------------

function SDisplay:Flip()

	self.flipApp()
end

------------------------------------------------------------------------------------------------------------

function SDisplay:Finish()

	self.exitApp()
end
	
------------------------------------------------------------------------------------------------------------

function SDisplay:GetMouseButtons()
	return self.wm.MouseButton
end

------------------------------------------------------------------------------------------------------------

function SDisplay:GetMouseMove()
	return self.wm.MouseMove
end
	
------------------------------------------------------------------------------------------------------------

function SDisplay:GetKeyDown()
	return self.wm.KeyDown
end
	
------------------------------------------------------------------------------------------------------------
	
function SDisplay:GetRunApp()
	
	return self.runApp()
end

------------------------------------------------------------------------------------------------------------

return SDisplay

------------------------------------------------------------------------------------------------------------

	
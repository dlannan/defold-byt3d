------------------------------------------------------------------------------------------------------------

--local ffi 	= package.preload.ffi()

------------------------------------------------------------------------------------------------------------

sdl = require( "byt3d/ffi/sdl" )
sdl_image = require("byt3d/ffi/sdl_image")
egl = require( "byt3d/ffi/egl" )

------------------------------------------------------------------------------------------------------------
-- This is global.. because it damn well should be!!!
WM_frameMs	= 0.0
WM_fps		= 0

------------------------------------------------------------------------------------------------------------
-- Some platform specifics

local attrib_list = {}

if ffi.os == "OSX" then

    --print('wm.display/dpy/r', wm.display, dpy, r)
    attrib_list = {
        --        egl.EGL_LEVEL, 0,
        --        egl.EGL_SURFACE_TYPE, egl.EGL_WINDOW_BIT,
        egl.EGL_RENDERABLE_TYPE, egl.EGL_OPENGL_ES2_BIT,
        --        egl.EGL_NATIVE_RENDERABLE, egl.EGL_FALSE,
        egl.EGL_DEPTH_SIZE, egl.EGL_DONT_CARE,
        egl.EGL_NONE, egl.EGL_NONE
    }
elseif ffi.os == "Windows" or ffi.os == "Linux" then

    --print('wm.display/dpy/r', wm.display, dpy, r)
    attrib_list = {
        --        egl.EGL_LEVEL, 0,
        --        egl.EGL_SURFACE_TYPE, egl.EGL_WINDOW_BIT,
        egl.EGL_RENDERABLE_TYPE, egl.EGL_OPENGL_ES2_BIT,
        --        egl.EGL_NATIVE_RENDERABLE, egl.EGL_FALSE,
        egl.EGL_DEPTH_SIZE, 24,
        egl.EGL_NONE, egl.EGL_NONE
    }
end

------------------------------------------------------------------------------------------------------------
--- Only bother using SDL for Win/Linux/OSX platforms!!
--- Use EGL only for Android and IOS.

------------------------------------------------------------------------------------------------------------
-- SDL Initialisation
-- Use SDL for windowing and events

-- TODO: Clean this up so the system can switch between pure EGL and SDL.
--		 SDL will eventually only be for byt3d Editor.
------------------------------------------------------------------------------------------------------------

function VideoMode(ww, wh, fs)

    
    gl.glViewport( 0, 0, screen.w, screen.h )
end

------------------------------------------------------------------------------------------------------------

function InitSDL(ww, wh, fs)

    print("InitSDL:",ww, wh, fs)
    VideoMode(ww, wh, fs)
	-- Get Window info
	local wminfo = ffi.new( "SDL_SysWMinfo" )
	sdl.SDL_GetVersion( wminfo.version )
	sdl.SDL_GetWMInfo( wminfo )
	
	sdl_image.IMG_Init( bit.bor(sdl_image.IMG_INIT_PNG, sdl_image.IMG_INIT_JPG) ) 
	
	local systems 		= { "win", "x11", "dfb", "cocoa", "uikit" }
	local subsystem 	= wminfo.subsystem
	local wminfo 		= wminfo.info[systems[tonumber(subsystem)]]
	local window 		= wminfo.window
--	local display 		= nil

    --	if systems[subsystem]=="x11" then
--		display = wminfo.display
--		print('X11', display, window)
--	end

	-- Setup SDL Events - this is only temporary - will not use this for all.
	local event = ffi.new( "SDL_Event" )
	local prev_time, curr_time, fps = 0, 0, 0
	
	-- Build a window structure used for the EGL display setup.
	local windowStruct 			=  {}
	windowStruct.window 		= window
	windowStruct.display 		= display
    windowStruct.screen         = sdl_screen
	
	windowStruct.MouseButton	= {}
	windowStruct.MouseMove		= { x=0, y=0 }
	windowStruct.KeyUp			= {}
	windowStruct.KeyDown		= {}

    windowStruct.Swapbuffers    = function()

        egl.eglSwapBuffers(windowStruct.display, windowStruct.surface)
    end

	-- Update window function
	windowStruct.Update = function()
	
		-- Calculate the frame rate
		prev_time, curr_time = curr_time, os.clock()
		WM_frameMs = curr_time - prev_time + 0.00001
		WM_fps = 1.0/WM_frameMs

		-- Update the window caption with statistics
		sdl.SDL_WM_SetCaption( string.format("%dx%d | %.2f fps | %.2f mps", sdl_screen.w, sdl_screen.h, fps, fps * (sdl_screen.w * sdl_screen.h) / (1024*1024)), nil )

        -- Clear the KeyBuffers every frame - we dont keep crap lying around (do it yourself if you want!!)
        windowStruct.KeyUp			= {}
        windowStruct.KeyDown		= {}
        windowStruct.MouseButton[10]	= 0.0

        local kd = 1
        local ku = 1

		while sdl.SDL_PollEvent( event ) ~= 0 do

			if event.type == sdl.SDL_QUIT then
				return false
            end

            if event.type == sdl.SDL_VIDEORESIZE then
                VideoMode(event.resize.w, event.resize.h, 0)
                if Gcairo then Gcairo:UpdateSize() end
            end

            if event.type == sdl.SDL_MOUSEWHEEL then
                local x, y = event.wheel.x, event.wheel.y
                windowStruct.MouseButton[10] = y
            end

			if event.type == sdl.SDL_MOUSEMOTION then
				local motion, button = event.motion, event.button.button
				windowStruct.MouseMove.x = motion.x
				windowStruct.MouseMove.y = motion.y
			end

			if event.type == sdl.SDL_MOUSEBUTTONDOWN then
				local motion, button = event.motion, event.button.button
				windowStruct.MouseButton[button] = true
			end

			if event.type == sdl.SDL_MOUSEBUTTONUP then
				local motion, button = event.motion, event.button.button
				windowStruct.MouseButton[button] = false
			end

            if event.type == sdl.SDL_KEYDOWN then
                windowStruct.KeyDown[kd] = { scancode = event.key.keysym.scancode,
                                             sym = event.key.keysym.sym,
                                             mod = event.key.keysym.mod }; kd = kd + 1
            end

			if event.type == sdl.SDL_KEYUP then
				windowStruct.KeyUp[ku] = { scancode = event.key.keysym.scancode,
                                           sym = event.key.keysym.sym,
                                           mod = event.key.keysym.mod }; ku = ku + 1
			end
			
			if event.type == sdl.SDL_KEYUP and event.key.keysym.sym == sdl.SDLK_ESCAPE then
				event.type = sdl.SDL_QUIT
				sdl.SDL_PushEvent( event )
			end
		end
		return true
	end

	-- Quit Window Function
	windowStruct.Exit = function()

        egl.eglDestroyContext( windowStruct.display, windowStruct.context )
        egl.eglDestroySurface( windowStruct.display, windowStruct.surface )
        egl.eglTerminate( windowStruct.display )

        sdl.SDL_Quit()
	end

	return windowStruct
end

------------------------------------------------------------------------------------------------------------

function InitEGL(wm)

    --print('DISPLAY',wm.display)
	if wm.display == nil then
	   wm.display = egl.EGL_DEFAULT_DISPLAY
	end

    -- Need this for latest EGL support
    if(ffi.os == "Windows") then ffi.C.LoadLibraryA("d3dcompiler_43.dll") end

    local cfg_ctx     = egl.eglGetCurrentContext()
    local surf        = egl.eglGetCurrentSurface(0)
    local dpy         = egl.eglGetCurrentDisplay()
    
	local dpymode       = ffi.new("SDL_DisplayMode[1]")
	local currdpy       = sdl.SDL_GetCurrentDisplayMode();
	local res           = sdl.SDL_GetDesktopDisplayMode(currdpy, dpymode)
	print("Screen Display:", dpymode[0].w, dpymode[0].h, dpymode[0].refresh_rate)

    -- Enable "Free Running" mode - non VSync
    egl.eglSwapInterval( dpy, 0 )

    -- Put egl info back into window struct!
    wm.surface = surf
    wm.context = cfg_ctx
    wm.display = dpy

	return { surf=surf, ctx=cfg_ctx, dpy=dpy, config=cfg[0], rconf=r, display=dpymode[0] }
end

------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------

--local ffi 	= package.preload.ffi()

------------------------------------------------------------------------------------------------------------

-- sdl = require( "byt3d/ffi/sdl" )
-- sdl_image = require("byt3d/ffi/sdl_image")
-- egl = require( "byt3d/ffi/egl" )

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
end
if ffi.os == "Windows" then

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

if ffi.os == "Linux" then

    --print('wm.display/dpy/r', wm.display, dpy, r)
    attrib_list = {
        --        egl.EGL_LEVEL, 0,
        --        egl.EGL_SURFACE_TYPE, egl.EGL_WINDOW_BIT,
        egl.EGL_RENDERABLE_TYPE, egl.EGL_OPENGL_ES2_BIT,
        --        egl.EGL_NATIVE_RENDERABLE, egl.EGL_FALSE,
        egl.EGL_DEPTH_SIZE, 24,
        egl.EGL_NONE, egl.EGL_NONE
    }

    ffi.cdef[[
    // Types from various headers
    typedef struct _Display Display;
    typedef struct _XImage XImage;

    typedef struct {
        unsigned long pixel;
        unsigned short red, green, blue;
        char flags;  /* do_red, do_green, do_blue */
        char pad;
    } XColor; // Xlib.h

    typedef unsigned long XID; // Xdefs.h
    typedef XID Window;       // X.h
    typedef XID Drawable;     // X.h
    typedef XID Colormap;     // X.h

    // Functions from Xlib.h
    Display *XOpenDisplay(char*       /* display_name */ );
    int XDefaultScreen( Display*      /* display */ );
    Window XRootWindow( Display*      /* display */, int  /* screen_number */ );
    XImage *XGetImage( Display* ,  Drawable, int, int, unsigned int, unsigned int, unsigned long, int );
    int XFree( void* );
    int XQueryColor( Display*, Colormap, XColor* );
    Colormap XDefaultColormap(    Display*, int );
    
    // Functions from Xutil.h
    unsigned long XGetPixel(XImage *ximage, int x, int y);
    void XGetInputFocus(Display *d, Window *w, int *revert_ti);
    int XQueryTree(Display *display, Window w, Window *root_return, Window *parent_return, Window **children_return, unsigned int *nchildren_return);
    ]]
    
    function get_focus_window(d)

        -- local w = ffi.C.XRootWindow(d, 0)
        local w = ffi.new("Window[1]")
        local revert_to  = ffi.new("int[1]")
        print("getting input focus window ... ")
        ffi.C.XGetInputFocus(d, w, revert_to)
        if(w) then print("success:\n", d, w) end
        return w[0]
    end

    function get_topmost_window( d, start )

        local w = start
        local parent = ffi.new("Window[1]", start)
        local root = ffi.new("Window[1]")
        local children = ffi.new("Window *[1]")
        local nchildren = ffi.new("unsigned int[1]")

        print("getting top window ... ")
        while (parent[0] ~= root[0]) do
            w = parent[0]
            s = ffi.C.XQueryTree(d, w, root, parent, children, nchildren)
            if (s) then ffi.C.XFree(children[0]) end
            print("  get parent (window: %d)", w)
        end

        print("success (window: %d)", w)
        return w
    end
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
	-- Get Window info
	local wminfo = {}
	wminfo.version = 1 
	
	sdl_image.IMG_Init( bit.bor(sdl_image.IMG_INIT_PNG, sdl_image.IMG_INIT_JPG) ) 

    local windowStruct = {}
    -- Do this for each platform
    local d = ffi.C.XOpenDisplay(nil)
    local w = get_focus_window(d)
    w = get_topmost_window( d, w )
    windowStruct.window = w

    windowStruct.Swapbuffers = function()
    end
    
    -- Update window function
    windowStruct.Update = function()

        -- Calculate the frame rate
        curr_time = os.clock()
        prev_time = curr_time
        WM_frameMs = curr_time - prev_time + 0.00001
        WM_fps = 1.0/WM_frameMs

        -- Clear the KeyBuffers every frame - we dont keep crap lying around (do it yourself if you want!!)
        windowStruct.KeyUp			= {}
        windowStruct.KeyDown		= {}
        windowStruct.MouseButton	= { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
        windowStruct.MouseMove      = { x=0.0, y=0.0, 0.0, 0.0 }

        local kd = 1
        local ku = 1

        -- Key polling 
-- 		while sdl.SDL_PollEvent( event ) ~= 0 do
-- 
-- 			if event.type == sdl.SDL_QUIT then
-- 				return false
--             end
-- 
--             if event.type == sdl.SDL_VIDEORESIZE then
--                 VideoMode(event.resize.w, event.resize.h, 0)
--                 if Gcairo then Gcairo:UpdateSize() end
--             end
-- 
--             if event.type == sdl.SDL_MOUSEWHEEL then
--                 local x, y = event.wheel.x, event.wheel.y
--                 windowStruct.MouseButton[10] = y
--             end
-- 
-- 			if event.type == sdl.SDL_MOUSEMOTION then
-- 				local motion, button = event.motion, event.button.button
-- 				windowStruct.MouseMove.x = motion.x
-- 				windowStruct.MouseMove.y = motion.y
-- 			end
-- 
-- 			if event.type == sdl.SDL_MOUSEBUTTONDOWN then
-- 				local motion, button = event.motion, event.button.button
-- 				windowStruct.MouseButton[button] = true
-- 			end
-- 
-- 			if event.type == sdl.SDL_MOUSEBUTTONUP then
-- 				local motion, button = event.motion, event.button.button
-- 				windowStruct.MouseButton[button] = false
-- 			end
-- 
--             if event.type == sdl.SDL_KEYDOWN then
--                 windowStruct.KeyDown[kd] = { scancode = event.key.keysym.scancode,
--                                              sym = event.key.keysym.sym,
--                                              mod = event.key.keysym.mod }; kd = kd + 1
--             end
-- 
-- 			if event.type == sdl.SDL_KEYUP then
-- 				windowStruct.KeyUp[ku] = { scancode = event.key.keysym.scancode,
--                                            sym = event.key.keysym.sym,
--                                            mod = event.key.keysym.mod }; ku = ku + 1
-- 			end
-- 			
-- 			if event.type == sdl.SDL_KEYUP and event.key.keysym.sym == sdl.SDLK_ESCAPE then
-- 				event.type = sdl.SDL_QUIT
-- 				sdl.SDL_PushEvent( event )
-- 			end
-- 		end
 		return true
	end

	-- Quit Window Function
	windowStruct.Exit = function()

	end

	return windowStruct
end


------------------------------------------------------------------------------------------------------------

function InitEGL(wm)

    wm.display = egl.EGL_DEFAULT_DISPLAY
    
    -- Need this for latest EGL support
    if(ffi.os == "Windows") then ffi.C.LoadLibraryA("d3dcompiler_43.dll") end

    local dpy      		= egl.eglGetDisplay( egl.EGL_DEFAULT_DISPLAY )
    if dpy == egl.EGL_NO_DISPLAY then print("Cannot get current display.") end
    local initctx  		= egl.eglInitialize( dpy, nil, nil )
    if(initctx == 0) then print("Failed to initialize EGL.") end

    local attsize 		= table.getn(attrib_list)
    local cfg_attr 		= ffi.new( "EGLint["..attsize.."]", attrib_list )

    local cfg      		= ffi.new( "EGLConfig[1]" )
    local n_cfg    		= ffi.new( "EGLint[1]"    )

    local r0 			= egl.eglChooseConfig( dpy, cfg_attr, cfg, 1, n_cfg )
    if(r0 == nil) then print("Cannot find valid config: ", egl.eglGetError()) end

    local attrValues 	= { egl.EGL_RENDER_BUFFER, egl.EGL_BACK_BUFFER, egl.EGL_NONE }
    local attrList 		= ffi.new( "EGLint[3]", attrValues)

    local surf     		= egl.eglCreateWindowSurface( dpy, cfg[0], ffi.cast("void *", wm.window), attrList )
    if(surf == nil) then print("Cannot create surface: ", egl.eglGetError()) end
    
    attrValues 			= { egl.EGL_CONTEXT_CLIENT_VERSION, 2, egl.EGL_NONE }
    attrList 			= ffi.new( "EGLint[3]", attrValues)

    local cfg_ctx   	= egl.eglCreateContext( dpy, cfg[0], nil, attrList )
    if(cfg_ctx == nil) then print("Cannot create EGL Context:", egl.eglGetError()) end

local r        		= egl.eglMakeCurrent( dpy, surf, surf, cfg_ctx )
print('surf/ctx', surf, r0, ctx, r, n_cfg[0])
-- 
--     local dpymode       = ffi.new("SDL_DisplayMode[1]")
--     local currdpy       = sdl.SDL_GetCurrentDisplayMode();
--     local res           = sdl.SDL_GetDesktopDisplayMode(currdpy, dpymode)
--     print("Screen Display:", dpymode[0].w, dpymode[0].h, dpymode[0].refresh_rate)
-- 

    -- Enable "Free Running" mode - non VSync
    egl.eglSwapInterval( dpy, 0 )

    -- Put egl info back into window struct!
    wm.surface = surf
    wm.context = cfg_ctx
    wm.display = dpy

    return { surf=surf, ctx=cfg_ctx, dpy=dpy }
end
------------------------------------------------------------------------------------------------------------

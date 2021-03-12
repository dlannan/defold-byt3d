
BYT3D_VERSION		= release.."."..subversion

------------------------------------------------------------------------------------------------------------
-- Setup the root file path to use.
ffi 	= package.preload.ffi()

print("ffi.os : "..ffi.os)

package.path 		= package.path..";clibs/?.lua"
package.path 		= package.path..";lua/?.lua"
package.path 		= package.path..";byt3d/?.lua"
package.path 		= package.path..";?.lua"

------------------------------------------------------------------------------------------------------------
-- Setup OpenGLES2
local gl      = require( "byt3d/ffi/OpenGLES2" )

------------------------------------------------------------------------------------------------------------
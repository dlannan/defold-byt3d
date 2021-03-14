local vkheaders = require "byt3d/ffi/vulkan1header"

local defcore       = vkheaders.cleanup( vkheaders.gsubplatforms(vkheaders.core, "") )
local defextensions = vkheaders.cleanup( vkheaders.gsubplatforms(vkheaders.extensions, "") )

ffi.cdef (defcore)
ffi.cdef (defextensions)

local vk = ffi.load("vulkan")

return vk

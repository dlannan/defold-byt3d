local vk    = require "byt3d/ffi/vulkan1"
local vku   = require "byt3d/ffi/vulkan1utils"
local vkh   = require "byt3d/ffi/vulkan1header"

------------------------------------------------------------------------------------------------------------

local byt3dVulkan  	= {}

local APP_SHORT_NAME = "vk_byt3d_instance"

------------------------------------------------------------------------------------------------------------

function byt3dVulkan:Instance() 

	-- // initialize the VkApplicationInfo structure
	local app_info = ffi.new("VkApplicationInfo[1]")
	app_info[0].sType = vk.VK_STRUCTURE_TYPE_APPLICATION_INFO
	app_info[0].pNext = ffi.NULL
	app_info[0].pApplicationName = APP_SHORT_NAME
	app_info[0].applicationVersion = 1
	app_info[0].pEngineName = APP_SHORT_NAME
	app_info[0].engineVersion = 1
	app_info[0].apiVersion = vk.VK_API_VERSION

	-- // initialize the VkInstanceCreateInfo structure
	local inst_info = ffi.new("VkInstanceCreateInfo[1]")
	inst_info[0].sType = vk.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
	inst_info[0].pNext = ffi.NULL
	inst_info[0].flags = 0
	inst_info[0].pApplicationInfo = app_info
	inst_info[0].enabledExtensionCount = 0
	inst_info[0].ppEnabledExtensionNames = ffi.NULL
	inst_info[0].enabledLayerCount = 0
	inst_info[0].ppEnabledLayerNames = ffi.NULL

	self.app_info     = app_info
	self.inst_info    = inst_info

	self.inst = ffi.new("VkInstance[1]")
	local res = ffi.new("VkResult[1]")

	res[0] = vk.vkCreateInstance(inst_info, ffi.NULL, self.inst)
	if (res[0] == vk.VK_ERROR_INCOMPATIBLE_DRIVER) then 
		print("cannot find a compatible Vulkan ICD\n")
		os.exit(-1)
	elseif (res[0] ~= vk.VK_SUCCESS) then 
		print("unknown error: ", res[0])
		os.exit(-1)
	end
end

------------------------------------------------------------------------------------------------------------

function byt3dVulkan:InstanceFinish()
	vk.vkDestroyInstance(self.info.inst, ffi.NULL)
end

------------------------------------------------------------------------------------------------------------

function byt3dVulkan:Devices()

	local res = ffi.new("VkResult[1]")

	-- Enumerate devices
	local gpu_count = ffi.new("uint32_t[1]", 1)
	res[0] = vk.vkEnumeratePhysicalDevices(self.inst[0], gpu_count, ffi.NULL)
	print("Result: ", res[0], "  GPUS: ", gpu_count[0])
	self.info = {}
	self.info.gpus = ffi.new("VkPhysicalDevice["..gpu_count[0].."]")
	self.info.gpucount = gpu_count[0]
	res[0] = vk.vkEnumeratePhysicalDevices(self.inst[0], gpu_count, self.info.gpus)
	print(res[0])

	-- Create device 
	local queue_info = ffi.new("VkDeviceQueueCreateInfo[1]")
	self.info.queue_family_count = ffi.new("uint32_t[1]")
	vk.vkGetPhysicalDeviceQueueFamilyProperties(self.info.gpus[0], self.info.queue_family_count, ffi.NULL)
	print(self.info.queue_family_count[0])

	self.info.queue_props = ffi.new("VkQueueFamilyProperties["..self.info.queue_family_count[0].."]")
	vk.vkGetPhysicalDeviceQueueFamilyProperties(self.info.gpus[0], self.info.queue_family_count, self.info.queue_props);
	print(self.info.queue_family_count[0])

	local found = false
	for i = 0, self.info.queue_family_count[0] do
		if (bit.band(self.info.queue_props[i].queueFlags, vk.VK_QUEUE_GRAPHICS_BIT)) then 
			queue_info[0].queueFamilyIndex = i
			self.info.graphics_queue_family_index = i
			found = true
			break
		end
	end
	
	print("FOUND: ", found)
	print("FAMILY COUNT: ", self.info.queue_family_count[0])

	local queue_priorities = ffi.new("float[1]", 0.0)
	queue_info[0].sType = vk.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO
	queue_info[0].pNext = ffi.NULL
	queue_info[0].queueCount = 1
	queue_info[0].pQueuePriorities = queue_priorities

	local device_info = ffi.new("VkDeviceCreateInfo[1]")
	device_info[0].sType = vk.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO
	device_info[0].pNext = ffi.NULL
	device_info[0].queueCreateInfoCount = 1
	device_info[0].pQueueCreateInfos = queue_info
	device_info[0].enabledExtensionCount = 0
	device_info[0].ppEnabledExtensionNames = ffi.NULL
	device_info[0].enabledLayerCount = 0
	device_info[0].ppEnabledLayerNames = ffi.NULL
	device_info[0].pEnabledFeatures = ffi.NULL

	self.info.device = ffi.new("VkDevice[1]")
	res[0] = vk.vkCreateDevice(self.info.gpus[0], device_info, ffi.NULL, self.info.device)
	print(res[0])
end 

------------------------------------------------------------------------------------------------------------

function byt3dVulkan:DevicesFinish()
	vk.vkDestroyDevice(self.info.device[0], ffi.NULL)
end

------------------------------------------------------------------------------------------------------------

function byt3dVulkan:CommandBuffers()

	local res = ffi.new("VkResult[1]")

	-- /* Create a command pool to allocate our command buffer from */
	local cmd_pool_info = ffi.new("VkCommandPoolCreateInfo[1]")
	cmd_pool_info[0].sType = vk.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO
	cmd_pool_info[0].pNext = ffi.NULL
	cmd_pool_info[0].queueFamilyIndex = self.info.graphics_queue_family_index
	cmd_pool_info[0].flags = 0

	self.info.cmd_pool  = ffi.new("VkCommandPool[1]")
	
	res[0] = vk.vkCreateCommandPool(self.info.device[0], cmd_pool_info, NULL, self.info.cmd_pool)
	print("vkCreateCommandPool", res[0])

	-- /* Create the command buffer from the command pool */
	local cmd = ffi.new("VkCommandBufferAllocateInfo[1]")
	cmd[0].sType = vk.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO
	cmd[0].pNext = ffi.NULL
	cmd[0].commandPool = self.info.cmd_pool[0]
	cmd[0].level = vk.VK_COMMAND_BUFFER_LEVEL_PRIMARY;
	cmd[0].commandBufferCount = 1

	self.info.cmd = ffi.new("VkCommandBuffer["..cmd[0].commandBufferCount.."]")

	res[0] = vk.vkAllocateCommandBuffers(self.info.device[0], cmd, self.info.cmd)
	print(res[0])
end

------------------------------------------------------------------------------------------------------------

function byt3dVulkan:CommandBuffersFinish()

	local cmd_bufs = ffi.new("VkCommandBuffer[1]", self.info.cmd[0])
	vk.vkFreeCommandBuffers(self.info.device[0], self.info.cmd_pool[0], 1, cmd_bufs)
	vk.vkDestroyCommandPool(self.info.device[0], self.info.cmd_pool[0], ffi.NULL)
end

------------------------------------------------------------------------------------------------------------

function byt3dVulkan:Init()

	self:Instance()
	self:Devices()	
	self:CommandBuffers()

end

------------------------------------------------------------------------------------------------------------

function byt3dVulkan:Finish()

	self:CommandBuffersFinish()
	self:DevicesFinish()	
	self:InstanceFinish()
end

------------------------------------------------------------------------------------------------------------

return byt3dVulkan

------------------------------------------------------------------------------------------------------------

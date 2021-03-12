--~ /*
--~  * Created by David Lannan
--~  * User: David Lannan
--~  * Date: 5/22/2012
--~  * Time: 7:04 PM
--~  * 
--~  */

local lnode	= require("byt3d/framework/byt3dNode")
local lmat	= require("byt3d/math/Matrix44")

--~ 	/// <summary>
--~ 	/// Camera object derived from node (has location and orientation)
--~ 	/// The node provides view information for the camera pivot.
--~ 	/// </summary>
byt3dLayer =
{
}


function byt3dLayer:New()

	local newLayer = deepcopy(byt3dLayer)
	return newLayer
end


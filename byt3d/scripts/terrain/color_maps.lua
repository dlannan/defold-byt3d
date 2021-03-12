-- 
------------------------------------------------------------------------------------------------------------
--/*
--* And now for the maniacs (we know you're out there) who'd type this in,
--* here's the color map used to create the planet seen in Color Plate 1:
--*/

------------------------------------------------------------------------------------------------------------

local color_maps = {}

------------------------------------------------------------------------------------------------------------
-- Loads a png and turns it into colour map by converting first row of 256 pixels to one.

function color_maps:LoadPng(Gcairo, name, filename)
	local image = Gcairo:LoadImage(name, filename)
	
	local data = Gcairo:GetImageData(image)
	local cmap = {}
	-- Build the colour map from the first row.
	for i=0, 255 do
		cmap[i] = { data[i * 4], data[i * 4 + 1], data[i * 4 + 2]}
	end
	color_maps[name] = cmap
	return cmap
end

------------------------------------------------------------------------------------------------------------

function color_maps:DumpCmap(Gcairo, name, filename, cmap)
	
	local cfile = io.open(filename, "w")
	
	cfile:write("------------------------------------------------------------------------------------------------------------\n")
	cfile:write("local "..name.." = \n")
	cfile:write("{")
	
	local ccount = 0
	for i=0, 254 do
		
		local c = cmap[i]
		cfile:write("{ "..c[1]..", "..c[2]..", "..c[3].."}, ")
		ccount = ccount + 1
		if(ccount == 5) then 
			cfile:write("\n")
			ccount = 0 
		end
	end	
	
	local c = cmap[255]
	cfile:write("{ "..c[1]..", "..c[2]..", "..c[3].."} ")
	cfile:write("}\n")
	cfile:write("------------------------------------------------------------------------------------------------------------\n")
	cfile:close()
end

------------------------------------------------------------------------------------------------------------
local planet_map =
{{1,14,81}, {176,134,80}, {170,123,72}, {164,113,64}, {158,103,56},
{153,93,48}, {153,92,46}, {153,90,44}, {154,88,42}, {154,86,40},
{154,84,38}, {154,83,36}, {155,81,34}, {155,79,32}, {155,77,30},
{156,76,28}, {155,74,26}, {154,72,24}, {153,70,22}, {153,68,21},
{152,66,19}, {151,64,17}, {150,62,15}, {150,60,14}, {149,58,12},
{148,56,10}, {147,54,8}, {147,52,7}, {146,50,5}, {145,48,3},
{144,46,1}, {144,45,0}, {142,45,1}, {141,46,2}, {139,47,3},
{138,47,4}, {137,48,5}, {135,49,6}, {134,49,7}, {133,50,8},
{131,51,9}, {130,51,10}, {128,52,11}, {127,53,12}, {126,53,13},
{124,54,14}, {123,55,15}, {122,56,16}, {121,57,17}, {120,57,17},
{119,58,18}, {118,59,19}, {117,59,20}, {116,60,20}, {114,61,21},
{113,61,22}, {112,62,22}, {111,63,23}, {110,63,24}, {109,64,25},
{108,65,25}, {107,65,26}, {106,66,27}, {105,67,28}, {103,68,28},
{101,68,26}, {99,69,24}, {97,69,23}, {95,70,21}, {93,70,19},
{92,71,18}, {90,72,16}, {88,72,14}, {86,73,13}, {84,73,11},
{83,74,9}, {81,75,8}, {79,75,6}, {77,76,4}, {76,77,3},
{74,76,3}, {73,75,4}, {71,74,5}, {70,74,5}, {68,73,6},
{67,72,7}, {65,71,7}, {64,71,8}, {62,70,9}, {61,69,9},
{59,68,10}, {58,68,11}, {56,67,11}, {55,66,12}, {53,65,13},
{52,65,14}, {51,64,14}, {49,63,15}, {48,62,16}, {46,62,16},
{45,61,17}, {43,60,18}, {42,59,18}, {40,59,19}, {39,58,20},
{37,57,20}, {36,56,21}, {34,56,22}, {33,55,22}, {31,54,23},
{30,53,24}, {29,53,25}, {28,52,25}, {27,51,25}, {25,50,24},
{24,50,24}, {22,49,24}, {21,48,23}, {19,47,23}, {19,47,23},
{19,47,23}, {19,47,23}, {19,47,24}, {19,47,24}, {19,47,24},
{20,47,25}, {20,47,25}, {20,47,25}, {20,47,26}, {20,47,26},
{20,47,26}, {21,47,27}, {21,47,27}, {21,47,27}, {21,47,28},
{21,47,28}, {21,47,28}, {21,47,28}, {21,47,28}, {21,48,28},
{21,48,28}, {21,48,28}, {21,48,28}, {21,49,28}, {21,49,28},
{21,49,28}, {21,49,28}, {21,50,28}, {21,50,28}, {21,50,28},
{21,50,28}, {21,51,28}, {23,52,30}, {26,53,32}, {28,54,34},
{31,55,37}, {34,56,39}, {36,57,41}, {39,58,43}, {41,59,46},
{44,60,48}, {47,61,50}, {49,62,53}, {52,63,55}, {54,64,57},
{57,65,59}, {60,66,62}, {62,67,64}, {65,68,66}, {68,69,69},
{69,69,69}, {69,69,69}, {69,70,70}, {70,70,70}, {70,70,70},
{70,70,70}, {71,71,71}, {71,70,70}, {72,70,69}, {72,69,69},
{73,69,68}, {74,68,68}, {74,68,67}, {75,67,67}, {76,67,66},
{76,66,66}, {77,66,65}, {78,65,65}, {78,65,64}, {79,64,64},
{80,64,63}, {81,64,63}, {82,63,62}, {84,62,61}, {94,74,73},
{104,87,86}, {115,100,99}, {125,113,112}, {135,125,125}, {146,138,138},
{156,151,151}, {166,164,164}, {177,177,177}, {196,196,196}, {216,216,216},
{235,235,235}, {255,255,255}, {255,255,255}, {255,255,255}, {255,255,255},
{255,255,255}, {255,255,255}, {255,255,255}, {255,255,255}, {255,255,255},
{255,255,255}, {255,255,255}, {255,255,255}, {255,255,255}, {255,255,255},
{255,255,255}, {255,255,255}, {255,255,255}, {255,255,255}, {255,255,255},
{255,255,255}, {255,255,255}, {255,255,255}, {255,255,255}, {255,255,255},
{255,255,255}, {255,255,255}, {255,255,255}, {255,255,255}, {255,255,255},
{255,255,255}}

------------------------------------------------------------------------------------------------------------
local coastal = 
{{ 191, 30, 0}, { 191, 31, 0}, { 191, 31, 1}, { 191, 32, 1}, { 191, 32, 1}, 
{ 191, 33, 1}, { 192, 34, 2}, { 192, 34, 2}, { 192, 35, 2}, { 192, 36, 3}, 
{ 192, 36, 3}, { 192, 37, 3}, { 192, 38, 4}, { 193, 39, 4}, { 193, 39, 4}, 
{ 193, 40, 5}, { 193, 41, 5}, { 193, 42, 5}, { 193, 43, 6}, { 194, 44, 6}, 
{ 194, 44, 7}, { 194, 45, 7}, { 194, 46, 7}, { 194, 47, 8}, { 195, 48, 8}, 
{ 195, 49, 8}, { 195, 50, 9}, { 195, 51, 9}, { 196, 52, 10}, { 196, 53, 10}, 
{ 196, 54, 10}, { 196, 55, 11}, { 196, 56, 11}, { 197, 57, 12}, { 197, 58, 12}, 
{ 197, 59, 13}, { 197, 60, 13}, { 198, 61, 13}, { 198, 62, 14}, { 198, 63, 14}, 
{ 198, 64, 15}, { 199, 66, 15}, { 199, 67, 16}, { 199, 68, 16}, { 200, 69, 16}, 
{ 200, 70, 17}, { 200, 71, 17}, { 200, 72, 18}, { 201, 74, 18}, { 201, 75, 19}, 
{ 201, 76, 19}, { 201, 77, 20}, { 202, 78, 20}, { 202, 80, 21}, { 202, 81, 21}, 
{ 203, 82, 22}, { 203, 83, 22}, { 203, 85, 23}, { 203, 86, 23}, { 204, 87, 24}, 
{ 204, 88, 24}, { 204, 89, 25}, { 204, 91, 25}, { 205, 92, 26}, { 205, 93, 27}, 
{ 205, 95, 27}, { 206, 96, 28}, { 206, 97, 28}, { 206, 98, 29}, { 206, 100, 29}, 
{ 207, 101, 30}, { 207, 102, 30}, { 207, 104, 31}, { 207, 105, 32}, { 208, 106, 32}, 
{ 208, 107, 33}, { 208, 109, 33}, { 208, 110, 34}, { 209, 111, 35}, { 209, 113, 35}, 
{ 209, 114, 36}, { 209, 115, 36}, { 210, 116, 37}, { 210, 118, 38}, { 210, 119, 38}, 
{ 210, 120, 39}, { 211, 122, 39}, { 211, 123, 40}, { 211, 124, 41}, { 211, 125, 41}, 
{ 212, 127, 42}, { 212, 128, 43}, { 212, 129, 43}, { 212, 131, 44}, { 212, 132, 45}, 
{ 213, 133, 45}, { 213, 134, 46}, { 213, 136, 47}, { 213, 137, 47}, { 213, 138, 48}, 
{ 214, 139, 49}, { 214, 141, 49}, { 214, 142, 50}, { 214, 143, 51}, { 214, 144, 52}, 
{ 214, 146, 52}, { 215, 147, 53}, { 215, 148, 54}, { 215, 149, 54}, { 215, 150, 55}, 
{ 215, 151, 56}, { 215, 153, 57}, { 215, 154, 57}, { 215, 155, 58}, { 215, 156, 59}, 
{ 215, 157, 60}, { 215, 158, 60}, { 215, 160, 61}, { 215, 161, 62}, { 215, 162, 63}, 
{ 215, 163, 63}, { 215, 164, 64}, { 215, 165, 65}, { 215, 166, 66}, { 215, 167, 67}, 
{ 215, 168, 67}, { 215, 169, 68}, { 215, 170, 69}, { 215, 171, 70}, { 215, 172, 71}, 
{ 215, 173, 72}, { 215, 174, 72}, { 215, 175, 73}, { 215, 176, 74}, { 215, 177, 75}, 
{ 215, 178, 76}, { 215, 179, 77}, { 215, 180, 77}, { 215, 181, 78}, { 215, 181, 79}, 
{ 215, 182, 80}, { 215, 183, 81}, { 215, 184, 82}, { 215, 185, 83}, { 215, 186, 83}, 
{ 213, 195, 95}, { 210, 203, 109}, { 206, 212, 126}, { 201, 220, 143}, { 196, 227, 161}, 
{ 191, 234, 180}, { 185, 240, 197}, { 178, 245, 214}, { 172, 249, 228}, { 165, 252, 240}, 
{ 158, 254, 249}, { 151, 255, 254}, { 146, 255, 255}, { 141, 253, 253}, { 136, 251, 250}, 
{ 130, 248, 245}, { 125, 245, 238}, { 119, 240, 230}, { 113, 236, 222}, { 107, 231, 212}, 
{ 102, 225, 201}, { 96, 220, 192}, { 94, 218, 187}, { 92, 216, 183}, { 89, 213, 178}, 
{ 87, 211, 173}, { 85, 208, 169}, { 82, 206, 164}, { 80, 203, 159}, { 78, 201, 155}, 
{ 75, 199, 150}, { 73, 196, 146}, { 71, 194, 141}, { 69, 191, 137}, { 67, 189, 133}, 
{ 65, 187, 128}, { 63, 184, 124}, { 61, 182, 120}, { 59, 180, 117}, { 57, 178, 113}, 
{ 55, 176, 110}, { 53, 174, 106}, { 51, 172, 103}, { 50, 170, 100}, { 48, 168, 98}, 
{ 47, 167, 96}, { 46, 166, 95}, { 45, 165, 93}, { 44, 164, 91}, { 43, 162, 89}, 
{ 42, 161, 88}, { 41, 160, 86}, { 41, 159, 84}, { 40, 157, 83}, { 39, 156, 81}, 
{ 38, 155, 79}, { 37, 153, 78}, { 36, 152, 76}, { 35, 151, 75}, { 34, 150, 73}, 
{ 33, 148, 71}, { 33, 147, 70}, { 32, 146, 68}, { 31, 144, 67}, { 30, 143, 65}, 
{ 29, 142, 64}, { 29, 140, 62}, { 28, 139, 61}, { 27, 138, 59}, { 26, 137, 58}, 
{ 26, 135, 57}, { 25, 134, 55}, { 24, 133, 54}, { 24, 131, 52}, { 23, 130, 51}, 
{ 22, 129, 50}, { 22, 128, 48}, { 21, 126, 47}, { 20, 125, 46}, { 20, 124, 45}, 
{ 19, 123, 43}, { 19, 122, 42}, { 18, 120, 41}, { 17, 119, 40}, { 17, 118, 38}, 
{ 16, 117, 37}, { 16, 116, 36}, { 15, 115, 35}, { 15, 114, 34}, { 14, 112, 33}, 
{ 14, 111, 32}, { 13, 110, 31}, { 13, 109, 30}, { 12, 108, 29}, { 12, 107, 28}, 
{ 11, 106, 27}, { 11, 105, 26}, { 10, 104, 25}, { 10, 104, 24}, { 9, 103, 23}, 
{ 9, 102, 22}, { 9, 101, 21}, { 8, 100, 21}, { 8, 99, 20}, { 7, 99, 19}, 
{ 7, 98, 18}, { 7, 97, 17}, { 6, 96, 17}, { 6, 96, 16}, { 6, 95, 15}, 
{ 5, 95, 15} }
------------------------------------------------------------------------------------------------------------
local ground = 
{{ 151, 167, 167}, { 150, 166, 166}, { 148, 165, 165}, { 147, 164, 164}, { 145, 163, 164}, 
{ 144, 162, 163}, { 142, 161, 162}, { 141, 160, 161}, { 139, 159, 160}, { 137, 158, 159}, 
{ 136, 156, 158}, { 134, 155, 157}, { 133, 154, 156}, { 131, 153, 155}, { 130, 152, 154}, 
{ 128, 151, 153}, { 127, 150, 152}, { 125, 149, 151}, { 123, 148, 150}, { 122, 147, 150}, 
{ 120, 146, 149}, { 119, 145, 148}, { 117, 143, 147}, { 116, 142, 146}, { 114, 141, 145}, 
{ 113, 140, 144}, { 111, 139, 143}, { 109, 138, 142}, { 108, 137, 141}, { 106, 136, 140}, 
{ 105, 135, 139}, { 103, 134, 138}, { 102, 133, 137}, { 100, 132, 137}, { 99, 130, 136}, 
{ 97, 129, 135}, { 95, 128, 134}, { 94, 127, 133}, { 92, 126, 132}, { 91, 125, 131}, 
{ 89, 124, 130}, { 85, 121, 127}, { 77, 115, 123}, { 69, 110, 118}, { 61, 104, 113}, 
{ 53, 99, 108}, { 45, 93, 103}, { 37, 87, 99}, { 29, 82, 94}, { 26, 82, 92}, 
{ 27, 84, 92}, { 28, 87, 92}, { 29, 90, 91}, { 29, 92, 91}, { 30, 95, 91}, 
{ 31, 98, 91}, { 31, 100, 91}, { 32, 103, 90}, { 33, 106, 90}, { 34, 108, 90}, 
{ 34, 108, 90}, { 34, 109, 90}, { 34, 109, 90}, { 34, 109, 90}, { 34, 110, 90}, 
{ 34, 110, 90}, { 34, 110, 90}, { 34, 111, 90}, { 34, 111, 90}, { 34, 111, 90}, 
{ 34, 111, 90}, { 35, 112, 90}, { 35, 112, 90}, { 35, 112, 90}, { 35, 113, 90}, 
{ 35, 113, 90}, { 35, 113, 90}, { 35, 113, 90}, { 35, 114, 90}, { 35, 114, 90}, 
{ 35, 114, 90}, { 35, 115, 90}, { 35, 115, 90}, { 35, 115, 90}, { 36, 115, 90}, 
{ 36, 116, 90}, { 36, 116, 90}, { 36, 116, 90}, { 36, 117, 90}, { 36, 117, 90}, 
{ 36, 117, 90}, { 36, 117, 89}, { 36, 118, 89}, { 36, 118, 89}, { 36, 118, 89}, 
{ 36, 119, 89}, { 36, 119, 89}, { 37, 119, 89}, { 37, 119, 89}, { 37, 120, 89}, 
{ 37, 120, 89}, { 37, 120, 89}, { 37, 121, 89}, { 37, 121, 89}, { 37, 121, 89}, 
{ 37, 121, 89}, { 37, 122, 89}, { 37, 122, 89}, { 37, 122, 89}, { 37, 123, 89}, 
{ 38, 123, 89}, { 38, 123, 89}, { 38, 124, 89}, { 38, 124, 89}, { 38, 124, 89}, 
{ 38, 124, 89}, { 38, 125, 89}, { 38, 125, 89}, { 38, 125, 89}, { 38, 126, 89}, 
{ 38, 126, 89}, { 38, 126, 89}, { 38, 126, 89}, { 39, 127, 89}, { 39, 127, 89}, 
{ 39, 127, 89}, { 39, 128, 89}, { 39, 128, 89}, { 39, 128, 89}, { 39, 128, 89}, 
{ 39, 129, 89}, { 39, 129, 89}, { 39, 129, 89}, { 39, 130, 89}, { 39, 130, 89}, 
{ 40, 130, 89}, { 40, 130, 89}, { 40, 131, 89}, { 40, 131, 89}, { 40, 131, 89}, 
{ 40, 132, 89}, { 40, 132, 89}, { 40, 132, 89}, { 40, 132, 88}, { 40, 133, 88}, 
{ 40, 133, 88}, { 40, 133, 88}, { 40, 134, 88}, { 41, 134, 88}, { 41, 134, 88}, 
{ 41, 134, 88}, { 41, 135, 88}, { 41, 135, 88}, { 41, 135, 88}, { 41, 136, 88}, 
{ 41, 136, 88}, { 41, 136, 88}, { 41, 137, 90}, { 42, 140, 97}, { 42, 143, 103}, 
{ 43, 147, 110}, { 43, 150, 117}, { 44, 153, 123}, { 44, 156, 130}, { 45, 159, 136}, 
{ 45, 162, 143}, { 46, 165, 150}, { 46, 169, 156}, { 47, 170, 159}, { 47, 170, 160}, 
{ 47, 170, 160}, { 47, 171, 161}, { 47, 171, 162}, { 47, 172, 163}, { 47, 172, 163}, 
{ 47, 172, 164}, { 47, 173, 165}, { 47, 173, 166}, { 47, 174, 167}, { 47, 174, 167}, 
{ 47, 174, 168}, { 47, 175, 169}, { 47, 175, 170}, { 47, 175, 171}, { 48, 176, 171}, 
{ 48, 176, 172}, { 48, 177, 173}, { 48, 177, 174}, { 48, 177, 175}, { 48, 178, 175}, 
{ 48, 178, 176}, { 48, 178, 177}, { 48, 179, 178}, { 48, 179, 179}, { 48, 180, 179}, 
{ 48, 180, 180}, { 48, 180, 181}, { 48, 181, 182}, { 48, 181, 183}, { 48, 181, 183}, 
{ 49, 182, 184}, { 49, 182, 185}, { 49, 183, 186}, { 49, 183, 186}, { 49, 183, 187}, 
{ 49, 184, 188}, { 49, 184, 189}, { 49, 184, 190}, { 49, 185, 190}, { 49, 185, 191}, 
{ 49, 186, 192}, { 49, 186, 193}, { 49, 186, 194}, { 49, 187, 194}, { 49, 187, 195}, 
{ 49, 188, 196}, { 49, 188, 197}, { 50, 188, 198}, { 50, 189, 198}, { 50, 189, 199}, 
{ 50, 189, 200}, { 50, 190, 201}, { 50, 190, 202}, { 50, 191, 202}, { 50, 191, 203}, 
{ 50, 191, 204}, { 50, 192, 205}, { 50, 192, 206}, { 50, 192, 206}, { 50, 193, 207}, 
{ 50, 193, 208}, { 50, 194, 209}, { 50, 194, 209}, { 51, 194, 210}, { 51, 195, 211}, 
{ 51, 195, 212}, { 51, 195, 213}, { 51, 196, 213}, { 51, 196, 214}, { 51, 197, 215}, 
{ 51, 197, 216}, { 51, 197, 217}, { 51, 198, 217}, { 51, 198, 218}, { 51, 198, 219}, 
{ 51, 199, 220}, { 51, 199, 221}, { 51, 200, 221}, { 51, 200, 222}, { 52, 200, 223}, 
{ 52, 201, 224}, { 52, 201, 225}, { 52, 202, 225}, { 52, 202, 226}, { 52, 202, 227}, 
{ 52, 203, 228} }
------------------------------------------------------------------------------------------------------------

color_maps.planet_map = planet_map
color_maps.coastal = coastal
color_maps.ground = ground
return color_maps

------------------------------------------------------------------------------------------------------------
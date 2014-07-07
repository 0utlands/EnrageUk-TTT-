-- Simplistic Map vote v2 by ilya
-- Entire script recoded from v1

MAPV = {}

-- This is the delay before players can start to vote 
-- used to stop people from rtv'ing when they first get in
MAPV["Delay"] = 20

-- How long the vote will be on screen for
MAPV["VoteTime"] = 20 

-- Main color of the mapvote
MAPV["MainColor"] = Color(222,100,100)

-- The time of the fade transition
MAPV["AnimationSpeed"] = 1

-- The darkness of the boxes in the vote #/255
MAPV["BoxDarkness"] = 210

-- Do you want to use specific prefixes for maps?
-- If not the map vote can be any map in your maps folder
MAPV["UseMapPrefixes"] = true

-- Add Prefixs for maps here
MAPV["MapPrefixes"] = {
	"deathrun_", 
	"dr_", 
}

-- List of commands that will let you rock the vote
-- keep these lower case
MAPV["Command"] = {
	"rtv",
	"!rtv",
	"/rtv",
}

-- Enable and disable the use of tags here
MAPV["MapTags"] = true

-- How much percent of the players is needed to start a mapvote
MAPV["VotePercent"] = 0.66

-- 1 = Default
-- 2 = Extend map function
-- 3 = Random map from all possible maps
MAPV["LastBoxMode"] = 1

-- Mute all players when the map vote is up?
MAPV["MutePlayers"] = true

-- The default font for the mapvote
MAPV["FontType"] = "Arial"

-- When no map image is found it will use this
MAPV["DefaultImage"] = "http://i.imgur.com/SwWuzBO.png"

-- Image for the random map option.
MAPV["RandomMapImage"] = "http://i.imgur.com/excwLTy.jpg"

-- Use this if you want to add specific maps without adding all the ones with that
-- prefix.
MAPV["SpecificMaps"] = {
	--"ttt_67thway_v4", -- example
}

-- HERE IS WHERE YOU SET MAP IMAGES AND TAGS
-- This may be a tad more confusing than the old
-- way but trust me, this is much more efficient than
-- before.

MAPV["ImagesAndTags"] = {}

-- Ignore this. Its just used to make it easier for you.
local function add_map( mapname, name, images, tag)
	MAPV["ImagesAndTags"][mapname] = { NAME = name, IMAGETABLE = images or nil, TAG = tag or nil }
end

-- READ THIS PLEASE --------------------------------------------------------------------------------------------------------------------- <<<<<<<<<<<<< READ
-- Ok on to adding map images.
-- If you don't want to add something then leave it blank and move on to the next argument
-- You can also add as many images as you want for a map it will choose a random one
-- Below in the table of images, put the width of the image in the string along with the 
-- link, this will lead to much better aligning of your image and separate the width and
-- link with 2 spaces. Adding the width is optional, just used for better alignment.
-- Again if any of this is confusing to you then ask me over steam for help.

-- LAYOUT           <> = required       [] = optional
-- add_map( <Exact name of map> , [A Name for the map to show on the vote], [{ "link2image.com  Width", "link2image.com  Width" }], [tag])

add_map( "deathrun_atomic_warfare", "Atomic Warfare", { "http://i.imgur.com/nwFohhRh.jpg  1024", "http://i.imgur.com/nSkcTi8h.jpg  1024", "http://i.imgur.com/jegKYJrh.jpg  1024" }, "POPULAR")
add_map( "deathrun_marioworld_final", "Mario World", { "http://i.imgur.com/pwe9q92h.jpg" }, "OVERPLAYED")
add_map( "deathrun_amazon_b3", "Amazon", { "http://i.imgur.com/9SsDY7Ph.jpg  1024" })
add_map( "deathrun_blood_final", "Blood", { "http://i.imgur.com/2kOFsaeh.jpg  1024" })
add_map( "deathrun_parking_garage", "Parking Garage", { "http://i.imgur.com/Yjk8ASeh.jpg  1024", "http://i.imgur.com/IrZ6Djdh.jpg  1024" })
add_map( "bhop_null", "Null", { "http://cloud-2.steampowered.com/ugc/902131725057711744/857E66CF74395E856867A476FC99C06E1D35F19A/  1600" })
add_map( "deathrun_missing_v1", "Missing", { "http://cloud-2.steampowered.com/ugc/902131725057713416/BA55CDFF57974B15B046A1E5EE5F38FFF00F8DF0/  1600" })
add_map( "dr_minecraft", "Minecraft", { "http://cloud-2.steampowered.com/ugc/902131725057713995/9FD0E22C5971CB7898758FE1B3DE786E23758C04/  1600" })
add_map( "deathrun_poker_final5", "Poker", { "http://cloud-2.steampowered.com/ugc/902131725057799474/A1DCA69A79C6B0C89E203A2C424B559A20F63ABD/  1600" })
add_map( "deathrun_no_hope_v3", "No Hope", { "http://cloud-4.steampowered.com/ugc/902131725057800381/2983AE763D63CB15E8EF42F3A870A645D8A51ED7/  1600" })
add_map( "deathrun_southpark__rfix", "Southpark", { "http://cloud-2.steampowered.com/ugc/902131725057801076/1CE26252AE3DA8EB51A20AABC610EC0266BD8A4E/  1600" })

-- Its best that the image height is greater than 720p for higher resolutions

-- Minetest 0.4.7 mod: technic
-- namespace: technic
-- (c) 2012-2013 by RealBadAngel <mk@realbadangel.pl>

technic = {}

local load_start = os.clock()
local modpath = minetest.get_modpath("technic")
technic.modpath = modpath

-- Boilerplate to support intllib
if intllib then
	technic.getter = intllib.Getter()
else
	technic.getter = function(s) return s end
end
local S = technic.getter

-- Read configuration file
dofile(modpath.."/config.lua")

-- Helper functions
dofile(modpath.."/helpers.lua")

-- Items 
dofile(modpath.."/items.lua")

-- Craft recipes for items 
dofile(modpath.."/crafts.lua")

-- Register functions
dofile(modpath.."/register.lua")

-- Machines
dofile(modpath.."/machines/init.lua")

-- Tools
dofile(modpath.."/tools/init.lua")

-- Aliases for legacy node/item names
dofile(modpath.."/legacy.lua")

if minetest.setting_get("log_mod") then
	print(S("[Technic] Loaded in %f seconds"):format(os.clock() - load_start))
end


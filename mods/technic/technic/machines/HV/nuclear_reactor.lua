-- The enriched uranium rod driven EU generator.
-- A very large and advanced machine providing vast amounts of power.
-- Very efficient but also expensive to run as it needs uranium. (10000EU 86400 ticks (one week))
-- Provides HV EUs that can be down converted as needed.
--
-- The nuclear reactor core needs water and a protective shield to work.
-- This is checked now and then and if the machine is tampered with... BOOM!

local burn_ticks   = 7 * 24 * 60 * 60       -- (seconds).
local power_supply = 100000                 -- EUs
local fuel_type    = "technic:uranium_fuel" -- The reactor burns this stuff

local S = technic.getter

-- FIXME: recipe must make more sense like a rod recepticle, steam chamber, HV generator?
minetest.register_craft({
	output = 'technic:hv_nuclear_reactor_core',
	recipe = {
		{'technic:stainless_steel_ingot', 'technic:stainless_steel_ingot', 'technic:stainless_steel_ingot'},
		{'technic:stainless_steel_ingot',                              '', 'technic:stainless_steel_ingot'},
		{'technic:stainless_steel_ingot',              'technic:hv_cable', 'technic:stainless_steel_ingot'},
	}
})

local generator_formspec =
	"invsize[8,9;]"..
	"label[0,0;"..S("Nuclear Reactor Rod Compartment").."]"..
	"list[current_name;src;2,1;3,2;]"..
	"list[current_player;main;0,5;8,4;]"

-- "Boxy sphere"
local nodebox = {
	{ -0.353, -0.353, -0.353, 0.353, 0.353, 0.353 }, -- Box
	{ -0.495, -0.064, -0.064, 0.495, 0.064, 0.064 }, -- Circle +-x
	{ -0.483, -0.128, -0.128, 0.483, 0.128, 0.128 },
	{ -0.462, -0.191, -0.191, 0.462, 0.191, 0.191 },
	{ -0.433, -0.249, -0.249, 0.433, 0.249, 0.249 },
	{ -0.397, -0.303, -0.303, 0.397, 0.303, 0.303 },
	{ -0.305, -0.396, -0.305, 0.305, 0.396, 0.305 }, -- Circle +-y
	{ -0.250, -0.432, -0.250, 0.250, 0.432, 0.250 },
	{ -0.191, -0.461, -0.191, 0.191, 0.461, 0.191 },
	{ -0.130, -0.482, -0.130, 0.130, 0.482, 0.130 },
	{ -0.066, -0.495, -0.066, 0.066, 0.495, 0.066 },
	{ -0.064, -0.064, -0.495, 0.064, 0.064, 0.495 }, -- Circle +-z
	{ -0.128, -0.128, -0.483, 0.128, 0.128, 0.483 },
	{ -0.191, -0.191, -0.462, 0.191, 0.191, 0.462 },
	{ -0.249, -0.249, -0.433, 0.249, 0.249, 0.433 },
	{ -0.303, -0.303, -0.397, 0.303, 0.303, 0.397 },
}

minetest.register_node("technic:hv_nuclear_reactor_core", {
	description = S("Nuclear Reactor Core"),
	tiles = {"technic_hv_nuclear_reactor_core.png", "technic_hv_nuclear_reactor_core.png",
	         "technic_hv_nuclear_reactor_core.png", "technic_hv_nuclear_reactor_core.png",
	         "technic_hv_nuclear_reactor_core.png", "technic_hv_nuclear_reactor_core.png"},
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2},
	legacy_facedir_simple = true,
	sounds = default.node_sound_wood_defaults(),
	drawtype="nodebox",
	paramtype = "light",
	stack_max = 1,
	node_box = {
		type = "fixed",
		fixed = nodebox
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Nuclear Reactor Core"))
		meta:set_int("HV_EU_supply", 0)
		-- Signal to the switching station that this device burns some
		-- sort of fuel and needs special handling
		meta:set_int("HV_EU_from_fuel", 1)
		meta:set_int("burn_time", 0)
		meta:set_string("formspec", generator_formspec)
		local inv = meta:get_inventory()
		inv:set_size("src", 6)
	end,	
	can_dig = technic.machine_can_dig,
	allow_metadata_inventory_put = technic.machine_inventory_put,
	allow_metadata_inventory_take = technic.machine_inventory_take,
	allow_metadata_inventory_move = technic.machine_inventory_move,
})

minetest.register_node("technic:hv_nuclear_reactor_core_active", {
	tiles = {"technic_hv_nuclear_reactor_core.png", "technic_hv_nuclear_reactor_core.png",
	         "technic_hv_nuclear_reactor_core.png", "technic_hv_nuclear_reactor_core.png",
		 "technic_hv_nuclear_reactor_core.png", "technic_hv_nuclear_reactor_core.png"},
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
	legacy_facedir_simple = true,
	sounds = default.node_sound_wood_defaults(),
	drop="technic:hv_nuclear_reactor_core",
	drawtype="nodebox",
	light_source = 15,
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = nodebox
	},
	can_dig = technic.machine_can_dig,
	allow_metadata_inventory_put = technic.machine_inventory_put,
	allow_metadata_inventory_take = technic.machine_inventory_take,
	allow_metadata_inventory_move = technic.machine_inventory_move,
})

local check_reactor_structure = function(pos)
	-- The reactor consists of a 9x9x9 cube structure
	-- A cross section through the middle:
	--  CCCC CCCC
	--  CBBB BBBC
	--  CBSS SSBC
	--  CBSWWWSBC
	--  CBSW#WSBC
	--  CBSW|WSBC
	--  CBSS|SSBC
	--  CBBB|BBBC
	--  CCCC|CCCC
	--  C = Concrete, B = Blast resistant concrete, S = Stainless Steel,
	--  W = water node, # = reactor core, | = HV cable
	--  The man-hole and the HV cable is only in the middle
	--  The man-hole is optional

	local vm = VoxelManip()
	local pos1 = vector.subtract(pos, 4)
	local pos2 = vector.add(pos, 4)
	local MinEdge, MaxEdge = vm:read_from_map(pos1, pos2)
	local data = vm:get_data()
	local area = VoxelArea:new({MinEdge=MinEdge, MaxEdge=MaxEdge})

	local c_concrete = minetest.get_content_id("technic:concrete")
	local c_blast_concrete = minetest.get_content_id("technic:blast_resistant_concrete")
	local c_stainless_steel = minetest.get_content_id("technic:stainless_steel_block")
	local c_water_source = minetest.get_content_id("default:water_source")
	local c_water_flowing = minetest.get_content_id("default:water_flowing")

	local concretelayer, blastlayer, steellayer, waterlayer = 0, 0, 0, 0

	for z = pos1.z, pos2.z do
	for y = pos1.y, pos2.y do
	for x = pos1.x, pos2.x do
		-- If the position is in the outer layer
		if x == pos1.x or x == pos2.x or
		   y == pos1.y or y == pos2.y or
		   z == pos1.z or z == pos2.z then
			if data[area:index(x, y, z)] == c_concrete then
				concretelayer = concretelayer + 1
			end
		elseif x == pos1.x+1 or x == pos2.x-1 or
		   y == pos1.y+1 or y == pos2.y-1 or
		   z == pos1.z+1 or z == pos2.z-1 then
			if data[area:index(x, y, z)] == c_blast_concrete then
				blastlayer = blastlayer + 1
			end
		elseif x == pos1.x+2 or x == pos2.x-2 or
		   y == pos1.y+2 or y == pos2.y-2 or
		   z == pos1.z+2 or z == pos2.z-2 then
			if data[area:index(x, y, z)] == c_stainless_steel then
				steellayer = steellayer + 1
			end
		elseif x == pos1.x+3 or x == pos2.x-3 or
		   y == pos1.y+3 or y == pos2.y-3 or
		   z == pos1.z+3 or z == pos2.z-3 then
		   	local cid = data[area:index(x, y, z)]
			if cid == c_water_source or cid == c_water_flowing then
				waterlayer = waterlayer + 1
			end
		end
	end
	end
	end
	if waterlayer >= 25 and
	   steellayer >= 96 and
	   blastlayer >= 216 and
	   concretelayer >= 384 then
		return true
	end
end

local explode_reactor = function(pos)
	print("A reactor exploded at "..minetest.pos_to_string(pos))
end

local function damage_nearby_players(pos)
	local objs = minetest.get_objects_inside_radius(pos, 4)
	for _, o in pairs(objs) do
		if o:is_player() then
			o:set_hp(math.max(o:get_hp() - 2, 0))
		end
	end
end

minetest.register_abm({
	nodenames = {"technic:hv_nuclear_reactor_core", "technic:hv_nuclear_reactor_core_active"},
	interval = 1,
	chance   = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		local machine_name = S("Nuclear Reactor Core")
		local burn_time = meta:get_int("burn_time") or 0

		if burn_time >= burn_ticks or burn_time == 0 then
			local inv = meta:get_inventory()
			if not inv:is_empty("src") then 
				local srclist = inv:get_list("src")
				local correct_fuel_count = 0
				for _, srcstack in pairs(srclist) do
					if srcstack then
						if  srcstack:get_name() == fuel_type then
							correct_fuel_count = correct_fuel_count + 1
						end
					end
				end
				-- Check that the reactor is complete as well
				-- as the correct number of correct fuel
				if correct_fuel_count == 6 and
				   check_reactor_structure(pos) then
					meta:set_int("burn_time", 1)
					technic.swap_node(pos, "technic:hv_nuclear_reactor_core_active") 
					meta:set_int("HV_EU_supply", power_supply)
					for idx, srcstack in pairs(srclist) do
						srcstack:take_item()
						inv:set_stack("src", idx, srcstack)
					end
					return
				end
			end
			meta:set_int("HV_EU_supply", 0)
			meta:set_int("burn_time", 0)
			meta:set_string("infotext", S("%s Idle"):format(machine_name))
			technic.swap_node(pos, "technic:hv_nuclear_reactor_core")
		elseif burn_time > 0 then
			damage_nearby_players(pos)
			if not check_reactor_structure(pos) then
				explode_reactor(pos)
			end
			burn_time = burn_time + 1
			meta:set_int("burn_time", burn_time)
			local percent = math.floor(burn_time / burn_ticks * 100)
			meta:set_string("infotext", machine_name.." ("..percent.."%)")
			meta:set_int("HV_EU_supply", power_supply)
		end
	end
})

technic.register_machine("HV", "technic:hv_nuclear_reactor_core",        technic.producer)
technic.register_machine("HV", "technic:hv_nuclear_reactor_core_active", technic.producer)


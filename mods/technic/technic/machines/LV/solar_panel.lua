-- Solar panels are the building blocks of LV solar arrays
-- They can however also be used separately but with reduced efficiency due to the missing transformer.
-- Individual panels are less efficient than when the panels are combined into full arrays.

local S = technic.getter

minetest.register_node("technic:solar_panel", {
	tiles = {"technic_solar_panel_top.png",  "technic_solar_panel_bottom.png", "technic_solar_panel_side.png",
	         "technic_solar_panel_side.png", "technic_solar_panel_side.png",   "technic_solar_panel_side.png"},
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
	sounds = default.node_sound_wood_defaults(),
    	description = S("Solar Panel"),
	active = false,
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = true,	
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("LV_EU_supply", 0)
		meta:set_string("infotext", S("Solar Panel"))
	end,
})

minetest.register_craft({
	output = 'technic:solar_panel',
	recipe = {
		{'technic:doped_silicon_wafer', 'technic:doped_silicon_wafer', 'technic:doped_silicon_wafer'},
		{'technic:wrought_iron_ingot',  'technic:lv_cable0',           'technic:wrought_iron_ingot'},

	}
})

minetest.register_abm({
	nodenames = {"technic:solar_panel"},
	interval   = 1,
	chance     = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		-- The action here is to make the solar panel prodice power
		-- Power is dependent on the light level and the height above ground
		-- 130m and above is optimal as it would be above cloud level.
		-- Height gives 1/4 of the effect, light 3/4. Max. effect is 26EU.
		-- There are many ways to cheat by using other light sources like lamps.
		-- As there is no way to determine if light is sunlight that is just a shame.
		-- To take care of some of it solar panels do not work outside daylight hours or if
		-- built below -10m
		local pos1 = {x=pos.x, y=pos.y+1, z=pos.z}
		local machine_name = S("Solar Panel")

		local light = minetest.get_node_light(pos1, nil)
		local time_of_day = minetest.get_timeofday()
		local meta = minetest.get_meta(pos)
		if light == nil then light = 0 end
		-- turn on panel only during day time and if sufficient light
                -- I know this is counter intuitive when cheating by using other light sources underground.
		if light >= 12 and time_of_day >= 0.24 and time_of_day <= 0.76 and pos.y > -10 then
			local charge_to_give = math.floor((light + pos1.y) * 3)
			charge_to_give = math.max(charge_to_give, 0)
			charge_to_give = math.min(charge_to_give, 200)
			meta:set_string("infotext", S("%s Active"):format(machine_name).." ("..charge_to_give.."EU)")
			meta:set_int("LV_EU_supply", charge_to_give)
		else
			meta:set_string("infotext", S("%s Idle"):format(machine_name))
			meta:set_int("LV_EU_supply", 0)
		end
	end,
}) 

technic.register_machine("LV", "technic:solar_panel", technic.producer)


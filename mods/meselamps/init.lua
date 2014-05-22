local dyes = {
	{"white", "White", "basecolor_white"},
	{"grey", "Grey", "basecolor_grey"},
	{"black", "Black", "basecolor_black"},
	{"red", "Red", "basecolor_red"},
	{"yellow", "Yellow", "basecolor_yellow"},
	{"green", "Green", "basecolor_green"},
	{"cyan", "Cyan", "basecolor_cyan"},
	{"blue", "Blue", "basecolor_blue"},
	{"magenta", "Magenta", "basecolor_magenta"},
	{"orange", "Orange", "excolor_orange"},
	{"violet", "Violet", "excolor_violet"},
	{"brown", "Brown", "unicolor_dark_orange"},
	{"pink", "Pink", "unicolor_light_red"},
	{"dark_grey", "Dark Grey", "unicolor_darkgrey"},
	{"dark_green", "Dark Green", "unicolor_dark_green"},
}

local box_flat_n = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, 0.4375, 0.5, 0.5, 0.5},
		{-0.4375, -0.4375, 0.375, 0.4375, 0.4375, 0.5}
	}
}

local box_flat_s = {
	type = "fixed",
	fixed = {-0.5, -0.5, 0.375, 0.5, 0.5, 0.5}
}

for _,dye in ipairs(dyes) do
	minetest.register_node("meselamps:lamp_cube_"..dye[1].."_0", {
		description = dye[2] .. " Lamp",
		tiles = {"meselamp_"..dye[1].."_dark.png^meselamp_cube_frame.png"},
		paramtype = "light",
		groups = {snappy=1, oddly_breakable_by_hand=4},
		sounds = default.node_sound_defaults(),
		mesecons = {effector = { action_on = function(pos,node)
			minetest.swap_node(pos, {name = string.sub(node.name, 0, -2).."1", param2 = node.param2})
		end }}
	})
	minetest.register_node("meselamps:lamp_cube_"..dye[1].."_1", {
		description = dye[2] .. " Lamp",
		tiles = {"meselamp_"..dye[1]..".png^meselamp_cube_frame.png"},
		paramtype = "light",
		groups = {snappy=1, oddly_breakable_by_hand=4, not_in_creative_inventory=1},
		sounds = default.node_sound_defaults(),
		light_source = 15,
		drop = "meselamps:lamp_cube_"..dye[1].."_0",
		mesecons = {effector = {action_off = function(pos,node)
			minetest.swap_node(pos, {name = string.sub(node.name, 0, -2).."0", param2 = node.param2})
		end }}	
	})
	minetest.register_node("meselamps:lamp_flat_"..dye[1].."_0", {
		description = dye[2] .. " Flat Lamp",
		tiles = {"meselamp_"..dye[1].."_dark.png^meselamp_cube_frame.png"},
		paramtype = "light",
		paramtype2 = "facedir",
		drawtype = "nodebox",
		node_box = box_flat_n, selection_box = box_flat_s,
		groups = {snappy=1, oddly_breakable_by_hand=4},
		sounds = default.node_sound_defaults(),
		mesecons = {effector = { action_on = function(pos,node)
			minetest.swap_node(pos, {name = string.sub(node.name, 0, -2).."1", param2 = node.param2})
		end }},
		after_place_node = function(pos, placer)
			local node = minetest.get_node(pos)
			local ppos = placer:getpos()
			node.param2 = minetest.dir_to_facedir({x = pos.x - ppos.x, y = pos.y - ppos.y - 1.5, z = pos.z - ppos.z}, true)
			minetest.debug("param2 = " .. node.param2)
			minetest.swap_node(pos, node)
		end
	})
	minetest.register_node("meselamps:lamp_flat_"..dye[1].."_1", {
		description = dye[2] .. " Flat Lamp",
		tiles = {"meselamp_"..dye[1]..".png^meselamp_cube_frame.png"},
		paramtype = "light",
		paramtype2 = "facedir",
		drawtype = "nodebox",
		node_box = box_flat_n, selection_box = box_flat_s,
		groups = {snappy=1, oddly_breakable_by_hand=4, not_in_creative_inventory=1},
		sounds = default.node_sound_defaults(),
		light_source = 15,
		drop = "meselamps:lamp_flat_"..dye[1].."_0",
		mesecons = {effector = {action_off = function(pos,node)
			minetest.swap_node(pos, {name = string.sub(node.name, 0, -2).."0", param2 = node.param2})
		end }}	
	})
	minetest.register_craft({
		type = "shapeless",
		output = "meselamps:lamp_cube_"..dye[1].."_0",
		recipe = {"group:dye,"..dye[3], "default:stone", "default:mese_crystal"},
	})
	minetest.register_craft({
		type = "shapeless",
		output = "meselamps:lamp_flat_"..dye[1].."_0 4",
		recipe = {"meselamps:lamp_cube_"..dye[1].."_0"}
	})
end

local S = technic.getter

local tube = {
	insert_object = function(pos, node, stack, direction)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:add_item("src", stack)
	end,
	can_insert = function(pos, node, stack, direction)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:room_for_item("src", stack)
	end,
	connect_sides = {left=1, right=1, back=1, top=1, bottom=1},
}

function technic.register_generator(data) 
	local tier = data.tier
	local ltier = string.lower(tier)

	local groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2}
	local active_groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1}
	if data.tube then
		groups.tubedevice = 1
		groups.tubedevice_receiver = 1
		active_groups.tubedevice = 1
		active_groups.tubedevice_receiver = 1
	end

	local generator_formspec =
		"invsize[8,9;]"..
		"label[0,0;"..S("%s Generator"):format(tier).."]"..
		"list[current_name;src;3,1;1,1;]"..
		"image[4,1;1,1;default_furnace_fire_bg.png]"..
		"list[current_player;main;0,5;8,4;]"
	
	local desc = S("%s Generator"):format(tier)
	minetest.register_node("technic:"..ltier.."_generator", {
		description = desc,
		tiles = {"technic_"..ltier.."_generator_top.png", "technic_machine_bottom.png",
		         "technic_"..ltier.."_generator_side.png", "technic_"..ltier.."_generator_side.png",
		         "technic_"..ltier.."_generator_side.png", "technic_"..ltier.."_generator_front.png"}, 
		paramtype2 = "facedir",
		groups = groups,
		legacy_facedir_simple = true,
		sounds = default.node_sound_wood_defaults(),
		tube = data.tube and tube or nil,
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", desc)
			meta:set_int(data.tier.."_EU_supply", 0)
			meta:set_int("burn_time", 0)
			meta:set_int("tube_time",  0)
			meta:set_string("formspec", generator_formspec)
			local inv = meta:get_inventory()
			inv:set_size("src", 1)
		end,
		can_dig = technic.machine_can_dig,
		allow_metadata_inventory_put = technic.machine_inventory_put,
		allow_metadata_inventory_take = technic.machine_inventory_take,
		allow_metadata_inventory_move = technic.machine_inventory_move,
	})

	minetest.register_node("technic:"..ltier.."_generator_active", {
		description = desc,
		tiles = {"technic_"..ltier.."_generator_top.png", "technic_machine_bottom.png",
		         "technic_"..ltier.."_generator_side.png", "technic_"..ltier.."_generator_side.png",
		         "technic_"..ltier.."_generator_side.png", "technic_"..ltier.."_generator_front_active.png"},
		paramtype2 = "facedir",
		groups = active_groups,
		legacy_facedir_simple = true,
		sounds = default.node_sound_wood_defaults(),
		tube = data.tube and tube or nil,
		drop = "technic:"..ltier.."_generator",
		can_dig = technic.machine_can_dig,
		allow_metadata_inventory_put = technic.machine_inventory_put,
		allow_metadata_inventory_take = technic.machine_inventory_take,
		allow_metadata_inventory_move = technic.machine_inventory_move,
	})
	minetest.register_abm({
		nodenames = {"technic:"..ltier.."_generator", "technic:"..ltier.."_generator_active"},
		interval = 1,
		chance = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local meta = minetest.get_meta(pos)
			local burn_time = meta:get_int("burn_time")
			local burn_totaltime = meta:get_int("burn_totaltime")
			-- If more to burn and the energy produced was used: produce some more
			if burn_time > 0 then
				meta:set_int(tier.."_EU_supply", data.supply)
				burn_time = burn_time - 1
				meta:set_int("burn_time", burn_time)
			end
			-- Burn another piece of fuel
			if burn_time == 0 then
				local inv = meta:get_inventory()
				if not inv:is_empty("src") then 
					local fuellist = inv:get_list("src")
					local fuel = minetest.get_craft_result(
							{method = "fuel", width = 1,
							items = fuellist})
					if not fuel or fuel.time == 0 then
						meta:set_string("infotext", S("%s Out Of Fuel"):format(desc))
						technic.swap_node(pos, "technic:"..ltier.."_generator")
						return
					end
					meta:set_int("burn_time", fuel.time)
					meta:set_int("burn_totaltime", fuel.time)
					local stack = inv:get_stack("src", 1)
					stack:take_item()
					inv:set_stack("src", 1, stack)
					technic.swap_node(pos, "technic:"..ltier.."_generator_active")
					meta:set_int(tier.."_EU_supply", data.supply)
				else
					technic.swap_node(pos, "technic:"..ltier.."_generator")
					meta:set_int(tier.."_EU_supply", 0)
				end
			end
			if burn_totaltime == 0 then burn_totaltime = 1 end
			local percent = math.floor((burn_time / burn_totaltime) * 100)
			meta:set_string("infotext", desc.." ("..percent.."%)")
				meta:set_string("formspec", 
					"size[8, 9]"..
					"label[0, 0;Generator]"..
					"list[current_name;src;3, 1;1, 1;]"..
					"image[4, 1;1, 1;default_furnace_fire_bg.png^[lowpart:"..
					(percent)..":default_furnace_fire_fg.png]"..
					"list[current_player;main;0, 5;8, 4;]")
		end
	})
	technic.register_machine(tier, "technic:"..ltier.."_generator",        technic.producer)
	technic.register_machine(tier, "technic:"..ltier.."_generator_active", technic.producer)
end


-- This file supplies the various kinds of pneumatic tubes

pipeworks.tubenodes = {}

minetest.register_alias("pipeworks:tube", "pipeworks:tube_000000")

-- now, a function to define the tubes

local REGISTER_COMPATIBILITY = true

local vti = {4, 3, 2, 1, 6, 5}

local register_one_tube = function(name, tname, dropname, desc, plain, noctrs, ends, short, inv, special, connects, style)
	local outboxes = {}
	local outsel = {}
	local outimgs = {}
	
	for i = 1, 6 do
		outimgs[vti[i]] = plain[i]
	end
	
	for _, v in ipairs(connects) do
		pipeworks.add_node_box(outboxes, pipeworks.tube_boxes[v])
		table.insert(outsel, pipeworks.tube_selectboxes[v])
		outimgs[vti[v]] = noctrs[v]
	end

	if #connects == 1 then
		local v = connects[1]
		v = v-1 + 2*(v%2) -- Opposite side
		outimgs[vti[v]] = ends[v]
	end

	local tgroups = {snappy = 3, tube = 1, not_in_creative_inventory = 1}
	local tubedesc = desc.." "..dump(connects).."... You hacker, you."
	local iimg = plain[1]
	local wscale = {x = 1, y = 1, z = 1}

	if #connects == 0 then
		tgroups = {snappy = 3, tube = 1}
		tubedesc = desc
		iimg=inv
		outimgs = {
			short, short,
			ends[3],ends[4],
			short, short
		}
		outboxes = { -24/64, -9/64, -9/64, 24/64, 9/64, 9/64 }
		outsel = { -24/64, -10/64, -10/64, 24/64, 10/64, 10/64 }
		wscale = {x = 1, y = 1, z = 0.01}
	end
	
	table.insert(pipeworks.tubenodes, name.."_"..tname)
	
	local nodedef = {
		description = tubedesc,
		drawtype = "nodebox",
		tiles = outimgs,
		sunlight_propagates = true,
		inventory_image = iimg,
		wield_image = iimg,
		wield_scale = wscale,
		paramtype = "light",
		selection_box = {
	             	type = "fixed",
			fixed = outsel
		},
		node_box = {
			type = "fixed",
			fixed = outboxes
		},
		groups = tgroups,
		sounds = default.node_sound_wood_defaults(),
		walkable = true,
		stack_max = 99,
		basename = name,
		style = style,
		drop = name.."_"..dropname,
		tubelike = 1,
		tube = {connect_sides = {front = 1, back = 1, left = 1, right = 1, top = 1, bottom = 1}},
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("tubelike", 1)
			if minetest.registered_nodes[name.."_"..tname].on_construct_ then
				minetest.registered_nodes[name.."_"..tname].on_construct_(pos)
			end
		end,
		after_place_node = function(pos)
			pipeworks.scan_for_tube_objects(pos)
			if minetest.registered_nodes[name.."_"..tname].after_place_node_ then
				minetest.registered_nodes[name.."_"..tname].after_place_node_(pos)
			end
		end,
		after_dig_node = function(pos)
			pipeworks.scan_for_tube_objects(pos)
			if minetest.registered_nodes[name.."_"..tname].after_dig_node_ then
				minetest.registered_nodes[name.."_"..tname].after_dig_node_(pos)
			end
		end
	}
	if style == "6d" then
		nodedef.paramtype2 = "facedir"
	end
	
	if special == nil then special = {} end

	for key, value in pairs(special) do
		if key == "on_construct" or key == "after_dig_node" or key == "after_place_node" then
			nodedef[key.."_"] = value
		elseif key == "groups" then
			for group, val in pairs(value) do
				nodedef.groups[group] = val
			end
		elseif key == "tube" then
			for key, val in pairs(value) do
				nodedef.tube[key] = val
			end
		elseif type(value) == "table" then
			nodedef[key] = pipeworks.replace_name(value, "#id", tname)
		elseif type(value) == "string" then
			nodedef[key] = string.gsub(value, "#id", tname)
		else
			nodedef[key] = value
		end
	end

	local prefix = ":"
	if string.find(name, "pipeworks:") then prefix = "" end

	minetest.register_node(prefix..name.."_"..tname, nodedef)
end

pipeworks.register_tube = function(name, desc, plain, noctrs, ends, short, inv, special, old_registration)
	if old_registration then
		for xm = 0, 1 do
		for xp = 0, 1 do
		for ym = 0, 1 do
		for yp = 0, 1 do
		for zm = 0, 1 do
		for zp = 0, 1 do
			local connects = {}
			if xm == 1 then
				connects[#connects+1] = 1
			end
			if xp == 1 then
				connects[#connects+1] = 2
			end
			if ym == 1 then
				connects[#connects+1] = 3
			end
			if yp == 1 then
				connects[#connects+1] = 4
			end
			if zm == 1 then
				connects[#connects+1] = 5
			end
			if zp == 1 then
				connects[#connects+1] = 6
			end
			local tname = xm..xp..ym..yp..zm..zp
			register_one_tube(name, tname, "000000", desc, plain, noctrs, ends, short, inv, special, connects, "old")
		end
		end
		end
		end
		end
		end
	else
		-- 6d tubes: uses only 10 nodes instead of 64, but the textures must be rotated
		local cconnects = {{}, {1}, {1, 2}, {1, 3}, {1, 3, 5}, {1, 2, 3}, {1, 2, 3, 5}, {1, 2, 3, 4}, {1, 2, 3, 4, 5}, {1, 2, 3, 4, 5, 6}}
		for index, connects in ipairs(cconnects) do
			register_one_tube(name, tostring(index), "1", desc, plain, noctrs, ends, short, inv, special, connects, "6d")
		end
		if REGISTER_COMPATIBILITY then
			local cname = name.."_compatibility"
			minetest.register_node(cname, {
				drawtype = "airlike",
				style = "6d",
				basename = name,
				inventory_image = inv,
				wield_image = inv,
				paramtype = "light",
				sunlight_propagates = true,
				description = "Pneumatic tube segment (legacy)",
				on_construct = function(pos)
					local meta = minetest.get_meta(pos)
					meta:set_int("tubelike", 1)
				end,
				after_place_node = function(pos)
					pipeworks.scan_for_tube_objects(pos)
					if minetest.registered_nodes[name.."_1"].after_place_node_ then
						minetest.registered_nodes[name.."_1"].after_place_node_(pos)
					end
				end,
				groups = {not_in_creative_inventory = 1, tube_to_update = 1},
				tube = {connect_sides = {front = 1, back = 1, left = 1, right = 1, top = 1, bottom = 1}},
				drop = name.."_1",
			})
			table.insert(pipeworks.tubenodes,cname)
			for xm = 0, 1 do
			for xp = 0, 1 do
			for ym = 0, 1 do
			for yp = 0, 1 do
			for zm = 0, 1 do
			for zp = 0, 1 do
				local tname = xm..xp..ym..yp..zm..zp
				minetest.register_alias(name.."_"..tname, cname)
			end
			end
			end
			end
			end
			end
		end
	end
end

if REGISTER_COMPATIBILITY then
	minetest.register_abm({
		nodenames = {"group:tube_to_update"},
		interval = 1,
		chance = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local minp = {x = pos.x-1, y = pos.y-1, z = pos.z-1}
			local maxp = {x = pos.x+1, y = pos.y+1, z = pos.z+1}
			if table.getn(minetest.find_nodes_in_area(minp, maxp, "ignore")) == 0 then
				pipeworks.scan_for_tube_objects(pos)
			end
		end
	})
end

-- now let's actually call that function to get the real work done!

local noctr_textures = {"pipeworks_tube_noctr.png", "pipeworks_tube_noctr.png", "pipeworks_tube_noctr.png",
			"pipeworks_tube_noctr.png", "pipeworks_tube_noctr.png", "pipeworks_tube_noctr.png"}
local plain_textures = {"pipeworks_tube_plain.png", "pipeworks_tube_plain.png", "pipeworks_tube_plain.png",
			"pipeworks_tube_plain.png", "pipeworks_tube_plain.png", "pipeworks_tube_plain.png"}
local end_textures = {"pipeworks_tube_end.png", "pipeworks_tube_end.png", "pipeworks_tube_end.png",
		      "pipeworks_tube_end.png", "pipeworks_tube_end.png", "pipeworks_tube_end.png"}
local short_texture = "pipeworks_tube_short.png"
local inv_texture = "pipeworks_tube_inv.png"

pipeworks.register_tube("pipeworks:tube", "Pneumatic tube segment", plain_textures, noctr_textures, end_textures, short_texture, inv_texture)

if pipeworks.enable_mese_tube then
	local mese_noctr_textures = {"pipeworks_mese_tube_noctr_1.png", "pipeworks_mese_tube_noctr_2.png", "pipeworks_mese_tube_noctr_3.png",
				     "pipeworks_mese_tube_noctr_4.png", "pipeworks_mese_tube_noctr_5.png", "pipeworks_mese_tube_noctr_6.png"}
	local mese_plain_textures = {"pipeworks_mese_tube_plain_1.png", "pipeworks_mese_tube_plain_2.png", "pipeworks_mese_tube_plain_3.png",
				     "pipeworks_mese_tube_plain_4.png", "pipeworks_mese_tube_plain_5.png", "pipeworks_mese_tube_plain_6.png"}
	local mese_end_textures = {"pipeworks_mese_tube_end.png", "pipeworks_mese_tube_end.png", "pipeworks_mese_tube_end.png",
				   "pipeworks_mese_tube_end.png", "pipeworks_mese_tube_end.png", "pipeworks_mese_tube_end.png"}
	local mese_short_texture = "pipeworks_mese_tube_short.png"
	local mese_inv_texture = "pipeworks_mese_tube_inv.png"
	pipeworks.register_tube("pipeworks:mese_tube", "Mese pneumatic tube segment", mese_plain_textures, mese_noctr_textures,
				mese_end_textures, mese_short_texture, mese_inv_texture,
				{tube = {can_go = function(pos, node, velocity, stack)
						 local tbl = {}
						 local meta = minetest.get_meta(pos)
						 local inv = meta:get_inventory()
						 local found = false
						 local name = stack:get_name()
						 for i, vect in ipairs(pipeworks.meseadjlist) do
							 if meta:get_int("l"..tostring(i).."s") == 1 then
								 for _, st in ipairs(inv:get_list("line"..tostring(i))) do
									 if st:get_name() == name then
										 found = true
										 table.insert(tbl, vect)
									 end
								 end
							 end
						 end
						 if found == false then
							 for i, vect in ipairs(pipeworks.meseadjlist) do
								 if meta:get_int("l"..tostring(i).."s") == 1 then
									 if inv:is_empty("line"..tostring(i)) then
										 table.insert(tbl, vect)
									 end
								 end
							 end
						 end
						 return tbl
					end},
				 on_construct = function(pos)
					 local meta = minetest.get_meta(pos)
					 local inv = meta:get_inventory()
					 for i = 1, 6 do
						 meta:set_int("l"..tostring(i).."s", 1)
						 inv:set_size("line"..tostring(i), 6*1)
					 end
					 meta:set_string("formspec",
							 "size[8,11]"..
							 "list[current_name;line1;1,0;6,1;]"..
							 "list[current_name;line2;1,1;6,1;]"..
							 "list[current_name;line3;1,2;6,1;]"..
							 "list[current_name;line4;1,3;6,1;]"..
							 "list[current_name;line5;1,4;6,1;]"..
							 "list[current_name;line6;1,5;6,1;]"..
							 "image[0,0;1,1;pipeworks_white.png]"..
							 "image[0,1;1,1;pipeworks_black.png]"..
							 "image[0,2;1,1;pipeworks_green.png]"..
							 "image[0,3;1,1;pipeworks_yellow.png]"..
							 "image[0,4;1,1;pipeworks_blue.png]"..
							 "image[0,5;1,1;pipeworks_red.png]"..
							 "button[7,0;1,1;button1;On]"..
							 "button[7,1;1,1;button2;On]"..
							 "button[7,2;1,1;button3;On]"..
							 "button[7,3;1,1;button4;On]"..
							 "button[7,4;1,1;button5;On]"..
							 "button[7,5;1,1;button6;On]"..
							 "list[current_player;main;0,7;8,4;]")
					 meta:set_string("infotext", "Mese pneumatic tube")
				 end,
				 on_receive_fields = function(pos, formname, fields, sender)
					 local meta = minetest.get_meta(pos)
					 local i
					 if fields.quit then return end
					 for key, _ in pairs(fields) do i = key end
					 if i == nil then return end
					 i = string.sub(i,-1)
					 newstate = 1 - meta:get_int("l"..i.."s")
					 meta:set_int("l"..i.."s",newstate)
					 local frm = "size[8,11]"..
						 "list[current_name;line1;1,0;6,1;]"..
						 "list[current_name;line2;1,1;6,1;]"..
						 "list[current_name;line3;1,2;6,1;]"..
						 "list[current_name;line4;1,3;6,1;]"..
						 "list[current_name;line5;1,4;6,1;]"..
						 "list[current_name;line6;1,5;6,1;]"..
						 "image[0,0;1,1;pipeworks_white.png]"..
						 "image[0,1;1,1;pipeworks_black.png]"..
						 "image[0,2;1,1;pipeworks_green.png]"..
						 "image[0,3;1,1;pipeworks_yellow.png]"..
						 "image[0,4;1,1;pipeworks_blue.png]"..
						 "image[0,5;1,1;pipeworks_red.png]"
					 for i = 1, 6 do
						 local st = meta:get_int("l"..tostring(i).."s")
						 if st == 0 then
							 frm = frm.."button[7,"..tostring(i-1)..";1,1;button"..tostring(i)..";Off]"
						 else
							 frm = frm.."button[7,"..tostring(i-1)..";1,1;button"..tostring(i)..";On]"
						 end
					 end
					 frm = frm.."list[current_player;main;0,7;8,4;]"
					 meta:set_string("formspec", frm)
				 end,
				 can_dig = function(pos, player)
					 local meta = minetest.get_meta(pos)
					 local inv = meta:get_inventory()
					 return (inv:is_empty("line1") and inv:is_empty("line2") and inv:is_empty("line3") and
							 inv:is_empty("line4") and inv:is_empty("line5") and inv:is_empty("line6"))
				 end
				}, true) -- Must use old tubes, since the textures are rotated with 6d ones
end

if pipeworks.enable_detector_tube then
	local detector_plain_textures = {"pipeworks_detector_tube_plain.png", "pipeworks_detector_tube_plain.png", "pipeworks_detector_tube_plain.png",
					 "pipeworks_detector_tube_plain.png", "pipeworks_detector_tube_plain.png", "pipeworks_detector_tube_plain.png"}
	local detector_inv_texture = "pipeworks_detector_tube_inv.png"
	pipeworks.register_tube("pipeworks:detector_tube_on", "Detector tube segment on (you hacker you)", detector_plain_textures, noctr_textures,
				end_textures, short_texture, detector_inv_texture,
				{tube = {can_go = function(pos, node, velocity, stack)
						 local meta = minetest.get_meta(pos)
						 local name = minetest.get_node(pos).name
						 local nitems = meta:get_int("nitems")+1
						 meta:set_int("nitems", nitems)
						 minetest.after(0.1, minetest.registered_nodes[name].item_exit, pos)
						 return pipeworks.notvel(pipeworks.meseadjlist,velocity)
					end},
				 groups = {mesecon = 2, not_in_creative_inventory = 1},
				 drop = "pipeworks:detector_tube_off_1",
				 mesecons = {receptor = {state = "on",
							 rules = pipeworks.mesecons_rules}},
				 item_exit = function(pos)
					local meta = minetest.get_meta(pos)
					local nitems = meta:get_int("nitems")-1
					local node = minetest.get_node(pos)
					local name = node.name
					local fdir = node.param2
					if nitems == 0 then
						 minetest.set_node(pos, {name = string.gsub(name, "on", "off"), param2 = fdir})
						 mesecon:receptor_off(pos, pipeworks.mesecons_rules)
					else
						 meta:set_int("nitems", nitems)
					end
				 end,
				 on_construct = function(pos)
					 local meta = minetest.get_meta(pos)
					 meta:set_int("nitems", 1)
					 local name = minetest.get_node(pos).name
					 minetest.after(0.1, minetest.registered_nodes[name].item_exit,pos)
	end})
	pipeworks.register_tube("pipeworks:detector_tube_off", "Detector tube segment", detector_plain_textures, noctr_textures,
				end_textures, short_texture, detector_inv_texture,
				{tube = {can_go = function(pos, node, velocity, stack)
						local node = minetest.get_node(pos)
						local name = node.name
						local fdir = node.param2
						minetest.set_node(pos,{name = string.gsub(name, "off", "on"), param2 = fdir})
						mesecon:receptor_on(pos, pipeworks.mesecons_rules)
						return pipeworks.notvel(pipeworks.meseadjlist, velocity)
					end},
				 groups = {mesecon = 2},
				 mesecons = {receptor = {state = "off",
							 rules = pipeworks.mesecons_rules}}
	})
end

if pipeworks.enable_conductor_tube then
	local conductor_plain_textures = {"pipeworks_conductor_tube_plain.png", "pipeworks_conductor_tube_plain.png", "pipeworks_conductor_tube_plain.png",
					  "pipeworks_conductor_tube_plain.png", "pipeworks_conductor_tube_plain.png", "pipeworks_conductor_tube_plain.png"}
	local conductor_noctr_textures = {"pipeworks_conductor_tube_noctr.png", "pipeworks_conductor_tube_noctr.png", "pipeworks_conductor_tube_noctr.png",
					  "pipeworks_conductor_tube_noctr.png", "pipeworks_conductor_tube_noctr.png", "pipeworks_conductor_tube_noctr.png"}
	local conductor_end_textures = {"pipeworks_conductor_tube_end.png", "pipeworks_conductor_tube_end.png", "pipeworks_conductor_tube_end.png",
					"pipeworks_conductor_tube_end.png", "pipeworks_conductor_tube_end.png", "pipeworks_conductor_tube_end.png"}
	local conductor_short_texture = "pipeworks_conductor_tube_short.png"
	local conductor_inv_texture = "pipeworks_conductor_tube_inv.png"

	local conductor_on_plain_textures = {"pipeworks_conductor_tube_on_plain.png", "pipeworks_conductor_tube_on_plain.png", "pipeworks_conductor_tube_on_plain.png",
					     "pipeworks_conductor_tube_on_plain.png", "pipeworks_conductor_tube_on_plain.png", "pipeworks_conductor_tube_on_plain.png"}
	local conductor_on_noctr_textures = {"pipeworks_conductor_tube_on_noctr.png", "pipeworks_conductor_tube_on_noctr.png", "pipeworks_conductor_tube_on_noctr.png",
					     "pipeworks_conductor_tube_on_noctr.png", "pipeworks_conductor_tube_on_noctr.png", "pipeworks_conductor_tube_on_noctr.png"}
	local conductor_on_end_textures = {"pipeworks_conductor_tube_on_end.png", "pipeworks_conductor_tube_on_end.png", "pipeworks_conductor_tube_on_end.png",
					   "pipeworks_conductor_tube_on_end.png", "pipeworks_conductor_tube_on_end.png", "pipeworks_conductor_tube_on_end.png"}

	pipeworks.register_tube("pipeworks:conductor_tube_off", "Conductor tube segment", conductor_plain_textures, conductor_noctr_textures,
				conductor_end_textures, conductor_short_texture, conductor_inv_texture,
				{groups = {mesecon = 2},
				 mesecons = {conductor = {state = "off",
							  rules = pipeworks.mesecons_rules,
							  onstate = "pipeworks:conductor_tube_on_#id"}}
	})

	pipeworks.register_tube("pipeworks:conductor_tube_on", "Conductor tube segment on (you hacker you)", conductor_on_plain_textures, conductor_on_noctr_textures,
				conductor_on_end_textures, conductor_short_texture, conductor_inv_texture,
				{groups = {mesecon = 2, not_in_creative_inventory = 1},
				 drop = "pipeworks:conductor_tube_off_1",
				 mesecons = {conductor = {state = "on",
							  rules = pipeworks.mesecons_rules,
							  offstate = "pipeworks:conductor_tube_off_#id"}}
	})
end

if pipeworks.enable_accelerator_tube then
	local accelerator_noctr_textures = {"pipeworks_accelerator_tube_noctr.png", "pipeworks_accelerator_tube_noctr.png", "pipeworks_accelerator_tube_noctr.png",
					    "pipeworks_accelerator_tube_noctr.png", "pipeworks_accelerator_tube_noctr.png", "pipeworks_accelerator_tube_noctr.png"}
	local accelerator_plain_textures = {"pipeworks_accelerator_tube_plain.png" ,"pipeworks_accelerator_tube_plain.png", "pipeworks_accelerator_tube_plain.png",
					    "pipeworks_accelerator_tube_plain.png", "pipeworks_accelerator_tube_plain.png", "pipeworks_accelerator_tube_plain.png"}
	local accelerator_end_textures = {"pipeworks_accelerator_tube_end.png", "pipeworks_accelerator_tube_end.png", "pipeworks_accelerator_tube_end.png",
					  "pipeworks_accelerator_tube_end.png", "pipeworks_accelerator_tube_end.png", "pipeworks_accelerator_tube_end.png"}
	local accelerator_short_texture = "pipeworks_accelerator_tube_short.png"
	local accelerator_inv_texture = "pipeworks_accelerator_tube_inv.png"

	pipeworks.register_tube("pipeworks:accelerator_tube", "Accelerator pneumatic tube segment", accelerator_plain_textures,
				accelerator_noctr_textures, accelerator_end_textures, accelerator_short_texture, accelerator_inv_texture,
				{tube = {can_go = function(pos, node, velocity, stack)
						 velocity.speed = velocity.speed+1
						 return pipeworks.notvel(pipeworks.meseadjlist, velocity)
					end}
	})
end

if pipeworks.enable_crossing_tube then
	-- FIXME: The textures are not the correct ones
	local crossing_noctr_textures = {"pipeworks_crossing_tube_noctr.png", "pipeworks_crossing_tube_noctr.png", "pipeworks_crossing_tube_noctr.png",
					 "pipeworks_crossing_tube_noctr.png", "pipeworks_crossing_tube_noctr.png", "pipeworks_crossing_tube_noctr.png"}
	local crossing_plain_textures = {"pipeworks_crossing_tube_plain.png" ,"pipeworks_crossing_tube_plain.png", "pipeworks_crossing_tube_plain.png",
					 "pipeworks_crossing_tube_plain.png", "pipeworks_crossing_tube_plain.png", "pipeworks_crossing_tube_plain.png"}
	local crossing_end_textures = {"pipeworks_crossing_tube_end.png", "pipeworks_crossing_tube_end.png", "pipeworks_crossing_tube_end.png",
				       "pipeworks_crossing_tube_end.png", "pipeworks_crossing_tube_end.png", "pipeworks_crossing_tube_end.png"}
	local crossing_short_texture = "pipeworks_crossing_tube_short.png"
	local crossing_inv_texture = "pipeworks_crossing_tube_inv.png"

	pipeworks.register_tube("pipeworks:crossing_tube", "Crossing tube segment", crossing_plain_textures,
				crossing_noctr_textures, crossing_end_textures, crossing_short_texture, crossing_inv_texture,
				{tube = {can_go = function(pos, node, velocity, stack)
						 return {velocity}
					end}
	})
end

if pipeworks.enable_sand_tube then
	local sand_noctr_textures = {"pipeworks_sand_tube_noctr.png", "pipeworks_sand_tube_noctr.png", "pipeworks_sand_tube_noctr.png",
				     "pipeworks_sand_tube_noctr.png", "pipeworks_sand_tube_noctr.png", "pipeworks_sand_tube_noctr.png"}
	local sand_plain_textures = {"pipeworks_sand_tube_plain.png", "pipeworks_sand_tube_plain.png", "pipeworks_sand_tube_plain.png",
				     "pipeworks_sand_tube_plain.png", "pipeworks_sand_tube_plain.png", "pipeworks_sand_tube_plain.png"}
	local sand_end_textures = {"pipeworks_sand_tube_end.png", "pipeworks_sand_tube_end.png", "pipeworks_sand_tube_end.png",
				   "pipeworks_sand_tube_end.png", "pipeworks_sand_tube_end.png", "pipeworks_sand_tube_end.png"}
	local sand_short_texture = "pipeworks_sand_tube_short.png"
	local sand_inv_texture = "pipeworks_sand_tube_inv.png"

	pipeworks.register_tube("pipeworks:sand_tube", "Sand pneumatic tube segment", sand_plain_textures, sand_noctr_textures, sand_end_textures,
				sand_short_texture, sand_inv_texture,
				{groups = {sand_tube = 1}})

	minetest.register_abm({nodenames = {"group:sand_tube"},
			       interval = 1,
			       chance = 1,
			       action = function(pos, node, active_object_count, active_object_count_wider)
				       for _, object in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
					       if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
						       if object:get_luaentity().itemstring ~= "" then
							       local titem = pipeworks.tube_item(pos,object:get_luaentity().itemstring)
							       titem:get_luaentity().start_pos = {x = pos.x, y = pos.y-1, z = pos.z}
							       titem:setvelocity({x = 0.01, y = 1, z = -0.01})
							       titem:setacceleration({x = 0, y = 0, z = 0})
						       end
						       object:get_luaentity().itemstring = ""
						       object:remove()
					       end
				       end
			       end
	})
end

if pipeworks.enable_mese_sand_tube then
	local mese_sand_noctr_textures = {"pipeworks_mese_sand_tube_noctr.png", "pipeworks_mese_sand_tube_noctr.png", "pipeworks_mese_sand_tube_noctr.png",
					  "pipeworks_mese_sand_tube_noctr.png", "pipeworks_mese_sand_tube_noctr.png", "pipeworks_mese_sand_tube_noctr.png"}
	local mese_sand_plain_textures = {"pipeworks_mese_sand_tube_plain.png", "pipeworks_mese_sand_tube_plain.png", "pipeworks_mese_sand_tube_plain.png",
					  "pipeworks_mese_sand_tube_plain.png", "pipeworks_mese_sand_tube_plain.png", "pipeworks_mese_sand_tube_plain.png"}
	local mese_sand_end_textures = {"pipeworks_mese_sand_tube_end.png", "pipeworks_mese_sand_tube_end.png", "pipeworks_mese_sand_tube_end.png",
					"pipeworks_mese_sand_tube_end.png", "pipeworks_mese_sand_tube_end.png", "pipeworks_mese_sand_tube_end.png"}
	local mese_sand_short_texture = "pipeworks_mese_sand_tube_short.png"
	local mese_sand_inv_texture = "pipeworks_mese_sand_tube_inv.png"

	pipeworks.register_tube("pipeworks:mese_sand_tube", "Mese sand pneumatic tube segment", mese_sand_plain_textures, mese_sand_noctr_textures,
				mese_sand_end_textures, mese_sand_short_texture,mese_sand_inv_texture,
				{groups = {mese_sand_tube = 1},
				 on_construct = function(pos)
					 local meta = minetest.env:get_meta(pos)
					 meta:set_int("dist", 0)
					 meta:set_string("formspec",
							 "size[2,1]"..
								 "field[.5,.5;1.5,1;dist;distance;${dist}]")
					 meta:set_string("infotext", "Mese sand pneumatic tube")
				 end,
				 on_receive_fields = function(pos,formname,fields,sender)
					 local meta = minetest.env:get_meta(pos)
					 local dist
					 _, dist = pcall(tonumber, fields.dist)
					 if dist and 0 <= dist and dist <= 8 then meta:set_int("dist", dist) end
				 end,
	})

	local function get_objects_with_square_radius(pos, rad)
		rad = rad + .5;
		local objs = {}
		for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, math.sqrt(3)*rad)) do
			if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
				local opos = object:getpos()
				if pos.x - rad <= opos.x and opos.x <= pos.x + rad and pos.y - rad <= opos.y and opos.y <= pos.y + rad and pos.z - rad <= opos.z and opos.z <= pos.z + rad then
					objs[#objs + 1] = object
				end
			end
		end
		return objs
	end

	minetest.register_abm({nodenames = {"group:mese_sand_tube"},
			       interval = 1,
			       chance = 1,
			       action = function(pos, node, active_object_count, active_object_count_wider)
				       for _,object in ipairs(get_objects_with_square_radius(pos, minetest.env:get_meta(pos):get_int("dist"))) do
					       if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
						       if object:get_luaentity().itemstring ~= "" then
							       local titem = pipeworks.tube_item(pos, object:get_luaentity().itemstring)
							       titem:get_luaentity().start_pos = {x = pos.x, y = pos.y-1, z = pos.z}
							       titem:setvelocity({x = 0.01, y = 1, z = -0.01})
							       titem:setacceleration({x = 0, y = 0, z = 0})
						       end
						       object:get_luaentity().itemstring = ""
						       object:remove()
					       end
				       end
			       end
	})
end

local function facedir_to_right_dir(facedir)
	
	--find the other directions
	local backdir = minetest.facedir_to_dir(facedir)
	local topdir = ({[0] = {x = 0, y = 1, z = 0},
			 {x = 0, y = 0, z = 1},
			 {x = 0, y = 0, z = -1},
			 {x = 1, y = 0, z = 0},
			 {x = -1, y = 0, z = 0},
			 {x = 0, y = -1, z = 0}})[math.floor(facedir/4)]
	
	--return a cross product
	return {x = topdir.y*backdir.z - backdir.y*topdir.z,
		y = topdir.z*backdir.x - backdir.z*topdir.x,
		z = topdir.x*backdir.y - backdir.x*topdir.y}
end

if pipeworks.enable_one_way_tube then
	minetest.register_node("pipeworks:one_way_tube", {
		description = "One way tube",
		tiles = {"pipeworks_one_way_tube_top.png", "pipeworks_one_way_tube_top.png", "pipeworks_one_way_tube_output.png",
			"pipeworks_one_way_tube_input.png", "pipeworks_one_way_tube_side.png", "pipeworks_one_way_tube_top.png"},
		paramtype2 = "facedir",
		drawtype = "nodebox",
		paramtype = "light",
		node_box = {type = "fixed",
			fixed = {{-1/2, -9/64, -9/64, 1/2, 9/64, 9/64}}},
		groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, tubedevice = 1, tubedevice_receiver = 1},
		legacy_facedir_simple = true,
		sounds = default.node_sound_wood_defaults(),
		on_construct = function(pos)
			minetest.get_meta(pos):set_int("tubelike", 1)
		end,
		after_place_node = function(pos)
			pipeworks.scan_for_tube_objects(pos)
		end,
		after_dig_node = function(pos)
			pipeworks.scan_for_tube_objects(pos)
		end,
		tube = {connect_sides = {left = 1, right = 1},
			can_go = function(pos, node, velocity, stack)
				return velocity
			end,
			insert_object = function(pos, node, stack, direction)
				item1 = pipeworks.tube_item(pos, stack)
				item1:get_luaentity().start_pos = pos
				item1:setvelocity({x = direction.x*direction.speed, y = direction.y*direction.speed, z = direction.z*direction.speed})
				item1:setacceleration({x = 0, y = 0, z = 0})
				return ItemStack("")
			end,
			can_insert = function(pos, node, stack, direction)
				local dir = facedir_to_right_dir(node.param2)
				if dir.x == direction.x and dir.y == direction.y and dir.z == direction.z then
					return true
				end
				return false
			end},
	})
end

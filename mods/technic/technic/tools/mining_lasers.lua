
local r_corr = 0.25 -- Remove a bit more nodes (if shooting diagonal) to let it look like a hole (sth like antialiasing)

local mining_lasers_list = {
--	{<num>, <range of the laser shots>, <max_charge>, <charge_per_shot>},
	{"1", 7, 50000, 1000},
	{"2", 14, 200000, 2000},
	{"3", 21, 650000, 3000},
}

local f_1 = 0.5 - r_corr
local f_2 = 0.5 + r_corr

local S = technic.getter

minetest.register_craft({
	output = 'technic:laser_mk1',
	recipe = {
		{'default:diamond', 'technic:carbon_steel_ingot', 'technic:red_energy_crystal'},
		{'',                'technic:carbon_steel_ingot', 'technic:carbon_steel_ingot'},
		{'',                '',                           'default:copper_ingot'},
	}
})
minetest.register_craft({
	output = 'technic:laser_mk2',
	recipe = {
		{'default:diamond', 'technic:carbon_steel_ingot', 'technic:laser_mk1'},
		{'',                'technic:carbon_steel_ingot', 'technic:green_energy_crystal'},
		{'',                '',                           'default:copper_ingot'},
	}
})
minetest.register_craft({
	output = 'technic:laser_mk3',
	recipe = {
		{'default:diamond', 'technic:carbon_steel_ingot', 'technic:laser_mk2'},
		{'',                'technic:carbon_steel_ingot', 'technic:blue_energy_crystal'},
		{'',                '',                           'default:copper_ingot'},
	}
})


local function get_used_dir(dir)
	local abs_dir = {x = math.abs(dir.x),
			y = math.abs(dir.y),
			z = math.abs(dir.z)}
	local dir_max = math.max(abs_dir.x, abs_dir.y, abs_dir.z)
	if dir_max == abs_dir.x then
		local tab = {"x", {x = 1, y = dir.y / dir.x, z = dir.z / dir.x}}
		if dir.x >= 0 then
			tab[3] = "+"
		end
		return tab
	end
	if dir_max == abs_dir.y then
		local tab = {"y", {x = dir.x / dir.y, y = 1, z = dir.z / dir.y}}
		if dir.y >= 0 then
			tab[3] = "+"
		end
		return tab
	end
	local tab = {"z", {x = dir.x / dir.z, y = dir.y / dir.z, z = 1}}
	if dir.z >= 0 then
		tab[3] = "+"
	end
	return tab
end

local function node_tab(z, d)
	local n1 = math.floor(z * d + f_1)
	local n2 = math.floor(z * d + f_2)
	if n1 == n2 then
		return {n1}
	end
	return {n1, n2}
end

local function laser_node(pos, player)
	local node = minetest.get_node(pos)
	if node.name == "air"
	or node.name == "ignore"
	or node.name == "default:lava_source"
	or node.name == "default:lava_flowing" then
		return
	end
	if minetest.is_protected(pos, player:get_player_name()) then
		minetest.record_protection_violation(pos, player:get_player_name())
		return
	end
	if node.name == "default:water_source"
	or node.name == "default:water_flowing" then
		minetest.remove_node(pos)
		minetest.add_particle(pos,
				{x=0, y=2, z=0},
				{x=0, y=-1, z=0},
				1.5,
				8,
				false,
				"smoke_puff.png")
		return
	end
	if player then
		minetest.node_dig(pos, node, player)
	end
end

local function laser_nodes(pos, dir, player, range)
	local t_dir = get_used_dir(dir)
	local dir_typ = t_dir[1]
	if t_dir[3] == "+" then
		f_tab = {1, range}
	else
		f_tab = {-range, -1}
	end
	local d_ch = t_dir[2]
	if dir_typ == "x" then
		for d = f_tab[1],f_tab[2],1 do
			local x = d
			local ytab = node_tab(d_ch.y, d)
			local ztab = node_tab(d_ch.z, d)
			for _, y in pairs(ytab) do
				for _, z in pairs(ztab) do
					laser_node({x = pos.x + x, y = pos.y + y, z = pos.z + z}, player)
				end
			end
		end
		return
	end
	if dir_typ == "y" then
		for d = f_tab[1], f_tab[2] do
			local xtab = node_tab(d_ch.x, d)
			local y = d
			local ztab = node_tab(d_ch.z, d)
			for _, x in pairs(xtab) do
				for _, z in pairs(ztab) do
					laser_node({x = pos.x + x, y = pos.y + y, z = pos.z + z}, player)
				end
			end
		end
		return
	end
	for d = f_tab[1], f_tab[2] do
		local xtab = node_tab(d_ch.x, d)
		local ytab = node_tab(d_ch.y, d)
		local z = d
		for _, x in pairs(xtab) do
			for _, y in pairs(ytab) do
				laser_node({x = pos.x + x, y = pos.y + y, z = pos.z + z}, player)
			end
		end
	end
end

local function laser_shoot(player, range, particle_texture, sound)
	local playerpos = player:getpos()
	local dir = player:get_look_dir()

	local startpos = {x = playerpos.x, y = playerpos.y + 1.6, z = playerpos.z}
	local mult_dir = vector.multiply(dir, 50)
	minetest.add_particle(startpos, dir, mult_dir, range / 11, 1, false, particle_texture)
	laser_nodes(vector.round(startpos), dir, player, range)
	minetest.sound_play(sound, {pos = playerpos, gain = 1.0, max_hear_distance = range})
end


for _, m in pairs(mining_lasers_list) do
	technic.register_power_tool("technic:laser_mk"..m[1], m[3])
	minetest.register_tool("technic:laser_mk"..m[1], {
		description = S("Mining Laser Mk%d"):format(m[1]),
		inventory_image = "technic_mining_laser_mk"..m[1]..".png",
		stack_max = 1,
		wear_represents = "technic_RE_charge",
		on_refill = technic.refill_RE_charge,
		on_use = function(itemstack, user)
			local meta = minetest.deserialize(itemstack:get_metadata())
			if not meta or not meta.charge then
				return
			end

			-- If there's enough charge left, fire the laser
			if meta.charge >= m[4] then
				meta.charge = meta.charge - m[4]
				laser_shoot(user, m[2], "technic_laser_beam_mk"..m[1]..".png", "technic_laser_mk"..m[1])
				technic.set_RE_wear(itemstack, meta.charge, m[3])
				itemstack:set_metadata(minetest.serialize(meta))
			end
			return itemstack
		end,
	})
end


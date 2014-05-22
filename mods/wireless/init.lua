receivers = {}
-- ================
-- Function declarations
-- ================

 function getspec(node)
	if not minetest.registered_nodes[node.name] then return false end -- ignore unknown nodes
	return minetest.registered_nodes[node.name].wireless
end
 
 function get_range(pos, target_pos)
	local x_dist = target_pos.x - pos.x
	local y_dist = target_pos.y - pos.y
	local z_dist = target_pos.z- pos.z
	local dist = math.sqrt(x_dist^2 + y_dist^2 + z_dist^2)
	print(dist)
	return dist
 end
 
 local on_digiline_receive = function (pos, node, channel, msg)
	local range = 25 
	print("digiline received")
	for i=1, #receivers do  -- Iterate over receivers
		if get_range(pos, receivers[i]) <= range then -- max range
			local target_node = minetest.env:get_node(receivers[i])
			if getspec(target_node) ~= nil then
				local target_spec = getspec(target_node)	
				target_spec.receiver.action(receivers[i], channel, msg)
			else print("Receiver no longer there")
			end
		end
	end
end

local check_msgs = function (pos, channel, msg)
	local meta = minetest.env:get_meta(pos)
	if chan1~="" and msg1 ~= "" then  --don't send blank digiline msgs
		digiline:receptor_send(pos, digiline.rules.default,channel, msg)
	end
end

local register = function (pos)
	local meta = minetest.env:get_meta(pos)
	local RID = meta:get_int("RID")
	if receivers[RID] == nil then
		table.insert(receivers, pos)
		meta:set_int("RID", #receivers)
	end
	
	
end
-- ================
-- ABM declarations
 -- ================
minetest.register_abm({
nodenames = {"wireless:recv"},
interval=1.0,
chance=1,
action = function(pos) 
	register(pos)
end
})

-- ================
-- Node declarations
-- ================

minetest.register_node("wireless:recv", {  -- Relays wireless to digiline
	paramtype = "light",
	description = "wireless digiline receiver",
	digiline = --declare as digiline-capable
	{
		receptor = {},
	},
	wireless = {
		receiver = {
			action = check_msgs 
		}
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.500000,-0.500000,-0.500000,0.500000,-0.125000,0.500000}, --Base
			{-0.062500,-0.125000,-0.062500,0.062500,0.500000,0.062500}, --Antenna
		}
	},
	tiles = {"recv_side.png"},
	groups = {oddly_breakable_by_hand=1},
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("infotext", "Wireless digiline receiver")
		 register(pos)  --register and record RID
	end,
})

minetest.register_node("wireless:trans", { -- Relays digiline to wireless
	paramtype = "light",
	description = "wireless digiline transmitter",
	digiline = --declare as digiline-capable
	{
		receptor = {},
		effector = {
			action = on_digiline_receive
		},
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.500000,-0.500000,-0.500000,0.500000,-0.125000,0.500000}, --Base
			{-0.062500,-0.125000,-0.062500,0.062500,0.500000,0.062500}, --Antenna
		}
	},
	tiles = {"trans_side.png"},
	groups = {oddly_breakable_by_hand=1},
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("infotext", "wireless digiline transmitter")
		print("trans construct")
	end,
	on_punch = function(pos)
		print("trans punched")
	end
	
})

-- ================
--Crafting recipes
-- ================
 
 minetest.register_craft({
	 output = 'wireless:trans',
	 recipe = {
		{"mesecons_extrawires:vertical_off", "", ""},
		{"default:steel_ingot", "mesecons_luacontroller:luacontroller0000", "default:steel_ingot"},
		{"default:steel_ingot", "digilines:wire_std_00000000", "default:steel_ingot"}
	 }
 })
 
 minetest.register_craft({
	 output = 'wireless:recv',
	 recipe = {
		{ "", "", "mesecons_extrawires:vertical_off"},
		{"default:steel_ingot", "mesecons_luacontroller:luacontroller0000", "default:steel_ingot"},
		{"default:steel_ingot", "digilines:wire_std_00000000", "default:steel_ingot"}
	 }
 })
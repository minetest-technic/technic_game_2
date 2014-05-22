
local filename=minetest.get_worldpath() .. "/teleport_tubes"

local function read_file()
	local f = io.open(filename, "r")
	if f==nil then return {} end
    	local t = f:read("*all")
    	f:close()
	if t=="" or t==nil then return {} end
	return minetest.deserialize(t)
end

local function write_file(tbl)
	local f = io.open(filename, "w")
    	f:write(minetest.serialize(tbl))
    	f:close()
end

local function update_pos_in_file(pos)
	local tbl=read_file()
	for _,val in ipairs(tbl) do
		if val.x==pos.x and val.y==pos.y and val.z==pos.z then
			local meta = minetest.get_meta(val)
			val.channel = meta:get_string("channel")
			val.cr = meta:get_int("can_receive")
		end
	end
	write_file(tbl)
end

local function add_tube_in_file(pos,channel, cr)
	local tbl=read_file()
	for _,val in ipairs(tbl) do
		if val.x==pos.x and val.y==pos.y and val.z==pos.z then
			return
		end
	end
	table.insert(tbl,{x=pos.x,y=pos.y,z=pos.z,channel=channel,cr=cr})
	write_file(tbl)
end

local function remove_tube_in_file(pos)
	local tbl=read_file()
	local newtbl={}
	for _,val in ipairs(tbl) do
		if val.x~=pos.x or val.y~=pos.y or val.z~=pos.z then
			table.insert(newtbl,val)
		end
	end
	write_file(newtbl)
end

local function get_tubes_in_file(pos,channel)
	local tbl=read_file()
	local newtbl={}
	local changed=false
	for _,val in ipairs(tbl) do
		local node = minetest.get_node(val)
		local meta = minetest.get_meta(val)
		-- That shouldn't be needed anymore since the mvps callback, but we leave it nevertheless
		if node.name~="ignore"  and (val.channel~=meta:get_string("channel") or val.cr~=meta:get_int("can_receive")) then
			val.channel=meta:get_string("channel")
			val.cr=meta:get_int("can_receive")
			changed=true
		end
		if val.cr==1 and val.channel==channel and (val.x~=pos.x or val.y~=pos.y or val.z~=pos.z) then
			table.insert(newtbl,val)
		end
	end
	if changed then write_file(tbl) end
	return newtbl
end

local teleport_noctr_textures={"pipeworks_teleport_tube_noctr.png","pipeworks_teleport_tube_noctr.png","pipeworks_teleport_tube_noctr.png",
		"pipeworks_teleport_tube_noctr.png","pipeworks_teleport_tube_noctr.png","pipeworks_teleport_tube_noctr.png"}
local teleport_plain_textures={"pipeworks_teleport_tube_plain.png","pipeworks_teleport_tube_plain.png","pipeworks_teleport_tube_plain.png",
		"pipeworks_teleport_tube_plain.png","pipeworks_teleport_tube_plain.png","pipeworks_teleport_tube_plain.png"}
local teleport_end_textures={"pipeworks_teleport_tube_end.png","pipeworks_teleport_tube_end.png","pipeworks_teleport_tube_end.png",
		"pipeworks_teleport_tube_end.png","pipeworks_teleport_tube_end.png","pipeworks_teleport_tube_end.png"}
local teleport_short_texture="pipeworks_teleport_tube_short.png"
local teleport_inv_texture="pipeworks_teleport_tube_inv.png"

pipeworks.register_tube("pipeworks:teleport_tube","Teleporter pneumatic tube segment",teleport_plain_textures,
	teleport_noctr_textures,teleport_end_textures,teleport_short_texture,teleport_inv_texture, {
	tube = {
		can_go = function(pos,node,velocity,stack)
			velocity.x = 0
			velocity.y = 0
			velocity.z = 0
			local meta = minetest.get_meta(pos)
			local channel = meta:get_string("channel")
			local target = get_tubes_in_file(pos,channel)
			if target[1] == nil then return {} end
			local d = math.random(1,#target)
			pos.x = target[d].x
			pos.y = target[d].y
			pos.z = target[d].z
			return pipeworks.meseadjlist
		end
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("channel","")
		meta:set_int("can_receive",1)
		meta:set_string("formspec","size[9,1;]"..
				"field[0,0.5;7,1;channel;Channel:;${channel}]"..
				"button[8,0;1,1;bt;On]")
		add_tube_in_file(pos,"")
	end,
	on_receive_fields = function(pos,formname,fields,sender)
		local meta = minetest.get_meta(pos)
		
		--check for private channels
		if fields.channel ~= nil then
			local name, mode = fields.channel:match("^([^:;]+)([:;])")
			if name and mode and name ~= sender:get_player_name() then
				
				--channels starting with '[name]:' can only be used by the named player
				if mode == ":" then
					minetest.chat_send_player(sender:get_player_name(), "Sorry, channel '"..fields.channel.."' is reserved for exclusive use by "..name)
					return
				
				--channels starting with '[name];' can be used by other players, but cannot be received from
				elseif mode == ";" and (meta:get_int("can_receive") ~= 0) == (fields["bt"] == nil) then
					minetest.chat_send_player(sender:get_player_name(), "Sorry, receiving from channel '"..fields.channel.."' is reserved for "..name)
					return
				end
			end
		end
		
		if fields.channel==nil then fields.channel=meta:get_string("channel") end
		meta:set_string("channel",fields.channel)
		remove_tube_in_file(pos)
		local cr = meta:get_int("can_receive")
		if fields["bt"] then
			cr=1-cr
			meta:set_int("can_receive",cr)
			if cr==1 then
				meta:set_string("formspec","size[9,1;]"..
					"field[0,0.5;7,1;channel;Channel:;${channel}]"..
					"button[8,0;1,1;bt;On]")
			else
				meta:set_string("formspec","size[9,1;]"..
					"field[0,0.5;7,1;channel;Channel:;${channel}]"..
					"button[8,0;1,1;bt;Off]")
			end
		end
		add_tube_in_file(pos,fields.channel, cr)
	end,
	on_destruct = function(pos)
		remove_tube_in_file(pos)
	end})

if minetest.get_modpath("mesecons_mvps") ~= nil then
	mesecon:register_on_mvps_move(function(moved_nodes)
		for _, n in ipairs(moved_nodes) do
			if string.find(n.node.name, "pipeworks:teleport_tube") ~= nil then
				update_pos_in_file(n.pos)
			end
		end
	end)
end

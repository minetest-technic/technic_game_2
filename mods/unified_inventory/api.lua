
-- Create detached creative inventory after loading all mods
minetest.after(0.01, function()
	local rev_aliases = {}
	for source, target in pairs(minetest.registered_aliases) do
		if not rev_aliases[target] then rev_aliases[target] = {} end
		table.insert(rev_aliases[target], source)
	end
	unified_inventory.items_list = {}
	for name, def in pairs(minetest.registered_items) do
		if (not def.groups.not_in_creative_inventory or
		   def.groups.not_in_creative_inventory == 0) and
		   def.description and def.description ~= "" then
			table.insert(unified_inventory.items_list, name)
			local all_names = rev_aliases[name] or {}
			table.insert(all_names, name)
			for _, name in ipairs(all_names) do
				local recipes = minetest.get_all_craft_recipes(name)
				if recipes then
					for _, recipe in ipairs(recipes) do
						unified_inventory.register_craft(recipe)
					end
				end
			end
		end
	end
	table.sort(unified_inventory.items_list)
	unified_inventory.items_list_size = #unified_inventory.items_list
	print("Unified Inventory. inventory size: "..unified_inventory.items_list_size)
	for _, name in ipairs(unified_inventory.items_list) do
		local def = minetest.registered_items[name]
		if type(def.drop) == "string" then
			local dstack = ItemStack(def.drop)
			if not dstack:is_empty() and dstack:get_name() ~= name then
				unified_inventory.register_craft({
					type = "digging",
					items = {name},
					output = def.drop,
					width = 0,
				})

			end
		end
	end
end)


-- load_home
local function load_home()
	local input = io.open(unified_inventory.home_filename, "r")
	if input then
		while true do
			local x = input:read("*n")
			if x == nil then
				break
			end
			local y = input:read("*n")
			local z = input:read("*n")
			local name = input:read("*l")
			unified_inventory.home_pos[name:sub(2)] = {x = x, y = y, z = z}
		end
		io.close(input)
	else
		unified_inventory.home_pos = {}
	end
end
load_home()

function unified_inventory.set_home(player, pos)
	local player_name = player:get_player_name()
	unified_inventory.home_pos[player_name] = pos
	-- save the home data from the table to the file
	local output = io.open(unified_inventory.home_filename, "w")
	for k, v in pairs(unified_inventory.home_pos) do
		if v ~= nil then
			output:write(math.floor(v.x).." "
					..math.floor(v.y).." "
					..math.floor(v.z).." "
					..k.."\n")
		end
	end
	io.close(output)
end

function unified_inventory.go_home(player)
	local pos = unified_inventory.home_pos[player:get_player_name()]
	if pos ~= nil then
		player:setpos(pos)
	end
end

-- register_craft
function unified_inventory.register_craft(options)
	if  options.output == nil then
		return
	end
	local itemstack = ItemStack(options.output)
	if itemstack:is_empty() then
		return
	end
	if options.type == "normal" and options.width == 0 then
		options = { type = "shapeless", items = options.items, output = options.output, width = 0 }
	end
	if unified_inventory.crafts_table[itemstack:get_name()] == nil then
		unified_inventory.crafts_table[itemstack:get_name()] = {}
	end
	table.insert(unified_inventory.crafts_table[itemstack:get_name()],options)
end


local craft_type_defaults = {
	width = 3,
	height = 3,
	uses_crafting_grid = false,
}


function unified_inventory.craft_type_defaults(name, options)
	if not options.description then
		options.description = name
	end
	setmetatable(options, {__index = craft_type_defaults})
	return options
end


function unified_inventory.register_craft_type(name, options)
	unified_inventory.registered_craft_types[name] =
			unified_inventory.craft_type_defaults(name, options)
end


unified_inventory.register_craft_type("normal", {
	description = "Crafting",
	width = 3,
	height = 3,
	uses_crafting_grid = true,
})


unified_inventory.register_craft_type("shapeless", {
	description = "Mixing",
	width = 3,
	height = 3,
	uses_crafting_grid = true,
})


unified_inventory.register_craft_type("cooking", {
	description = "Cooking",
	width = 1,
	height = 1,
})


unified_inventory.register_craft_type("digging", {
	description = "Digging",
	width = 1,
	height = 1,
})


function unified_inventory.register_page(name, def)
	unified_inventory.pages[name] = def
end


function unified_inventory.register_button(name, def)
	if not def.action then
		def.action = function(player)
			unified_inventory.set_inventory_formspec(player, name)
		end
	end
	def.name = name
	table.insert(unified_inventory.buttons, def)
end


function unified_inventory.is_creative(playername)
	if minetest.check_player_privs(playername, {creative=true}) or
	   minetest.setting_getbool("creative_mode") then
		return true
	end
end


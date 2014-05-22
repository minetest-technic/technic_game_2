
minetest.register_privilege("creative", {
	description = "Can use the creative inventory",
	give_to_singleplayer = false,
})

local trash = minetest.create_detached_inventory("trash", {
	--allow_put = function(inv, listname, index, stack, player)
	--	if unified_inventory.is_creative(player:get_player_name()) then
	--		return stack:get_count()
	--	else
	--		return 0
	--	end
	--end,
	on_put = function(inv, listname, index, stack, player)
		inv:set_stack(listname, index, nil)
		local player_name = player:get_player_name()
		minetest.sound_play("trash", {to_player=player_name, gain = 1.0})
	end,
})
trash:set_size("main", 1)

unified_inventory.register_button("craft", {
	type = "image",
	image = "ui_craft_icon.png",
})

unified_inventory.register_button("craftguide", {
	type = "image",
	image = "ui_craftguide_icon.png",
})

unified_inventory.register_button("home_gui_set", {
	type = "image",
	image = "ui_sethome_icon.png",
	action = function(player)
		local player_name = player:get_player_name()
		unified_inventory.set_home(player, player:getpos())
		local home = unified_inventory.home_pos[player_name]
		if home ~= nil then
			minetest.sound_play("dingdong",
					{to_player=player_name, gain = 1.0})
			minetest.chat_send_player(player_name,
					"Home position set to: "
					..minetest.pos_to_string(home))
		end
	end,
})

unified_inventory.register_button("home_gui_go", {
	type = "image",
	image = "ui_gohome_icon.png",
	action = function(player)
		minetest.sound_play("teleport",
				{to_player=player:get_player_name(), gain = 1.0})
		unified_inventory.go_home(player)
	end,
})

unified_inventory.register_button("misc_set_day", {
	type = "image",
	image = "ui_sun_icon.png",
	action = function(player)
		local player_name = player:get_player_name()
		if minetest.check_player_privs(player_name, {settime=true}) then
			minetest.sound_play("birds",
					{to_player=player_name, gain = 1.0})
			minetest.set_timeofday((6000 % 24000) / 24000)
			minetest.chat_send_player(player_name,
					"Time of day set to 6am")
		else
			minetest.chat_send_player(player_name,
					"You don't have the"
					.." settime priviledge!")
		end
	end,
})

unified_inventory.register_button("misc_set_night", {
	type = "image",
	image = "ui_moon_icon.png",
	action = function(player)
		local player_name = player:get_player_name()
		if minetest.check_player_privs(player_name, {settime=true}) then
			minetest.sound_play("owl",
					{to_player=player_name, gain = 1.0})
			minetest.set_timeofday((21000 % 24000) / 24000)
			minetest.chat_send_player(player_name,
					"Time of day set to 9pm")
		else
			minetest.chat_send_player(player_name,
					"You don't have the"
					.." settime priviledge!")
		end
	end,
})

unified_inventory.register_button("clear_inv", {
	type = "image",
	image = "ui_trash_icon.png",
	action = function(player)
		local player_name = player:get_player_name()
		if not unified_inventory.is_creative(player_name) then
			minetest.chat_send_player(player_name,
					"This button has been disabled outside"
					.." of creative mode to prevent"
					.." accidental inventory trashing."
					.." Use the trash slot instead.")
			return
		end
		player:get_inventory():set_list("main", {})
		minetest.chat_send_player(player_name, 'Inventory Cleared!')
		minetest.sound_play("trash_all",
				{to_player=player_name, gain = 1.0})
	end,
})

unified_inventory.register_page("craft", {
	get_formspec = function(player, formspec)
		local player_name = player:get_player_name()
		local formspec = "background[0,1;8,3;ui_crafting_form.png]"
		formspec = formspec.."background[0,4.5;8,4;ui_main_inventory.png]"
		formspec = formspec.."label[0,0;Crafting]"
		formspec = formspec.."listcolors[#00000000;#00000000]"
		formspec = formspec.."list[current_player;craftpreview;6,1;1,1;]"
		formspec = formspec.."list[current_player;craft;2,1;3,3;]"
		formspec = formspec.."label[7,2.5;Trash:]"
		formspec = formspec.."list[detached:trash;main;7,3;1,1;]"
		if unified_inventory.is_creative(player_name) then
			formspec = formspec.."label[0,2.5;Refill:]"
			formspec = formspec.."list[detached:"..minetest.formspec_escape(player_name).."refill;main;0,3;1,1;]"
		end
		return {formspec=formspec}
	end,
})


-- stack_image_button(): generate a form button displaying a stack of items
--
-- Normally a simple item_image_button[] is used.  If the stack contains
-- more than one item, item_image_button[] doesn't have an option to
-- display an item count in the way that an inventory slot does, so
-- we have to fake it using the label facility.
--
-- The specified item may be a group.  In that case, the group will be
-- represented by some item in the group, along with a flag indicating
-- that it's a group.  If the group contains only one item, it will be
-- treated as if that item had been specified directly.

local function stack_image_button(x, y, w, h, buttonname_prefix, item)
	local name = item:get_name()
	local count = item:get_count()
	local show_is_group = false
	local displayitem = name
	local selectitem = name
	if name:sub(1, 6) == "group:" then
		local group_name = name:sub(7)
		local group_item = unified_inventory.get_group_item(group_name)
		show_group = not group_item.sole
		displayitem = group_item.item or "unknown"
		selectitem = group_item.sole and displayitem or name
	end
	-- Hackily shift the count to the bottom right
	local shiftstr = "\n\n        "
	return string.format("item_image_button[%u,%u;%u,%u;%s;%s;%s]",
			x, y, w, h,
			minetest.formspec_escape(displayitem),
			minetest.formspec_escape(buttonname_prefix..selectitem),
			count ~= 1 and shiftstr..tostring(count) or "")
end

unified_inventory.register_page("craftguide", {
	get_formspec = function(player)
		local player_name = player:get_player_name()
		local formspec = ""
		formspec = formspec.."background[0,4.5;8,4;ui_main_inventory.png]"
		formspec = formspec.."background[0,1;8,3;ui_craftguide_form.png]"
		formspec = formspec.."label[0,0;Crafting Guide]"
		formspec = formspec.."listcolors[#00000000;#00000000]"
		local craftinv = minetest.get_inventory({
			type = "detached",
			name = player_name.."craftrecipe"
		})
		local item_name = unified_inventory.current_item[player_name] or ""

		formspec = formspec.."textarea[0.3,0.6;10,1;;Result: "..minetest.formspec_escape(item_name)..";]"
		formspec = formspec.."list[detached:"..minetest.formspec_escape(player_name).."craftrecipe;output;6,1;1,1;]"

		local alternate, alternates, craft, craft_type
		alternate = unified_inventory.alternate[player_name]
		local crafts = unified_inventory.crafts_table[item_name]
		if crafts ~= nil and #crafts > 0 then
			alternates = #crafts
			craft = crafts[alternate]
		end

		if craft then
			craftinv:set_stack("output", 1, craft.output)
			craft_type = unified_inventory.registered_craft_types[craft.type] or
					unified_inventory.craft_type_defaults(craft.type, {})
			formspec = formspec.."label[6,3.35;Method:]"
			formspec = formspec.."label[6,3.75;"
					..minetest.formspec_escape(craft_type.description).."]"
		else
			craftinv:set_stack("output", 1, item_name)
			craft_type = unified_inventory.craft_type_defaults("", {})
			formspec = formspec.."label[6,3.35;No recipes]"
		end

		local width = craft and craft.width or 0
		if width == 0 then
			-- Shapeless recipe
			width = craft_type.width
		end

		local height = craft_type.height
		if craft then
			height = math.ceil(table.maxn(craft.items) / width)
		end

		local i = 1
		-- This keeps recipes aligned to the right,
		-- so that they're close to the arrow.
		local xoffset = 1 + (3 - width)
		for y = 1, height do
		for x = 1, width do
			local item = craft and craft.items[i]
			if item then
				formspec = formspec..stack_image_button(
						xoffset + x, y, 1.1, 1.1,
						"item_button_", ItemStack(item))
			else
				-- Fake buttons just to make grid
				formspec = formspec.."image_button["
					..tostring(xoffset + x)..","..tostring(y)
					..";1,1;ui_blank_image.png;;]"
			end
			i = i + 1
		end
		end

		if craft_type.uses_crafting_grid then
			formspec = formspec.."label[6,1.95;Copy to craft grid:]"
					.."button[6,2.5;0.6,0.5;craftguide_craft_1;1]"
					.."button[6.6,2.5;0.6,0.5;craftguide_craft_10;10]"
					.."button[7.2,2.5;0.6,0.5;craftguide_craft_max;All]"
		end

		if alternates and alternates > 1 then
			formspec = formspec.."label[0,2.6;Recipe "
					..tostring(alternate).." of "
					..tostring(alternates).."]"
					.."button[0,3.15;2,1;alternate;Alternate]"
		end
		return {formspec = formspec}
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local amount
	for k, v in pairs(fields) do
		amount = k:match("craftguide_craft_(.*)")
		if amount then break end
	end
	if not amount then return end
	local player_name = player:get_player_name()
	local recipe_inv = minetest.get_inventory({
		type="detached",
		name=player_name.."craftrecipe",
	})

	local output = unified_inventory.current_item[player_name]
	if (not output) or (output == "") then return end

	local player_inv = player:get_inventory()

	local crafts = unified_inventory.crafts_table[output]
	if (not crafts) or (#crafts == 0) then return end

	local alternate = unified_inventory.alternate[player_name]

	local craft = crafts[alternate]
	if craft.width > 3 then return end

	local needed = craft.items

	local craft_list = player_inv:get_list("craft")

	local width = craft.width
	if width == 0 then
		-- Shapeless recipe
		width = 3
	end

	if amount == "max" then
		amount = 99 -- Arbitrary; need better way to do this.
	else
		amount = tonumber(amount)
	end

	for iter = 1, amount do
		local index = 1
		for y = 1, 3 do
			for x = 1, width do
				local needed_item = needed[index]
				if needed_item then
					local craft_index = ((y - 1) * 3) + x
					local craft_item = craft_list[craft_index]
					if (not craft_item) or (craft_item:is_empty()) or (craft_item:get_name() == needed_item) then
						itemname = craft_item and craft_item:get_name() or needed_item
						local needed_stack = ItemStack(needed_item)
						if player_inv:contains_item("main", needed_stack) then
							local count = (craft_item and craft_item:get_count() or 0) + 1
							if count <= needed_stack:get_definition().stack_max then
								local stack = ItemStack({name=needed_item, count=count})
								craft_list[craft_index] = stack
								player_inv:remove_item("main", needed_stack)
							end
						end
					end
				end
				index = index + 1
			end
		end
	end

	player_inv:set_list("craft", craft_list)

	unified_inventory.set_inventory_formspec(player, "craft")
end)

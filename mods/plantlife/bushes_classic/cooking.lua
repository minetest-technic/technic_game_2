-- Boilerplate to support localized strings if intllib mod is installed.
local S
if (minetest.get_modpath("intllib")) then
  dofile(minetest.get_modpath("intllib").."/intllib.lua")
  S = intllib.Getter(minetest.get_current_modname())
else
  S = function ( s ) return s end
end


-- Basket

minetest.register_craft({
    output = "bushes:basket_empty",
    recipe = {
	{ "default:stick", "default:stick", "default:stick" },
	{ "", "default:stick", "" },
    },
})

-- Sugar

minetest.register_craftitem(":bushes:sugar", {
    description = S("Sugar"),
    inventory_image = "bushes_sugar.png",
    on_use = minetest.item_eat(1),
	groups = {food_sugar=1}
})

minetest.register_craft({
    output = "bushes:sugar 1",
    recipe = {
	{ "default:papyrus", "default:papyrus" },
    },
})

for i, berry in ipairs(bushes_classic.bushes) do
	local desc = bushes_classic.bushes_descriptions[i]

	minetest.register_craftitem(":bushes:"..berry.."_pie_raw", {
		description = S("Raw "..desc.." pie"),
		inventory_image = "bushes_"..berry.."_pie_raw.png",
		on_use = minetest.item_eat(4),
	})

	if berry ~= "mixed_berry" then
		minetest.register_craftitem(":bushes:"..berry, {
			description = S(desc),
			inventory_image = "bushes_"..berry..".png",
			groups = {berry = 1, [berry] = 1},
			on_use = minetest.item_eat(1),
		})

		if minetest.registered_nodes["farming:soil"] then
			minetest.register_craft({
				output = "bushes:"..berry.."_pie_raw 1",
				recipe = {
				{ "group:food_sugar", "farming:flour", "group:food_sugar" },
				{ "group:"..berry, "group:"..berry, "group:"..berry },
				},
			})
		else
			minetest.register_craft({
				output = "bushes:"..berry.."_pie_raw 1",
				recipe = {
				{ "group:food_sugar", "group:junglegrass", "group:food_sugar" },
				{ "group:"..berry, "group:"..berry, "group:"..berry },
				},
			})
		end
	end

	-- Cooked pie

	minetest.register_craftitem(":bushes:"..berry.."_pie_cooked", {
		description = S("Cooked "..desc.." pie"),
		inventory_image = "bushes_"..berry.."_pie_cooked.png",
		on_use = minetest.item_eat(6),
	})

	minetest.register_craft({
		type = "cooking",
		output = "bushes:"..berry.."_pie_cooked",
		recipe = "bushes:"..berry.."_pie_raw",
		cooktime = 30,
	})

	-- slice of pie

	minetest.register_craftitem(":bushes:"..berry.."_pie_slice", {
		description = S("Slice of "..desc.." pie"),
		inventory_image = "bushes_"..berry.."_pie_slice.png",
		on_use = minetest.item_eat(1),
	})

	minetest.register_craft({
		output = "bushes:"..berry.."_pie_slice 6",
		recipe = {
		{ "bushes:"..berry.."_pie_cooked" },
		},
	})

	-- Basket with pies

	minetest.register_craft({
		output = "bushes:basket_"..berry.." 1",
		recipe = {
		{ "bushes:"..berry.."_pie_cooked", "bushes:"..berry.."_pie_cooked", "bushes:"..berry.."_pie_cooked" },
		{ "", "bushes:basket_empty", "" },
		},
	})
end

if minetest.registered_nodes["farming_plus:strawberry"] then
	minetest.register_craftitem(":farming_plus:strawberry_item", {
		description = S("Strawberry"),
		inventory_image = "farming_strawberry.png",
		on_use = minetest.item_eat(2),
		groups = {berry=1, strawberry=1}
	})
end

if minetest.registered_nodes["farming:soil"] then
	minetest.register_craft({
		output = "bushes:mixed_berry_pie_raw 2",
		recipe = {
		{ "group:food_sugar", "farming:flour", "group:food_sugar" },
		{ "group:berry", "group:berry", "group:berry" },
		{ "group:berry", "group:berry", "group:berry" },
		},
	})
else
	minetest.register_craft({
		output = "bushes:mixed_berry_pie_raw 2",
		recipe = {
		{ "group:food_sugar", "group:junglegrass", "group:food_sugar" },
		{ "group:berry", "group:berry", "group:berry" },
		{ "group:berry", "group:berry", "group:berry" },
		},
	})
end


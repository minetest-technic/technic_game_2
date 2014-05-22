-- tubes crafting recipes

minetest.register_craft({
	output = 'pipeworks:tube_1 9',
	recipe = {
		{'technic:stainless_steel_ingot', 'default:glass', 'technic:stainless_steel_ingot'},
		{'technic:stainless_steel_ingot', 'default:glass', 'technic:stainless_steel_ingot'},
		{'technic:stainless_steel_ingot', 'default:glass', 'technic:stainless_steel_ingot'},
	}
})
minetest.register_craft({
	output = 'pipeworks:mese_tube_000000',
	recipe = {
		{'default:mese_crystal_fragment', 'pipeworks:tube_1', 'default:mese_crystal_fragment'},
		}
})

minetest.register_craft({
    output = 'pipeworks:accelerator_tube_1',
    recipe = {
        {'technic:copper_coil', 'pipeworks:tube_1', 'technic:copper_coil'},
        }
})

minetest.register_craft({
    output = 'pipeworks:detector_tube_off_1',
    recipe = {
        {'mesecons:mesecon', 'pipeworks:tube_1', 'mesecons:mesecon'},
        }
})

minetest.register_craft({
    output = 'pipeworks:sand_tube_1',
    recipe = {
        {'default:sand', 'pipeworks:tube_1', 'default:sand'},
        }
})

minetest.register_craft({
    output = 'pipeworks:mese_sand_tube_1',
    recipe = {
        {'default:mese_crystal_fragment', 'pipeworks:sand_tube_1', 'default:mese_crystal_fragment'},
        }
})

minetest.register_craft({
    output = 'pipeworks:teleport_tube_1',
    recipe = {
        {'default:mese_crystal', 'technic:copper_coil', 'default:mese_crystal'},
        {'pipeworks:tube_1', 'technic:control_logic_unit', 'pipeworks:tube_1'},
        {'default:mese_crystal', 'technic:copper_coil', 'default:mese_crystal'},
        }
})

minetest.register_craft({
	output = 'technic:diamond_drill_head',
	recipe = {
		{'technic:stainless_steel_ingot', 'default:diamond', 'technic:stainless_steel_ingot'},
		{'default:diamond',               '',                'default:diamond'},
		{'technic:stainless_steel_ingot', 'default:diamond', 'technic:stainless_steel_ingot'},
	}
})

minetest.register_craft({
	output = 'technic:green_energy_crystal',
	recipe = {
		{'default:gold_ingot', 'technic:battery', 'dye:green'},
		{'technic:battery', 'technic:red_energy_crystal', 'technic:battery'},
		{'dye:green', 'technic:battery', 'default:gold_ingot'},
	}
})

minetest.register_craft({
	output = 'technic:blue_energy_crystal',
	recipe = {
		{'default:gold_ingot', 'technic:battery', 'dye:blue'},
		{'technic:battery', 'technic:green_energy_crystal', 'technic:battery'},
		{'dye:blue', 'technic:battery', 'default:gold_ingot'},
	}
})

minetest.register_craft({
	output = 'technic:red_energy_crystal',
	recipe = {
		{'default:gold_ingot', 'technic:battery', 'dye:red'},
		{'technic:battery', 'default:diamondblock', 'technic:battery'},
		{'dye:red', 'technic:battery', 'default:gold_ingot'},
	}
})

minetest.register_craft({
	output = 'technic:fine_copper_wire 2',
	recipe = {
		{'', 'default:copper_ingot', ''},
		{'', 'default:copper_ingot', ''},
		{'', 'default:copper_ingot', ''},
	}
})

minetest.register_craft({
	output = 'technic:copper_coil 1',
	recipe = {
		{'technic:fine_copper_wire', 'technic:wrought_iron_ingot', 'technic:fine_copper_wire'},
		{'technic:wrought_iron_ingot', '', 'technic:wrought_iron_ingot'},
		{'technic:fine_copper_wire', 'technic:wrought_iron_ingot', 'technic:fine_copper_wire'},
	}
})

minetest.register_craft({
	output = 'technic:motor',
	recipe = {
		{'technic:carbon_steel_ingot', 'technic:copper_coil', 'technic:carbon_steel_ingot'},
		{'technic:carbon_steel_ingot', 'technic:copper_coil', 'technic:carbon_steel_ingot'},
		{'technic:carbon_steel_ingot', 'default:copper_ingot', 'technic:carbon_steel_ingot'},
	}
})

minetest.register_craft({
	output = 'technic:lv_transformer',
	recipe = {
		{'technic:wrought_iron_ingot', 'technic:wrought_iron_ingot', 'technic:wrought_iron_ingot'},
		{'technic:copper_coil',        'technic:wrought_iron_ingot', 'technic:copper_coil'},
		{'technic:wrought_iron_ingot', 'technic:wrought_iron_ingot', 'technic:wrought_iron_ingot'},
	}
})

minetest.register_craft({
	output = 'technic:mv_transformer',
	recipe = {
		{'technic:carbon_steel_ingot', 'technic:carbon_steel_ingot', 'technic:carbon_steel_ingot'},
		{'technic:copper_coil',        'technic:carbon_steel_ingot', 'technic:copper_coil'},
		{'technic:carbon_steel_ingot', 'technic:carbon_steel_ingot', 'technic:carbon_steel_ingot'},
	}
})

minetest.register_craft({
	output = 'technic:hv_transformer',
	recipe = {
		{'technic:stainless_steel_ingot', 'technic:stainless_steel_ingot', 'technic:stainless_steel_ingot'},
		{'technic:copper_coil',           'technic:stainless_steel_ingot', 'technic:copper_coil'},
		{'technic:stainless_steel_ingot', 'technic:stainless_steel_ingot', 'technic:stainless_steel_ingot'},
	}
})

minetest.register_craft({
	output = 'technic:control_logic_unit',
	recipe = {
		{'', 'default:gold_ingot', ''},
		{'default:copper_ingot', 'technic:silicon_wafer', 'default:copper_ingot'},
		{'', 'default:copper_ingot', ''},
	}
})

minetest.register_craft({
	output = 'technic:mixed_metal_ingot 9',
	recipe = {
		{'technic:stainless_steel_ingot', 'technic:stainless_steel_ingot', 'technic:stainless_steel_ingot'},
		{'default:bronze_ingot',          'default:bronze_ingot',          'default:bronze_ingot'},
		{'moreores:tin_ingot',            'moreores:tin_ingot',            'moreores:tin_ingot'},
	}
})

minetest.register_craft({
	output = 'technic:carbon_cloth',
	recipe = {
		{'technic:graphite', 'technic:graphite', 'technic:graphite'}
	}
})

minetest.register_craftitem("technic:nothing", {
	description = "",
	inventory_image = "blank.png",
})

minetest.register_craft({
	type = "shapeless",
	output = "technic:nothing",
	recipe = {"default:copper_ingot", "default:steel_ingot"}
})

if minetest.register_craft_predict then
	minetest.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv)
		if itemstack:get_name() == "technic:nothing" then
			return ItemStack("")
		end
	end)
end


--[[
= Cow for Creatures MOB-Engine (cme) =
Copyright (C) 2019 Mob API Developers and Contributors

bed.lua

This software is provided 'as-is', without any express or implied warranty. In no
event will the authors be held liable for any damages arising from the use of
this software.

Permission is granted to anyone to use this software for any purpose, including
commercial applications, and to alter it and redistribute it freely, subject to the
following restrictions:

1. The origin of this software must not be misrepresented; you must not
claim that you wrote the original software. If you use this software in a
product, an acknowledgment in the product documentation is required.
2. Altered source versions must be plainly marked as such, and must not
be misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
]]

-- Bed node
minetest.register_node("cow:bed", {
	description = "Cow Bed",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.46875, -0.5, -0.46875, 0.46875, -0.4375, 0.46875}, 
			{-0.4375, -0.5, -0.4375, 0.4375, -0.375, 0.4375}, 
		}
	},
	tiles = {"cow_bed.png"},
	sunlight_propagates = true,
	buildable_to = true,
	walkable = false,
	groups = {snappy = 3, attached_node = 1, flammable = 1},
	sounds = default.node_sound_leaves_defaults(),
})
core.register_craft({
	output = 'cow:bed',
	replacements = {{"cow:cowboy_bell", "cow:cowboy_bell"}},
	recipe = {
		{'farming:straw', '', 'farming:straw'},
		{'', 'cow:cowboy_bell', ''},
		{'farming:straw', '', 'farming:straw'},
	}
})

-- Sheep Bed
creatures.register_mob_node("cow:bed", {
	mob_name = "cow:cow",
	
	-- Search MOB
	search_mob = true,
	
	-- On load MOB
	on_load_mob = function(pos, new_ent)
		new_ent.randomized_value = minetest.deserialize(meta:get_string("randomized_values"))
	end,
	
	-- On set mob node
	on_set_mob_node = function(pos, ent)
		local meta = minetest.get_meta(pos)
		meta:set_string("randomized_values", minetest.serialize(ent.randomized_value))
	end,
	
	-- On reset mob node
	on_reset_mob_node = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("randomized_values", "")
	end,
})

--[[
= Chicken for Creatures MOB-Engine (cme) =
Copyright (C) 2019 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

nest.lua

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

-- Nest node
minetest.register_node("chicken:nest", {
	description = "Nest",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = { -- Created with NodeBoxEditor
			{0.125, -0.5, -0.25, 0.3125, -0.3125, 0.25}, 
			{-0.3125, -0.5, -0.25, -0.125, -0.3125, 0.25}, 
			{-0.25, -0.5, 0.125, 0.25, -0.3125, 0.3125}, 
			{-0.25, -0.5, -0.3125, 0.25, -0.3125, -0.125}, 
			{-0.1875, -0.3125, -0.25, 0.1875, -0.25, -0.1875}, 
			{-0.1875, -0.3125, 0.1875, 0.1875, -0.25, 0.25}, 
			{0.1875, -0.3125, -0.1875, 0.25, -0.25, 0.1875}, 
			{-0.25, -0.3125, -0.1875, -0.1875, -0.25, 0.1875}, 
			{0.0625, -0.5, -0.3125, 0.3125, -0.4375, 0.3125}, 
			{-0.3125, -0.5, -0.3125, -0.0625, -0.4375, 0.3125}, 
			{-0.3125, -0.5, 0.0625, 0.3125, -0.4375, 0.3125}, 
			{-0.3125, -0.5, -0.3125, 0.3125, -0.4375, -0.0625}, 
			{0.25, -0.4375, -0.3125, 0.375, -0.375, 0.3125}, 
			{-0.375, -0.4375, -0.3125, -0.25, -0.375, 0.3125}, 
			{-0.3125, -0.4375, 0.25, 0.3125, -0.375, 0.375}, 
			{-0.3125, -0.4375, -0.375, 0.3125, -0.375, -0.25}, 
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-6 / 16, -8 / 16, -6 / 16, 6 / 16, -5 /16, 6 / 16},
	},
	tiles = {"farming_straw.png^[transformR90"},
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {snappy = 3, attached_node = 1, flammable = 1},
	sounds = default.node_sound_leaves_defaults(),
})
core.register_craft({
	output = 'chicken:nest',
	recipe = {
		{'', 'farming:wheat', ''},
		{'farming:wheat', 'farming:seed_wheat', 'farming:wheat'},
		{'', 'farming:wheat', ''},
	}
})
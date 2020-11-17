--[[
= Cow for Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors

bell.lua

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

--[[
	2020-05-20

	As per License's rule number 2:
	- Modified by h4ml3t to add localization (translation) file support.
--]]

-- Used for localization

local S = minetest.get_translator("cow")

-- Cowboy Bell
minetest.register_node("cow:cowboy_bell", {
	description = S("Cowboy Bell"),
	inventory_image = "cow_cowboy_bell.png",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.25, 0.25, -0.375, 0.25},
			{-0.1875, -0.375, -0.1875, 0.1875, -0.125, 0.1875},
			{-0.125, -0.125, -0.125, 0.125, -0.0625, 0.125},
			{-0.0625, -0.0625, -0.0625, 0.0625, 0, 0.0625},
		}
	},
	tiles = {
		"cow_cowboy_bell_top.png", -- Top
		"cow_cowboy_bell_bottom.png", -- Bottom
		"cow_cowboy_bell_side1.png", -- Right
		"cow_cowboy_bell_side1.png", -- Left
		"cow_cowboy_bell_side2.png^[transformFX", -- Back
		"cow_cowboy_bell_side2.png" -- Front
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0, 0.25},
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0, 0.25},
	},
	sunlight_propagates = true,
	buildable_to = true,
	groups = {snappy = 3, attached_node = 1, flammable = 1},
	sounds = default.node_sound_wood_defaults(),
})
minetest.register_craft({
	output = 'cow:cowboy_bell',
	recipe = {
		{'', 'wool:blue', 'wool:blue'},
		{'default:steel_ingot', 'default:steel_ingot', 'wool:blue'},
		{'group:stick', 'default:steel_ingot', ''},
	}
})

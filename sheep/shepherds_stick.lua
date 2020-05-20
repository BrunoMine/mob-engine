--[[
= Sheep for Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors

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

--[[
	2020-05-20

	As per License's rule number 2:
	- Modified by h4ml3t to add localization (translation) file support.
--]]

-- Used for localization

local S = minetest.get_translator("sheep")

-- Shepherd's Wooden Stick
minetest.register_node("sheep:shepherd_wooden_stick", {
	description = S("Shepherd's Wooden Stick"),
	inventory_image = "sheep_shepherd_wooden_stick.png",
	wield_image = "sheep_shepherd_wooden_stick.png",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, -0.0625, 0.0625, 0.0625, 0.0625},
			{0.125, 0.125, -0.0625, 0.25, 0.375, 0.0625},
			{0.0625, 0.0625, -0.0625, 0.1875, 0.1875, 0.0625},
			{0, 0, -0.0625, 0.125, 0.125, 0.0625},
			{0.0625, 0.3125, -0.0625, 0.1875, 0.4375, 0.0625},
			{-0.0625, 0.375, -0.0625, 0.125, 0.5, 0.0625},
			{-0.125, 0.3125, -0.0625, 0, 0.4375, 0.0625},
		}
	},
	tiles = {
		"sheep_shepherd_wooden_stick_top.png", -- Top
		"sheep_shepherd_wooden_stick_bottom.png", -- Bottom
		"sheep_shepherd_wooden_stick_right.png", -- Right
		"sheep_shepherd_wooden_stick_left.png", -- Left
		"sheep_shepherd_wooden_stick_front.png^[transformFX", -- Back
		"sheep_shepherd_wooden_stick_front.png" -- Front
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.1875, -0.5, -0.125, 0.25, 0.5, 0.125},
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.1875, -0.5, -0.125, 0.25, 0.75, 0.125},
	},
	sunlight_propagates = true,
	buildable_to = true,
	groups = {snappy = 3, attached_node = 1, flammable = 1},
	sounds = default.node_sound_wood_defaults(),
})
minetest.register_craft({
	output = 'sheep:shepherd_wooden_stick',
	recipe = {
		{'', 'farming:wheat', 'group:stick'},
		{'', 'group:stick', 'farming:string'},
		{'group:stick', 'farming:string', 'farming:string'},
	}
})

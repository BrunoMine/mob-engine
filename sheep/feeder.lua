--[[
= Sheep for Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors

feeder.lua

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

-- Textures
local tiles_feeder = {
	"(default_acacia_wood.png^(farming_straw.png^sheep_feeder_layer_top.png^[makealpha:76,255,0))", -- Top
	"default_acacia_wood.png", -- Bottom
	"(default_acacia_wood.png^(farming_straw.png^sheep_feeder_layer_side.png^[makealpha:76,255,0))", -- Right
	"(default_acacia_wood.png^(farming_straw.png^sheep_feeder_layer_side.png^[makealpha:76,255,0))", -- Left
	"(default_acacia_wood.png^(farming_straw.png^sheep_feeder_layer_side.png^[makealpha:76,255,0))", -- Back
	"(default_acacia_wood.png^(farming_straw.png^sheep_feeder_layer_side.png^[makealpha:76,255,0))" -- Front
}

-- Feeder definitions
local feeder_node_def = {
	description = S("Hay Feeder"),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = { -- Created with NodeBoxEditor
			{-0.5000, -0.3750,  0.4375,  0.5000, -0.0625,  0.5000},
			{-0.5000, -0.3750, -0.3750,  0.5000, -0.0625, -0.3125},
			{ 0.4375, -0.3750, -0.3750,  0.5000, -0.0625,  0.5000},
			{-0.5000, -0.3750, -0.3750, -0.4375, -0.0625,  0.5000},
			{-0.5000, -0.3750, -0.3750,  0.5000, -0.3125,  0.5000},
			{ 0.4375, -0.5000, -0.3750,  0.5000, -0.3750, -0.3125},
			{ 0.4375, -0.5000,  0.4375,  0.5000, -0.3750,  0.5000},
			{-0.5000, -0.5000,  0.4375, -0.4375, -0.3750,  0.5000},
			{-0.5000, -0.5000, -0.3750, -0.4375, -0.3750, -0.3125}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5000, -0.5000, -0.3750,  0.5000, -0.0625,  0.5000},
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.5000, -0.5000, -0.3750,  0.5000,  1.0000,  0.5000},
	},
	tiles = {
		"default_acacia_wood.png", -- Top
		"default_acacia_wood.png", -- Bottom
		"default_acacia_wood.png", -- Right
		"default_acacia_wood.png", -- Left
		"default_acacia_wood.png", -- Back
		"default_acacia_wood.png" -- Front
	},
	sunlight_propagates = true,
	buildable_to = true,
	groups = {snappy = 3, attached_node = 1, flammable = 1},
	sounds = default.node_sound_wood_defaults(),
}

local node_steps_def = {

	{ node_box = { type = "fixed", fixed = { -- 1
		{-0.5000, -0.3750,  0.4375,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.0625, -0.3125},
		{ 0.4375, -0.3750, -0.3750,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750, -0.4375, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.3125,  0.5000},
		{ 0.4375, -0.5000, -0.3750,  0.5000, -0.3750, -0.3125},
		{ 0.4375, -0.5000,  0.4375,  0.5000, -0.3750,  0.5000},
		{-0.5000, -0.5000,  0.4375, -0.4375, -0.3750,  0.5000},
		{-0.5000, -0.5000, -0.3750, -0.4375, -0.3750, -0.3125},
		{-0.4375, -0.3125, -0.3125,  0.4375, -0.2500,  0.4375}}},
	selection_box = { type = "fixed", fixed = {-0.5000, -0.5000, -0.3750,  0.5000, -0.0625,  0.5000}},
	tiles = tiles_feeder, },

	{ node_box = { type = "fixed", fixed = { -- 2
		{-0.5000, -0.3750,  0.4375,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.0625, -0.3125},
		{ 0.4375, -0.3750, -0.3750,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750, -0.4375, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.3125,  0.5000},
		{ 0.4375, -0.5000, -0.3750,  0.5000, -0.3750, -0.3125},
		{ 0.4375, -0.5000,  0.4375,  0.5000, -0.3750,  0.5000},
		{-0.5000, -0.5000,  0.4375, -0.4375, -0.3750,  0.5000},
		{-0.5000, -0.5000, -0.3750, -0.4375, -0.3750, -0.3125},
		{-0.4375, -0.3125, -0.3125,  0.4375, -0.1875,  0.4375}}},
	selection_box = { type = "fixed", fixed = {-0.5000, -0.5000, -0.3750,  0.5000, -0.0625,  0.5000}},
	tiles = tiles_feeder, },

	{ node_box = { type = "fixed", fixed = { -- 3
		{-0.5000, -0.3750,  0.4375,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.0625, -0.3125},
		{ 0.4375, -0.3750, -0.3750,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750, -0.4375, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.3125,  0.5000},
		{ 0.4375, -0.5000, -0.3750,  0.5000, -0.3750, -0.3125},
		{ 0.4375, -0.5000,  0.4375,  0.5000, -0.3750,  0.5000},
		{-0.5000, -0.5000,  0.4375, -0.4375, -0.3750,  0.5000},
		{-0.5000, -0.5000, -0.3750, -0.4375, -0.3750, -0.3125},
		{-0.4375, -0.3125, -0.3125,  0.4375, -0.1250,  0.4375}}},
	selection_box = { type = "fixed", fixed = {-0.5000, -0.5000, -0.3750,  0.5000, -0.0625,  0.5000}},
	tiles = tiles_feeder, },

	{ node_box = { type = "fixed", fixed = { -- 4
		{-0.5000, -0.3750,  0.4375,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.0625, -0.3125},
		{ 0.4375, -0.3750, -0.3750,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750, -0.4375, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.3125,  0.5000},
		{ 0.4375, -0.5000, -0.3750,  0.5000, -0.3750, -0.3125},
		{ 0.4375, -0.5000,  0.4375,  0.5000, -0.3750,  0.5000},
		{-0.5000, -0.5000,  0.4375, -0.4375, -0.3750,  0.5000},
		{-0.5000, -0.5000, -0.3750, -0.4375, -0.3750, -0.3125},
		{-0.4375, -0.3125, -0.3125,  0.4375, -0.0625,  0.4375}}},
	selection_box = { type = "fixed", fixed = {-0.5000, -0.5000, -0.3750,  0.5000, -0.0625,  0.5000}},
	tiles = tiles_feeder, },

	{ node_box = { type = "fixed", fixed = { -- 5
		{-0.5000, -0.3750,  0.4375,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.0625, -0.3125},
		{ 0.4375, -0.3750, -0.3750,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750, -0.4375, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.3125,  0.5000},
		{ 0.4375, -0.5000, -0.3750,  0.5000, -0.3750, -0.3125},
		{ 0.4375, -0.5000,  0.4375,  0.5000, -0.3750,  0.5000},
		{-0.5000, -0.5000,  0.4375, -0.4375, -0.3750,  0.5000},
		{-0.5000, -0.5000, -0.3750, -0.4375, -0.3750, -0.3125},
		{-0.4375, -0.3125, -0.3125,  0.4375,  0.0000,  0.4375}}},
	selection_box = { type = "fixed", fixed = {-0.5000, -0.5000, -0.3750,  0.5000,  0.0000,  0.5000}},
	tiles = tiles_feeder, },

	{ node_box = { type = "fixed", fixed = { -- 6
		{-0.5000, -0.3750,  0.4375,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.0625, -0.3125},
		{ 0.4375, -0.3750, -0.3750,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750, -0.4375, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.3125,  0.5000},
		{ 0.4375, -0.5000, -0.3750,  0.5000, -0.3750, -0.3125},
		{ 0.4375, -0.5000,  0.4375,  0.5000, -0.3750,  0.5000},
		{-0.5000, -0.5000,  0.4375, -0.4375, -0.3750,  0.5000},
		{-0.5000, -0.5000, -0.3750, -0.4375, -0.3750, -0.3125},
		{-0.4375, -0.3125, -0.3125,  0.4375,  0.0625,  0.4375}}},
	selection_box = { type = "fixed", fixed = {-0.5000, -0.5000, -0.3750,  0.5000,  0.0625,  0.5000}},
	tiles = tiles_feeder, },

	{ node_box = { type = "fixed", fixed = { -- 7
		{-0.5000, -0.3750,  0.4375,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.0625, -0.3125},
		{ 0.4375, -0.3750, -0.3750,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750, -0.4375, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.3125,  0.5000},
		{ 0.4375, -0.5000, -0.3750,  0.5000, -0.3750, -0.3125},
		{ 0.4375, -0.5000,  0.4375,  0.5000, -0.3750,  0.5000},
		{-0.5000, -0.5000,  0.4375, -0.4375, -0.3750,  0.5000},
		{-0.5000, -0.5000, -0.3750, -0.4375, -0.3750, -0.3125},
		{-0.4375, -0.3125, -0.3125,  0.4375,  0.1250,  0.4375}}},
	selection_box = { type = "fixed", fixed = {-0.5000, -0.5000, -0.3750,  0.5000,  0.1250,  0.5000}},
	tiles = tiles_feeder, },

	{ node_box = { type = "fixed", fixed = { -- 8
		{-0.5000, -0.3750,  0.4375,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.0625, -0.3125},
		{ 0.4375, -0.3750, -0.3750,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750, -0.4375, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.3125,  0.5000},
		{ 0.4375, -0.5000, -0.3750,  0.5000, -0.3750, -0.3125},
		{ 0.4375, -0.5000,  0.4375,  0.5000, -0.3750,  0.5000},
		{-0.5000, -0.5000,  0.4375, -0.4375, -0.3750,  0.5000},
		{-0.5000, -0.5000, -0.3750, -0.4375, -0.3750, -0.3125},
		{-0.4375, -0.3125, -0.3125,  0.4375,  0.1875,  0.4375}}},
	selection_box = { type = "fixed", fixed = {-0.5000, -0.5000, -0.3750,  0.5000,  0.1875,  0.5000}},
	tiles = tiles_feeder, },

	{ node_box = { type = "fixed", fixed = { -- 9
		{-0.5000, -0.3750,  0.4375,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.0625, -0.3125},
		{ 0.4375, -0.3750, -0.3750,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750, -0.4375, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.3125,  0.5000},
		{ 0.4375, -0.5000, -0.3750,  0.5000, -0.3750, -0.3125},
		{ 0.4375, -0.5000,  0.4375,  0.5000, -0.3750,  0.5000},
		{-0.5000, -0.5000,  0.4375, -0.4375, -0.3750,  0.5000},
		{-0.5000, -0.5000, -0.3750, -0.4375, -0.3750, -0.3125},
		{-0.4375, -0.3125, -0.3125,  0.4375,  0.2500,  0.4375}}},
	selection_box = { type = "fixed", fixed = {-0.5000, -0.5000, -0.3750,  0.5000,  0.2500,  0.5000}},
	tiles = tiles_feeder, },

	{ node_box = { type = "fixed", fixed = { -- 10
		{-0.5000, -0.3750,  0.4375,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.0625, -0.3125},
		{ 0.4375, -0.3750, -0.3750,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750, -0.4375, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.3125,  0.5000},
		{ 0.4375, -0.5000, -0.3750,  0.5000, -0.3750, -0.3125},
		{ 0.4375, -0.5000,  0.4375,  0.5000, -0.3750,  0.5000},
		{-0.5000, -0.5000,  0.4375, -0.4375, -0.3750,  0.5000},
		{-0.5000, -0.5000, -0.3750, -0.4375, -0.3750, -0.3125},
		{-0.4375, -0.3125, -0.3125,  0.4375,  0.2500,  0.4375},
		{-0.3125,  0.3125, -0.1875,  0.3125,  0.3750,  0.3125},
		{-0.3750,  0.2500, -0.2500,  0.3750,  0.3125,  0.3750}}},
	selection_box = { type = "fixed", fixed = {-0.5000, -0.5000, -0.3750,  0.5000,  0.3750,  0.5000}},
	tiles = tiles_feeder, },

	{ node_box = { type = "fixed", fixed = { -- 11
		{-0.5000, -0.3750,  0.4375,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.0625, -0.3125},
		{ 0.4375, -0.3750, -0.3750,  0.5000, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750, -0.4375, -0.0625,  0.5000},
		{-0.5000, -0.3750, -0.3750,  0.5000, -0.3125,  0.5000},
		{ 0.4375, -0.5000, -0.3750,  0.5000, -0.3750, -0.3125},
		{ 0.4375, -0.5000,  0.4375,  0.5000, -0.3750,  0.5000},
		{-0.5000, -0.5000,  0.4375, -0.4375, -0.3750,  0.5000},
		{-0.5000, -0.5000, -0.3750, -0.4375, -0.3750, -0.3125},
		{-0.4375, -0.3125, -0.3125,  0.4375,  0.3125,  0.4375},
		{-0.3125,  0.3750, -0.1875,  0.3125,  0.4375,  0.3125},
		{-0.3750,  0.3125, -0.2500,  0.3750,  0.3750,  0.3750}}},
	selection_box = { type = "fixed", fixed = {-0.5000, -0.5000, -0.3750,  0.5000,  0.4375,  0.5000}},
	tiles = tiles_feeder, },
}


creatures.make_feeder_nodes("sheep:hay_feeder", {

	supply = {
		["farming:wheat"] = { food = 1, count = 15 },
		["farming:straw"] = { food = 3, count = 5 },
		["default:grass_1"] = { food = 1, count = 15 },
		["default:grass_2"] = { food = 1, count = 15 },
		["default:grass_3"] = { food = 1, count = 15 },
		["default:grass_4"] = { food = 1, count = 15 },
		["default:grass_5"] = { food = 1, count = 15 },
		["default:dry_shrub"] = { food = 1, count = 15 },
		["default:dry_grass_1"] = { food = 1, count = 15 },
		["default:dry_grass_2"] = { food = 1, count = 15 },
		["default:dry_grass_3"] = { food = 1, count = 15 },
		["default:dry_grass_4"] = { food = 1, count = 15 },
		["default:dry_grass_5"] = { food = 1, count = 15 },
		["default:junglegrass"] = { food = 1, count = 15 },
		["default:marram_grass_1"] = { food = 1, count = 15 },
		["default:marram_grass_2"] = { food = 1, count = 15 },
		["default:marram_grass_3"] = { food = 1, count = 15 },
		["default:marram_grass_4"] = { food = 1, count = 15 },
		["default:marram_grass_5"] = { food = 1, count = 15 },
	},

	disable_infotext = true,

	max_food = 100,

	node_def = feeder_node_def,

	steps_def = {
		{ food =   1, node_def = node_steps_def[1]  },
		{ food =  10, node_def = node_steps_def[2]  },
		{ food =  20, node_def = node_steps_def[3]  },
		{ food =  30, node_def = node_steps_def[4]  },
		{ food =  40, node_def = node_steps_def[5]  },
		{ food =  50, node_def = node_steps_def[6]  },
		{ food =  60, node_def = node_steps_def[7]  },
		{ food =  70, node_def = node_steps_def[8]  },
		{ food =  80, node_def = node_steps_def[9]  },
		{ food =  90, node_def = node_steps_def[10] },
		{ food = 100, node_def = node_steps_def[11] },
	}
})


-- Drinking Fountain node
minetest.register_node("sheep:drinking_fountain", {
	description = S("Sheep Drinking Fountain"),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = { -- Created with NodeBoxEditor
			{-0.4375, -0.5000,  0.3750,  0.4375, -0.1250,  0.4375},
			{-0.4375, -0.5000, -0.4375,  0.4375, -0.1875,  0.4375},
			{-0.4375, -0.5000, -0.4375,  0.4375, -0.1250, -0.375},
			{-0.4375, -0.5000, -0.3750, -0.3750, -0.1250,  0.375},
			{0.3750, -0.5000, -0.3750,  0.4375, -0.1250,  0.375},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.4375, -0.5000, -0.4375,  0.4375, -0.1250,  0.4375},
	},
	tiles = {
		"(default_water.png^((default_acacia_wood.png)^sheep_drinking_fountain_layer_top.png^[makealpha:76,255,0))", -- Top
		"default_acacia_wood.png", -- Bottom
		"default_acacia_wood.png", -- Right
		"default_acacia_wood.png", -- Left
		"default_acacia_wood.png", -- Back
		"default_acacia_wood.png" -- Front
	},
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {snappy = 3, attached_node = 1, flammable = 1},
	sounds = default.node_sound_wood_defaults()
})

minetest.register_craft({
	output = 'sheep:hay_feeder',
	replacements = {{"sheep:shepherd_wooden_stick", "sheep:shepherd_wooden_stick"}},
	recipe = {
		{'group:stick', 'default:acacia_wood', 'group:stick'},
		{'default:acacia_wood', 'farming:wheat', 'default:acacia_wood'},
		{'group:stick', 'sheep:shepherd_wooden_stick', 'group:stick'},
	}
})

minetest.register_craft({
	output = 'sheep:drinking_fountain',
	replacements = {
		{"sheep:shepherd_wooden_stick", "sheep:shepherd_wooden_stick"},
		{"group:water_bucket", "bucket:bucket_empty"}
	},
	recipe = {
		{'group:stick', 'default:acacia_wood', 'group:stick'},
		{'default:acacia_wood', 'group:water_bucket', 'default:acacia_wood'},
		{'group:stick', 'sheep:shepherd_wooden_stick', 'group:stick'},
	}
})

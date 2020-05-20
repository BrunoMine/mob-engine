--[[
= Ghost for Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

init.lua

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

local S = minetest.get_translator("ghost")

-- Spawn chance
local spawn_chance = tonumber(minetest.settings:get("ghost_spawn_chance") or 1)

local def = {

	-- MOB description
	description = S("Ghost"),

	-- MOB preset
	mob_preset = "default",

	stats = {
		hp = 12,
		lifetime = 600,
		burn_light = {min = 15, max = 15},
		can_fly = true,
		can_panic = false,
		has_falldamage = false,
		hostile = true,
	},

	combat = {
		attack_damage = 2,
		attack_speed = 1.1,
		attack_radius = 1.5,
		attack_hit_interval = 1.5,
		attack_collide_with_target = true,

		search_enemy = true,
		search_timer = 2,
		search_radius = 12,
		search_type = "player",
	},

	modes = creatures.make_mob_modes({
		fly_speed = 2,
		fly_run_speed = 2.6,
		attack = true,
		fly_max_height = 25,
		fly_target_offset = 2.1,
	}),

	model = {
		mesh = "ghost.b3d",
		textures = {"ghost.png"},
		c_box = {0.6, 1.3},
		vision_height = 1.1,
		rotation = -90.0,
		animations = {
			idle = {	frames = {  0,  80, 15}},
			fly = {		frames = {102, 122, 12}},
			attack = {	frames = {102, 122, 25}},
			death = {	frames = { 81, 101, 28, false}, duration = 1.32},
		},
	},

	sounds = {
		on_damage = {"ghost_hit", 0.4},
		on_death = {"ghost_death", 0.7},
		random = {
			idle = {"ghost", 0.5, 10, 20, 30},
		},
	},

	spawning = {
		ambience = {

			-- [1] Surface ABM
			creatures.make_spawn_ambience({
				preset = "surface_abm",
				override = {
					max_number = 1,
					light = {min = 0, max = 8},
					time = {min = 18500, max = 4000},
				},
			}),

			-- [2] Surface Generated
			creatures.make_spawn_ambience({
				preset = "surface_gen",
				override = {
					max_number = 1,
					light = {min = 0, max = 8},
					time = {min = 18500, max = 4000},
				},
			}),

			-- [3] Cave ABM
			creatures.make_spawn_ambience({
				preset = "cave_abm",
				override = {
					number = {min = 1, max = 2},
					max_number = 2,
					abm_chance = 7300,
					light = {min = 0, max = 8},
				},
			}),

			-- [4] Cave Generated
			creatures.make_spawn_ambience({
				preset = "cave_gen",
				override = {
					number = 1,
					max_number = 2,
					on_generated_chance = 100,
					light = {min = 0, max = 8},
				},
			}),

		},

		spawn_egg = { texture = "ghost_spawner_egg.png", },

		spawner = {
			avoid_player_range = 15,
			light = {min = 0, max = 8},
			dummy_scale = {x=1.25, y=1.25},
		}
	},
}

creatures.register_mob("ghost:ghost", def)

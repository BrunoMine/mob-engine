--[[
= Oerrki for Creatures MOB-Engine (cme) =
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

-- Spawn chance
local spawn_chance = tonumber(minetest.settings:get("chicken_spawn_chance") or 1)

local def = {
	
	-- MOB description
	description = "Oerrki",
	
	-- MOB preset
	mob_preset = "default",
	
	stats = {
		hp = 15,
		lifetime = 600,
		sneaky = true,
		hostile = true,
		
		can_panic = false,
	},
	
	combat = {
		attack_damage = 2,
		attack_speed = 0.6,
		attack_radius = 2.1,
		attack_hit_interval = 1.5,
		attack_collide_with_target = true,
		
		search_enemy = true,
		search_timer = 1.6,
		search_radius = 12,
		search_type = "player",
	},
	
	modes = creatures.make_mob_modes({
		walk_speed = 1.5,
		run_speed = 2.9,
		attack = true,
	}),
	
	model = {
		mesh = "oerrki.b3d",
		textures = {"oerrki.png"},
		c_box = {0.6, 1.85},
		vision_height = 1.65,
		rotation = -90.0,
		animations = {
			idle = {	frames = { 1, 23, 15}},
			walk = {	frames = {24, 31,  8, false}},
			attack = {	frames = {37, 49, 18}},
			death = {	frames = {50, 76, 32, false}, duration = 2.52},
		},
	},
	
	sounds = {
		on_damage = {"oerrki_hit"},
		on_death = {"oerrki_hit"},
		swim = {"creatures_splash"},
		random = {
			idle = {"oerrki_idle", 1.0, 25},
			attack = {"oerrki_attack", 1.0, 20},
		},
	},
	
	spawning = {
		ambience = {
			
			-- [1] Cave ABM
			creatures.make_spawn_ambience({
				preset = "cave_abm",
				override = {
					light = {min = 0, max = 8},
					height = {min = -300, max = 0},
				},
			}),
			
			-- [2] Cave Generated
			creatures.make_spawn_ambience({
				preset = "cave_gen",
				override = {
					light = {min = 0, max = 8},
					height = {min = -300, max = 0},
				},
			}),
			
			-- [3] Deep Cave ABM
			creatures.make_spawn_ambience({
				preset = "cave_abm",
				override = {
					number = 1,
					max_number = 3,
					light = {min = 0, max = 8},
					height = {min = -30000, max = -300},
				},
			}),
			
			-- [4] Deep Cave Generated
			creatures.make_spawn_ambience({
				preset = "cave_gen",
				override = {
					number = 1,
					max_number = 3,
					light = {min = 0, max = 8},
					height = {min = -30000, max = -300},
				},
			}),
			
		},
		
		spawn_egg = { texture = "oerrki_spawner_egg.png", },

		spawner = {
			avoid_player_range = 20,
			light = {min = 0, max = 8},
			dummy_scale = {x=0.9, y=0.9},
		}
	},
}

creatures.register_mob("oerrki:oerrki", def)

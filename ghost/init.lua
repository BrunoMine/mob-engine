--[[
= Ghost for Creatures MOB-Engine (cme) =
Copyright (C) 2019 Mob API Developers and Contributors
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
local spawn_chance = tonumber(minetest.settings:get("ghost_spawn_chance") or 1)

local def = {
	-- general
	stats = {
		hp = 12,
		lifetime = 300, -- 5 Minutes
		can_burn = true,
		can_fly = true,
		burn_light = {min = 15, max = 15},
		burn_time_of_day = {min = 6000, max = 18000},
		has_falldamage = false,
		has_kockback = true,
		hostile = true,
	},

	modes = {
		idle = {chance = 0.65, duration = 3, update_yaw = 6},
		fly = {chance = 0.25, duration = 2.5, moving_speed = 2, max_height = 25, target_offset = 2.1},
		-- special modes
		attack = {chance = 0, moving_speed = 2.6, duration = 20},
	},

	model = {
		mesh = "ghost.b3d",
		textures = {"ghost.png"},
		collisionbox_width = 0.6,
		collisionbox_height = 1.3,
		vision_height = 1.1,
		rotation = -90.0,
		animations = {
			idle = {start = 0, stop = 80, speed = 15},
			fly = {start = 102, stop = 122, speed = 12},
			attack = {start = 102, stop = 122, speed = 25},
			death = {start = 81, stop = 101, speed = 28, loop = false, duration = 1.32},
		},
	},

	sounds = {
		on_damage = {name = "ghost_hit", gain = 0.4, distance = 10},
		on_death = {name = "ghost_death", gain = 0.7, distance = 10},
		random = {
			idle = {name = "ghost", gain = 0.5, distance = 10, time_min = 23},
		},
	},

	combat = {
		attack_damage = 2,
		attack_speed = 1.1,
		attack_radius = 1.5,
		attack_hit_interval = 1.5,
		
		search_enemy = true,
		search_timer = 2,
		search_radius = 12,
		search_type = "player",
	},

	spawning = {
		ambience = {
			-- Surface
			{
				spawn_type = "abm",
				
				abm_interval = 40,
				abm_chance = 7300/spawn_chance,
				max_number = 1*spawn_chance,
				number = 1*spawn_chance,
				time_range = {min = 18500, max = 4000},
				light = {min = 0, max = 8},
				height_limit = {min = 1, max = 80},
				
				abm_nodes = {
					spawn_on = {"default:gravel", "default:dirt_with_grass", "default:dirt",
					"group:leaves", "group:sand"},
				},
			},
			{
				spawn_type = "generated",
				
				max_number = 1*spawn_chance,
				number = 1*spawn_chance,
				time_range = {min = 18500, max = 4000},
				light = {min = 0, max = 8},
				height_limit = {min = 1, max = 80},
				
				on_generated_chance = 60*spawn_chance,
				on_generated_nodes = {
					spawn_on = {"default:gravel", "default:dirt_with_grass", "default:dirt",
					"group:leaves", "group:sand"},
				},
			},
			-- Deep
			{
				spawn_type = "abm",
				
				abm_interval = 40,
				abm_chance = 7300/spawn_chance,
				max_number = 2*spawn_chance,
				number = 1*spawn_chance,
				light = {min = 0, max = 8},
				height_limit = {min = -30000, max = 0},
				
				abm_nodes = {
					spawn_on = {"default:stone"},
				},
			},
			{
				spawn_type = "generated",
				
				abm_interval = 40,
				abm_chance = 7300/spawn_chance,
				max_number = 2*spawn_chance,
				number = 1*spawn_chance,
				light = {min = 0, max = 8},
				height_limit = {min = -30000, max = 0},
				
				on_generated_chance = 100,
				on_generated_nodes = {
					spawn_on = {"default:stone"},
				},
			},
		},
		
		spawn_egg = {
			description = "Ghost Spawn-Egg",
			texture = "egg_ghost.png",
		},

		spawner = {
			description = "Ghost Spawner",
			range = 8,
			number = 6,
			light = {min = 0, max = 8},
			dummy_scale = {x=1.25, y=1.25},
		}
	},
}

creatures.register_mob("ghost:ghost", def)

--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors

default.lua

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


-- 'Default' MOB preset
creatures.registered_presets.mob["default"] = {
	stats_preset = "default",
	spawn_preset = "default",
}

-- 'Default' MOB stats preset
creatures.registered_presets.mob_stats["default"] = {
	
	hp = 12,
	
	can_jump = 1,
	
	can_swim = true,
	can_burn = false,
	can_panic = true,
	
	has_falldamage = true,
	has_kockback = true,
	
}

-- 'Default' MOB Spawn preset
creatures.registered_presets.mob_spawn["default"] = {

	spawn_egg = {
		texture = "creatures_spawn_egg.png"
	},
	
	spawner = {
		range = 8,
		number = 4,
	},
}

-- 'Default Env' MOB Spawn Ambience
creatures.registered_presets.mob_spawn_ambience["default_env"] = {
	
	spawn_type = "environment",
	
	max_number = 4,
	zone_width = 100,
	number = {min = 1, max = 3},
	
	time = {min = 5100, max = 18300},
	light = {min = 10, max = 15},
	height = {min = 0, max = 150},
	
	-- Spawn environment
	spawn_env_chance = 2,
	spawn_env_biomes = creatures.merge_groups({
		creatures.biome_groups.humid_grass,
		creatures.biome_groups.dry_grass,
		creatures.biome_groups.snowy
	})
	
}

-- 'Surface ABM' MOB Spawn Ambience
creatures.registered_presets.mob_spawn_ambience["surface_abm"] = {
	
	spawn_type = "abm",
	
	number = 1,
	max_number = 2,
	zone_width = 80,
	
	light = {min = 0, max = 8},
	height = {min = 0, max = 200},
	
	abm_interval = 300,
	abm_chance = 7600,
	abm_nodes = {
		spawn_on = creatures.node_groups.surface,
	},
	
}

-- 'Surface Gen' MOB Spawn Ambience
creatures.registered_presets.mob_spawn_ambience["surface_gen"] = {
	
	spawn_type = "generated",

	number = 1,
	max_number = 2,
	zone_width = 80,

	light = {min = 0, max = 8},
	height = {min = 0, max = 200},

	on_generated_chance = 60,
	on_generated_nodes = {
		spawn_on = creatures.node_groups.surface,
		get_under_air = true, 
	},
	
}

-- 'Cave ABM' MOB Spawn Ambience
creatures.registered_presets.mob_spawn_ambience["cave_abm"] = {
	
	spawn_type = "abm",
	
	number = 1,
	max_number = 3,
	spawn_zone_width = 80,
	
	height = {min = -30000, max = 0},
	
	abm_interval = 300,
	abm_chance = 5500,
	abm_nodes = {
		spawn_on = {"default:stone"},
	},
	
}

-- 'Cave Gen' MOB Spawn Ambience
creatures.registered_presets.mob_spawn_ambience["cave_gen"] = {
	
	spawn_type = "generated",
	
	number = {min = 1, max = 2},
	max_number = 3,
	zone_width = 80,
	
	height = {min = -30000, max = 0},
	
	on_generated_chance = 60,
	on_generated_nodes = { 
		spawn_on = {"default:stone"}, 
		get_under_air = true, 
	},
	
}




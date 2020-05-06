--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2019 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

presets.lua

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


-- Animal MOB preset
creatures.registered_presets.mob["animal"] = {
	mob_stats = "animal",
}

-- "Animal" MOB stats preset
creatures.registered_presets.mob_stats["animal"] = {
	hp = 8,
	can_jump = 1,
	can_swim = true,
	can_burn = true,
	can_panic = true,
	has_falldamage = true,
	has_kockback = true,
}

-- "Default" MOB Spawn preset
creatures.registered_presets.mob_spawn["default"] = {

	spawn_egg = {},
	
	spawner = {
		range = 8,
		player_range = 20,
		number = 4,
	},
}

-- MOB Spawn Ambience
creatures.registered_presets.mob_spawn_ambience["default"] = {
	
	spawn_type = "environment",
	
	max_number = 6,
	spawn_zone_width = 100,
	number = {min = 2, max = 3},
	time_range = {min = 5100, max = 18300},
	light = {min = 10, max = 15},
	height_limit = {min = 0, max = 150},
	
	-- Spawn environment
	spawn_env_chance = 2,
	spawn_env_biomes = {
		-- Grassland
		"grassland", 
		"grassland_ocean",
		"floatland_grassland",
		"snowy_grassland",
		"snowy_grassland_ocean",
		-- Coniferous forest
		"deciduous_forest",
		"deciduous_forest_ocean",
		-- Tundra
		"tundra_highland",
		"tundra",
		-- Taiga
		"taiga",
		"taiga_ocean",
		-- Ice
		"icesheet",
		"icesheet_ocean",
	}
	
}

-- Make env node
creatures.make_env_node["dirt"] = function(spawn_def, env_node)
	
	-- Dirt for spawn env
	minetest.register_node(env_node.nodename, {
		description = "Dirt",
		tiles = {"default_dirt.png"},
		groups = {crumbly = 3, soil = 1, not_in_creative_inventory = 1},
		sounds = default.node_sound_dirt_defaults(),
		drop = "default:dirt",
	})
	
	spawn_def.spawn_env_nodes = {
		emergent = env_node.emergent_nodename,
		spawn_on = {
			"default:dirt_with_grass", 
			"default:dirt_with_snow", "default:snowblock", "default:snow",
		},
		place_on = {
			"default:dirt_with_grass", 
			"default:dirt_with_snow", "default:snowblock", "default:snow",
		},
		set_on = {env_node.nodename},
		build = {
			place = {
				nodename = env_node.nodename,
				nodes = {
					"default:dirt_with_grass", 
					"default:dirt_with_snow", "default:snowblock", "default:snow",
				},
				y_diff = -2,
			},
		},
	}
	
	return spawn_def
end

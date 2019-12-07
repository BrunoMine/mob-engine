--[[
= Zombie for Creatures MOB-Engine (cme) =
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
local spawn_chance = tonumber(minetest.settings:get("zombie_spawn_chance") or 1)

local def = {
	-- general
	stats = {
		hp = 20,
		lifetime = 300, -- 5 Minutes
		can_jump = 1,
		can_swim = true,
		can_burn = true,
		burn_light = {min = 15, max = 15},
		burn_time_of_day = {min = 6000, max = 18000},
		has_falldamage = true,
		has_kockback = true,
		hostile = true,
	},

	modes = {
		idle = {chance = 0.7, duration = 3, update_yaw = 6},
		walk = {chance = 0.3, duration = 5.5, moving_speed = 1, search_radius = 5},
		walk_around = {chance = 0.2, duration = 20, moving_speed = 1},
		-- special modes
		attack = {chance = 0, moving_speed = 2.5, duration = 20},
	},

	model = {
		mesh = "zombie.b3d",
		textures = {"zombie.png"},
		collisionbox_width = 0.5,
		collisionbox_height = 1.75,
		vision_height = 1.4,
		rotation = -90.0,
		animations = {
			idle = {start = 0, stop = 80, speed = 15},
			walk = {start = 102, stop = 122, speed = 10.5},
			attack = {start = 102, stop = 122, speed = 25},
			death = {start = 81, stop = 101, speed = 28, loop = false, duration = 2.12},
		},
	},

	sounds = {
		on_damage = {name = "zombie_hit", gain = 0.4, distance = 10},
		on_death = {name = "zombie_death", gain = 0.7, distance = 10},
		swim = {name = "creatures_splash", gain = 1.0, distance = 10},
			random = {
			idle = {name = "zombie", gain = 0.7, distance = 12},
		},
	},

	combat = {
		attack_damage = 1,
		attack_speed = 0.6,
		attack_radius = 1.5,

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
				
				max_number = 2*spawn_chance,
				number = 1*spawn_chance,
				light = {min = 0, max = 8},
				height_limit = {min = -200, max = 0},
				
				abm_nodes = {
					spawn_on = {
						"default:stone", 
						"default:dirt_with_grass", 
						"default:dirt_with_dry_grass",
						"default:dirt_with_coniferous_litter",
						"default:dirt_with_rainforest_litter", 
						"default:dirt_with_snow", "default:snow",
						"default:dirt",
						"default:cobblestone", 
						"default:mossycobble", 
						"group:sand"
					},
				},
				abm_interval = 36,
				abm_chance = (7600/spawn_chance),
			},
			{
				spawn_type = "generated",
				
				max_number = 2*spawn_chance,
				number = 1*spawn_chance,
				light = {min = 0, max = 8},
				height_limit = {min = -200, max = 0},
				
				on_generated_chance = 60*spawn_chance,
				on_generated_nodes = {
					spawn_on = {
						"default:dirt_with_grass", 
						"default:dirt_with_dry_grass",
						"default:dirt_with_coniferous_litter",
						"default:dirt_with_rainforest_litter", 
						"default:dirt_with_snow", "default:snow",
						"default:dirt",
						"group:sand"
					},
					get_under_air = true, 
				},
			},
			-- Deep
			{ 
				spawn_type = "abm",
				
				max_number = 3*spawn_chance,
				number = 1*spawn_chance,
				light = {min = 0, max = 8},
				height_limit = {min = -30000, max = 0},
				
				abm_nodes = {
					spawn_on = {"default:stone"},
				},
				abm_interval = 55,
				abm_chance = 5500/spawn_chance,
			},
			{ 
				spawn_type = "generated",
				
				max_number = 3*spawn_chance,
				number = {
					min = 1*spawn_chance, 
					max = 2*spawn_chance
				},
				light = {min = 0, max = 8},
				height_limit = {min = -30000, max = 0},
				
				on_generated_chance = 100,
				on_generated_nodes = { 
					spawn_on = {"default:stone"}, 
					get_under_air = true, 
				},
			},
		},
		
		spawn_egg = {
			description = "Zombie Spawn-Egg",
			texture = "egg_zombie.png",
		},

		spawner = {
			description = "Zombie Spawner",
			range = 8,
			number = 6,
			light = {min = 0, max = 8},
		}
	},

	drops = {
		{"creatures:rotten_flesh", {min = 1, max = 2}, chance = 0.7},
	}
}

creatures.register_mob("zombie:zombie", def)


-- Place spawners in dungeons
local function place_spawner(tab)
	local pos = tab[math.random(1, (#tab or 4))]
	pos.y = pos.y - 1
	local n = core.get_node_or_nil(pos)
	if n and n.name ~= "air" then
		pos.y = pos.y + 1
		core.set_node(pos, {name = "zombie:zombie_spawner"})
	end
end
core.set_gen_notify("dungeon")
core.register_on_generated(function(minp, maxp, blockseed)
	local ntf = core.get_mapgen_object("gennotify")
	if ntf and ntf.dungeon and #ntf.dungeon > 3 then
		core.after(3, place_spawner, table.copy(ntf.dungeon))
	end
end)

-- Replace old zombie spawner
minetest.register_lbm({
	name = "zombie:replace_old_spawner",
	nodenames = {"creatures:zombie_spawner"},
	action = function(pos, node)
		minetest.set_node(pos, {name = "zombie:zombie_spawner"})
	end,
})

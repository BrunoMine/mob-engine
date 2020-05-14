--[[
= Zombie for Creatures MOB-Engine (cme) =
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
local spawn_chance = tonumber(minetest.settings:get("zombie_spawn_chance") or 1)

local def = {
	
	-- MOB description
	description = "Zombie",
	
	-- MOB preset
	mob_preset = "default",
	
	stats = {
		hp = 15,
		lifetime = 600, 
		can_burn = true,
		burn_light = {min = 15, max = 15},
		hostile = true,
	},
	
	combat = {
		attack_damage = 1,
		attack_hit_interval = 0.9,
		attack_radius = 2.1,
		attack_collide_with_target = true,

		search_enemy = true,
		search_timer = 2,
		search_radius = 12,
		search_type = "player",
	},
	
	modes = creatures.make_mob_modes({
		walk_speed = 1.1,
		run_speed = 1.1,
		attack = true,
	}),
	
	model = {
		mesh = "zombie.b3d",
		textures = {"zombie.png"},
		c_box = {0.5, 1.75},
		vision_height = 1.4,
		rotation = -90.0,
		animations = {
			idle = {	frames = {  0,  80, 15}},
			walk = {	frames = {102, 122, 20}},
			attack = {	frames = {102, 122, 20}},
			death = {	frames = { 81, 101, 20, false}, duration = 2.12},
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

	spawning = {
		ambience = {
			
			-- [1] Surface ABM
			creatures.make_spawn_ambience({
				preset = "surface_abm",
				override = {
					light = {min = 0, max = 8},
				},
			}),
			
			-- [2] Surface Generated
			creatures.make_spawn_ambience({
				preset = "surface_gen",
				override = {
					light = {min = 0, max = 8},
				},
			}),
			
			-- [3] Cave ABM
			creatures.make_spawn_ambience({
				preset = "cave_abm",
				override = {
					light = {min = 0, max = 8},
				},
			}),
			
			-- [4] Cave Generated
			creatures.make_spawn_ambience({
				preset = "cave_gen",
				override = {
					light = {min = 0, max = 8},
				},
			}),
			
		},
		
		spawn_egg = { texture = "zombie_spawner_egg.png", },

		spawner = {
			avoid_player_range = 15,
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

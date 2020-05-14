--[[
= Chicken for Creatures MOB-Engine (cme) =
Copyright (C) 2019 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

chicken.lua

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

-- Idle 2
creatures.register_idle_mode("chicken:idle2", {
	time = 2,
})

-- Pick
creatures.register_idle_mode("chicken:pick")


creatures.register_mob("chicken:chicken", {
	
	-- MOB description
	description = "Chicken",
	
	-- MOB preset
	mob_preset = "default",
	
	-- general
	stats = {
		hp = 5,
		can_jump = 0.55,
		sneaky = true,
	},
	
	hunger = {
		days_interval = 5,
		food = {
			nodes = {
				"chicken:chicken_feeder_1",
				"chicken:chicken_feeder_2",
				"chicken:chicken_feeder_3",
				"chicken:chicken_feeder_4",
				"chicken:chicken_feeder_5",
				"chicken:chicken_feeder_6",
				"chicken:chicken_feeder_7",
				"chicken:chicken_feeder_8"
			}
		},
	},
	
	randomize = {
		values = {
			{textures = {"chicken_white.png"}, tags = { feather_color = "white" }},
			{textures = {"chicken_black.png"}, tags = { feather_color = "black" }},
			{textures = {"chicken_brown.png"}, tags = { feather_color = "brown" }}
		}
	},
	
	modes = creatures.make_mob_modes({
		walk_speed = 0.7, 
		run_speed = 2.7, 
		
		-- Follow
		follow_items = {["farming:seed_wheat"]=true}, 
		
		-- Eat
		eat_full_time = 4,
		eat_exact_time = 2,
		eat_nodes = {
			["default:grass_1"] = {}, 
			["default:grass_2"] = {}, 
			["default:grass_3"] = {}, 
			["default:grass_4"] = {}, 
			["default:grass_5"] = {}, 
			["default:dirt_with_grass"] = {}, 
		},
		
		-- Custom
		custom = {
			["chicken:dropegg"] = {chance = 1, duration = 8},
			["chicken:idle2"] = {chance = 19, duration = 0.8},
			["chicken:pick"] = {chance = 20, duration = 2},
		},
	}),
	
	model = {
		mesh = "chicken.b3d",
		textures = {"chicken_white.png"},
		c_box = {0.5, 0.7},
		vision_height = 0.4,
		weight = 15,
		rotation = 90.0,
		collide_with_objects = false,
		animations = {
			idle = {	frames = { 0, 1,  10}},
			walk = {	frames = { 4, 36, 50}},
			swim = {	frames = {51, 87, 40}},
			panic = {	frames = {51, 87, 55}},
			death = {	frames = {135, 160, 28, false}, duration = 2.12},
			-- Custom Animations
			["chicken:idle2"] = {	frames = {40,  50, 50}},
			["chicken:pick"] = {	frames = {88, 134, 50}},
		},
	},
	
	child = {
		name = "chicken:chicken_child",
		days_to_grow = 3,
		model = {
			scale = {x = 0.7, y = 0.7}
		},
	},
	
	mating = {
		child_mob = "chicken:chicken_child", 
		interval = 3, 
		birth_multiplier = 0.5,
		spawn_type = "mob_node", 
	},
	
	sounds = {
		on_damage = {"chicken_hit", 0.5},
		on_death = {"chicken_hit", 0.5},
		swim = {"creatures_splash"},
		random = {
			idle = {"chicken", 0.9, 12, 8, 50},
		},
	},

	spawning = {
		
		ambience = {
			
			-- [1] 'Default' Spawn env node with dirt
			creatures.make_spawn_ambience({
				preset = "default_env",
				nodes = {
					type = "dirt",
					emergent = {
						nodename = "chicken:emergent_spawn_env",
						place_on = creatures.node_groups.surface_humid_dirt,
					},
					env_node = {
						nodename = "chicken:dirt_spawn_env",
					},
				},
				override = {
					max_number = 6,
					number = {min = 2, max = 3},
					spawn_env_chance = chicken.spawn_env_chance,
					spawn_env_seed = 7254361944,
				},
			}),
			
		},
		
		spawner = {
			dummy_scale = {x=2.2, y=2.2},
		}
	},
	
	drops = function(self)
		if self.is_child then return end
		
		local items = {}
		
		-- Meat
		if self.death_reason == "burn" then
			table.insert(items, {"chicken:chicken_meat"})
		else
			table.insert(items, {"chicken:chicken_flesh"})
		end
		
		table.insert(items, {"chicken:feather_" .. self.feather_color, {min = 1, max = 2}, chance = 0.45})
		
		creatures.drop_items(self.object:get_pos(), items)
	end,
	
})

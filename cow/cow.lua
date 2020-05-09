--[[
= Cow for Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors

cow.lua

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


creatures.register_mob("cow:cow", {
	
	-- MOB description
	description = "Cow",
	
	-- MOB preset
	mob_preset = "default",
	
	stats = {
		hp = 18,
	},
	
	hunger = {
		days_interval = 5,
		water = {
			nodes = {
				"cow:drinking_fountain", 
				"group:water",
			}
		},
		food = {
			nodes = {
				"cow:cow_feeder_1",
				"cow:cow_feeder_2",
				"cow:cow_feeder_3",
				"cow:cow_feeder_4",
				"cow:cow_feeder_5",
				"cow:cow_feeder_6",
				"cow:cow_feeder_7",
				"cow:cow_feeder_8",
				"cow:cow_feeder_9",
				"cow:cow_feeder_10",
				"cow:cow_feeder_11",
				"farming:straw",
			}
		},
	},
	
	modes = {
		idle = {chance = 0.5, duration = 10, random_yaw = 4},
		walk = {
			chance = 0.15, 
			duration = 20, 
			moving_speed = 0.8,
			search_radius = 5
		},
		walk_around = {
			chance = 0.15, 
			duration = 20, 
			moving_speed = 0.7
		},
		eat = {	
			chance = 0.2,
			duration = 4,
			eat_time = 1.2,
			sound = "creatures_eat_grass",
			nodes = {
				["default:grass_1"] = {remove=true}, 
				["default:grass_2"] = {remove=true}, 
				["default:grass_3"] = {remove=true}, 
				["default:grass_4"] = {remove=true}, 
				["default:grass_5"] = {remove=true}, 
				["default:dirt_with_grass"] = {replace="default:dirt"}, 
			}
		},
		follow = {
			chance = 0, 
			duration = 20, 
			radius = 5, 
			moving_speed = 0.8, 
			items = {["farming:wheat"]=true}, 
			search_timer = 5
		},
	},
	
	model = {
		mesh = "cow.b3d",
		textures = {"cow_white_and_black.png"},
		collisionbox_width = 0.9,
		collisionbox_height = 1.2,
		rotation = -90.0,
		scale = {x = 3.7, y = 3.7},
		vision_height = 0.9,
		animations = {
			idle = {start = 1, stop = 30, speed = 18},
			walk = {start = 31, stop = 60, speed = 20},
			run = {start = 91, stop = 120, speed = 20},
			eat = {start = 61, stop = 90, speed = 12, loop = false},
			death = {start = 121, stop = 135, speed = 15, loop = false, duration = 2.52},
		},
	},
	
	randomize = {
		values = {
			{textures = {"cow_white_and_black.png"},},
			{textures = {"cow_white_and_brown.png"},},
			{textures = {"cow_brown_and_black.png"},},
			{textures = {"cow_white.png"},},
			{textures = {"cow_grey.png"},},
			{textures = {"cow_black.png"},},
			{textures = {"cow_brown.png"},},
		},
	},
	
	sounds = {
		on_damage = {name = "sheep", gain = 1.0, distance = 10},
		on_death = {name = "sheep", gain = 1.0, distance = 10},
		swim = {name = "creatures_splash", gain = 1.0, distance = 10,},
		random = {
			idle = {name = "cow", gain = 0.6, distance = 10},
		},
	},
	
	get_staticdata = function(self)
		return {
			["cow:last_milk_day"] = self["cow:last_milk_day"],
		}
	end,
	
	spawning = {
		
		ambience = {
			
			-- [1] 'Default Env' Spawn env node with dirt
			creatures.make_spawn_ambience({
				preset = "default_env",
				nodes = {
					type = "dirt",
					emergent = {
						nodename = "cow:emergent_spawn_env",
						place_on = creatures.node_groups.surface_humid_dirt,
					},
					env_node = {
						nodename = "cow:dirt_spawn_env",
					},
				},
				override = {
					spawn_env_seed = 4687381594,
				},
			}),
			
		},
		
		spawn_egg = { texture = "cow_spawner_egg.png", },
		
		spawner = {
			dummy_scale = {x=1.75, y=1.75},
		},
	},
	
	child = {
		name = "cow:cow_child",
		days_to_grow = 7,
		model = {
			collisionbox_width = 0.7,
			collisionbox_height = 1.1,
			scale = {x = 2.35, y = 2.35}
		},
	},
	
	mating = {
		child_mob = "cow:cow_child", 
		interval = 5, 
		birth_multiplier = 0.2,
		spawn_type = "mob_node", 
	},
	
	drops = {
		{"cow:raw_beef", 1, chance = 1},
	},
	
	on_rightclick = function(self, clicker)
		if self.is_died == true or self.is_child == true then return end
		
		local itemstack = clicker:get_wielded_item()
		
		if itemstack:get_name() == "bucket:bucket_empty" then
			
			if self["cow:last_milk_day"] == nil then
				self["cow:last_milk_day"] = -1
			end
			
			local server_time = minetest.get_day_count() + minetest.get_timeofday()
			
			-- Check last time
			if self["cow:last_milk_day"]+1 > server_time then
				return
			end
			
			local inv = clicker:get_inventory()
			if inv:room_for_item("main", "cow:bucket_milk 1") == true then
				inv:remove_item("main", "bucket:bucket_empty 1")
				inv:add_item("main", "cow:bucket_milk 1")
				-- Reset time
				self["cow:last_milk_day"] = server_time
				core.sound_play("cow_bucket_milk", {pos = self.object:get_pos(), max_hear_distance = 5, gain = 1})
			end
			
		end
	end,
})

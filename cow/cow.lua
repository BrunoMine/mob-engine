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
		water = {
			nodes = {
				cow.cow_drinking_fountain, 
				"group:water",
			}
		},
		food = {
			feeders = {cow.cow_hay_feeder},
		},
	},
	
	modes = creatures.make_mob_modes({
		walk_speed = 0.8, 
		run_speed = 1.2, 
		
		-- Follow
		follow_items = {["farming:wheat"]=true}, 
		
		-- Eat
		eat_full_time = 4,
		eat_exact_time = 1.2,
		eat_sound = {"creatures_eat_grass", 1.0, 10}, 
		eat_nodes = {
			["default:grass_1"] = {remove=true}, 
			["default:grass_2"] = {remove=true}, 
			["default:grass_3"] = {remove=true}, 
			["default:grass_4"] = {remove=true}, 
			["default:grass_5"] = {remove=true}, 
			["default:dirt_with_grass"] = {replace="default:dirt"}, 
		},
	}),
	
	mob_node = { name = "cow:cowboy_bell" },
	
	model = {
		mesh = "cow.b3d",
		textures = {"cow_white_and_black.png"},
		c_box = {0.9, 1.2}, 
		rotation = -90.0,
		scale = {x = 3.7, y = 3.7},
		vision_height = 0.9,
		weight = 100, 
		animations = {
			idle = {	frames = {  1,  30, 18}},
			walk = {	frames = { 31,  60, 20}},
			run = {		frames = { 91, 120, 20}},
			eat = {		frames = { 61,  90, 12, false}},
			death = {	frames = {121, 135, 15, false}, duration = 2.52},
		},
	},
	
	randomize = {
		values = {
			{textures = {"cow_white_and_black.png"}, tags = { leather_color = "white_and_black" }},
			{textures = {"cow_white_and_brown.png"}, tags = { leather_color = "white_and_brown" }},
			{textures = {"cow_brown_and_black.png"}, tags = { leather_color = "brown_and_black" }},
			{textures = {"cow_white.png"}, tags = { leather_color = "white" }},
			{textures = {"cow_grey.png"}, tags = { leather_color = "grey" }},
			{textures = {"cow_black.png"}, tags = { leather_color = "black" }},
			{textures = {"cow_brown.png"}, tags = { leather_color = "brown" }},
		},
	},
	
	sounds = {
		on_damage = {"cow_damage"},
		on_death = {"cow_damage"},
		swim = {"creatures_splash"},
		random = {
			idle = {"cow", 0.6},
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
			c_box = {0.7, 1.1},
			scale = {x = 2.35, y = 2.35}
		},
	},
	
	mating = {
		child_mob = "cow:cow_child", 
		interval = 5, 
		birth_multiplier = 0.2,
		spawn_type = "mob_node", 
	},
	
	drops = function(self)
		
		if self.is_child then return end
		
		local items = {}
		
		-- Meat
		if self.death_reason == "burn" then
			table.insert(items, {"cow:roast_beef"})
		else
			table.insert(items, {"cow:raw_beef"})
		end
		
		table.insert(items, {"cow:leather_" .. self.leather_color})
		
		creatures.drop_items(self.object:get_pos(), items)
	end,
	
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

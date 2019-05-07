--[[
= Sheep for Creatures MOB-Engine (cme) =
Copyright (C) 2019 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

sheep.lua

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

sheep.set_color = function(self)
	if self and self.object then
		local ext = ".png"
		if self.has_wool ~= true then
			ext = ".png^(sheep_shaved.png^[colorize:" .. self.wool_color:gsub("grey", "gray") .. ":50)"
		end
		self.object:set_properties({textures = {"sheep.png^sheep_" .. self.wool_color .. ext}})
	end
end
local setColor = sheep.set_color

local function shear(self, drop_count, sound)
	if self.has_wool == true then
		self.has_wool = false
		local pos = self.object:getpos()
		if sound then
			core.sound_play("shears", {pos = pos, gain = 1, max_hear_distance = 10})
		end

		setColor(self)
		creatures.drop_items(pos, {{"wool:" .. self.wool_color, drop_count}})
	end
end


-- white, grey, brown, black (see wool colors as reference)
local colors = {"white", "grey", "brown", "black"}

creatures.register_mob("sheep:sheep", {
	stats = {
		hp = 8,
		lifetime = 450, -- 7,5 Minutes
		can_jump = 1,
		can_swim = true,
		can_burn = true,
		can_panic = true,
		has_falldamage = true,
		has_kockback = true,
	},
	
	hunger = {
		days_interval = 5,
		water = true,
		water_nodes = {"sheep:drinking_fountain", "group:water"},
		food = {
			nodes = {
				"sheep:sheep_feeder_1",
				"sheep:sheep_feeder_2",
				"sheep:sheep_feeder_3",
				"sheep:sheep_feeder_4",
				"sheep:sheep_feeder_5",
				"sheep:sheep_feeder_6",
				"sheep:sheep_feeder_7",
				"sheep:sheep_feeder_8",
				"sheep:sheep_feeder_9",
				"sheep:sheep_feeder_10",
				"sheep:sheep_feeder_11"
			}
		},
	},
	
	modes = {
		idle = {chance = 0.5, duration = 10, random_yaw = 4},
		walk = {
			chance = 0.14, 
			duration = 20, 
			moving_speed = 1.3,
			search_radius = 5
		},
		walk_around = {
			chance = 0.2, 
			duration = 20, 
			moving_speed = 0.7
		},
		-- special modes
		follow = {chance = 0, duration = 20, radius = 4, moving_speed = 1, items = {["farming:wheat"]=true}, search_timer = 4},
		eat = {	chance = 0.25,
			duration = 4,
			nodes = {
				"default:grass_1", "default:grass_2", "default:grass_3",
				"default:grass_4", "default:grass_5", "default:dirt_with_grass"
			}
		},
	},
	
	model = {
		mesh = "sheep.b3d",
		textures = {"sheep.png^sheep_white.png"},
		collisionbox_width = 0.9,
		collisionbox_height = 1.2,
		rotation = 0.0,
		vision_height = 0.9,
		animations = {
			idle = {start = 1, stop = 60, speed = 15},
			walk = {start = 81, stop = 101, speed = 18},
			eat = {start = 107, stop = 170, speed = 12, loop = false},
			follow = {start = 81, stop = 101, speed = 15},
			death = {start = 171, stop = 191, speed = 32, loop = false, duration = 2.52},
		},
	},

	sounds = {
		on_damage = {name = "sheep", gain = 1.0, distance = 10},
		on_death = {name = "sheep", gain = 1.0, distance = 10},
		swim = {name = "creatures_splash", gain = 1.0, distance = 10,},
		random = {
			idle = {name = "sheep", gain = 0.6, distance = 10, time_min = 23},
		},
	},
	
	drops = function(self)
		if self.is_child then return end
		local items = {{"sheep:sheep_flesh"}}
		if self.has_wool then
			table.insert(items, {"wool:" .. self.wool_color, {min = 1, max = 2}})
		end
		creatures.drop_items(self.object:getpos(), items)
	end,
	
	child = {
		name = "sheep:sheep_child",
		days_to_grow = 5,
		model = {
			collisionbox_width = 0.7,
			collisionbox_height = 1.1,
			scale = {x = 0.65, y = 0.65}
		},
		
		-- Callbacks
		on_grow = function(self, new_self)
			new_self.wool_color = self.wool_color
		end,
	},
	
	mating = {
		child_mob = "sheep:sheep_child", 
		interval = 5, 
		spawn_type = "mob_node", 
	},
	
	spawning = {
		
		ambience = {
			
			{
				max_number = 4,
				spawn_zone_width = 100,
				number = {min = 2, max = 4},
				time_range = {min = 5100, max = 18300},
				light = {min = 10, max = 15},
				height_limit = {min = 1, max = 100},
				
				spawn_on = {
					"default:dirt_with_grass", 
					"default:dirt_with_snow", "default:snow", "default:snowblock",
				},
				
				abm_nodes = {
					spawn_on = {
						"default:dirt_with_grass", 
						"default:dirt_with_snow", "default:snow", "default:snowblock",
					},
					neighbors = {
						"group:dirt"
					},
				},
				abm_interval = 55,
				abm_chance = 7800,
				
				on_generated_nodes = {
					spawn_on = {
						"default:dirt_with_grass", 
						"default:dirt_with_snow", "default:snowblock",
					},
				},
				on_generated_chance = 35,
			}
		},
		
		spawn_egg = {
			description = "Sheep Spawn-Egg",
			texture = "egg_sheep.png",
		},

		spawner = {
			description = "Sheep Spawner",
			range = 8,
			player_range = 20,
			number = 6,
		}
	},

	get_staticdata = function(self)
		return {
			has_wool = self.has_wool,
			wool_color = self.wool_color,
			["sheep:last_day_clipped"] = self["sheep:last_day_clipped"],
		}
	end,

	on_activate = function(self, staticdata)
	
		if staticdata == "" then
			self.has_wool = true
			self["sheep:last_day_clipped"] = core.get_day_count()
		end
		
		-- Timer
		self["sheep:regrow_timer"] = 0
		
		if not self.wool_color then
			self.wool_color =  colors[math.random(1, #colors)]
		end
		-- update fur
		setColor(self)
	end,

	on_rightclick = function(self, clicker)
		if self.is_child then return end
		local item = clicker:get_wielded_item()
		if item then
			local name = item:get_name()
			if name == "creatures:shears" and self.has_wool then
				shear(self, math.random(1, 2), true)
				item:add_wear(65535/100)
			end
			if not minetest.settings:get_bool("creative_mode") then
				clicker:set_wielded_item(item)
			end
		end
	end,

	on_step = function(self, dtime)
		self["sheep:regrow_timer"] = self["sheep:regrow_timer"] + dtime
		
		if self["sheep:regrow_timer"] >= 30 then
			self["sheep:regrow_timer"] = 0
			
			if (self["sheep:last_day_clipped"]+3) <= core.get_day_count() then
				self["sheep:last_day_clipped"] = core.get_day_count()
				self.has_wool = true
				setColor(self)
			end
		end
		
	end
})

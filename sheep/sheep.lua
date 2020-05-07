--[[
= Sheep for Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors
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
	
	-- MOB description
	description = "Sheep",
	
	-- MOB preset
	mob_preset = "animal",
	
	-- Spawn preset
	spawn_preset = "default",
	
	hunger = {
		days_interval = 5,
		water = {
			nodes = {
				"sheep:drinking_fountain", 
				"group:water",
			}
		},
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
				"sheep:sheep_feeder_11",
				"farming:straw",
			}
		},
	},
	
	randomize = {
		values = {
			{
				textures = {"sheep.png^sheep_white.png"}, 
				tags = {
					wool_color = "white"
				}
			},
			{
				textures = {"sheep.png^sheep_black.png"}, 
				tags = {
					wool_color = "black"
				}
			},
			{
				textures = {"sheep.png^sheep_brown.png"}, 
				tags = {
					wool_color = "brown"
				}
			},
			{
				textures = {"sheep.png^sheep_grey.png"}, 
				tags = {
					wool_color = "grey"
				}
			},
		},
		on_randomize = function(self, values)
			self.has_wool = true
			setColor(self)
		end,
	},
	
	modes = {
		idle = {
			chance = 50, 
			duration = {min=5, max=10}, 
			random_yaw = 4
		},
		walk = {
			duration = 20, 
			moving_speed = 1.3,
			search_radius = 5
		},
		walk_around = {
			chance = 30, 
			duration = 20, 
			moving_speed = 0.7
		},
		-- special modes
		follow = {
			duration = 20, 
			radius = 4, 
			moving_speed = 1, 
			items = {["farming:wheat"]=true}, 
			search_timer = 4
		},
		eat = {	
			chance = 20,
			duration = 4,
			eat_time = 2,
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
	},
	
	model = {
		mesh = "sheep.b3d",
		textures = {"sheep.png^sheep_white.png"},
		collisionbox_width = 0.9,
		collisionbox_height = 1.2,
		rotation = -90.0,
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
			idle = {name = "sheep", gain = 0.6, distance = 10, time_min = 20, time_max = 30},
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
			setColor(new_self)
		end,
	},
	
	mating = {
		child_mob = "sheep:sheep_child", 
		interval = 5, 
		birth_multiplier = 0.3,
		spawn_type = "mob_node", 
	},
	
	spawning = {
	
		ambience = {
			
			-- [1] 'Default' Spawn env node with dirt
			creatures.make_spawn_ambience({
				preset = "default_env",
				env_node = {
					type = "dirt",
					nodename = "sheep:dirt_spawn_env",
					emergent_nodename = "sheep:emergent_spawn_env",
					spawn_on = creatures.merge_groups({
						creatures.node_groups.humid_grass,
						creatures.node_groups.snowy
					}),
				},
				override = {
					spawn_env_chance = sheep.spawn_env_chance,
					spawn_env_seed = 2359,
					spawn_env_biomes = creatures.merge_groups({
						creatures.biome_groups.humid_grass,
						creatures.biome_groups.snowy
					}),
				},
			}),
			
		},
		
		spawn_egg = { texture = "egg_sheep.png" },
		
		spawner = {
			range = 8,
			player_range = 20,
			number = 6,
			dummy_scale = {x=1.7, y=1.7},
		},
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
		
	end,

	mob_item_tool = {
		["creatures:shears"] = {
			wear = 500,
			disabled_in_child = true,
			on_use = function(self, clicker)
				if self.has_wool then
					shear(self, math.random(1, 2), true)
					return true
				end
				return false
			end,
		},
	},

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

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
		local pos = self.object:get_pos()
		if sound then
			core.sound_play("creatures_shears", {pos = pos, gain = 1, max_hear_distance = 10})
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
	mob_preset = "default",
	
	hunger = {
		water = {
			nodes = {
				"sheep:drinking_fountain", 
				"group:water",
			}
		},
		food = {
			feeders = {"sheep:hay_feeder"},
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
	},
	
	modes = creatures.make_mob_modes({
		walk_speed = 1.3, 
		run_speed = 2.1, 
		
		-- Follow
		follow_items = {["farming:wheat"]=true}, 
		
		-- Eat
		eat_full_time = 4,
		eat_exact_time = 2,
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
	
	model = {
		mesh = "sheep.b3d",
		textures = {"sheep.png^sheep_white.png"},
		c_box = {0.9, 1.2},
		rotation = -90.0,
		vision_height = 0.9,
		animations = {
			idle = {	frames = {  1,  60, 15}},
			walk = {	frames = { 81, 101, 18}},
			eat = {		frames = {107, 170, 12, false}},
			follow = {	frames = { 81, 101, 15}},
			death = {	frames = {171, 191, 32, false}, duration = 2.52},
		},
	},

	sounds = {
		on_damage = {"sheep"},
		on_death = {"sheep"},
		swim = {"creatures_splash"},
		random = {
			idle = {"sheep", 0.6, 10, 20, 30},
		},
	},
	
	drops = function(self)
		if self.is_child then return end
		
		local items = {}
		
		-- Meat
		if self.death_reason == "burn" then
			table.insert(items, {"sheep:sheep_meat"})
		else
			table.insert(items, {"sheep:sheep_flesh"})
		end
		
		-- Wool
		if self.has_wool then
			table.insert(items, {"wool:" .. self.wool_color})
		end
		
		creatures.drop_items(self.object:get_pos(), items)
	end,
	
	child = {
		name = "sheep:sheep_child",
		days_to_grow = 5,
		model = {
			c_box = {0.7, 1.1}, 
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
			
			-- [1] 'Default Env' Spawn env node with dirt
			creatures.make_spawn_ambience({
				preset = "default_env",
				nodes = {
					type = "dirt",
					emergent = {
						nodename = "sheep:emergent_spawn_env",
						place_on = creatures.node_groups.surface_humid_dirt,
					},
					env_node = {
						nodename = "sheep:dirt_spawn_env",
					},
				},
				override = {
					spawn_env_chance = sheep.spawn_env_chance,
					spawn_env_seed = 2359234129,
				},
			}),
			
		},
		
		spawn_egg = { texture = "sheep_egg.png" },
		
		spawner = {
			dummy_scale = {x=1.7, y=1.7},
		},
	},
	
	on_activate = function(self, staticdata)
	
		if self.has_wool == nil then self.has_wool = true end
		self["sheep:last_day_clipped"] = self["sheep:last_day_clipped"] or core.get_day_count()
		
		setColor(self)
		
		-- Timer
		self.sheep_regrow_wool = self:mob_actfac_time(30)
		
	end,
	
	get_staticdata = function(self)
		return {
			has_wool = self.has_wool,
			wool_color = self.wool_color,
			["sheep:last_day_clipped"] = self["sheep:last_day_clipped"],
		}
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
		self.sheep_regrow_wool = self.sheep_regrow_wool - dtime
		
		if self.sheep_regrow_wool <= 0 then
			self.sheep_regrow_wool = self:mob_actfac_time(30)
			
			if (self["sheep:last_day_clipped"]+3) <= core.get_day_count() then
				self["sheep:last_day_clipped"] = core.get_day_count()
				self.has_wool = true
				setColor(self)
			end
		end
		
	end
})

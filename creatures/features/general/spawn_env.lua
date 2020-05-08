--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

spawn_env.lua

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

-- MOB spawn ambience Presets
creatures.registered_presets.mob_spawn_ambience = {}

local registered_emergent_nodes = {}

local nodes_count = 0

-- Try spawn env
local try_spawn = function(pos, label, spawn_on)
	
	-- Check Spawn env node
	if minetest.get_meta(pos):get_string("creatures:spawn_env") == "" then return end
	
	-- Check MOB
	local meta = minetest.get_meta(pos)
	local spawn_env = minetest.deserialize(meta:get_string("creatures:spawn_env"))
	
	-- Check clean cycle
	if spawn_env.clean_cycle == creatures.cleaning_cycle then return end
	
	-- Try spawn
	local self = creatures.spawn_at_ambience(pos, label, 
		{
			spawn_on = spawn_on,
			only_one = true,
			ignore_height_limits = true,
			ignore_time_range = true,
			ignore_light = true,
		}
	)
	
	-- Check if spawn
	if self == nil then return end
	
	self.is_wild = true
	self.spawn_env = {
		node_pos = table.copy(pos),
		node_name = minetest.get_node(pos).name,
	}
	spawn_env.clean_cycle = creatures.cleaning_cycle
	meta:set_string("creatures:spawn_env", minetest.serialize(spawn_env))
end

-- Register spawn env
creatures.register_spawn_env = function(label)
	
	nodes_count = nodes_count + 1
	
	local def = creatures.registered_spawn[label]
	local def_nodes = def.spawn_env_nodes
	
	local emergent_nodename = def_nodes.emergent.nodename
	registered_emergent_nodes[emergent_nodename] = {}
	registered_emergent_nodes[emergent_nodename].label = label
	registered_emergent_nodes[emergent_nodename].spawn_env_nodes = def.spawn_env_nodes
	registered_emergent_nodes[emergent_nodename].number = def.number
	
	-- Emergent node
	minetest.register_node(emergent_nodename, {
		description = "Emergent Spawn Env Node",
		tiles = {"creatures_spawn_env.png"},
		paramtype = "light",
		drawtype = "glasslike_framed_optional",
		sunlight_propagates = true,
		groups = {emergent_spawn_env = 1, not_in_creative_inventory = 1},
		drop = "",
	})
	
	minetest.register_decoration({
		name = "creatures:spawn_env_"..nodes_count,
		decoration = emergent_nodename,
		deco_type = "simple",
		place_on = def_nodes.emergent.place_on,
		--place_offset_y = 5,
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.0001,
			spread = {x = 200, y = 200, z = 200},
			seed = def.spawn_env_seed or creatures.make_number(def.mob_name),
			octaves = 3,
			persist = 0.6 * (def.spawn_env_chance or 1),
			lacunarity = 1,
		},
		biomes = def.spawn_env_biomes,
		y_max = def.height_limit.max or 200,
		y_min = def.height_limit.min or 0,
		param2 = 4,
	})
	
	-- ABM to try spawn MOB periodically
	minetest.register_abm{
		label = "set spawn env node "..nodes_count,
		nodenames = {def_nodes.env_node.nodename},
		neighbors = def_nodes.env_node.neighbors,
		interval = 10,
		chance = 1,
		action = function(pos)
			try_spawn(pos, label, def_nodes.spawn_on)
		end,
	}
	
end

minetest.register_lbm({
	name = "creatures:set_spawn_env_node",
	run_at_every_load = true,
	nodenames = {"group:emergent_spawn_env"},
	action = function(pos)
		local nodename = minetest.get_node(pos).name
		local def = registered_emergent_nodes[minetest.get_node(pos).name]
		local def_nodes = def.spawn_env_nodes
		
		local number = 1
		if def.number then
			if type(def.number) == "number" then
				number = def.number
			else
				number = math.random(def.number.min, def.number.max)
			end
		end
		
		-- Remove emergent node
		minetest.remove_node(pos)
		
		-- Place env node
		local placed = {}
		do
			local nodes = minetest.find_nodes_in_area(
				{x=pos.x-6, y=pos.y-6, z=pos.z-6}, 
				{x=pos.x+6, y=pos.y+6, z=pos.z+6}, 
				def_nodes.env_node.place_on
			)
			local n = number
			while n > 0 and #nodes > 0 do
				local p = creatures.get_random_from_table(nodes, true)
				minetest.set_node(
					{x=p.x, y=p.y+(def_nodes.env_node.y_diff or 0), z=p.z},
					{name=def_nodes.env_node.nodename}
				)
				table.insert(placed, {x=p.x, y=p.y+(def_nodes.env_node.y_diff or 0), z=p.z})
				n = n - 1
			end
		end
		
		-- Set up env nodes and first spawn
		for _,p in ipairs(placed) do
			
			local meta = minetest.get_meta(p)
			local spawn_env = {
				mob_name = def.mob_name,
				clean_cycle = nil, -- Try spawn first time
			}
			meta:set_string("creatures:spawn_env", minetest.serialize(spawn_env))
			
			try_spawn(p, def.label, def_nodes.spawn_on)
		end
		
	end,
})

-- Check env node
local check_env_node = function(self)
	local node = creatures.get_far_node(self.spawn_env.node_pos) -- force load node
	
	-- Check node
	if node.name ~= self.spawn_env.node_name then
		return false
	end
	
	-- Check metadata
	local meta = minetest.get_meta(self.spawn_env.node_pos)
	if meta:get_string("creatures:spawn_env") == "" then
		return false
	end
	
	return true
end

-- Clear spawn env node
local clear_env_node = function(self)
	if check_env_node(self) == false then return end
	
	-- Remove data from node
	local meta = minetest.get_meta(self.spawn_env.node_pos)
	meta:set_string("creatures:spawn_env", "")
	
	-- Remove data from lua entity
	self.spawn_env = nil
end

-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	-- Load Spawning MOB preset
	def.spawning = creatures.apply_preset(
		def.spawning, 
		def.spawn_preset, 
		creatures.registered_presets.mob_spawn,
		true
	)
	
	-- Register 'on_die' callback
	creatures.register_on_die(mob_name, function(self, reason)
		if self.spawn_env ~= nil then
			clear_env_node(self)
		end
	end)
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		self.is_wild = self.is_wild or false
	end)
	
	-- Register 'get_staticdata'
	creatures.register_get_staticdata(mob_name, function(self)
		if self.activated and self.spawn_env ~= nil and self.mob_node ~= nil and self.mob_node.pos ~= nil then
			clear_env_node(self)
			self.is_wild = false
			return
		end
		if self.spawn_env ~= nil then
			return {
				is_wild = self.is_wild,
				spawn_env = self.spawn_env,
			}
		end
	end)
	
end)

-- Registered env node makers
creatures.make_env_node = {}

-- Make spawn env nodes
creatures.make_spawn_ambience = function(def)
	
	-- Basic definitions
	local spawn_def = table.copy(creatures.registered_presets.mob_spawn_ambience[def.preset or "default"])
	
	-- Spawn env node
	if spawn_def.spawn_type == "environment" then 
		spawn_def = creatures.make_env_node[def.nodes.type](spawn_def, def.nodes)
	end
	
	-- Apply overrided definitions
	spawn_def = creatures.apply_preset(
		spawn_def, 
		nil, 
		def.override
	)
	
	return spawn_def
end
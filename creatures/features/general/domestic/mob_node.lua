--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

mob_node.lua

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


creatures.registered_mob_nodes = {}

-- Check mob_node at pos
local check_node = function(pos)
	local node = creatures.get_far_node(pos)
	if not creatures.registered_mob_nodes[node.name] then
		return false
	end
	return true
end


-- Get saved MOBs
local get_saved_mobs = function(pos)
	if not check_node(pos) then return end
	
	-- Meta
	local meta = minetest.get_meta(pos)
	
	-- Saved mobs
	local saved_mobs = meta:get_string("saved_mobs")
	if saved_mobs == "" then
		saved_mobs = {}
	else
		saved_mobs = minetest.deserialize(saved_mobs)
	end
	
	return saved_mobs
end

-- Set saved MOBs
local set_saved_mobs = function(pos, saved_mobs)
	
	local meta = minetest.get_meta(pos)
	
	local n = 0
	for a,b in pairs(saved_mobs) do
		n = n + 1
	end
	
	meta:set_string("saved_mobs", minetest.serialize(saved_mobs))
end


-- Check node from MOB
local check_node_from_node = function(self)
	if not check_node(self.mob_node.pos) then return false end
	
	-- Saved mobs
	local saved_mobs = get_saved_mobs(self.mob_node.pos)
	
	if saved_mobs[self.mob_number] == nil then return false end
	
	return true
end


-- Save MOB on node
local save_mob = function(self, staticdata)
	
	-- Check MOB number
	if self.mob_number == nil then return false end
	
	-- Check node
	if not check_node(self.mob_node.pos) then return false end
	
	-- Saved mobs
	local saved_mobs = get_saved_mobs(self.mob_node.pos)
	
	-- Save MOB
	saved_mobs[self.mob_number] = {
		mob_name = self.mob_name,
		pos = self.object:get_pos(),
		staticdata = staticdata or self:get_staticdata(),
	}
	
	set_saved_mobs(self.mob_node.pos, saved_mobs)
	
	-- Execute custom callback
	local def = creatures.registered_mob_nodes[minetest.get_node(self.mob_node.pos).name]
	if def.on_save_mob then
		def.on_save_mob(pos, self)
	end
	
	return true
end


-- Remove MOB from node
local remove_mob = function(self)
	
	-- Check node
	if not check_node(self.mob_node.pos) or not self.mob_number then return false end
	
	-- Saved mobs
	local saved_mobs = get_saved_mobs(self.mob_node.pos)
	
	-- Remove MOB
	saved_mobs[self.mob_number] = nil
	
	set_saved_mobs(self.mob_node.pos, saved_mobs)
	
	return true
end


-- Load MOB
local load_mobs = function(pos)
	
	-- Check node
	if not check_node(pos) then return false end
	
	-- Saved mobs
	local saved_mobs = get_saved_mobs(pos)
	
	for mob_number,data in pairs(saved_mobs) do
		local obj = minetest.add_entity(data.pos, data.mob_name, data.staticdata)
		local self = obj:get_luaentity()
		
		-- Execute custom callback
		local def = creatures.registered_mob_nodes[minetest.get_node(pos).name]
		if self and def.on_load_mob then
			def.on_load_mob(pos, self)
		end
	end
	
	-- Update last cleaning cycle
	minetest.get_meta(pos):set_float("cleaning_cycle", creatures.cleaning_cycle)
end


-- Check cleaning cycle
local valid_cleaning_cycle = function(pos)
	local meta = minetest.get_meta(pos)
	local last_cycle = meta:get_float("cleaning_cycle")
	
	if meta:get_string("started") == "" then
		last_cycle = creatures.cleaning_cycle
		meta:set_float("cleaning_cycle", creatures.cleaning_cycle)
		meta:set_string("started", "yes")
	end
	
	if last_cycle < creatures.cleaning_cycle then
		return false
	end
	return true
end


-- Register mob node
creatures.register_mob_node = function(mob_node, def)
	
	local mob_name = def.mob_name
	
	-- ABM
	minetest.register_abm{
		nodenames = {mob_node},
		interval = 5,
		chance = 1,
		action = function(pos)
			
			-- If removed all objects
			if valid_cleaning_cycle(pos) == true then return end
			
			-- Load MOBs
			load_mobs(pos)
		end
	}
	
	
	-- LBM
	minetest.register_lbm({
		name = ":"..mob_node.."_load",
		nodenames = {mob_node},
		run_at_every_load = true,
		action = function(pos, node)
			
			-- If removed all objects
			if valid_cleaning_cycle(pos) == true then return end
			
			-- Load MOBs
			load_mobs(pos)
		end,
	})
	
	
	-- Register 'on_die' callback
	creatures.register_on_die(mob_name, function(self, reason)
		if self.mob_node then
			remove_mob(self)
			self.mob_node = nil
		end
	end)
	
	
	-- Register 'get_staticdata'
	creatures.register_get_staticdata(mob_name, function(self)
		return {
			mob_node = self.mob_node,
		}
	end)
	
	
	-- Register 'on_get_staticdata'
	creatures.register_on_get_staticdata(mob_name, function(self, staticdata)
		if self.mob_node == nil then return end
		-- Update MOB pos when cleared
		save_mob(self, staticdata)
	end)
	
	
	-- Register 'on_clear_objects'
	creatures.register_on_clear_objects(mob_name, function(self, staticdata)
		if self.mob_node == nil then return end
		-- Update MOB pos when cleared
		save_mob(self)
	end)
	
	-- For child MOB
	if def.child then
		-- Register 'on_grow'
		creatures.register_on_grow(def.child.name, function(self, new_self) 
			
			-- Update MOB node
			if self.mob_node then
				new_self.mob_node = self.mob_node
				save_mob(new_self)
			end
			
		end)
	end
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		self.timers.mob_node = 10
		
	end)
	
	-- Register 'on_step'
	creatures.register_on_step(mob_name, function(self, dtime)
		
		-- Timer update
		self.timers.mob_node = self.timers.mob_node - dtime
		
		if self.timers.mob_node <= 0 then
			self.timers.mob_node = 10
			
			local me = self.object
			local my_pos = me:get_pos()
			
			-- With MOB node
			if self.mob_node then
				
				local dist = creatures.get_dist_p1top2(my_pos, self.mob_node.pos)
				
				-- Check mob node
				if dist < (def.search_radius or 10) 
					and check_node_from_node(self) == true
				then
					
					-- Reset lifetime
					self.lifetimer = 0
				
				-- Lose mob node
				else
					
					remove_mob(self)
					self.mob_node = nil
				end
			
			-- Without MOB node
			else
				-- Search a MOB node
				local p = minetest.find_node_near(my_pos, 8, {mob_node}, true)
				if p then
					-- Use this mob node
					self.mob_node = {
						pos = p,
					}
					save_mob(self)
				end
			end 
			
		end
	end)
	
	-- Registered mob nodes
	creatures.registered_mob_nodes[mob_node] = def
end

-- Get mob node definitions
creatures.get_mob_node_def = function(node_name)
	return creatures.registered_mob_nodes[node_name]
end

-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	-- Register MOB node
	if def.mob_node then 
		creatures.register_mob_node(def.mob_node.name, {
			mob_name = mob_name,
			on_save_mob = def.mob_node.on_save_mob,
			on_load_mob = def.mob_node.on_load_mob,
		})
	end
	
end)


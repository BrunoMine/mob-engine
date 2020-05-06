--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

register_mob.lua

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

-- Registered Mobs
creatures.registered_mobs = {}

-- MOB presets
creatures.registered_presets.mob = {}

-- Get MOB definitions
creatures.mob_def = function(self)
	return creatures.registered_mobs[self.mob_name]
end
creatures.get_def = creatures.mob_def

-- Organize a entity table for registration
local function entity_table(mob_name, def)
	
	def.stats = def.stats or {}
	
	-- Load MOB preset
	def = creatures.apply_preset(
		def, 
		def.mob_preset, 
		creatures.registered_presets.mob
	)
	
	local ent_def = {}
	
	-- Register call custom 'get_staticdata'
	if def.get_staticdata then creatures.register_get_staticdata(mob_name, def.get_staticdata) end
	-- Register call custom 'on_activate'
	if def.on_activate then creatures.register_on_activate(mob_name, def.on_activate) end
	-- Register call custom 'on_deactivate'
	if def.on_deactivate then creatures.register_on_deactivate(mob_name, def.on_deactivate) end
	-- Register call custom 'on_punch'
	if def.on_punch then creatures.register_on_punch(mob_name, def.on_punch) end
	-- Register call custom 'on_rightclick'
	if def.on_rightclick then creatures.register_on_rightclick(mob_name, def.on_rightclick) end
	-- Register call custom 'on_step'
	if def.on_step then creatures.register_on_step(mob_name, def.on_step) end
	
	-- Get staticdata
	ent_def.get_staticdata = function(self) 
		-- Registered callbacks
		return self:mob_get_staticdata() 
	end
	
	-- On activate
	ent_def.on_activate = function(self, staticdata)		
		
		-- Load registered callbacks tables
		for table_name,meta in pairs(creatures.registered_mobs[mob_name].meta_tables) do
			self[meta.index] = meta.data
		end
		
		-- MOB name
		self.mob_name = mob_name
		
		-- Timers
		self.timers = {}
		
		-- Immortal is needed to disable clientside smokepuff shit 
		self.object:set_armor_groups({fleshy = 100, immortal = 1})
		
		-- Registered callbacks
		return self:mob_on_activate(staticdata)
	end
	
	-- On Punch
	ent_def.on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		-- Registered callbacks
		return self:mob_on_punch(puncher, time_from_last_punch, tool_capabilities, dir)
	end
	
	-- On Rightclick
	ent_def.on_rightclick = function(self, clicker)
		-- Registered callbacks
		return self:mob_on_rightclick(clicker)
	end
	
	-- On Step
	ent_def.on_step = function(self, dtime)
		-- Registered callbacks
		return self:mob_on_step(dtime)
	end

	return ent_def
end


-- On register mob
creatures.registered_on_register_mob = {}
creatures.register_on_register_mob = function(func)
	table.insert(creatures.registered_on_register_mob, func)
end


-- Register a Mob
function creatures.register_mob(mob_name, mob_def) -- returns true if sucessfull
	if not mob_def or not mob_name then
		creatures.throw_error("Can't register mob. No name or Definition given.")
		return false
	end
	
	-- Registered mobs
	creatures.registered_mobs[mob_name] = mob_def
	
	-- Meta tables
	creatures.registered_mobs[mob_name].meta_tables = {}
	
	-- Organize entity table
	creatures.registered_mobs[mob_name].ent_def = entity_table(mob_name, mob_def)
	
	-- Run on_register_mob callback
	for _,f in ipairs(creatures.registered_on_register_mob) do
		f(mob_name, mob_def)
	end
	
	local entity_meta = {}
	
	-- Engine callbacks
	for i,f in pairs(creatures.entity_meta) do
		entity_meta[i] = f
	end
	
	-- Register Entity
	core.register_entity(mob_name, setmetatable(creatures.registered_mobs[mob_name].ent_def, {__index = entity_meta}))
	
	return true
end





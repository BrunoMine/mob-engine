--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

callbacks.lua

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


-- Create callbacks
creatures.create_mob_callback = function(call_name, def)
	
	-- Registration
	local register
	if def.register_type == "custom" then
		register = def.register
	
	-- Include call functions on 'registered_mobs'
	elseif def.register_type == "mob_functions" then
		register = function(mob_name, func)
	
			-- Check callback table
			if creatures.registered_mobs[mob_name][call_name.."_table"] == nil then
				creatures.registered_mobs[mob_name][call_name.."_table"] = {}
				
				-- Mark index for MOB meta table
				table.insert(creatures.registered_mobs[mob_name].meta_tables, {
					index = "mob_"..call_name.."_tb",
					data = creatures.registered_mobs[mob_name][call_name.."_table"]
				})
			end
			
			table.insert(creatures.registered_mobs[mob_name][call_name.."_table"], func)
		end
	end
	
	-- Execution
	local executer
	if def.executer_type == "custom" then
		executer = def.executer
	
	-- Run registered checker for a true
	elseif def.executer_type == "checker" then
		executer = function(self, ...)
			
			for _,f in ipairs(self["mob_"..call_name.."_tb"] or {}) do
				local r = f(self, ...)
				if r == true then
					return r
				end
			end
			
		end
	end
	
	-- Create register function
	creatures["register_"..call_name] = register
	
	-- Create executer function
	
	-- Create MOB callback on lua entity
	if def.executer_is_mob_callback == true then
		creatures.entity_meta["mob_"..call_name] = executer
	
	-- Create a simple executer function
	else
		creatures[call_name] = executer
	end
end


-- Register 'on_step'
creatures.create_mob_callback("on_step", {
	register_type = "mob_functions",
	
	executer_type = "custom",
	executer_is_mob_callback = true,
	executer = function(self, dtime)
		
		if self:mob_is_active() == false then return end
		
		if self.activated ~= true then return end
		
		-- Round dtime
		local rdtime = math.floor(dtime * 100) / 100 
		
		-- Run registered 'on_step'
		for _,f in ipairs(self.mob_on_step_tb or {}) do
			local r = f(self, rdtime)
			if r == true then
				return r
			end
		end
		
	end,
})


-- Register 'on_punch'
creatures.create_mob_callback("on_punch", {
	register_type = "mob_functions",
	
	executer_type = "checker",
	executer_is_mob_callback = true,
})


-- Register 'on_deactivate'
creatures.create_mob_callback("on_deactivate", {
	register_type = "mob_functions",
	
	executer_type = "checker",
	executer_is_mob_callback = true,
})


-- Register 'on_die'
creatures.create_mob_callback("on_die", {
	register_type = "mob_functions",
	
	executer_type = "checker",
	executer_is_mob_callback = true,
})


-- Register 'on_rightclick'
creatures.create_mob_callback("on_rightclick", {
	register_type = "mob_functions",
	
	executer_type = "checker",
	executer_is_mob_callback = true,
})


-- Register 'get_staticdata'
creatures.create_mob_callback("get_staticdata", {
	register_type = "mob_functions",
	
	executer_type = "custom",
	executer_is_mob_callback = true,
	executer = function(self, dtime)
		
		if self.activated == true then
			self:mob_on_deactivate()
		end
		self.activated = true
		
		-- Run registered 'get_staticdata'
		local data = {}
		
		for _,f in ipairs(self.mob_get_staticdata_tb) do
			local other_data = f(self)
			
			-- Merge results
			if other_data and type(other_data) == "table" then
				for s,w in pairs(other_data) do
					data[s] = w
				end
			end
		end
		
		return minetest.serialize(data)
		
	end,
})


-- Register 'on_activate'
creatures.create_mob_callback("on_activate", {
	register_type = "mob_functions",
	
	executer_type = "custom",
	executer_is_mob_callback = true,
	executer = function(self, staticdata)
		
		-- Restore Staticdata for entity
		if staticdata then
			local tab = core.deserialize(staticdata)
			if tab and type(tab) == "table" then
				for s,w in pairs(tab) do
					self[tostring(s)] = w
				end
			end
		end
		
		-- Run registered 'on_activate'
		for _,f in ipairs(self.mob_on_activate_tb or {}) do
			local r = f(self, staticdata)
			if r == true then
				return r
			end
		end
		
	end,
})


-- Register 'on_change_hp'
creatures.create_mob_callback("on_change_hp", {
	register_type = "mob_functions",
	
	executer_type = "custom",
	executer_is_mob_callback = true,
	executer = function(self, hp)
		
		-- Run registered 'on_change_hp'
		for _,f in ipairs(self.mob_on_change_hp_tb or {}) do
			local r, new_hp = f(self, hp)
			if new_hp then
				hp = new_hp
			end
			if r == true then
				return r, hp
			end
		end
		
		return true, hp
		
	end,
})


-- Register 'on_clear_objects'
creatures.create_mob_callback("on_clear_objects", {
	register_type = "mob_functions",
	
	executer_type = "checker",
	executer_is_mob_callback = true,
})


-- Execute 'on_clear_objects'
local old_clear = minetest.clear_objects
minetest.clear_objects = function(...)
	
	-- Run registered 'on_clear_objects'
	for obj_id,self in pairs(minetest.luaentities) do
		if self.mob_name and creatures.registered_mobs[self.mob_name] then
			self:mob_on_clear_objects()
		end
	end
	
	return old_clear(...)
end


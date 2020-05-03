--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

mating.lua

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

-- Indexed methods
local find_target = creatures.find_target
local random = math.random
local total = table.maxn
local get_day_count = minetest.get_day_count


-- Register 'is_fertile'
creatures.create_mob_callback("is_fertile", {
	register_type = "mob_functions",
	
	executer_type = "custom",
	executer_is_mob_callback = true,
	executer = function(self)
		
		local def = creatures.mob_def(self)
		
		-- Check fertile
		if (not def.mating) or self.mating_last_day + def.mating.interval > get_day_count() then 
			return false 
		end
		
		-- Run registered 'is_fertile'
		for _,f in ipairs(self.mob_is_fertile_tb or {}) do
			local r = f(self)
			if r == false then
				return false
			end
		end
		
		return true
		
	end,
})


-- Register 'spawn_child'
creatures.create_mob_callback("spawn_child", {
	register_type = "mob_functions",
	
	executer_type = "checker",
	executer_is_mob_callback = true,
})


-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	if not def.mating then return end
	
	-- Check MOB child name
	if def.mating.child_mob == nil then
		def.mating.child_mob = def.child.name
	end
	
	-- Register 'get_staticdata'
	creatures.register_get_staticdata(mob_name, function(self)
		
		return {
			mating_last_day = self.mating_last_day,
		}
		
	end)
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		self.mating_last_day = self.mating_last_day or minetest.get_day_count()
		
		self.timers.mating = random(5.01, (self:mob_actfac_time(15)+0.01))
		
	end)
	
	-- Register 'on_step'
	creatures.register_on_step(mob_name, function(self, dtime)
		
		-- Timer update
		self.timers.mating = self.timers.mating - dtime
		
		if self.timers.mating <= 0 then
			self.timers.mating = self:mob_actfac_time(15)
			
			-- Check if interval is elapsed
			if self:mob_is_fertile() == false then 
				return 
			end
			
			-- Search another MOB to mating
			local mobs = find_target(self.current_pos, 6, {
					xray = false, 
					no_count = false, 
					search_type = "mate", 
					mob_name = mob_name, 
				}
			)
			
			-- Check MOBs
			local fertile_mobs = {}
			for _,obj in ipairs(mobs) do
				local ent = obj:get_luaentity()
				if ent.mob_is_fertile and ent:mob_is_fertile() == true then
					table.insert(fertile_mobs, ent)
				end
			end
			
			if table.maxn(fertile_mobs) >= 2 then
				-- Random number of childs for spawn
				local c = math.ceil((total(fertile_mobs) * (def.mating.birth_multiplier or 0.5)))
				
				while c > 0 do
					-- Spawn child
					self:mob_spawn_child()
					c = c - 1
				end
				for _,entity in ipairs(fertile_mobs) do
					entity.mating_last_day = minetest.get_day_count()
				end
			end
			
		end
	end)
	
end)

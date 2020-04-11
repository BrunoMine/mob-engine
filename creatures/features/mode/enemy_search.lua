--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

enemy_search.lua

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

-- Methods
local random = math.random
local start_mode = creatures.start_mode
local find_target = creatures.find_target
local get_vision_pos = creatures.get_vision_pos

-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	if not def.combat then return end
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		-- Timer
		self.timers.enemy_search = random(1.01, (self:mob_actfac_time(def.combat.search_timer)+1.01))
		
	end)
	
	-- Register 'on_step'
	creatures.register_on_step(mob_name, function(self, dtime)
		
		-- Timer update
		self.timers.enemy_search = self.timers.enemy_search - dtime
		
		-- if elapsed timer
		if self.timers.enemy_search <= 0 then
			self.timers.enemy_search = self:mob_actfac_time(def.combat.search_timer)
			
			-- Current mode
			if self.mode ~= "idle" then return end
			
			-- Action factor
			if self:mob_actfac_bool(1.2) == false then return end
			
			-- Search a target (1-2ms)
			if 
				-- has no target yet
				not self.target 
				-- and is a hostile
				and (self.stats.hostile and def.combat.search_enemy)
				-- and not in "panic" mode
				and self.mode ~= "panic" 
			then 
				
				local current_pos = self.object:getpos()
				current_pos.y = current_pos.y + 0.5
				
				-- targets list
				local targets = find_target(get_vision_pos(self), def.combat.search_radius, {
					search_type = def.combat.search_type, 
					mob_name = def.combat.search_name, 
					xray = def.combat.search_xray,
					ignore_obj = {self.object},
				})
				
				-- choose a random target
				if #targets > 1 then
					self.target = targets[random(1, #targets)]
				elseif #targets == 1 then
					self.target = targets[1]
				end
				
				-- if a target was found
				if self.target then
					
					-- change mode
					start_mode(self, "attack")
				end
			end
		end
	end)
	
end)

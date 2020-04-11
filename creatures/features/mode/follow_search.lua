--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

follow_search.lua

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
local hasMoved = creatures.compare_pos
local find_target = creatures.find_target
local start_mode = creatures.start_mode
local get_vision_pos = creatures.get_vision_pos

-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	if not def.modes.follow then return end
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		-- Timer
		self.timers.follow_search = random(1.01, (self:mob_actfac_time(def.modes.follow.search_timer)+1.01))
		
	end)
	
	-- Register 'on_step'
	creatures.register_on_step(mob_name, function(self, dtime)
		
		self.timers.follow_search = self.timers.follow_search - dtime
		
		if self.timers.follow_search <= 0 then
			self.timers.follow_search = self:mob_actfac_time(def.modes.follow.search_timer)
			
			-- Current mode
			if self.mode ~= "idle" then return end
			
			-- Action factor
			if self:mob_actfac_bool(1.2) == false then return end
			
			local current_pos = self.object:get_pos()
			current_pos.y = current_pos.y + 0.5
			
			-- Search a target
			if 
				-- if not target yet
				not self.target 
			then
					
				-- if a target was found
				for _,target in ipairs(find_target(get_vision_pos(self), (def.modes.follow.radius or 5), {
					search_type = "player",
					ignore_obj = {self.object}
				})) do
					
					-- change mode
					-- check target wielded item
					local name = target:get_wielded_item():get_name()
					if name and def.modes.follow.items[name] == true then
						self.target = target
						start_mode(self, "follow")
					end
				end
			end
		end
	end)
	
end)

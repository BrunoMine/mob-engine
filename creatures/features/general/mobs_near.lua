--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

mobs_near.lua

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

-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		-- Timer
		self.timers.mobs_near = math.random(0.1, 5)
		
		self.mobs_near = 0
		
	end)
	
	-- Register 'on_step'
	creatures.register_on_step(mob_name, function(self, dtime)
		
		self.timers.mobs_near = self.timers.mobs_near - dtime
			
		if self.timers.mobs_near <= 0 then
			self.timers.mobs_near = 5
			
			self.mobs_near = #creatures.find_target(self.object:get_pos(), 4, {
				search_type = "all", 
				xray = true,
			})
			
			self.mobs_near = self.mobs_near - 1
			
			-- Choose a time for update
			if self.mobs_near < 8 then
				self.timers.mobs_near = math.random(4, 6)
			elseif self.mobs_near < 15 then
				self.timers.mobs_near = math.random(7, 9)
			elseif self.mobs_near < 20 then
				self.timers.mobs_near = math.random(9, 11)
			else
				self.timers.mobs_near = math.random(19, 21)
			end
			
		end
		
	end)
	
end)

--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

fallen.lua

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
	
	def.stats.has_falldamage = def.stats.has_falldamage or true
	
	if def.stats.has_falldamage == false then return end
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		local current_pos = self.object:get_pos()
		
		local next_time = math.random(0.01, creatures.action_factor_time(self, 0.2, 2))
		
		-- Set fall settings
		self.fall = {}
		self.fall.time = next_time
		self.fall.y = current_pos.y
		self.fall.last_y = current_pos.y
		
		-- Params
		def.stats.max_drop = def.stats.max_drop or 2
		
		self.timers.fall = next_time
	end)
	
	-- Register 'on_step'
	creatures.register_on_step(mob_name, function(self, dtime)
		
		-- Timer update
		self.timers.fall = self.timers.fall - dtime
		
		if self.timers.fall <= 0 then
			
			local next_time = creatures.action_factor_time(self, 0.2, 2)
			
			local current_pos = self.object:get_pos()
			
			-- If falling
			if current_pos.y < self.fall.last_y then
				
				-- Update falling data
				self.fall.time = self.fall.time + next_time
				self.fall.y = self.fall.y or current_pos.y
				self.fall.last_y = current_pos.y
				
				
			-- If not falling
			else
				
				-- If finish fall
				if (self.fall.y - self.fall.last_y) > 3 and not self.in_water then
					
					local dist = self.fall.y - current_pos.y
					local time = self.fall.time
					local damage = 0
					
					if time/dist < 0.2 then
						damage = dist - 3
					end
					
					if damage > 0 then
						creatures.change_hp(self, (damage * -1), "fall")
					end
					
				end
				
				-- Reset falling data
				self.fall.time = next_time
				self.fall.y = current_pos.y
				
			end
			
			self.timers.fall = next_time
		end
	end)
	
end)

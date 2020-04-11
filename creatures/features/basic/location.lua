--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

location.lua

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
		self.timers.pos = 0
		
		self.last_node = {name="ignore"}
		self.last_pos = self.object:get_pos()
		self.current_node = {name="ignore"}
		self.current_pos = self.object:get_pos()
		
		
	end)
	
	-- Register 'on_step'
	creatures.register_on_step(mob_name, function(self, dtime)
		
		-- Timer update
		self.timers.pos = self.timers.pos + dtime
		
		if self.timers.pos >= 0.5 then
			self.timers.pos = 0
			
			-- localize some things
			local current_pos = self.object:get_pos()
			
			if not vector.equals(current_pos, self.last_pos) then
				
				-- Update last locate
				self.last_pos = current_pos
				self.last_node = self.current_node
				self.last_light = minetest.get_node_light(self.last_pos)
				
				self.current_pos = self.object:get_pos()
				self.current_node = core.get_node_or_nil(current_pos)
			end
			
		end
	end)
	
end)

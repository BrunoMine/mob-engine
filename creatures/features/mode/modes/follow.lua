--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

follow.lua

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


-- Follow mode ("follow")
creatures.register_mode("follow", {

	-- On start
	start = function(self)
		
		-- Timer
		self.mdt.follow = 0
		self.mdt.follow_walk = 0
	end,
	
	-- On step
	on_step = function(self, dtime)
		
		-- Check target
		if not self.target then
			self.mode = ""
			return
		end
		
		-- Timer update
		self.mdt.follow = self.mdt.follow + dtime
		self.mdt.follow_walk = self.mdt.follow_walk + dtime
		
		if self.mdt.follow > 0.5 then
			self.mdt.follow = 0
			
			-- localize some things
			local mode_def = creatures.mode_def(self)
			local current_mode = self.mode
			local current_pos = self.object:getpos()
			current_pos.y = current_pos.y + 0.5
			
			-- Check target
			if not self.target
				or not (mode_def.items and mode_def.items[self.target:get_wielded_item():get_name()] == true)
			then 
				self.target = nil
				creatures.start_mode(self, "idle")
				return
			end
			
			-- Target values
			local p2 = self.target:getpos()
			
			local dist = creatures.get_dist_p1top2(current_pos, p2)
			
			-- Max distance radius for have a target
			local radius = mode_def.radius
			
			-- Check if target is too far
			if dist == -1 or dist > (radius or 5) then
				self.target = nil
				creatures.start_mode(self, "idle")
				return
			end
			
			-- Walk or run to the target
			if self.mdt.follow_walk > 1 then
				self.mdt.follow_walk = 0
				
				creatures.set_dir(self, creatures.get_dir_p1top2(current_pos, p2))
				creatures.send_in_dir(self, mode_def.moving_speed)
				creatures.set_animation(self, "walk")
			end
		end
	end,
})


-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)

	if not def.modes.follow then return end
	
	if def.modes.follow.items then
		creatures.register_on_rightclick(mob_name, function(self, clicker)
			local mode_def = creatures.mode_def(self, "follow")
			if mode_def.items[clicker:get_wielded_item():get_name()] == true then
				self.target = clicker
				creatures.start_mode(self, "follow")
			end
		end)
	end
	
end)


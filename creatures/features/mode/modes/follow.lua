--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors
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
		
		local mode_def = creatures.mode_def(self)
		
		-- Timer
		self.mdt.follow = math.random(0, 5)
		self.mdt.follow_walk = math.random(0, creatures.action_factor_time(self, 0.3))
		
		self.mode_vars.speed = mode_def.moving_speed
	end,
	
	-- On step
	on_step = function(self, dtime)
		
		-- Check target
		if not self.target then
			creatures.start_mode(self, "idle")
			return
		end
		
		self.mdt.follow = self.mdt.follow + dtime
		
		-- Check follow mode
		if self.mdt.follow > 5 then
			self.mdt.follow = 0
			
			-- localize some things
			local mode_def = creatures.mode_def(self)
			local current_mode = self.mode
			local current_pos = self.object:get_pos()
			current_pos.y = current_pos.y + 0.5
			
			-- Check target item
			if mode_def.items and not mode_def.items[self.target:get_wielded_item():get_name()] == true then 
				self.target = nil
				creatures.start_mode(self, "idle")
				return
			end
			
			-- Check target distance
			local dist = creatures.get_dist_p1top2(current_pos, self.target:get_pos())
			local max_dist = mode_def.radius
			
			-- Check if target is too far
			if dist == -1 or dist > (max_dist or 5) then
				self.target = nil
				creatures.start_mode(self, "idle")
				return
			end
			
		end
		
		
		self.mdt.follow_walk = self.mdt.follow_walk - dtime
		
		-- Walk or run to the target
		if self.mdt.follow_walk <= 0 then
			self.mdt.follow_walk = creatures.action_factor_time(self, 0.3)
			
			creatures.set_dir(self, creatures.get_dir_p1top2(self.object:get_pos(), self.target:get_pos()))
			creatures.send_in_dir(self, self.mode_vars.speed)
			creatures.set_animation(self, "walk")
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


--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

walk_around.lua

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
	
		self.mdt.walk_around = 0
		self.walk_around_time = 0
	end)
	
end)


-- On finish path
local on_finish_path = function(self)
	-- Stop movement
	self:mob_go_dir(0, {x=0,z=0})
	-- Stop walk animation
	creatures.set_animation(self, "idle")
end


-- Methods
local get_nodes = creatures.get_under_walkable_nodes_in_area
local p1top2 = creatures.get_dir_p1top2
local random = creatures.get_random_from_table
local start_mode = creatures.start_mode
local minp = vector.subtract
local maxp = vector.add
local total = table.maxn

-- Walk Around mode ("walk_around")
creatures.register_mode("walk_around", {
	
	-- On start
	start = function(self)
		
		local current_pos = self.object:get_pos()
		current_pos = vector.round(current_pos)
		
		if self:mob_actfac_bool(0.8) == false then
			start_mode(self, "idle")
			return 
		end
		
		-- Get walkable nodes
		local nodes = get_nodes(
			minp(current_pos, 1), 
			maxp(current_pos, 1)
		)
		
		for i,p in ipairs(nodes) do
			if p.x == current_pos.x and p.z == current_pos.z then
				table.remove(nodes, i)
				break
			end
		end
		
		local t = total(nodes)
		
		-- Check walkable nodes
		if t <= 0 then
			-- Finish mode
			start_mode(self, "idle")
			return
		end
		
		local pos
		
		if t == 1 then
			pos = nodes[1]
		else
			pos = random(nodes)
		end
		
		-- Walk 1 node in any direction
		local new_dir = p1top2(current_pos, pos)
		
		-- Check new dir
		if not new_dir then 
			-- Finish mode
			start_mode(self, "idle")
			return
		end
		
		self:mob_set_dir(new_dir)
		
		local walk_time = 1/self.mode_def.moving_speed
		
		-- Time to end mode
		self.mdt.walk = walk_time
		self.modetimer = walk_time + 0.2
		
		-- Send
		self:mob_go_dir(self.mode_def.moving_speed)
		self:mob_set_anim("walk")
		
	end,
	
	-- On step
	on_step = function(self, dtime)
		
		self.mdt.walk = self.mdt.walk - dtime
		
		if self.mdt.walk <= 0 then
			self.mdt.walk = 1
			
			-- Stop movement
			self:mob_go_dir(0, {x=0,z=0})
			-- Stop walk animation
			creatures.set_animation(self, "idle")
			
		end
	end,
	
})



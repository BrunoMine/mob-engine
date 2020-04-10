--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

walk.lua

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
local start_mode = creatures.start_mode
local get_under = creatures.get_under_walkable_nodes_in_area
local int = math.floor
local total = table.maxn
local new_path = creatures.new_path
local random = creatures.get_random_from_table
local minp = vector.subtract
local maxp = vector.add
local get_def = creatures.get_def

-- On finish path
local on_finish_path = function(self)
	-- Stop movement
	self:mob_go_dir(0, {x=0,z=0})
	-- Stop walk animation
	self:mob_set_animation("idle")
end

-- Walk mode ("walk")
creatures.register_mode("walk", {
	
	-- On start
	start = function(self)
		
		-- If Search a node
		if self.mode_def.search_radius then
			
			if self:mob_actfac_bool(300) == false then
				start_mode(self, "idle")
				return 
			end
			
			local mode_def = self.mode_def
			
			local mob_def = get_def(self)
			
			local current_pos = self.object:get_pos()
			current_pos.y = current_pos.y + 0.5
			
			-- [PROBLEM!] Causes performance issues above 100 MOBs
			
			local search_radius = mode_def.search_radius
			local nodes = get_under(
				{ -- min pos
					x = current_pos.x - search_radius,
					y = current_pos.y - int(mob_def.stats.can_jump),
					z = current_pos.z - search_radius,
				}, 
				{ -- max pos
					x = current_pos.x + search_radius,
					y = current_pos.y + int(mob_def.stats.can_jump),
					z = current_pos.z + search_radius,
				}
			)
			
			-- Try find a path
			local p = random(nodes, true)
			
			if new_path(
				self, 
				p, 
				{
					speed = mode_def.moving_speed,
					on_finish = on_finish_path,
					on_interrupt = on_finish_path,
					search_def = {
						max_jump = int(mob_def.stats.can_jump),
						search_radius = mode_def.search_radius,
						time_to_find = 0.08,
					}
				}
			) == true then
				
				-- Start walk animation
				self:mob_mode_set_anim()
			end
			
			-- Check if there is no path
			if self.path.status == false then
				-- Finish mode
				start_mode(self, "idle")
			end
		
		-- Random dir
		else
			-- Set random dir
			self:mob_random_dir()
			
			-- Start movement
			self:mob_go_dir(mode_def.moving_speed)
			
			-- Update animation
			self:mob_mode_set_anim()
		end
	end,
	
	-- On step
	on_step = function(self, dtime)
		
		return self:mob_path_step(dtime)
		
	end,
})



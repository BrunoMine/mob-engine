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
		
		local def_mode = creatures.mode_def(self)
		
		-- If Search a node
		if def_mode.search_radius then
			
			local mob_def = creatures.get_def(self)
			
			local current_pos = self.object:getpos()
			current_pos.y = current_pos.y + 0.5
			
			local search_radius = def_mode.search_radius
			local nodes = creatures.get_under_walkable_nodes_in_area(
				{ -- min pos
					x = current_pos.x - search_radius,
					y = current_pos.y - math.floor(mob_def.stats.can_jump),
					z = current_pos.z - search_radius,
				}, 
				{ -- max pos
					x = current_pos.x + search_radius,
					y = current_pos.y + math.floor(mob_def.stats.can_jump),
					z = current_pos.z + search_radius,
				}
			)
			
			-- Try find path
			local n = table.maxn(nodes)
			if n > 3 then n = 3 end
			while n > 0 do
				
				local p
				p, nodes = creatures.get_random_from_table(nodes, true)
				
				if creatures.new_path(
					self, 
					{x=p.x, y=p.y, z=p.z}, 
					{
						speed = def_mode.moving_speed,
						on_finish = on_finish_path,
						on_interrupt = on_finish_path,
						search_def = {
							max_jump = math.floor(mob_def.stats.can_jump),
							search_radius = def_mode.search_radius,
							time_to_find = 0.08,
						}
					}
				) == true then
					
					-- Start walk animation
					self:mob_mode_set_anim()
					break
				end
				
				n = n - 1
			end
			
			-- Check if there is no path
			if self.path.status == false then
				-- Finish mode
				creatures.start_mode(self, "idle")
			end
		
		-- Random dir
		else
			-- Set random dir
			self:mob_random_dir()
			
			-- Start movement
			self:mob_go_dir(def_mode.moving_speed)
			
			-- Update animation
			self:mob_mode_set_anim()
		end
	end,
	
	-- On step
	on_step = function(self, dtime)
		
		return self:mob_path_step(dtime)
		
	end,
})



--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2019 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

hunger.lua

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


-- Check path
exists_path = function(self, target_pos, def)
	
	if creatures.find_path(
		self, 
		target_pos, 
		{ 
			search_distance = 8, 
			max_jump = def.stats.can_jump or 1, 
			max_drop = def.stats.max_drop or 2,
		}
	) then
		return true
	end
	
	return false
end


-- Eat nodes near
local eat_nodes_near = function(self, nodes, def)
	
	local pos = self.object:get_pos()
	
	for _,target_pos in ipairs(minetest.find_nodes_in_area(
		{x=pos.x-8, y=pos.y-2, z=pos.z-8}, 
		{x=pos.x+8, y=pos.y+2, z=pos.z+8}, 
		nodes
	)) do
		
		if exists_path(self, target_pos, def) == true then
			return true, target_pos
		end
	end
	
	return false
end


-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	if not def.hunger then return end
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		self.satiated = self.satiated or true
		self.last_satiated_day = self.last_satiated_day or minetest.get_day_count()
		self.hunger_activated = false
		
		-- Timer
		self.timers.hunger = math.random(8, self:mob_actfac_time(10, 2))
		
	end)
	
	-- Register 'on_step'
	creatures.register_on_step(mob_name, function(self, dtime)
		
		
		self.timers.hunger = self.timers.hunger - dtime
		
		if self.timers.hunger <= 0 then
			self.timers.hunger = math.random(8, self:mob_actfac_time(10, 2))
			
			-- If wild then ignore hunger
			if self.is_wild == true then
				return
			end
			
			local mob_def = creatures.mob_def(self)
			
			if not mob_def.hunger then return end
			
			-- Update day for eat
			local days = minetest.get_day_count() - self.last_satiated_day
			
			local thirsty = false
			local hungry = false
			
			while (days >= mob_def.hunger.days_interval) do
				-- If need water
				if mob_def.hunger.water then
					local eat, node_pos = eat_nodes_near(self, mob_def.hunger.water_nodes or {"group:water"}, def)
					if eat == false then
						thirsty = true
					end
				end
				
				-- If need food
				if mob_def.hunger.food then
					local eat, node_pos = eat_nodes_near(self, mob_def.hunger.food.nodes, def)
					if eat == false then
						hungry = true
					end
					-- Check feeder
					if node_pos then 
						if creatures.registered_feeder_nodes[minetest.get_node(node_pos).name] then
							creatures.set_feeder_level(node_pos, -1)
						else
							minetest.remove_node(node_pos)
						end
					end
				end
				
				if hungry == false and thirsty == false then
					days = days - mob_def.hunger.days_interval
				else
					break
				end
			end
			
			-- Update satiated status
			if days > mob_def.hunger.days_interval then
				self.satiated = false
			else
				self.satiated = true
			end
			
			-- Check if kill MOB
			if hungry == true then
				if self.hunger_activated == false then
					self.object:remove()
				else
					creatures.kill_mob(self, "creatures:hungry")
				end
			elseif thirsty == true then
				if self.hunger_activated == false then
					self.object:remove()
				else
					creatures.kill_mob(self, "creatures:thirsty")
				end
			end
			
			self.last_satiated_day = minetest.get_day_count() - days
			self.hunger_activated = true
		end
	end)
	
	-- Register 'get_staticdata'
	creatures.register_get_staticdata(mob_name, function(self)
		return {
			satiated = self.satiated,
			last_satiated_day = self.last_satiated_day,
		}
	end)
	
end)

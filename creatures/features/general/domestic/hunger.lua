--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors
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

-- Methods
local get_day_count = minetest.get_day_count
local set_feeder_level = creatures.feeder.modify_level
local find_nodes_in_area = minetest.find_nodes_in_area
local find_path = creatures.find_path
local remove_node = minetest.remove_node
local kill_mob = creatures.kill_mob

-- Global tables
registered_feeder_nodes = creatures.registered_feeder_nodes

-- Check path
exists_path = function(self, target_pos, def)
	
	if find_path(
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
local eat_nodes_near = function(self, find_nodes)
	
	local pos = self.current_pos
	
	local nodes = find_nodes_in_area(
		{x=pos.x-8, y=pos.y-2, z=pos.z-8}, 
		{x=pos.x+8, y=pos.y+2, z=pos.z+8}, 
		find_nodes
	)
	
	for _,target_pos in ipairs(nodes) do
		if creatures.mob_sight(self, target_pos, { ignore_all_obj=true, target_is_node=true }) == true then
			return target_pos
		end
	end
end


-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	if not def.hunger then return end
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		self.last_satiated_day = self.last_satiated_day or get_day_count()
		self.hunger_activated = false
		
		-- Timer
		self.timers.hunger = math.random(8, self:mob_actfac_time(10))
		
	end)
	
	-- Register 'on_step'
	creatures.register_on_step(mob_name, function(self, dtime)
		
		self.timers.hunger = self.timers.hunger - dtime
		
		if self.is_wild ~= true and self.timers.hunger <= 0 then
			self.timers.hunger = self:mob_actfac_time(10, 2)
			
			local thirsty = false
			local hungry = false
			
			
			-- If need water
			if def.hunger.water then
				
				thirsty = true
				
				-- Search water
				local water_pos = eat_nodes_near(self, def.hunger.water.nodes)
				if water_pos then
					thirsty = false
				end
			end
			
			
			-- If need food
			if def.hunger.food then
				
				-- Days interval
				local days_interval = def.hunger.days_interval
				
				-- Days to saciate
				local days = get_day_count() - self.last_satiated_day
				
				-- Check if hungry
				if days >= def.hunger.days_interval then
					hungry = true
				end
				
				-- Food node
				local food_pos = eat_nodes_near(self, def.hunger.food.nodes)
				
				while hungry == true and food_pos do
				
					-- Is feeder node
					if registered_feeder_nodes[minetest.get_node(food_pos).name] then
						
						-- Food units to eat
						local food_to_eat = math.floor(days/days_interval)
						
						set_feeder_level(food_pos, (food_to_eat * -1))
						
						-- Update days
						days = days - (food_to_eat * days_interval)
						
					-- Is food node
					else
						
						remove_node(food_pos)
						
						-- Update days
						days = days - days_interval
					end
					
					-- Try find food or feeder node
					food_pos = eat_nodes_near(self, def.hunger.food.nodes)
					
					-- Update hungry status
					if days < days_interval then
						hungry = false
					end
				end
				
				-- Update last saciated day
				self.last_satiated_day = get_day_count() - days
				
			end
			
			
			-- Check if kill MOB
			if hungry == true then
				if self.hunger_activated == false then
					self.object:remove()
				else
					kill_mob(self, "creatures:hungry")
				end
			
			elseif thirsty == true then
				if self.hunger_activated == false then
					self.object:remove()
				else
					kill_mob(self, "creatures:thirsty")
				end
			end
			
			self.hunger_activated = true
		end
	end)
	
	-- Register 'get_staticdata'
	creatures.register_get_staticdata(mob_name, function(self)
		return {
			last_satiated_day = self.last_satiated_day,
		}
	end)
	
end)

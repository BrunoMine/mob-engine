--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

attack.lua

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

-- Follow time
local follow_time = 0.5


-- On finish path
local on_finish_path = function(self)
	-- Stop movement
	creatures.send_in_dir(self, 0, {x=0,y=0,z=0}, self.can_fly)
	creatures.set_animation(self, "idle")
end

-- On interrupt path
local on_interrupt_path = function(self)
	-- Stop movement
	creatures.send_in_dir(self, 0, {x=0,y=0,z=0}, self.can_fly)
	creatures.set_animation(self, "idle")
end

-- Check step
local check_step = function(self, step_pos, target_pos)
	if creatures.get_dist_p1top2(step_pos, target_pos) > 2 then 
		return true 
	end
	
	-- Vision height pos
	local vision_pos = creatures.get_vision_pos(self, step_pos)
	local r = creatures.mob_sight(vision_pos, self.target, {physical_access=true})
	return r
end

-- Enable to punch target
local enable_punch = function(self)
	if not self then return end
	self.mode_vars.can_punch = true
end

-- Enable to find path
local enable_to_find_path = function(self)
	if not self then return end
	self.mode_vars.can_find_path = true
end

-- Reset target memory
local reset_target_memory = function(self, memory_number)
	if self and self.mode_vars.target_memory == memory_number then
		self.mode_vars.target_memory = 0
	end
end

-- Rotate to target
local rotate_to_target = function(self, current_pos, target_pos)
	-- Rotate
	local new_dir = creatures.get_dir_p1top2(current_pos, target_pos, self.can_fly)
	if new_dir then
		--[[ 
			WARNING: For some totally unknown reason. 
			The object is rotated -90 degrees in this attack mode only. 
			Third parameter fix this temporarily.
		]]
		creatures.set_dir(self, new_dir, 90)
	end
end


-- Attack mode ("attack")
creatures.register_mode("attack", {
	
	-- On start
	start = function(self)
		-- Random dir
		creatures.set_dir(self, creatures.get_random_dir())
		-- Update mode settings
		creatures.mode_velocity_update(self)
		creatures.mode_animation_update(self)
		
		-- Ready for start a path
		self.mdt.attack = 0
		
		-- first target memory
		self.mode_vars.target_memory = 1
		core.after(5, reset_target_memory, self, 1)
		
		self.mode_vars.can_find_path = true
		self.mode_vars.can_punch = true
	end,
	
	-- On step
	on_step = function(self, dtime)
		
		-- Execute path step
		creatures.path_step(self, dtime)
		
		self.mdt.attack = self.mdt.attack + dtime
		if self.mdt.attack < 0.10 then
			return
		end
		self.mdt.attack = 0
		
		-- Check target
		if not self.target or not self.target:get_pos() then
			self.target = nil
			self.path.status = false
			creatures.start_mode(self, "idle")
			return
		end
		
		-- localize some things
		local def = creatures.registered_mobs[self.mob_name]
		local def_mode = creatures.mode_def(self)
		local modes = def.modes
		local current_mode = self.mode
		local me = self.object
		local current_pos = me:get_pos()
		current_pos.y = current_pos.y + 0.5
		local moved = self.moved
		
		-- Timer updates
		self.mdt.attack = self.mdt.attack + dtime
		
		-- Target values
		local target_pos = self.target:get_pos()
		local dist = creatures.get_dist_p1top2(current_pos, target_pos)
		
		--
		-- Check if can hit target now
		--
		
		-- Check attack distance
		if dist < def.combat.attack_radius 
			and creatures.mob_sight(self, self.target, {physical_access=true}) == true -- Check line of sight
		then
			-- Stop movement
			self.path.status = false
			creatures.send_in_dir(self, 0, {x=0,y=0,z=0}, self.can_fly)
			if self.animation ~= "attack" then
				creatures.set_animation(self, "attack")
			end
			
			-- Rotate
			rotate_to_target(self, current_pos, target_pos)
			
			-- Check punch interval
			if self.mode_vars.can_punch == true then
				
				self.mode_vars.can_punch = false
				core.after(def.combat.attack_hit_interval, enable_punch,  self)
				-- Attack
				self.target:punch(me, 1.0,  {
					full_punch_interval = def.combat.attack_hit_interval,
					damage_groups = {fleshy = def.combat.attack_damage}
				})
			end
			
			return 
		end
		
		--
		-- Check if can walk to target
		--
		
		-- Check if target is too far
		if dist > def.combat.search_radius then 
			self.target = nil
			self.path.status = false
			creatures.start_mode(self, "idle")
			return
		end
		
		-- Check memory
		if self.mode_vars.target_memory == 0 then
			self.target = nil
			self.path.status = false
			creatures.start_mode(self, "idle")
			return
		end
		
		-- More target values
		local see_target = creatures.mob_sight(self, self.target)
		
		-- Check target memory
		if see_target == true then
			-- Reload target memory
			local memory_number = self.mode_vars.target_memory + 1
			self.mode_vars.target_memory = memory_number
			core.after(5, reset_target_memory, self, memory_number)
		end
			
		if self.can_fly == true then
		
			-- Fly to target
			rotate_to_target(self, current_pos, target_pos)
			creatures.send_in_dir(self, def_mode.moving_speed, self.dir, self.can_fly)
			return
		
		end
		
		-- Can try find a path
		if self.path.status == false and self.mode_vars.can_find_path == true then
			self.mode_vars.can_find_path = false
			core.after(3, enable_to_find_path, self)
			
			-- New path
			if creatures.new_path(
				self, 
				creatures.get_node_pos_object(self.target), 
				{
					speed = def_mode.moving_speed,
					on_finish = on_finish_path,
					on_interrupt = on_interrupt_path,
					search_def = {
						target_dist = 2,
						check_step = check_step,
					},
				}
			) == true then
				creatures.set_animation(self, "attack")
			end
		end
		
		if self.path.status == false then
		
			-- Stand rotated to target
			creatures.send_in_dir(self, 0, {x=0,y=0,z=0}, self.can_fly)
			rotate_to_target(self, current_pos, target_pos)
			if self.animation ~= "idle" then
				creatures.set_animation(self, "idle")
			end
		end
		
	end,
})

creatures.register_on_hitted(function(self, puncher, time_from_last_punch, tool_capabilities, dir)

	if self.hostile == true then
		
		-- change mode
		self.target = puncher
		creatures.start_mode(self, "attack")
	end
end)



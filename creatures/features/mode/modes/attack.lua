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
	self:mob_go_dir(0, {x=0,y=0,z=0}, self.can_fly)
	self:mob_set_anim("idle")
end

-- On interrupt path
local on_interrupt_path = function(self)
	-- Stop movement
	self:mob_go_dir(0, {x=0,y=0,z=0}, self.can_fly)
	self:mob_set_anim("idle")
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
		self:mob_set_dir(new_dir, 90)
	end
end

-- Get time to hit
local get_time_to_punch = function(self)
	local time = (creatures.get_dist_p1top2(self.object:get_pos(), self.target:get_pos()) / (self.mode_vars.moving_speed/0.8))
	if time > 4 then time = 4 end
	if time < self.mode_vars.combat.attack_hit_interval then time = self.mode_vars.combat.attack_hit_interval end
	return time
end

-- Get target distance
local get_target_dist = function(self)
	return creatures.get_dist_p1top2(self.object:get_pos(), self.target:get_pos())
end

-- Get current pos
local get_current_pos = function(self)
	local current_pos = self.object:get_pos()
	current_pos.y = current_pos.y + 0.5
	return current_pos
end

-- Attack mode ("attack")
creatures.register_mode("attack", {
	
	-- On start
	start = function(self)
		
		local mob_def = creatures.mob_def(self)
		local mode_def = creatures.mode_def(self)
		
		-- Update mode settings
		creatures.mode_velocity_update(self)
		creatures.mode_animation_update(self)
		
		-- first target memory
		self.mode_vars.target_memory = 1
		minetest.after(5, reset_target_memory, self, 1)
		
		-- Target
		self.mode_vars.can_find_path = true
		
		-- Attack definitions
		self.mode_vars.combat = mob_def.combat
		self.mode_vars.moving_speed = mode_def.moving_speed
		
		-- Punch
		self.mdt.punch = get_time_to_punch(self)
		
		self.mdt.attack = math.random(0, 2)
		self.mdt.ai = math.random(0, 1)
	end,
	
	-- On step
	on_step = function(self, dtime)
		
		self.mdt.attack = self.mdt.attack + dtime
		
		-- Check attack mode
		if self.mdt.attack > 2 then
			self.mdt.attack = 0
			
			-- Check target
			if not self.target or not self.target:get_pos() then
				self.target = nil
				self.path.status = false
				creatures.start_mode(self, "idle")
				return
			end
			
			-- Check if target is too far
			if creatures.get_dist_p1top2(self.object:get_pos(), self.target:get_pos()) > self.mode_vars.combat.search_radius then
				self.target = nil
				self.path.status = false
				creatures.start_mode(self, "idle")
				return
			end
			
		end
		
		
		self.mdt.punch = self.mdt.punch - dtime
		
		-- Check if can punch
		if self.mdt.punch <= 0 then
			self.mdt.punch = get_time_to_punch(self)
			
			-- Check target
			if not self.target or not self.target:get_pos() then
				self.target = nil
				self.path.status = false
				creatures.start_mode(self, "idle")
				return
			end
			
			if get_target_dist(self) < self.mode_vars.combat.attack_radius
				and creatures.mob_sight(self, self.target, {physical_access=true}) == true -- Check line of sight
			then
				
				-- Stop movement
				self.path.status = false
				self:mob_go_dir(0, {x=0,y=0,z=0}, self.can_fly)
				
				-- Adjust animation
				if self.animation ~= "attack" then
					creatures.set_animation(self, "attack")
				end
				
				-- Rotate
				rotate_to_target(self, self.object:get_pos(), self.target:get_pos())
				
				-- Punch
				self.target:punch(
					self.object, 
					self.mode_vars.combat.attack_hit_interval, 
					{
						full_punch_interval = self.mode_vars.combat.attack_hit_interval,
						damage_groups = {fleshy = self.mode_vars.combat.attack_damage}
					}
				)
			end
		end
		
		
		self.mdt.ai = self.mdt.ai - dtime
		
		-- AI for attack
		if self.mdt.ai < 0 then
			self.mdt.ai = 2
			
			-- Check target
			if not self.target or not self.target:get_pos() then
				self.target = nil
				self.path.status = false
				creatures.start_mode(self, "idle")
				return
			end
			
			local current_pos = get_current_pos(self)
			local target_pos = self.target:get_pos()
			
			local see_target = creatures.mob_sight(self, self.target)
			
			-- Target values
			local dist = get_target_dist(self)
			
			
			--
			-- Target memory
			--
			
			-- Check target memory
			if self.mode_vars.target_memory == 0 then
				self.target = nil
				self.path.status = false
				creatures.start_mode(self, "idle")
				return
			end
			
			-- Reload target memory
			if see_target == true then
				local memory_number = self.mode_vars.target_memory + 1
				self.mode_vars.target_memory = memory_number
				core.after(15, reset_target_memory, self, memory_number)
			end
			
			
			--
			-- Walk to target
			--
			
			-- Can fly directly to target
			if self.can_fly == true then
			
				-- Fly to target
				rotate_to_target(self, current_pos, target_pos)
				self:mob_go_dir(self.mode_vars.moving_speed, self.dir, self.can_fly)
				return
			
			end
			
			-- Can walk directly to target
			if see_target == true 
				and (
					dist > self.combat.attack_radius
					or self.combat.attack_collide_with_target == true
				)
				and creatures.mob_sight(self, self.target, {physical_access=true}) == true
			then
				
				self:mob_go_dir(self.mode_vars.moving_speed, self.dir)
				rotate_to_target(self, current_pos, target_pos)
				if self.animation ~= "attack" then
					creatures.set_animation(self, "attack")
				end
				
				-- Cancel path way
				self.path.status = false
				
				self.mdt.ai = creatures.action_factor_time(self, 0.3)
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
						speed = self.mode_vars.moving_speed,
						on_finish = on_finish_path,
						on_interrupt = on_interrupt_path,
						search_def = {
							target_dist = self.mode_vars.combat.attack_radius,
							check_step = check_step,
							time_to_find = 0.2,
						},
					}
				) == true then
					creatures.path_step(self, dtime)
					return
				end
			end
			
			--
			-- No action
			--
			
			-- Stand rotated to target
			self:mob_go_dir(0, {x=0,y=0,z=0}, self.can_fly)
			rotate_to_target(self, current_pos, target_pos)
			if self.animation ~= "idle" then
				creatures.set_animation(self, "idle")
			end
		end
		
		-- Execute path step
		creatures.path_step(self, dtime)
		
	end,
})

creatures.register_on_hitted(function(self, puncher, time_from_last_punch, tool_capabilities, dir)

	if self.hostile == true then
		
		-- change mode
		self.target = puncher
		creatures.start_mode(self, "attack")
	end
end)



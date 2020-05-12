--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

swim.lua

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
local sound_play = minetest.sound_play
local get_node = minetest.get_node
local get_mob_def = creatures.mob_def
local reset_physic = creatures.reset_physic
local update_physic = creatures.update_physic
local spawn_particles = creatures.spawn_particles
local changeHP = creatures.change_hp
local max_breath = creatures.max_breath
local velocity_add = creatures.velocity_add
local copy_tb = creatures.copy_tb


-- Default swim nodes
creatures.swim_nodes = {
	-- Lava
	["default:lava_source"] = true,
	["default:lava_flowing"] = true,
	-- Water
	["default:water_source"] = true,
	["default:water_flowing"] = true,
	-- River Water
	["default:river_water_source"] = true,
	["default:river_water_flowing"] = true
}
local swim_nodes = creatures.swim_nodes


-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		self.can_swim = def.stats.can_swim
		
		-- Timers
		self.timers.swim = math.random(0.6, 0.8)
		self.timers.drown = 3
	end)
	
	-- Register 'on_step'
	creatures.register_on_step(mob_name, function(self, dtime)
		
		self.timers.swim = self.timers.swim - dtime
		
		-- Check swim
		if self.timers.swim <= 0 then
			self.timers.swim = math.random(0.6, 0.8)
			
			local me = self.object
			
			-- Check if in water
			if self.last_node and swim_nodes[self.last_node.name] then
				self.in_water = true
			else
				self.in_water = false
			end
			
			-- Remove gravity when in water
			if self.in_water then
				
				if self.physic.gravity then
					
					self.physic.gravity = false
					
					-- Update physic
					self:mob_update_physic()
					
					-- Update acceleration in water
					me:set_acceleration({x = 0, y = -1, z = 0})
					
					-- Reduce fall speed
					local vel = me:get_velocity()
					if vel.y < 0 then
						vel.y = vel.y * 0.1
						me:set_velocity(vel)
					end
				end
			else
				
				-- Update physic
				self:mob_reset_physic()
				self:mob_update_physic()
			end
			
			local c_pos = me:get_pos()
			
			-- MOB definition
			local mob_def = get_mob_def(self)
			
			-- Check Breath
			local breath_y = c_pos.y + (mob_def.model.vision_height or 0)
			local breath_nodename = get_node({x = c_pos.x, y = breath_y, z = c_pos.z}).name
			
			if swim_nodes[breath_nodename] then
				
				-- Reduce breath
				self.breath = self.breath - 1
				if self.breath < 0 then
					self.breath = 0
				end
				
				-- Swin
				local vel = me:get_velocity()
				me:set_velocity({x = vel.x, y = 1, z = vel.z})
				
				-- play swimming sounds
				if def.sounds and def.sounds.swim then
					local swim_snd = def.sounds.swim
					sound_play(swim_snd.name, {pos = c_pos, gain = swim_snd.gain or 1, max_hear_distance = swim_snd.distance or 10})
				end
				spawn_particles(c_pos, vel, "bubble.png")
			
			-- Out of water
			else
				
				-- Reestore breath
				self.breath = self.breath + 3
				local max_breath = max_breath(self)
				if self.breath > max_breath then
					self.breath = max_breath
				end
			end
		end
		
		self.timers.drown = self.timers.drown - dtime
		
		-- Add damage when drowning
		if self.timers.drown <= 0 then
			self.timers.drown = 1
			
			if self.breath <= 0 then
				changeHP(self, -1, "drown")
				
				-- Panic if possible
				if self.mode ~= "attack" then
					creatures.start_mode(self, "panic")
				end
			end
		end
	end)
	
end)

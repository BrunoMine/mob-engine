--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

modes.lua

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

-- Modpath
local modpath = core.get_modpath("creatures")


-- Methods
local random = creatures.get_random_index
local get_def = creatures.get_def

-- Update animation
creatures.mode_animation_update = function(self)
	minetest.log("deprecated", "[Creatures] Deprecated 'creatures.mode_animation_update' method (use 'self:mob_mode_set_anim')")
	self:mob_mode_set_anim()
end
creatures.entity_meta.mob_mode_set_anim = function(self)
	self:mob_set_anim(self.mode)
end
local mode_animation_update = creatures.mode_animation_update


-- Update velocity
creatures.mode_velocity_update = function(self)
	minetest.log("deprecated", "[Creatures] Deprecated 'creatures.mode_velocity_update' method (use 'self:mob_mode_set_velocity')")
	self:mob_mode_set_velocity()
end
creatures.entity_meta.mob_mode_set_velocity = function(self)
	local obj = self.object
	local dir = self.dir
	local mode = self.mode
	if not self.mob_modes[mode] then return end
	local speed = self.mob_modes[mode].moving_speed or 0
	
	local v = obj:get_velocity()
	
	if not dir.y then
		dir.y = v.y/speed
	end
	
	local new_v = {x = dir.x * speed, y = v.y , z = dir.z * speed}
	obj:set_velocity(new_v)
end


-- Get mode def
creatures.mode_def = function(self, mode)
	return creatures.registered_mobs[self.mob_name].modes[(mode or self.mode)]
end


-- Start a mode
creatures.start_mode = function(self, mode)
	
	-- Debug tool
	--minetest.chat_send_all("Starting mode: "..mode)
	
	-- Check mode
	if not self.mob_modes[mode] then
		creatures.throw_error("Mode "..dump(mode).." no registered in mob "..dump(self.mob_name))
		mode = "idle"
	end
	
	-- Update last mode
	self.last_mode = self.mode
	
	-- Update mode settings
	self.mode = mode
	self.mode_def = self.mob_modes[mode]
	self.modetimer = creatures.get_number(self.mob_modes[mode].duration or 5)
	self.mode_vars = {}
	self.mdt = {}
	
	-- Update mode on_step
	self.mob_mode_on_step = creatures.registered_modes[mode].on_step or function() end
	
	if creatures.registered_modes[mode] and creatures.registered_modes[mode].start then
		creatures.registered_modes[mode].start(self)
	end
end
local start_mode = creatures.start_mode


-- Default MOB mode on_step
creatures.entity_meta.mob_mode_on_step = function() end

-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	-- Save settings for modes
	creatures.registered_mobs[mob_name].modes = def.modes
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		self.mob_modes = def.modes
		
		self.mode = "idle"
		self.last_mode = "idle"
		self.mode_vars = {}
		
		self.mode_chances = creatures.make_table_chance(def.modes)
		
		-- Timers
		self.modetimer = math.random(1.01, 5.01)
		
		-- Timers for modes
		self.mdt = {}
		
		-- Update mode settings
		self:mob_mode_set_velocity()
		self:mob_mode_set_anim()
	end)
	
	-- 'on_step' callback for modes control
	creatures.register_on_step(mob_name, function(self, dtime)
		
		-- Timer updates
		self.modetimer = self.modetimer - dtime
		
		-- Select a mode
		if self.modetimer <= 0 then
			self.modetimer = math.random(3, 5)
			
			local def = get_def(self)
			
			-- Localize some things
			local modes = def.modes
			local current_mode = self.mode
			
			-- Get a random mode
			local new_mode = creatures.get_random_with_chance(self.mode_chances) or "idle"
			
			-- Update current_mode if changed when start
			self.mode = new_mode
			
			-- Start
			start_mode(self, new_mode)
		end
		
		-- Execute mode step
		self:mob_mode_on_step(dtime)
	end)
	
	-- Register 'get_staticdata'
	creatures.register_get_staticdata(mob_name, function(self)
		return {
			mode = self.mode,
			last_mode = self.last_mode,
			mdt = core.serialize(self.mdt),
			modetimer = self.modetimer,
		}
	end)
end)



-- Register a mode
creatures.registered_modes = {}
creatures.register_mode = function(modename, def)
	
	creatures.registered_modes[modename] = def
	
	return true
end

dofile(modpath .."/features/mode/modes/fly.lua")
dofile(modpath .."/features/mode/modes/walk.lua")
dofile(modpath .."/features/mode/modes/walk_around.lua")
dofile(modpath .."/features/mode/modes/panic.lua")
dofile(modpath .."/features/mode/modes/follow.lua")
dofile(modpath .."/features/mode/modes/attack.lua")
dofile(modpath .."/features/mode/modes/eat.lua")
dofile(modpath .."/features/mode/modes/idle.lua")

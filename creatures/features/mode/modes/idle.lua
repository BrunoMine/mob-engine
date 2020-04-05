--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

idle.lua

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


-- Registered idle modes
creatures.registered_idle_modes = {}

-- Register idle mode
creatures.register_idle_mode = function(mode_name, def)
	
	def = def or {}
	
	creatures.registered_idle_modes[mode_name] = def
	
	-- Mode def
	local mode_def = {}
	
	-- On start
	mode_def.start = function(self)
		
		local mode_def = creatures.mode_def(self)
		
		-- Random dir
		if mode_def.random_yaw then
			creatures.set_dir(self, creatures.get_random_dir())
		end
		
		-- Remove target
		self.target = nil
		
		-- Stop movement
		creatures.send_in_dir(self, 0)
		
		-- Update animation
		creatures.mode_animation_update(self)
	end
	
	
	-- On step
	mode_def.on_step = function(self, dtime)
		
		self.mdt[mode_name] = (self.mdt[mode_name] or 0) + dtime
		
		if def.time ~= nil and self.mdt[mode_name] >= def.time then
			
			local mode_def = creatures.mode_def(self, mode_name)
			
			if self.mdt[mode_name] >= def.time then
				-- Finish mode
				creatures.start_mode(self, "idle")
				return
			end
		end
	end
	
	
	-- Register mode
	creatures.register_mode(mode_name, mode_def)
	
end

-- Idle mode ("idle")
creatures.register_idle_mode("idle", {})




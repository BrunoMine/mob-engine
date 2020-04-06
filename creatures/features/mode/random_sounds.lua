--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

random_sounds.lua

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
	
	if not def.sounds.random then return end
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		-- Timers
		self.timers.rdm_sound = math.random(5, 15)
	end)
	
	-- 'on_step' callback
	creatures.register_on_step(mob_name, function(self, dtime)
		
		-- Timer updates
		self.timers.rdm_sound = self.timers.rdm_sound - dtime
		
		if self.timers.rdm_sound <= 0 then
			
			-- Current mode
			if self.mode == "" then 
				-- Cancel and restart loop
				self.timers.rdm_sound = math.random(5, 15)
				return 
			end
			
			-- Random sound
			local sound = (minetest.registered_entities[self.mob_name].sounds.random or {})[self.mode]
			if not sound then 
				-- Cancel and restart loop
				self.timers.rdm_sound = math.random(5, 15)
				return 
			end
			
			-- Play sound
			minetest.sound_play(sound.name, {
				pos = self.object:getpos(), 
				gain = sound.gain or 1, 
				max_hear_distance = sound.distance or 30
			})
			
			-- Restart loop with current mode frequency
			self.timers.rdm_sound = math.random((sound.time_min or 5), (sound.time_max or 15))
		end
	end)
	
	-- Register 'get_staticdata'
	creatures.register_get_staticdata(mob_name, function(self)
		return {
			soundtimer = self.soundtimer,
		}
	end)
end)

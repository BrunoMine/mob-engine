--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

stats.lua

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


-- MOB stats presets
creatures.registered_presets.mob_stats = {}

-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	-- Load MOB stats preset
	creatures.apply_preset(
		def.stats, 
		def.stats.stats_preset, 
		creatures.registered_presets.mob_stats
	)
	
	-- Entity definitions
	def.ent_def.stats = def.stats
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		-- Meta data
		self.mob_stats = def.stats
		
	end)
	
end)

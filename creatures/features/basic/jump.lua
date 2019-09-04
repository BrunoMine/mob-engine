--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

jump.lua

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
	
	def.ent_def.stepheight = 0.1
	
	-- Stepheight adjustment
	if def.stats.can_jump 
		and type(def.stats.can_jump) == "number" 
		and def.stats.can_jump > 0
	then
		def.ent_def.stepheight = def.stats.can_jump + 0.1
	end
	
end)

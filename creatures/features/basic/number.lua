--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors

number.lua

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

-- world MOB count
creatures.mob_count = creatures.mod_storage:get_float("mob_count") or 0

-- Get a new MOB number
creatures.new_mob_number = function()
	local n = creatures.mod_storage:get_float("mob_count") or 0
	n = n + 1
	creatures.mod_storage:set_float("mob_count", n)
	creatures.mob_count = n
	return n
end

-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	-- Register 'get_staticdata'
	creatures.register_get_staticdata(mob_name, function(self)
		return {
			mob_number = self.mob_number,
		}
	end)
	
end)
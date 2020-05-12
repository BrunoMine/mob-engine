--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

kill_mob.lua

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


-- Kill a Mob
creatures.kill_mob = function(self, reason)
	if not self then return end
	
	self.death_reason = reason or ""
	
	local def = creatures.mob_def(self)
	local me = self.object
	
	local pos = me:getpos()
	me:setvelocity({x=0,z=0,y=0})
	me:set_hp(1)
	
	if def.drops then
		if type(def.drops) == "function" then
			def.drops(me:get_luaentity())
		else
			creatures.drop_items(pos, def.drops)
		end
	end
	
	self:mob_on_die(reason)
	
	return true
end


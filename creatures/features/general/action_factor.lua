--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors

action_factor.lua

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

local sort = function(percent)
	if math.random(1, 100) <= percent then
		return true
	end
	return false
end

-- Get action factor
creatures.action_factor = function(self, post_factor)
	post_factor = post_factor or 1
	
	local can_act = true
	
	if self.mobs_near < 3 then
		can_act = sort(math.floor(60 * post_factor))
	elseif self.mobs_near < 6 then
		can_act = sort(math.floor(40 * post_factor))
	elseif self.mobs_near < 9 then
		can_act = sort(math.floor(30 * post_factor))
	elseif self.mobs_near < 12 then
		can_act = sort(math.floor(25 * post_factor))
	elseif self.mobs_near < 20 then
		can_act = sort(math.floor(15 * post_factor))
	elseif self.mobs_near < 40 then
		can_act = sort(math.floor(10 * post_factor))
	elseif self.mobs_near < 60 then
		can_act = sort(math.floor(5 * post_factor))
	elseif self.mobs_near < 80 then
		can_act = sort(math.floor(2 * post_factor))
	else
		can_act = sort(math.floor(1 * post_factor))
	end
	
	return can_act
end

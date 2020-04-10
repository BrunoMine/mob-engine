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
	minetest.log("deprecated", "[Creatures] Deprecated 'creatures.action_factor' method (use 'self:mob_actfac_bool')")
	return self:mob_actfac_bool(post_factor)
end
creatures.entity_meta.mob_actfac_bool = function(self, post_factor)
	post_factor = post_factor or 1
	
	--[[
		percent_of_chance = (100/mobs_near) * mobs_in_action
	  ]]
	local percent = (100/self.mobs_near) * 20
	
	local can_act = sort(math.floor(percent / post_factor))
	
	return can_act
end

-- Get action factor time
creatures.action_factor_time = function(self, n_time, post_factor)
	minetest.log("deprecated", "[Creatures] Deprecated 'creatures.action_factor_time' method (use 'self:mob_actfac_time')")
	return self:mob_actfac_time(n_time, post_factor)
end
creatures.entity_meta.mob_actfac_time = function(self, n_time, post_factor)
	post_factor = post_factor or 1
	
	local factor = 1
	
	if self.mobs_near > 3 then
		if self.mobs_near < 20 then
			factor = self.mobs_near/3
		else
			factor = 5
		end
	end
	
	return (n_time * factor * post_factor)
end

--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2019 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

burn.lua

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

local changeHP = creatures.change_hp

-- Default burn nodes
creatures.burn_nodes = {
	-- Fire
	["fire:basic_flame"] = { dmg = 2 },
	["fire:permanent_flame"] = { dmg = 2 },
	-- Lava
	["default:lava_source"] = { dmg = 4 },
	["default:lava_flowing"] = { dmg = 4 },
}
local burn_nodes = creatures.burn_nodes

-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	if def.stats.can_burn == false then return end
		
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		-- Timer
		self.timers.burn = math.random(0.1, 2)
		
	end)
	
	-- Register 'on_step'
	creatures.register_on_step(mob_name, function(self, dtime)
		
		-- Timer update
		self.timers.burn = self.timers.burn - dtime
		
		-- Add damage when in lava
		if self.timers.burn <= 0 then
			self.timers.burn = 1
			
			local dmg = 0
			
			-- Burn by hot node
			if self.last_node then
				local nodes = def.stats.burn_nodes or burn_nodes
				if nodes[self.last_node.name] then
					dmg = nodes[self.last_node.name].dmg
				end
			end
			
			-- Burn by light
			if def.stats.burn_light then
				if self.last_light and creatures.in_range(def.stats.burn_light, self.last_light) == true then
					dmg = dmg + (def.stats.burn_light_dmg or 1)
				end
			end
			
			-- Burn by light
			if def.stats.burn_time then
				if creatures.in_range(def.stats.burn_time, (core.get_timeofday()*24000), 24000) == true then
					dmg = dmg + (def.stats.burn_time_dmg or 1)
				end
			end
			
			-- Apply damage
			if dmg > 0 then
				changeHP(self, (dmg * -1), "burn")
				
				-- Panic if possible
				if self.mode ~= "attack" then
					creatures.start_mode(self, "panic")
				end
			end
			
		end
	end)
	
end)

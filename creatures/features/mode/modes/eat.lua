--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

eat.lua

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


-- Methods
local registered_nodes = minetest.registered_nodes
local set_node = minetest.set_node
local remove_node = minetest.remove_node
local add_item = minetest.add_item
local sound_play = minetest.sound_play
local get_node = minetest.get_node_or_nil
local start_mode = creatures.start_mode
local copy = table.copy
local random = math.random

-- Eat mode ("eat")
creatures.register_mode("eat", {
	
	-- On start
	start = function(self)
		
		if self:mob_actfac_bool(0.3) == false then
			start_mode(self, "idle")
			return 
		end
		
		-- Check eat node
		if not self.mode_vars.eat_node then
			
			-- Current Node
			local c_pos = self.current_pos
			local c_node = self.current_node
			
			-- Soil Node
			local s_pos = {x = c_pos.x, y = c_pos.y - 1, z = c_pos.z}
			local s_node = get_node(s_pos)
			
			local eat_pos, eat_node -- eaten node
			
			-- Choose a node
			
			-- Check current node
			if self.mode_def.nodes[c_node.name] then
				eat_pos = c_pos
				eat_node = c_node
			
			-- Check soil node
			elseif self.mode_def.nodes[s_node.name] then
				eat_pos = s_pos
				eat_node = s_node
				
			end
			
			-- Check eat node
			if not eat_node then
				-- Finish mode
				start_mode(self, "idle")
				return
			end
			
			self.mode_vars.eat_pos = copy(eat_pos)
			self.mode_vars.eat_node = copy(eat_node)
		end
		
		-- Start animation to eat
		self:mob_set_anim("eat")
		
		-- Timer to chance node
		self.mdt.eat = self.mode_def.eat_time
	end,
	
	-- On step
	on_step = function(self, dtime)
		
		self.mdt.eat = self.mdt.eat - dtime
		
		if self.mdt.eat <= 0 then
			self.mdt.eat = 1000 -- Avoid repeat action
			
			local node = self.mode_vars.eat_node
			local acts = self.mode_def.nodes[node.name]
			local node_def = registered_nodes[node.name]
			
			-- Actions
			if acts.replace then -- Replace
				set_node(self.mode_vars.eat_pos, {name = acts.replace})
			
			elseif acts.remove == true then -- Remove
				remove_node(self.mode_vars.eat_pos)
			end
			
			-- Sounds
			local sound = acts.sound or self.mode_def.sound
			if sound then 
				sound_play(sound, {pos = self.current_pos, max_hear_distance = 5, gain = 1})
			end
			
			-- Reset values
			self.mode_vars.eat_pos = nil
			self.mode_vars.eat_node = nil
		end
		
	end,
})



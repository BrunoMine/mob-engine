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



-- Eat mode ("eat")
creatures.register_mode("eat", {
	
	-- On start
	start = function(self)
		
		-- Localize some things
		local mode_def = creatures.mode_def(self)
		local me = self.object
		local current_pos = me:getpos()
		current_pos.y = current_pos.y + 0.5
		
		-- Check eat node
		if not self.eat_node and self.last_node.name then
			
			-- Sub Node
			local p = {x = current_pos.x, y = current_pos.y - 1, z = current_pos.z}
			local sn = core.get_node_or_nil(p)
			
			local eat_node -- eaten node
			
			if mode_def.nodes[self.last_node.name] then
				eat_node = current_pos
			elseif mode_def.nodes[sn.name] then
				eat_node = p
			end

			if not eat_node then
				-- Finish mode
				creatures.start_mode(self, "idle")
				return
			end
			
			self.eat_node = table.copy(eat_node)
			self.mdt.eat = 0
			creatures.set_animation(self, "eat")
		end
		
	end,
	
	-- On step
	on_step = function(self, dtime)
		
		self.mdt.eat = self.mdt.eat + dtime
		
		local mode_def = creatures.mode_def(self, "eat")
		
		if self.mdt.eat >= mode_def.eat_time and self.eat_node then
			
			local n = core.get_node_or_nil(self.eat_node)
			local nnn = n.name
			local action_def = mode_def.nodes[nnn]
			local node_def = core.registered_nodes[n.name]
			
			-- Check node
			if not action_def then
				-- Finish mode
				creatures.start_mode(self, "idle")
				return
			end
			
			-- Node modify
			if action_def.replace then
				core.set_node(self.eat_node, {name = action_def.replace})
			elseif action_def.remove == true then
				core.remove_node(self.eat_node)
			end
			
			-- Sounds
			local sound = action_def.sound or mode_def.sound
			if sound then 
				core.sound_play(sound, {pos = self.eat_node, max_hear_distance = 5, gain = 1})
			end
			
			-- Drop
			local drop = node_def.drop
			if drop then
				core.add_item(self.eat_node, drop)
			end
			
			self.eat_node = nil
		end
		
	end,
})



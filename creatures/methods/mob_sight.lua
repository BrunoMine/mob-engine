--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2019 Mob API Developers and Contributors

mob_sight.lua

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



-- Check line of sight
creatures.line_of_sight = function(pos1, pos2, def)
	def = def or {}
	
	local ignore_obj = {}
	if def.ignore_obj then
		for _,obj in ipairs(def.ignore_obj) do
			ignore_obj[tostring(obj)] = true
		end
	end
	
	local raycast = minetest.raycast(pos1, pos2, not def.ignore_all_obj, false)
	
	local n = raycast:next()
	while n do
		
		-- Objects
		if def.ignore_all_obj == false
			and n.type == "object" 
			-- Ignored objects
			and not ignore_obj[tostring(n.ref)] 
		then
			return false
		
		-- Nodes
		elseif n.type == "node" then
			
			-- Check if is target
			if def.target_is_node == true and vector.equals(vector.round(n.under), vector.round(pos2)) == true then
				return true
			end
			
			if def.physical_access == true then return false end
			
			local nn = minetest.get_node(n.under).name
			
			if not creatures.transparent_nodes[nn] then
				return false
			end
		
		-- Nothing
		elseif n.type == "nothing" then
			return true
		end
		
		n = raycast:next()
	end
	
	return true
end
local line_of_sight = creatures.line_of_sight

-- Check line of sight
creatures.mob_sight = function(viewer, target, def)
	def = def or {}
	def.ignore_obj = def.ignore_obj or {}
	
	def.ignore_all_obj = def.ignore_all_obj or false
	
	local targets = {}
	local target_obj, viewer_obj
	
	-- Target is a pos
	if target.y and target.x  and target.z then
		targets[1] = {x=target.x, y=target.y, z=target.z}
	
	-- Target is a object
	else
		table.insert(def.ignore_obj, target)
		
		local collisionbox = target:get_properties().collisionbox
		-- Get pos beetwen botton and top
		local pos = target:get_pos()
		
		local bottom_pos = table.copy(pos)
		bottom_pos.y = bottom_pos.y + collisionbox[2]
		local top_pos = table.copy(pos)
		top_pos.y = top_pos.y + collisionbox[5]
		
		table.insert(targets, bottom_pos)
		
		local height = math.abs(bottom_pos.y - top_pos.y)
		local step = 1
		for y = 0, (height-step), step do
			table.insert(targets, {x=pos.x, y=targets[#targets].y+step, z=pos.z})
		end
		
		table.insert(targets, top_pos)
	end
	
	local viewer_pos
	if viewer.y and viewer.x  and viewer.z then
		viewer_pos = {x=viewer.x, y=viewer.y, z=viewer.z}
	
	else
		table.insert(def.ignore_obj, viewer.object)
		
		viewer_pos = creatures.get_vision_pos(viewer)
	end
	
	-- Check all targets
	for _,target_pos in ipairs(targets) do
		if creatures.line_of_sight(viewer_pos, target_pos, {
			ignore_all_obj = def.ignore_all_obj,
			target_is_node = def.target_is_node,
			ignore_obj = def.ignore_obj,
			stepsize = def.stepsize or 0.5,
			physical_access = def.physical_access,
		}) == true then
			return true
		end
	end
	
	return false
end

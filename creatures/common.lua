--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2019 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

common.lua

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
local get_node = minetest.get_node
local get_item_group = minetest.get_item_group

-- Global tables
local registered_nodes = minetest.registered_nodes


-- Get random index
creatures.get_random_index = function(tb)
	local index_table = {}
	for index,d in pairs(tb) do
		table.insert(index_table, index)
	end
	return index_table[math.random(1, table.maxn(index_table))]
end

-- Get random value from table
creatures.get_random_from_table = function(tb, remove_value)
	local i = math.random(1, table.maxn(tb))
	local value = tb[i]
	if remove_value then
		table.remove(tb, i)
	end
	return value, tb
end

-- Make chance table
creatures.make_table_chance = function(tb)
	local table_chance = {}
	local total_percent = 0
	for i,v in pairs(tb) do
		table.insert(table_chance, {
			index = i,
			starts = total_percent + 1,
			ends = total_percent + (v.chance or 0),
		})
		total_percent = total_percent + (v.chance or 0)
	end
	return table_chance
end

-- Get random index from table with chances
creatures.get_random_with_chance = function(tb)
	local choose = math.random(1, 100)
	for _,v in ipairs(tb) do
		if choose >= v.starts and choose <= v.ends then
			return v.index
		end
	end
end

-- Error msg
creatures.throw_error = function(msg)
	core.log("error", "[Creatures]: " .. msg)
end

-- Get number
creatures.get_number = function(number)
	if type(number) == "number" then
		return number
	else
		return math.random(number.min, number.max)
	end
end

-- Get distance p1 to p2
creatures.get_dist_p1top2 = function(p1, p2)
	if not p1 or not p2 then
		return
	end
	local dist = {
		x=p2.x-p1.x, 
		y=p2.y-p1.y, 
		z=p2.z-p1.z
	}
	local real_dist = math.hypot(math.hypot(math.abs(dist.x), math.abs(dist.z)), math.abs(dist.y))
	return real_dist, dist
end

-- Velocity add
creatures.velocity_add = function(self, v_add)
	local obj = self.object
	local v = obj:get_velocity()
	
	local new_v = vector.add(v, v_add)
	
	obj:set_velocity(new_v)
end

creatures.get_far_node = function(pos)
	local node = get_node(pos)
	if node.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(pos, pos)
		node = get_node(pos)
	end
	return node
end
local get_far_node = creatures.get_far_node

-- Copy a table
creatures.copy_tb = function(tb)
	return minetest.deserialize(minetest.serialize(tb))
end

-- Int
creatures.int = function(n)
	if (n - math.floor(n)) > 0.5 then
		return math.ceil(n)
	else
		return math.floor(n)
	end
end

-- Get collisionbox
creatures.get_collisionbox = function(obj)
	-- For Lua entity
	if obj:get_luaentity() then 
		return obj:get_luaentity().collisionbox
	
	-- For players
	elseif obj:is_player() then
		return {-0.3, 0.0, -0.3, 0.3, 1.6, 0.3}
	end
end

-- Get pos object
creatures.get_node_pos_object = function(obj)
	local c = creatures.get_collisionbox(obj)
	local pos = obj:get_pos()
	return {
		x = creatures.int(pos.x - c[1]),
		y = creatures.int(pos.y - c[2] + 0.1),
		z = creatures.int(pos.z - c[3])
	}
end

-- Check free pos
creatures.check_free_pos = function(pos)
	local node = get_far_node(pos)
	if node.name == "air" then return true end
	local def = registered_nodes[node.name]
	if def ~= nil and def.walkable == false then return true end
	return false
end

-- Check if a node is wall/fence
creatures.is_wall = function(pos)
	local name = get_node(pos).name
	if get_item_group(name, "wall") == 1
		or get_item_group(name, "fence") == 1
	then
		return true
	end
	return false
end

-- Checks if a number is within range
creatures.in_range = function(range, value, cycle_limit)
	if not value or not range or not range.min or not range.max then
		return false
	end
	local new_range = table.copy(range)
	local new_value = value
	if cycle_limit and new_range.min > new_range.max then
		if new_value < new_range.max then
			new_value = new_value + cycle_limit
		end
		new_range.max = new_range.max + cycle_limit
	end
	if (new_value >= new_range.min and new_value <= new_range.max) then
		return true
	end
	return false
end

-- Make a number using a string
creatures.make_number = function(str)
	
	local number = "0"
	for n,_ in string.gmatch(str, ".") do
		number = number .. tostring(tonumber(n, 36))
	end
	
	return tonumber(number)
end
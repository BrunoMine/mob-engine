--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors

collision_avoid.lua

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
local get_objects_inside_radius = minetest.get_objects_inside_radius
local raycast = minetest.raycast
local registered_items = minetest.registered_items
local get_node = minetest.get_node
local get_collisionbox = creatures.get_collisionbox


-- Get vertices from collision box
local get_vertices = function(pos, box)
	return {
		xyz = {x = pos.x + box[1], y = pos.y + box[2], z = pos.z + box[3]},
		xyZ = {x = pos.x + box[1], y = pos.y + box[2], z = pos.z + box[6]},
		xYz = {x = pos.x + box[1], y = pos.y + box[5], z = pos.z + box[3]},
		xYZ = {x = pos.x + box[1], y = pos.y + box[5], z = pos.z + box[6]},
		Xyz = {x = pos.x + box[4], y = pos.y + box[2], z = pos.z + box[3]},
		XyZ = {x = pos.x + box[4], y = pos.y + box[2], z = pos.z + box[6]},
		XYz = {x = pos.x + box[4], y = pos.y + box[5], z = pos.z + box[3]},
		XYZ = {x = pos.x + box[4], y = pos.y + box[5], z = pos.z + box[6]},
	}
end

-- Get objects
local get_raycast = function(pos1, pos2, ignore_obj)
	local obj_avoid = tostring(ignore_obj or "")
	
	local raycast = raycast(pos1, pos2)
	
	
	local data = {
		nodes = {},
		objects = {}
	}
	
	local n = raycast:next()
	while n do
		
		-- Objects
		if n.type == "object" then
			
			local obj_st = tostring(n.ref)
			
			if obj_st ~= obj_avoid then
				data.objects[obj_st] = n.ref
				return data
			end
			
		-- Nodes
		elseif n.type == "node" then
			local nn = get_node(n.under).name
			
			if registered_items[nn].walkable ~= false then
				data.nodes[minetest.pos_to_string(n.under)] = nn
				
				return data
			end
			
		-- Nothing
		elseif n.type == "nothing" then
			return data
		end
		
		n = raycast:next()
	end
	
	return data
end


-- Stop movement
local stop_vel = function(obj)
	if not obj then return end
	obj:set_velocity({x=0,y=0,z=0})
end


-- Send MOB in opposite direction
local to_put_away = function(obj, pos)
	local dir = vector.direction(obj:get_pos(), pos)
	local vel = vector.multiply(dir, -1)
	
	if vel.x == 0 and vel.y == 0 and vel.z == 0 then
		vel.x = math.random(-1, 1)
		vel.z = math.random(-1, 1)
	end
	
	-- Little noise
	vel.x = vel.x + math.random(-0.25, 0.25)
	vel.z = vel.z + math.random(-0.25, 0.25)
	
	obj:set_velocity(vel)
	minetest.after(1, stop_vel, obj)
end


-- Check if is a MOB
local check_obj = function(me, obj)
	local ent = obj:get_luaentity()
	if (ent or {}).mob_number then
		to_put_away(me, obj:get_pos())
		return true
	end
	return false
end

-- Check MOB collision
local check_mob_collision = function(self)
	if not self.mob_number then return end
	
	local me = self.object
	local me_st = tostring(self.object)
	
	local my_box = get_collisionbox(me)
	
	-- Reduce box for analise
	my_box = {
		my_box[1] + 0.01,
		my_box[2] + 0.01,
		my_box[3] + 0.01,
		my_box[4] - 0.01,
		my_box[5] - 0.01,
		my_box[6] - 0.01,
	}
	
	local my_v = get_vertices(me:get_pos(), my_box)
	
	--[[
		xYz-----------xYZ-----------XYZ-----------XYz-----------xYz
		 |>-_       _->|>-_       _->|>-_       _->|>-_       _->|
		 |   \__ __/   |   \__ __/   |   \__ __/   |   \__ __/   |
		 |    __X__    |    __X__    |    __X__    |    __X__    |
		 |  _/     \_  |  _/     \_  |  _/     \_  |  _/     \_  |
		 |>-         ->|>-         ->|>-         ->|>-         ->|
		xyz-----------xyZ-----------XyZ-----------Xyz-----------xyz
	]]--
	for _,p in ipairs({
		-- Side
		{pos1 = my_v.xyz, pos2 = my_v.xYZ},
		{pos1 = my_v.xYZ, pos2 = my_v.XyZ},
		{pos1 = my_v.XyZ, pos2 = my_v.XYz},
		{pos1 = my_v.XYz, pos2 = my_v.xyz},
		{pos1 = my_v.xYz, pos2 = my_v.xyZ},
		{pos1 = my_v.xyZ, pos2 = my_v.XYZ},
		{pos1 = my_v.XYZ, pos2 = my_v.Xyz},
		{pos1 = my_v.Xyz, pos2 = my_v.xYz},
		-- Inside
		{pos1 = my_v.xyz, pos2 = my_v.XYZ},
		--{pos1 = my_v.XYZ, pos2 = my_v.xyz},
		--{pos1 = my_v.XyZ, pos2 = my_v.xYz},
		--{pos1 = my_v.xYz, pos2 = my_v.XyZ},
	}) do
		local new_data = get_raycast(p.pos1, p.pos2, me)
		
		-- Nodes
		for n,d in pairs(new_data.nodes) do
			to_put_away(me, minetest.string_to_pos(n))
			return
		end
		
		-- Objects
		for n,obj in pairs(new_data.objects) do
			if check_obj(me, obj) then 
				return false
			end
		end
	end
	
	-- Check exact pos
	for _,obj in ipairs(get_objects_inside_radius(me:get_pos(), 0.2)) do
		if tostring(obj) ~= me_st 
			and	check_obj(me, obj)
		then
			return false
		end
	end
	
	return true
end


-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		-- Collision count
		self.collision_count = 0
		
		-- Timers
		self.timers.collision = math.random(5, 15)
		
	end)
	
	-- Register 'on_step'
	creatures.register_on_step(mob_name, function(self, dtime)
		
		self.timers.collision = self.timers.collision - dtime
		
		-- Check collision
		if self.timers.collision <= 0 then
			self.timers.collision = math.random(8, 12)
			
			if self.collision_count > 3 then
				creatures.kill_mob(self, "no_space")
			end
			
			if check_mob_collision(self) == false then
				self.collision_count = self.collision_count + 1
				self.timers.collision = 2
			else
				self.collision_count = 0
			end
			
		end
	end)
	
end)

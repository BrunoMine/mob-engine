--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

direction.lua

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

-- Conversion

-- Convert dir to yaw
creatures.dir_to_yaw = function(dir)
	local a = math.deg(math.atan2(dir.x*-1, dir.z))
	if a < 0 then a = a + 360 end
	return math.rad(a)
end
local dir_to_yaw = creatures.dir_to_yaw

-- Convert yaw to dir
creatures.yaw_to_dir = function(yaw)
	return {x = math.sin(yaw)*-1, y = 0, z = math.cos(yaw)}
end
local yaw_to_dir = creatures.yaw_to_dir

-- Pos to pos

-- Get dir of p1 to p2
creatures.get_dir_p1top2 = function(p1, p2, include_y)
	
	local dist = {
		x=p2.x-p1.x, 
		y=0,
		z=p2.z-p1.z
	}
	local real_dist = math.hypot(math.abs(dist.x), math.abs(dist.z))
	
	-- Include Y
	if include_y == true then
		dist.y = p2.y - p1.y
		real_dist = math.hypot(real_dist, math.abs(dist.y))
	end
	
	if real_dist == 0 then return end
	
	local p = 1/real_dist
	
	local dir = {
		x = dist.x*p,
		y = dist.y*p,
		z = dist.z*p
	}
	return dir
end

-- Get yaw of p1 to p2
creatures.get_yaw_p1top2 = function(p1, p2)
	local dir = creatures.get_dir_p1top2(p1, p2)
	if not dir then return end
	return creatures.dir_to_yaw(dir)
end

-- Random

-- Get random yaw
creatures.get_random_yaw = function()
	return math.rad(math.random(0, 359))
end
local get_random_yaw = creatures.get_random_yaw

-- Get random dir
creatures.get_random_dir = function()
	return yaw_to_dir(get_random_yaw())
end
local random_dir = creatures.get_random_dir

-- Applying values

-- Set yaw
creatures.set_yaw = function(self, yaw, rotate)
	minetest.log("deprecated", "[Creatures] Deprecated 'creatures.set_yaw' method (use 'self:mob_set_yaw')")
	self:mob_set_yaw(yaw, rotate)
end
creatures.entity_meta.mob_set_yaw = function(self, yaw, rotate)
	rotate = rotate or 0
	local new_yaw = yaw+math.rad(self.model.rotation+rotate)
	self.object:set_yaw(new_yaw)
end

-- Set dir
creatures.set_dir = function(self, dir, rotate)
	minetest.log("deprecated", "[Creatures] Deprecated 'creatures.set_dir' method (use 'self:mob_set_dir')")
	self:mob_set_dir(dir, rotate)
end
creatures.entity_meta.mob_set_dir = function(self, dir, rotate)
	rotate = rotate or 0
	local yaw = creatures.dir_to_yaw(dir)
	local new_yaw = yaw+math.rad(self.model.rotation+rotate)
	self.object:set_yaw(new_yaw)
	self.dir = dir
end

-- Sending

-- Send in dir
creatures.send_in_dir = function(self, speed, dir, include_y)
	minetest.log("deprecated", "[Creatures] Deprecated 'creatures.send_in_dir' method (use 'self:mob_go_dir')")
	self:mob_go_dir(speed, dir, include_y)
end
creatures.entity_meta.mob_go_dir = function(self, speed, dir, include_y)
	if not dir then
		dir = self.dir
	end
	
	local y = self.object:get_velocity().y
	
	if include_y == true then
		y = (dir.y or 0) * speed
	end
	
	self.object:set_velocity({
		x = (dir.x or 0) * speed, 
		y = y, 
		z = (dir.z or 0) * speed
	})
end

-- Send in yaw
creatures.send_in_yaw = function(self, speed, yaw)
	minetest.log("deprecated", "[Creatures] Deprecated 'creatures.send_in_yaw' method (use 'self:send_in_yaw')")
	self:send_in_yaw(speed, dir, include_y)
end
creatures.entity_meta.send_in_yaw = function(self, speed, yaw)
	local dir
	if yaw then
		dir = creatures.yaw_to_dir(yaw)
	else
		dir = self.dir
	end
	
	self:mob_go_dir(self, speed, dir)
end

-- Randomize dir
creatures.entity_meta.mob_random_dir = function(self, dir)
	self:mob_set_dir(random_dir())
end

-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		-- Update direction
		self.dir = creatures.yaw_to_dir(self.object:getyaw())
		
	end)
	
end)



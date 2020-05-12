--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

physic.lua

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


-- Update physic
creatures.update_physic = function(self)
	minetest.log("deprecated", "[Creatures] Deprecated 'creatures.update_physic' method (use 'self:mob_update_physic')")
	self:mob_update_physic()
end
creatures.entity_meta.mob_update_physic = function(self)
	-- Gravity
	if self.physic.gravity == true then
		local acell = -1 + (self.weight * -0.2)
		if acell < -15 then
			acell = -15
		end
		self.object:setacceleration({x = 0, y = acell, z = 0})
	else
		self.object:setacceleration({x = 0, y = 0, z = 0})
	end
end


-- Reset physic
creatures.reset_physic = function(self)
	minetest.log("deprecated", "[Creatures] Deprecated 'creatures.reset_physic' method (use 'self:mob_reset_physic')")
	self:mob_reset_physic()
end
creatures.entity_meta.mob_reset_physic = function(self)
	self.physic.gravity = self.physic.default_gravity
end

-- Make collisionbox
creatures.make_collisionbox = function(width, height, y_diff)
	if not width then return end
	y_diff = y_diff or 0
	return {
		(width/-2), -0.01+y_diff, (width/-2), 
		(width/2), height+y_diff, (width/2)
	}
end

-- Get position of MOB vision
creatures.get_vision_pos = function(self, pos)
	pos = pos or self.object:get_pos()
	return {
		x = pos.x,
		y = pos.y + (self.vision_height or 0),
		z = pos.z,
	}
end

-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	-- Check values
	def.model.collisionbox_width = def.model.collisionbox_width or creatures.default_value.collisionbox_width
	def.model.collisionbox_height = def.model.collisionbox_height or creatures.default_value.collisionbox_height
	
	-- Entity definitions
	def.ent_def.stepheight = 0.1 -- ensure we get over slabs/stairs
	def.ent_def.collisionbox = creatures.make_collisionbox(def.model.collisionbox_width, def.model.collisionbox_height, def.model.center_height) or def.model.collisionbox
	def.model.collisionbox = def.ent_def.collisionbox
	def.ent_def.collide_with_objects = def.model.collide_with_objects or true
	def.ent_def.physical = true
	def.ent_def.vision_height = def.model.vision_height or 0
	def.ent_def.weight = def.model.weight or creatures.default_value.weight
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		
		-- Physic parameters
		self.physic = {}
		self.physic.gravity = true
		self.physic.default_gravity = true
		
		creatures.update_physic(self)
	end)
end)

-- Checks whether a body can be placed in a pos
creatures.check_mob_in_pos = function(self, pos)
	local c = self.collisionbox
	local w = math.ceil(math.abs(c[1]) + c[4])
	local h = math.ceil(math.abs(c[2]) + c[5])
	
	-- Extra nodes for width
	local ew = 0
	w = (w/2) - 0.5
	while w > 0 do
		ew = ew + 1
		w = w - 1
	end
	
	-- Extra nodes for height
	local eh = h - 1
	
	local x = (ew*-1)
	while x <= ew do
		local y = 0
		while y <= eh do
			local z = (ew*-1)
			while z <= ew do
				if creatures.check_free_pos({x=pos.x+x, y=pos.y+y, z=pos.z+z}) == false then
					return false
				end
				z = z + 1
			end
			y = y + 1
		end
		x = x + 1
	end
	
	return true
end


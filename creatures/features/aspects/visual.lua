--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2017 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

visual.lua

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


-- Register 'on_register_mob'
creatures.register_on_register_mob(function(mob_name, def)
	
	-- Entity definitions
	
	-- Adjust model frames
	for mode,d in pairs(def.model.animations) do
		if d.frames then
			def.model.animations[mode].start = d.frames[1]
			def.model.animations[mode].stop = d.frames[2]
			def.model.animations[mode].speed = d.frames[3]
			if d.frames[4] == false then def.model.animations[mode].loop = false end
		end
	end
	
	-- Mesh
	def.ent_def.visual = "mesh"
	def.ent_def.mesh = def.model.mesh
	def.ent_def.automatic_face_movement_dir = def.model.rotation or 0.0
	def.ent_def.backface_culling = def.model.backface_culling or false
	
	-- Textures
	def.ent_def.textures = def.model.textures
	
	-- General
	def.ent_def.visual_size = def.model.scale or {x = 1, y = 1}
	
	-- Model params
	def.ent_def.model = def.model
	
	-- Register 'on_activate'
	creatures.register_on_activate(mob_name, function(self, staticdata)
		self.mob_animations = def.model.animations
		self.animation = self.animation or ""
	end)
	
	-- Register 'get_staticdata'
	creatures.register_get_staticdata(mob_name, function(self)
		return {
			animation = self.animation,
		}
	end)
end)

-- Update animation
creatures.set_animation = function(self, anim_name)
	minetest.log("deprecated", "[Creatures] Deprecated 'creatures.set_animation' method (use 'self:mob_set_anim')")
	self:mob_set_anim(anim_name)
end
creatures.entity_meta.mob_set_anim = function(self, anim_name)
	
	local obj = self.object
	
	-- Animation definitions
	local def = self.mob_animations[anim_name]
	
	-- Check animation
	if not def then return end
	
	obj:set_animation(
		{x = def.start, y = def.stop}, 
		def.speed, 
		0, 
		def.loop
	)
	
	-- Update animation name
	self.animation = anim_name
end

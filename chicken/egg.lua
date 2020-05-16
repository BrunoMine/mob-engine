--[[
= Chicken for Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

egg.lua

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


local function timer(step, entity)
	if not entity or not entity.ref then
		return
	end
	
	local vel = entity.ref:getvelocity()
	if vel ~= nil and vel.x == 0 and vel.y == 0 and vel.z == 0 then
		if math.random(1, 100) <= 5 then
			minetest.add_entity(entity.ref:getpos(), "chicken:chicken")
		end
		entity.ref:remove()
	else
		minetest.after(step, timer, step, entity)
	end
end

function throw_egg(player, strength)
	local pos = player:getpos()
	pos.y = pos.y + 1.5
	local dir = player:get_look_dir()
	pos.x = pos.x + dir.x
	pos.z = pos.z + dir.z
	local obj = minetest.add_item(pos, "chicken:egg")
	if obj then
		local entity = obj:get_luaentity()
		entity.ref = obj
		entity.mergeable = false
		obj:setvelocity({x = dir.x * strength, y = -3, z = dir.z * strength})
		obj:setacceleration({x = dir.x * -5 + dir.y, y = -13, z = dir.z * -5 + dir.y})
		timer(0.1, entity)
		return true
	end
	return false
end

core.register_craftitem("chicken:egg", {
	description = "Chicken Egg",
	inventory_image = "chicken_egg.png",
	on_use = function(itemstack, user, pointed_thing)
		if throw_egg(user, 22) then
			itemstack:take_item()
		end
		return itemstack
	end,
})

core.register_craftitem("chicken:fried_egg", {
	description = "Fried Egg",
	inventory_image = "chicken_fried_egg.png",
	on_use = core.item_eat(2)
})

core.register_craft({
	type = "cooking",
	output = "chicken:fried_egg",
	recipe = "chicken:egg",
})


--[[
= Cow for Creatures MOB-Engine (cme) =
Copyright (C) 2019 Mob API Developers and Contributors

craftitems.lua

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

-- Cowboy Bell
core.register_craftitem("cow:cowboy_bell", {
	description = "Cowboy Bell",
	inventory_image = "cow_cowboy_bell.png",
})
core.register_craft({
	output = 'cow:cowboy_bell',
	recipe = {
		{'', 'wool:blue', 'wool:blue'},
		{'default:steel_ingot', 'default:steel_ingot', 'wool:blue'},
		{'group:stick', 'default:steel_ingot', ''},
	}
})

-- Bucket with Milk
core.register_craftitem("cow:bucket_milk", {
	description = "Bucket with Milk",
	inventory_image = "cow_bucket_milk.png",
	stack_max = 1,
})

-- Raw Beef Meat
core.register_craftitem("cow:raw_beef", {
	description = "Raw Beef Meat",
	inventory_image = "cow_raw_beef.png",
	on_use = core.item_eat(1)
})

-- Roast Beef
core.register_craftitem("cow:roast_beef", {
	description = "Roast Beef",
	inventory_image = "cow_roast_beef.png",
	on_use = core.item_eat(5)
})

core.register_craft({
	type = "cooking",
	output = "cow:roast_beef",
	recipe = "cow:raw_beef",
})

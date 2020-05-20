--[[
= Chicken for Creatures MOB-Engine (cme) =
Copyright (C) 2019 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

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

--[[
	2020-05-20

	As per License's rule number 2:
	- Modified by h4ml3t to add localization (translation) file support.
--]]

-- Used for localization

local S = minetest.get_translator("chicken")


-- Flesh
minetest.register_craftitem("chicken:chicken_flesh", {
	description = S("Raw Chicken Flesh"),
	inventory_image = "chicken_flesh.png",
	on_use = minetest.item_eat(1)
})

minetest.register_craftitem("chicken:chicken_meat", {
	description = S("Chicken Meat"),
	inventory_image = "chicken_meat.png",
	on_use = minetest.item_eat(3)
})

minetest.register_craft({
	type = "cooking",
	output = "chicken:chicken_meat",
	recipe = "chicken:chicken_flesh",
})

-- White Chicken Feather
minetest.register_craftitem("chicken:feather_white", {
	description = S("@1 Chicken Feather", S("White")),
	inventory_image = "chicken_feather_white.png",
	groups = {feather=1},
})

-- Black Chicken Feather
minetest.register_craftitem("chicken:feather_black", {
	description = S("@1 Chicken Feather", S("Black")),
	inventory_image = "chicken_feather_black.png",
	groups = {feather=1},
})

-- Brown Chicken Feather
minetest.register_craftitem("chicken:feather_brown", {
	description = S("@1 Chicken Feather", S("Brown")),
	inventory_image = "chicken_feather_brown.png",
	groups = {feather=1},
})

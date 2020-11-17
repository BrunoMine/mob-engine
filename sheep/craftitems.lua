--[[
= Sheep for Creatures MOB-Engine (cme) =
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

local S = minetest.get_translator("sheep")

-- Flesh
core.register_craftitem("sheep:sheep_flesh", {
	description = S("Raw Sheep Flesh"),
	inventory_image = "sheep_flesh.png",
	on_use = core.item_eat(1)
})

-- Meat
core.register_craftitem("sheep:sheep_meat", {
	description = S("Sheep Meat"),
	inventory_image = "sheep_meat.png",
	on_use = core.item_eat(3)
})

core.register_craft({
	type = "cooking",
	output = "sheep:sheep_meat",
	recipe = "sheep:sheep_flesh",
})


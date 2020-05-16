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


-- Bucket with Milk
core.register_craftitem("cow:bucket_milk", {
	description = "Milk Bucket",
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


-- White and Black Cow Leather
core.register_craftitem("cow:leather_white_and_black", {
	description = "White and Black Cow Leather",
	inventory_image = "cow_leather_white_and_black.png",
	groups = {leather=1},
})

-- Black Cow Leather
core.register_craftitem("cow:leather_black", {
	description = "Black Cow Leather",
	inventory_image = "cow_leather_black.png",
	groups = {leather=1},
})

-- White and Brown Cow Leather
core.register_craftitem("cow:leather_white_and_brown", {
	description = "White and Brown Cow Leather",
	inventory_image = "cow_leather_white_and_brown.png",
	groups = {leather=1},
})

-- Brown Cow Leather
core.register_craftitem("cow:leather_brown", {
	description = "Brown Cow Leather",
	inventory_image = "cow_leather_brown.png",
	groups = {leather=1},
})

-- Brown and Black Cow Leather
core.register_craftitem("cow:leather_brown_and_black", {
	description = "Brown and Black Cow Leather",
	inventory_image = "cow_leather_brown_and_black.png",
	groups = {leather=1},
})

-- Brown and Black Cow Leather
core.register_craftitem("cow:leather_white", {
	description = "White Cow Leather",
	inventory_image = "cow_leather_white.png",
	groups = {leather=1},
})

-- Grey Cow Leather
core.register_craftitem("cow:leather_grey", {
	description = "Grey Cow Leather",
	inventory_image = "cow_leather_grey.png",
	groups = {leather=1},
})

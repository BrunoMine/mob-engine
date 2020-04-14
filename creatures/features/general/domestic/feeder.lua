--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

feeder.lua

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


-- Global tables
creatures.registered_feeder_nodes = {}

-- API feature table
creatures.feeder = {}

-- Indexed tables
local feeder_nodes = creatures.registered_feeder_nodes
local registered_items = minetest.registered_items

-- Update feeder
local update_feeder_node = function(pos)
	local nodename = minetest.get_node(pos).name
	
	local def = feeder_nodes[nodename]
	if not def.node_steps then return end
	
	local meta = minetest.get_meta(pos)
	local food = meta:get_float("food") or 0
	
	-- Set infotext
	local percent = math.ceil((food/def.max_food)*100)
	meta:set_string("infotext", "Food: "..percent.."% ("..food..")")
	
	local selected_node_step = def.node_steps[1]
	
	local i = table.maxn(def.node_steps)
	while i > 1 do
		local node_step = def.node_steps[i]
		-- Check node step
		if node_step.food <= food then
			selected_node_step = def.node_steps[i]
			break
		end
		i = i - 1
	end
	local node = minetest.get_node(pos)
	node.name = selected_node_step.name
	minetest.swap_node(pos, node)
end


-- Set supply level
creatures.feeder.set_level = function(pos, food)
	
	-- Node Meta
	local meta = minetest.get_meta(pos)
	
	meta:set_float("food", food)
	
	-- Update node
	update_feeder_node(pos)
end


-- Modify food level
creatures.feeder.modify_level = function(pos, modify)
	
	-- Feeder definitions
	local def = feeder_nodes[minetest.get_node(pos).name]
	
	-- Node Meta
	local meta = minetest.get_meta(pos)
	local food = meta:get_float("food")
	
	food = food + modify
	
	if food < 0 then food = 0 end
	
	meta:set_float("food", food)
	
	-- Update node
	update_feeder_node(pos)
end


-- Supply feeder with item
creatures.feeder.supply_item = function(pos, itemstack)
	
	-- Feeder definitions
	local feeder_def = feeder_nodes[minetest.get_node(pos).name]
	
	-- Item definitions
	local item_name, item_count
	
	-- Serialized format 
	if type(itemstack) == "string" then
		local t = string.split(itemstack, " ")
		item_name = t[1]
		item_count = tonumber(t[2] or 1)
	
	-- Table format
	else
		item_name = itemstack.name or itemstack:get_name()
		item_count = itemstack.count or itemstack:get_count()
	end
	
	-- Supply
	local supply_def = feeder_def.supply[item_name]
	
	-- Node Meta
	local meta = minetest.get_meta(pos)
	local food = meta:get_float("food") or 0
	
	local take = 0
	
	-- Check how many items can be used
	while ((food + supply_def.food) <= feeder_def.max_food) and item_count > 0 do
		food = food + supply_def.food
		item_count = item_count - 1
		take = take + 1
	end
	
	-- Save new food level at node
	meta:set_float("food", food)
	
	-- Update node
	update_feeder_node(pos)
	
	return take
end


-- Register node feeder
creatures.register_feeder_node = function(nodename, def, secondary)
	feeder_nodes[nodename] = {}
	
	-- Feeder definitions
	feeder_nodes[nodename].supply = def.supply
	feeder_nodes[nodename].max_food = def.max_food
	feeder_nodes[nodename].node_steps = def.node_steps
	
	-- Old definitions to override
	feeder_nodes[nodename].old_on_rightclick = creatures.copy_tb(registered_items[nodename].on_rightclick)
	feeder_nodes[nodename].old_on_place = creatures.copy_tb(registered_items[nodename].on_place)
	feeder_nodes[nodename].old_on_dig = creatures.copy_tb(registered_items[nodename].on_dig)
	
	-- Insert 'mob_feeder' group
	local groups = creatures.copy_tb(registered_items[nodename].groups)
	groups.mob_feeder = 1
	
	-- Override node
	minetest.override_item(nodename, {
		stack_max = 1,
		groups = groups,
		
		on_rightclick = function(pos, node, player, itemstack, pointed_thing)
			
			-- Supply
			if itemstack and itemstack:get_name() and feeder_nodes[nodename].supply[itemstack:get_name()] then
				
				local take = creatures.feeder.supply_item(pos, itemstack)
				
				if take > 0 then
				
					itemstack:take_item(take)
					
				end
				
			end
			
			-- Execute registered 'on_rightclick'
			if feeder_nodes[nodename].old_on_rightclick then
				return feeder_nodes[nodename].old_on_rightclick(pos, node, player, itemstack, pointed_thing)
			end
			return itemstack
		end,
		
		on_place = function(itemstack, placer, pointed_thing)
			
			if not pointed_thing or not pointed_thing.above then return end
			
			-- Check if access another node
			local under = pointed_thing.under
			local node = minetest.get_node(under)
			local defnode = minetest.registered_nodes[node.name]
			if defnode and defnode.on_rightclick and
				((not placer) or (placer and not placer:get_player_control().sneak)) then
				return defnode.on_rightclick(under, node, placer, itemstack,
					pointed_thing) or itemstack
			end
			
			local supply = itemstack:get_meta():get_float("food")
			
			local result
			itemstack, result = minetest.item_place(itemstack, placer, pointed_thing)
			if not result then
				return itemstack
			end
			
			creatures.feeder.modify_level(result, supply)
			
			-- Execute registered 'on_place'
			if feeder_nodes[nodename].old_on_place then
				return feeder_nodes[nodename].old_on_place(itemstack, placer, pointed_thing)
			end
			
			itemstack:take_item()
			
			return itemstack
		end,
		
		on_dig = function(pos, node, digger)
			local meta = minetest.get_meta(pos)
			local inv = digger:get_inventory()
			
			local nodename = minetest.get_node(pos).name
			local def = feeder_nodes[nodename]
			local food = meta:get_float("food")
			local percent = math.ceil((food/def.max_food)*100)
			
			local itemstack = {name=nodename, count=1, meta={
				["food"] = food,
				["description"] = registered_items[nodename].description .. " ("..percent.."%)"
			}}
			
			if inv:room_for_item("main", itemstack) then
						
				-- Add into inventory
				inv:add_item("main", itemstack)
				
			else
				-- Drop 
				minetest.add_item(pos, itemstack)
			end
			
			minetest.remove_node(pos)
			
			-- Execute registered 'on_dig'
			if feeder_nodes[nodename].old_on_dig then
				return feeder_nodes[nodename].old_on_dig(pos, node, digger)
			end
		end,
	})
	
	-- Secondary registration to register node steps
	if secondary ~= true then
		-- Register feeder steps
		for _,node_step in ipairs(def.node_steps or {}) do 
			if node_step.name ~= nodename then
				creatures.register_feeder_node(node_step.name, def, true)
			end
		end
	end
	
end

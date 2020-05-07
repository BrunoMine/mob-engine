--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors

env_nodes.lua

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

local humid_nodes = creatures.merge_groups({
	creatures.node_groups.humid_grass,
	creatures.node_groups.snowy
})

-- "Dirt" Env Node
creatures.make_env_node["dirt"] = function(spawn_def, env_node)
	
	-- Dirt for spawn env
	minetest.register_node(env_node.nodename, {
		description = "Dirt",
		tiles = {"default_dirt.png"},
		groups = {crumbly = 3, soil = 1, not_in_creative_inventory = 1},
		sounds = default.node_sound_dirt_defaults(),
		drop = "default:dirt",
	})
	
	spawn_def.spawn_env_nodes = {
		emergent = env_node.emergent_nodename,
		spawn_on = env_node.spawn_on or humid_nodes,
		place_on = env_node.place_on or humid_nodes,
		set_on = {env_node.nodename},
		build = {
			place = {
				nodename = env_node.nodename,
				nodes = env_node.nodes or humid_nodes,
				y_diff = -2,
			},
		},
	}
	
	return spawn_def
end

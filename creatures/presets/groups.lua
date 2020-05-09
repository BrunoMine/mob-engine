--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors

groups.lua

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

-- Node Groups
creatures.node_groups = {}

-- Dirt Nodes from humid surface
creatures.node_groups.surface_humid_dirt = {
	"default:dirt_with_grass", 
	"default:dirt_with_snow", 
}

-- Dirt Nodes from dry surface
creatures.node_groups.surface_dry_dirt = {
	"default:dirt_with_dry_grass", 
	"default:dry_dirt_with_dry_grass", 
}

-- Nodes Snowy
creatures.node_groups.snowy = {
	"default:snowblock", 
	"default:snow", 
	"default:dirt_with_snow", 
}

-- Nodes from surface
creatures.node_groups.surface = {
	"default:stone", 
	"default:dirt_with_grass", 
	"default:dirt_with_dry_grass",
	"default:dirt_with_coniferous_litter",
	"default:dirt_with_rainforest_litter", 
	"default:dirt_with_snow", "default:snow",
	"default:dirt",
	"default:cobblestone", 
	"default:mossycobble", 
	"group:sand",
}

-- Biome Groups
creatures.biome_groups = {}

-- Biomes with humid grass
creatures.biome_groups.humid_grass = {
	-- Grassland
	"grassland",
	"floatland_grassland",
	"snowy_grassland",
	-- Taiga
	"taiga",
	-- Deciduous forest
	"deciduous_forest",
}

-- Biomes with dry grass
creatures.biome_groups.dry_grass = {
	-- Savanna
	"savanna", 
	"savanna_shore",
}

-- Biomes snowy
creatures.biome_groups.snowy = {
	-- Grassland
	"snowy_grassland",
	"snowy_grassland_ocean",
	-- Taiga
	"taiga", 
	"taiga_ocean", 
	-- Tundra
	"tundra_highland",
}

-- Merge group
creatures.merge_groups = function(groups)
	
	local indexed = {}
	
	for _,group in ipairs(groups) do
		for _,item in ipairs(group) do
			indexed[item] = true
		end
	end
	
	local merged = {}
	
	for item,_ in pairs(indexed) do
		table.insert(merged, item)
	end
	
	return merged
end
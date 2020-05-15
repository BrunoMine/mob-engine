--[[
= Creatures MOB-Engine (cme) =
Copyright (C) 2020 Mob API Developers and Contributors
Copyright (C) 2015-2016 BlockMen <blockmen2015@gmail.com>

init.lua

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

-- Global index
creatures = {}

-- MOB Engine entity metatable
creatures.entity_meta = {}

local modpath = core.get_modpath("creatures")


-- Common functions
dofile(modpath .."/common.lua")

-- Default values
dofile(modpath .."/params.lua")


-- Engine core

-- Presets
dofile(modpath .."/presets.lua")

-- MOB Callbacks
dofile(modpath .."/callbacks.lua")

-- Fence/wall adjust
dofile(modpath .."/fence_adjust.lua")

-- MOB Registration
dofile(modpath .."/register_mob.lua")

dofile(modpath .."/methods/mod_storage.lua")
dofile(modpath .."/methods/drop_items.lua")
dofile(modpath .."/methods/mob_sight.lua")
dofile(modpath .."/methods/find_target.lua")
dofile(modpath .."/methods/kill_mob.lua")
dofile(modpath .."/methods/spawn_particles.lua")
dofile(modpath .."/methods/get_under_walkable_height.lua")
dofile(modpath .."/methods/get_under_walkable_nodes_in_area.lua")


-- Engine Features

-- Aspects
dofile(modpath .."/features/aspects/stats.lua")
dofile(modpath .."/features/aspects/hp.lua")
dofile(modpath .."/features/aspects/breath.lua")
dofile(modpath .."/features/aspects/hostile.lua")
dofile(modpath .."/features/aspects/visual.lua")
dofile(modpath .."/features/aspects/physic.lua")
dofile(modpath .."/features/aspects/is_active.lua")

-- Basic
dofile(modpath .."/features/basic/number.lua")
dofile(modpath .."/features/basic/combat.lua")
dofile(modpath .."/features/basic/sounds.lua")
dofile(modpath .."/features/basic/jump.lua")
dofile(modpath .."/features/basic/drop.lua")
dofile(modpath .."/features/basic/location.lua")
dofile(modpath .."/features/basic/direction.lua")
dofile(modpath .."/features/basic/fly.lua")

-- General
dofile(modpath .."/features/general/action_factor.lua")
dofile(modpath .."/features/general/mobs_near.lua")
dofile(modpath .."/features/general/cleaning_cycles.lua")
dofile(modpath .."/features/general/remove.lua")
dofile(modpath .."/features/general/death_effects.lua")
dofile(modpath .."/features/general/footstep_effects.lua")
dofile(modpath .."/features/general/fallen.lua")
dofile(modpath .."/features/general/lifetime.lua")
dofile(modpath .."/features/general/swim.lua")
dofile(modpath .."/features/general/burn.lua")
dofile(modpath .."/features/general/on_hitted.lua")
dofile(modpath .."/features/general/knockback.lua")
dofile(modpath .."/features/general/path_finder.lua")
dofile(modpath .."/features/general/path.lua")
dofile(modpath .."/features/general/hit_bottom.lua")
dofile(modpath .."/features/general/mob_item_tool.lua")
dofile(modpath .."/features/general/randomize.lua")
dofile(modpath .."/features/general/spawn_env.lua")

-- General / Domestication
dofile(modpath .."/features/general/domestic/feeder.lua")
dofile(modpath .."/features/general/domestic/hunger.lua")
dofile(modpath .."/features/general/domestic/child.lua")
dofile(modpath .."/features/general/domestic/mating.lua")
dofile(modpath .."/features/general/domestic/tame.lua")
dofile(modpath .."/features/general/domestic/mob_node.lua")

-- Mode
dofile(modpath .."/features/mode/modes.lua")
dofile(modpath .."/features/mode/enemy_search.lua")
dofile(modpath .."/features/mode/follow_search.lua")
dofile(modpath .."/features/mode/random_sounds.lua")

-- Spawn
dofile(modpath .."/features/general/spawn.lua")
dofile(modpath .."/features/general/spawner.lua")
dofile(modpath .."/features/general/spawner_egg.lua")

-- Common items
dofile(modpath .."/items.lua")

-- MOB-Engine Presets
dofile(modpath .."/presets/groups.lua")
dofile(modpath .."/presets/default.lua")
dofile(modpath .."/presets/env_nodes.lua")


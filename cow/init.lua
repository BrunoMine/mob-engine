--[[
	Mod Cow for Minetest
	Copyright (C) 2020 BrunoMine (https://github.com/BrunoMine)
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>5.
	
  ]]

cow = {}

cow.spawn_env_chance = tonumber(minetest.settings:get("cow_spawn_chance") or 2)

local modpath = minetest.get_modpath("cow")

-- Craftitems
dofile(modpath.."/craftitems.lua")

-- Feeder
dofile(modpath.."/feeder.lua")

-- Cow
dofile(modpath.."/cow.lua")

-- Bed
dofile(modpath.."/bed.lua")


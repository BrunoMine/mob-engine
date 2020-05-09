--[[
	Mod Cow for Minetest
	Copyright (C) 2019 BrunoMine (https://github.com/BrunoMine)
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>5.
	
  ]]

cow = {}

cow.spawn_env_chance = tonumber(minetest.settings:get("cow_spawn_chance") or 2)

local modpath = minetest.get_modpath("cow")

dofile(modpath.."/craftitems.lua")
dofile(modpath.."/cow.lua")
dofile(modpath.."/bed.lua")
dofile(modpath.."/feeder.lua")


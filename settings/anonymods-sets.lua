--
-- Created by IntelliJ IDEA.
-- User: Stephen
-- Date: 08/07/2017
-- Time: 14:38
-- To change this template use File | Settings | File Templates.
--

local locomotiveFillSet = {group="locomotives", slots={1}, "fuels-high"}
local boilerFillSet = {group="burners", limits={5}, "fuels-high" }
local turretFillSet = {priority=2, group="turrets", limits= {10}, "ammo-bullets" }
local carFillSet = {priority=2, group="turrets", limits= {10}, "ammo-bullets" }
local rocketTurretFillSet = {priority=2, group="turrets", limits= {10}, "ammo-rockets" }
local shotgunTurretFillSet = {priority=2, group="turrets", limits= {10}, "ammo-shotgun" }

return {
    ["rocket-turret-1"] = rocketTurretFillSet,
    ["rocket-turret-2"] = rocketTurretFillSet,
    ["rocket-turret-3"] = rocketTurretFillSet,
    ["rocket-turret-4"] = rocketTurretFillSet,
    ["rocket-turret-5"] = rocketTurretFillSet,

    ["shotgun-turret-1"] = shotgunTurretFillSet,
    ["shotgun-turret-2"] = shotgunTurretFillSet,
    ["shotgun-turret-3"] = shotgunTurretFillSet,
    ["shotgun-turret-4"] = shotgunTurretFillSet,
    ["shotgun-turret-5"] = shotgunTurretFillSet,

    ["sniper-turret-1"] = turretFillSet,
    ["sniper-turret-2"] = turretFillSet,
    ["sniper-turret-3"] = turretFillSet,
    ["sniper-turret-4"] = turretFillSet,
    ["sniper-turret-5"] = turretFillSet,

    ["gun-turret"] = turretFillSet,
    ["gun-turret-2"] = turretFillSet,
    ["gun-turret-3"] = turretFillSet,
    ["gun-turret-4"] = turretFillSet,
    ["gun-turret-5"] = turretFillSet,

    ["car"] = carFillSet,
    ["car-2"] = carFillSet,
    ["car-3"] = carFillSet,
    ["car-4"] = carFillSet,
    ["car-5"] = carFillSet,

    ["tank"] = carFillSet,
    ["tank-2"] = carFillSet,
    ["tank-3"] = carFillSet,

    ["boiler"] = boilerFillSet,
    ["boiler-2"] = boilerFillSet,
    ["boiler-3"] = boilerFillSet,

    ["advanced-burner-mining-drill"] = boilerFillSet,
    ["brick-furnace"] = boilerFillSet,
    ["stone-chemical-furnace"] = boilerFillSet,
    ["brick-chemical-furnace"] = boilerFillSet,
    ["stone-mixing-furnace"] = boilerFillSet,
    ["brick-mixing-furnace"] = boilerFillSet,

}


-- $Id: fd.params.lua 3171 2008-11-06 09:06:29Z det $
local intMap = {
  footprintX               = true, -- fdTable -- footprintX --
  footprintZ               = true, -- fdTable -- footprintZ --
}

local boolMap = {
  blocking                 = true, -- fdTable -- blocking --
  flammable                = true, -- fdTable -- flammable --
  indestructible           = true, -- fdTable -- indestructible --
  nodrawundergray          = true, -- fdTable -- nodrawundergray --
  noselect                 = true, -- fdTable -- noselect --
  reclaimable              = true, -- fdTable -- reclaimable --
  upright                  = true, -- fdTable -- upright --
}

local floatMap = {
  collisionSphereScale     = true, -- fdTable -- collisionSphereScale --
  damage                   = true, -- fdTable -- damage --
  energy                   = true, -- fdTable -- energy --
  mass                     = true, -- fdTable -- mass --
  metal                    = true, -- fdTable -- metal --
  reclaimTime              = true, -- fdTable -- reclaimTime --
}

local float3Map = {
  collisionSphereOffset    = true, -- fdTable -- collisionSphereOffset --
}

local stringMap = {
  description              = true, -- fdTable -- description --
  featureDead              = true, -- fdTable -- featureDead --
  filename                 = true, -- fdTable -- filename --
  object                   = true, -- fdTable -- object --
}

return {
  intMap    = intMap,
  boolMap   = boolMap,
  floatMap  = floatMap,
  float3Map = float3Map,
  stringMap = stringMap,
}

-- SubTable: 	const LuaTable rootTable = game->defsParser->GetRoot().SubTable("FeatureDefs");
-- SubTable: 		const LuaTable fdTable = rootTable.SubTable(name);

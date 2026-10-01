--[[
	Private-server outdoor zones missing from GetMapContinents / GetMapZones.

	Azshara Crater (Aethro map ID 1005) is a standalone outdoor map. The
	client reports it as continent -1 / zone 0, which stock GatherMate
	treats as "not a zone" and also as an instance.
]]
local GatherMate = LibStub("AceAddon-3.0"):GetAddon("GatherMate")

-- Typical 3:2 outdoor-zone yard size. Used for minimap distance and node
-- merging. Zone-map pins use 0-1 coordinates and do not depend on this.
local DEFAULT_WIDTH = 5070.886912363937
local DEFAULT_HEIGHT = 3381.22554790382

local CustomZoneList = {
	{
		token = "AZSHARA_CRATER",
		name = "Azshara Crater",
		zoneID = 1005,
		canonicalFile = "AzsharaCrater",
		mapFiles = {
			AzsharaCrater = true,
			Azshara_Crater = true,
			ACrater = true,
			AZ_Crater = true,
		},
		mapIds = { 1005, 37, 268 },
		names = {
			["azshara crater"] = true,
		},
		width = DEFAULT_WIDTH,
		height = DEFAULT_HEIGHT,
	},
}

local CustomZones = {}
GatherMate.CustomZones = CustomZones

local registered = {}
local namesToDef = {}
local mapFilesToDef = {}
local mapIdsToDef = {}

local function GetServerMapId()
	-- Confirmed on Aethro: GetCurrentMapAreaID() == 1005 for Azshara Crater.
	-- GetInstanceInfo() does not return a map id on this client.
	if GetCurrentMapAreaID then
		local mapId = GetCurrentMapAreaID()
		if type(mapId) == "number" and mapId > 0 then
			return mapId
		end
	end
	if GetCurrentMapId then
		local mapId = GetCurrentMapId()
		if type(mapId) == "number" and mapId > 0 then
			return mapId
		end
	end
	if GetMapId then
		local mapId = GetMapId()
		if type(mapId) == "number" and mapId > 0 then
			return mapId
		end
	end
end

local function GetPlayerZoneName()
	local zoneName = GetRealZoneText()
	if zoneName and zoneName ~= "" then
		return zoneName
	end
	if GetInstanceInfo then
		return GetInstanceInfo()
	end
end

local function FindDefinition(zoneName, mapFile, mapId)
	if zoneName and zoneName ~= "" then
		local def = namesToDef[strlower(zoneName)]
		if def then
			return def
		end
	end
	if mapFile and mapFile ~= "" then
		local def = mapFilesToDef[mapFile]
		if def then
			return def
		end
	end
	if mapId then
		local def = mapIdsToDef[mapId]
		if def then
			return def
		end
	end
end

function CustomZones.GetDefinitionForPlayer()
	-- GetRealZoneText() is the truth. After .v back (GuildVillageHelper)
	-- the client is in Orgrimmar, but continent / GetMapInfo() can still
	-- be the crater for a while. A named non-crater zone is never the crater.
	-- Never learn new zone names (that used to turn Orgrimmar into a crater alias).
	local zoneName = GetPlayerZoneName()
	if zoneName and zoneName ~= "" then
		return FindDefinition(zoneName, nil, nil)
	end
	local C = GetCurrentMapContinent()
	if not C or C <= 0 then
		return FindDefinition(nil, GetMapInfo(), GetServerMapId())
	end
end

function CustomZones.IsCustomOutdoorZone(name)
	if not name or name == "" then
		return false
	end
	return namesToDef[strlower(name)] ~= nil
end

function CustomZones.IsPlayerInCustomZone()
	return CustomZones.GetDefinitionForPlayer() ~= nil
end

function CustomZones.ShouldTreatAsOutdoor()
	return CustomZones.GetDefinitionForPlayer() ~= nil
end

function CustomZones.GetPlayerZoneName()
	local def = CustomZones.GetDefinitionForPlayer()
	if def then
		return def.name
	end
	return GetPlayerZoneName()
end

function CustomZones.ResolveViewedZone()
	-- Only when the world map itself is on the crater. After .v back the
	-- Orgrimmar city map can still have a leftover crater map file / area
	-- id if we trust those on a stock continent.
	local C = GetCurrentMapContinent()
	if C and C > 0 then
		return
	end
	local def = FindDefinition(nil, GetMapInfo(), nil)
	if def then
		return def.name
	end
	local mapId = GetServerMapId()
	if mapId == 1005 then
		def = FindDefinition(nil, nil, mapId)
		if def then
			return def.name
		end
	end
end

function CustomZones.Register()
	local zoneData = GatherMate.zoneData
	if not zoneData then
		return
	end
	for _, def in ipairs(CustomZoneList) do
		registered[def.token] = def
		namesToDef[strlower(def.name)] = def
		if def.names then
			for name in pairs(def.names) do
				namesToDef[name] = def
			end
		end
		if def.mapFiles then
			for fileName in pairs(def.mapFiles) do
				mapFilesToDef[fileName] = def
			end
		end
		if def.canonicalFile then
			mapFilesToDef[def.canonicalFile] = def
		end
		if def.mapIds then
			for _, mapId in ipairs(def.mapIds) do
				mapIdsToDef[mapId] = def
			end
		end
		local data = { def.width, def.height, def.zoneID }
		zoneData[def.name] = data
	end
end

CustomZones.Register()

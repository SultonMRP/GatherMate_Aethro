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

local function LearnFromCurrentMap(def)
	if not def then
		return
	end
	-- Only learn map file / area id while the client is actually on the
	-- crater (continent -1). An open world map of Elwynn must not be
	-- recorded as AzsharaCrater.
	local C = GetCurrentMapContinent()
	if not C or C <= 0 then
		local mapFile = GetMapInfo()
		if mapFile and mapFile ~= "" and not def.mapFiles[mapFile] then
			def.mapFiles[mapFile] = true
			def.canonicalFile = mapFile
			mapFilesToDef[mapFile] = def
		end
		local mapId = GetServerMapId()
		if mapId and not mapIdsToDef[mapId] then
			mapIdsToDef[mapId] = def
		end
	end
	local zoneName = GetPlayerZoneName()
	if zoneName and zoneName ~= "" then
		local key = strlower(zoneName)
		if not namesToDef[key] then
			def.names[key] = true
			namesToDef[key] = def
			if GatherMate.zoneData then
				GatherMate.zoneData[zoneName] = { def.width, def.height, def.zoneID }
			end
		end
	end
end

function CustomZones.GetDefinitionForPlayer()
	-- Prefer the player's zone name so an open world map of another zone
	-- cannot impersonate the crater, and the crater still matches when
	-- the world map is pointed elsewhere.
	local def = FindDefinition(GetPlayerZoneName(), nil, nil)
	if def then
		LearnFromCurrentMap(def)
		return def
	end
	local C = GetCurrentMapContinent()
	if not C or C <= 0 then
		def = FindDefinition(nil, GetMapInfo(), GetServerMapId())
		if def then
			LearnFromCurrentMap(def)
			return def
		end
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
	local mapFile = GetMapInfo()
	local def = FindDefinition(nil, mapFile, nil)
	if def then
		return def.name
	end
	local C = GetCurrentMapContinent()
	if not C or C <= 0 then
		def = FindDefinition(nil, nil, GetServerMapId())
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

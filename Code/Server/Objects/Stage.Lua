local rs = game:GetService("ReplicatedStorage")

local sharedModules = rs.Modules.Shared
local assets = rs.Assets

local config = require(sharedModules.Configuration)
local funcLib = require(sharedModules.FunctionLibrary)
local mobObj = require(script.Parent.Mob)

local Stage = {}
Stage.__index = Stage

function Stage.new(index, playerObject)
	local self = setmetatable({}, Stage)
	self.Index = index
	self.Mobs = {}
	return self
end

function Stage:SpawnMobs()
	-- configuration
	local mapConfig = config.Maps[self.Index]
	
	-- create mob objects
	for _, position in ipairs(mapConfig.SpawnPositions) do
		local id, _ = funcLib.GetRandomId(mapConfig.MobSpawnChance)
		
		local mobObject = mobObj.new(id, position, self.Index) 
		self.Mobs[mobObject.Id] = mobObject
	end	
end

function Stage:MobCount()
	local counter = 0
	for _, mob in pairs(self.Mobs) do
		counter += 1
	end
	return counter
end

function Stage:FindNearestMob(position)
	if not position then return end
	local mobTable = {}

	for _, mob in pairs(self.Mobs) do
		
		-- TODO: change from basePosition to position later
		local magnitude = (mob.CurrentPosition - position).Magnitude		
		if magnitude < 20 then
			table.insert(mobTable, {MobObject = mob, Magnitude = magnitude})
		end
	end	

	table.sort(mobTable, function(a, b) return a.Magnitude < b.Magnitude end)
	local nearestMob = mobTable[1]
	
	if nearestMob then 
		return nearestMob.MobObject
	end	
end

function Stage:Dispose()
	self = nil
end

return Stage
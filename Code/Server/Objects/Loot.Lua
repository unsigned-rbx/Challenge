local serverScriptService = game:GetService("ServerScriptService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local httpService = game:GetService("HttpService")
local config = require(replicatedStorage.Modules.Shared.Configuration)
local weaponObj = require(serverScriptService.Modules.Objects.Weapon)

local rand = Random.new()

local Loot = {}
Loot.__index = Loot

function Loot:Setup(typeCategory, id, stage)
	local stageMultiplier = stage.Index
	self.LootType = typeCategory
	
	if typeCategory == "Currency" then
		self.Quantity = config.Constants.BASE_GOLD * stageMultiplier
		self.DisplayName = "Coin"		
	elseif typeCategory == "Weapon" then
		local baseDamage = config.Weapon[id].BaseDamage
		self.Object = weaponObj.new(
			httpService:GenerateGUID(false),
			id,
			baseDamage * stageMultiplier,
			false)
		self.DisplayName = config.Weapon[id].Name
	end
end

function Loot.New(typeCategory, id, stage)
	local self = setmetatable({}, Loot)
	self.Identifier = httpService:GenerateGUID(false)
	self.LootType = nil
	self.DisplayName = nil
	self.Quantity = nil

	self:Setup(typeCategory, id, stage)
	return self
end

return Loot

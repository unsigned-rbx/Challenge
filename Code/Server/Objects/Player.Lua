local serverScriptService = game:GetService("ServerScriptService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local modules = serverScriptService.Modules
local objects = modules.Objects
local remote = replicatedStorage.Remote

local config = require(replicatedStorage.Modules.Shared.Configuration)
local funcLib = require(replicatedStorage.Modules.Shared.FunctionLibrary)

local lootObj = require(objects.Loot)
local weaponObj = require(objects.Weapon)

local Player = {}
Player.__index = Player

function Player.new(player, data)
	local self = setmetatable({}, Player)
	
	-- player object
	self.Object = player
	
	-- buffer
	self.Stage = nil
	self.EquippedWeapon = nil
	self.InStage = false
	self.Loot = {}
	self.MaxHealth = 150
	self.CurrentHealth = 150
	
	self.Inventory = self:SetupInventory(data.Inventory)
	self.Statistics = data.Statistics
	self.PlayerStats = data.PlayerStats
	self.Gold = data.Gold
	return self	
end

function Player:SetupInventory(inventory)
	local returnTable = {}
	
	for _, weapon in ipairs(inventory.Weapons) do		
		local weapon = weaponObj.new(weapon.Id, weapon.ModelId, weapon.BaseDamage, weapon.Equipped)
		if weapon.Equipped then
			self.EquippedWeapon = weapon
		end
				
		returnTable[weapon.Id] = weapon 			
	end
	
	return returnTable
end

function Player:ResetCharacterData()
	self.CurrentHealth = self.MaxHealth
	
end

function Player:UpdateHealth(damage)
	self.CurrentHealth -= damage
	
	if self.CurrentHealth <= 0 then
		self.Object:LoadCharacter()
	end
	
	return self.CurrentHealth
end

function Player:AddItemToInventory(weaponObj)
	self.Inventory[weaponObj.Id] = weaponObj
	
	if weaponObj.BaseDamage > self.EquippedWeapon.BaseDamage then
		self:EquipWeapon(weaponObj.Id)
	end
end

function Player:ClaimLoot(identifier)
	local loot = self.Loot[identifier]
	
	if loot then
		if loot.LootType == "Currency" then
			self.Gold += loot.Quantity
			return loot
		elseif loot.LootType == "Weapon" then
			self:AddItemToInventory(loot.Object)
		end
		
		return loot
	end
end

function Player:GenerateLoot()
	local returnTable = {}
	
	for count = 1, config.Constants.MAX_DROPS do 
		local id, lootType = funcLib.GetRandomId(config.Maps[self.Stage.Index].LootTable)	
		local lootObject = lootObj.New(lootType, id, self.Stage)
		
		table.insert(returnTable, {
			Identifier = lootObject.Identifier, 
			Type = lootObject.LootType,
			DisplayName = lootObject.DisplayName
		})
		
		self.Loot[lootObject.Identifier] = lootObject
	end	
	
	return returnTable
end

function Player:UnequipWeapon(id)
	local weapon = self.Inventory[id]
	
	if weapon then
		weapon:Unequip()
		-- TODO: send message to client
	end
end

function Player:EquipWeapon(id)
	self:UnequipWeapon(self.EquippedWeapon.Id)
	local weapon = self.Inventory[id]
	
	if weapon then
		weapon:Equip()
		self.EquippedWeapon = weapon
		remote.Player.Client.EquipWeapon:FireClient(self.Object, weapon)
	end
end

function Player:EquipBestWeapon()
	local tbl = {}
	
	for _, weapon in pairs(self.Inventory) do
		table.insert(tbl, weapon)
	end
	
	table.sort(tbl, function (a, b) return a.BaseDamage > b.BaseDamage end)
	
	self:EquipWeapon(tbl[1].Id)
end

function Player:GetCharacterPosition()
	local character: Model = self.Object.Character
	
	if character then
		return character:GetPivot().Position
	end
end

function Player:GetDamage()
	local weapon = self.EquippedWeapon
	
	if weapon then
		return weapon.BaseDamage
	end
end

return Player
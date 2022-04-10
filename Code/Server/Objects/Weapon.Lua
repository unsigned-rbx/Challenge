local httpService = game:GetService("HttpService")

local Weapon = {}
Weapon.__index = Weapon

function Weapon.new(id, modelId, baseDamage, equipped)
	local self = setmetatable({}, Weapon)

	self.Id = id
	self.ModelId = modelId
	self.BaseDamage = baseDamage
	self.Equipped = equipped
	return self
end

function Weapon:Equip()
	self.Equipped = true
	return self.Equipped
end

function Weapon:Unequip()
	self.Equipped = false
	return self.Equipped
end


return Weapon

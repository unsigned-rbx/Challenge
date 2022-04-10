local Parser = {}

function Inventory(inventoryData)
	local returnTable = { 
		Weapons = {} 
	}
	for _, weapon in pairs(inventoryData) do
		table.insert(returnTable.Weapons, {
			Id = weapon.Id,
			ModelId = weapon.ModelId,
			Equipped = weapon.Equipped,
			BaseDamage = weapon.BaseDamage
		})
	end
	
	return returnTable
end

function Parser.Pack(playerData)
	return {
		Inventory = Inventory(playerData.Inventory),
		Gold = playerData.Gold,
		Statistics = playerData.Statistics,
		PlayerStats = playerData.PlayerStats
	}
end

return Parser
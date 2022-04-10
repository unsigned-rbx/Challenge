local httpService = game:GetService("HttpService")
local Extra = {}

Extra.TestData = {
	Inventory = {
		Weapons = {
			{ Id = httpService:GenerateGUID(false), ModelId = 1, BaseDamage = 20, Equipped = true },
		}
	},
	
	PlayerStats = {
		Strength = 15, -- strength
		Speed = 48
	},
	
	Statistics = {
		FastestRun = 0, -- mobs killed
	},
	Gold = 250
}

Extra.Template = {
	Inventory = {
		Weapons = {}
	},

	PlayerStats = {
		Strength = 0, -- strength
		Speed = 0
	},

	Statistics = {
		FastestRun = 0, -- mobs killed
	},
	
	Gold = 0
}

return Extra

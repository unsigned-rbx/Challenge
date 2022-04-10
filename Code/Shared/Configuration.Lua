local Config = {}

Config.Constants = {
	MAX_DROPS = 8,
	BASE_GOLD = 5
}

Config.Currency = {
	[1] = {
		Name = "Coin",
		Quantity = 1
	}
}

Config.Weapon = {
	[1] = {
		Name = "Justice",
		BaseDamage = 2
	},
	[2] = {
		Name = "Demolisher",
		BaseDamage = 10
	},
	[3] = {
		Name = "Skull Cleaver",
		BaseDamage = 15
	},
	[4] = {
		Name = "Demon Blade",
		BaseDamage = 20
	}
}

Config.Mobs = {
	[1] = {
		Name = "Frost Dragon",
		BaseHealth = 10
	},
	[2] = {
		Name = "Fire Dragon",
		BaseHealth = 20
	}
}

Config.Maps = {
	[1] = {
		Name = "Archipelago",
		LootTable = {
			{ Type = "Currency", Id = 1, Percentage = 0.80 },
			{ Type = "Weapon", Id = 2, Percentage = 0.90 },
			{ Type = "Weapon", Id = 3, Percentage = 1.00 }
		},
		ThumbnailId = 9298723308,
		MobCount = 3,
		SpawnPositions = { -- could be handled with the parts directly, but didn't really like that approach
			Vector3.new(-5505.892, 61.009, 456.543),
			Vector3.new(-5605.299, 66.983, 530.103),
			Vector3.new(-5575.907, 68.218, 700.087)
		},
		MobSpawnChance = {
			{ Type = "Mob", Id = 1, Percentage = 0.60},
			{ Type = "Mob", Id = 2, Percentage = 1.00}
		},
		StartPosition = Vector3.new(-5470.941, 66.904, 406.642)
	},
	[2] = {
		Name = "Castle Planet",
		LootTable = {
			{ Type = "Currency", Id = 1, Percentage = 0.70 },
			{ Type = "Weapon", Id = 3, Percentage = 0.90 },
			{ Type = "Weapon", Id = 4, Percentage = 1.00 }
		},
		ThumbnailId = 9298723308,
		MobCount = 3,
		SpawnPositions = {
			Vector3.new(-642.401, 55.813, 7156.474),
			Vector3.new(-642.401, 65.792, 7252.499),
			Vector3.new(-642.401, 46.682, 7049.649)
		},
		MobSpawnChance = {
			{ Type = "Mob", Id = 1, Percentage = 0.80},
			{ Type = "Mob", Id = 2, Percentage = 1.00}
		},
		StartPosition = Vector3.new(-642.401, 61.853, 6978.849)
		
	},
	[3] = {
		Name = "Northada",
		LootTable = {
			{ Type = "Currency", Id = 1, Percentage = 0.60 },
			{ Type = "Weapon", Id = 3, Percentage = 0.90 },
			{ Type = "Weapon", Id = 4, Percentage = 1.00 }
		},
		ThumbnailId = 9298723308,
		MobCount = 3,
		SpawnPositions = {
			Vector3.new(-3198.206, 255.454, -1185.255),
			Vector3.new(-3381.058, 235.798, -1052.984),
			Vector3.new(-3364.063, 275.331, -1324.297)
		},
		MobSpawnChance = {
			{ Type = "Mob", Id = 1, Percentage = 0.95},
			{ Type = "Mob", Id = 2, Percentage = 1.00}
		},
		StartPosition = Vector3.new(-3503.68, 223.406, -950.71)
	},
	
	[4] = {
		Name = "Hell",
		LootTable = {
			{ Type = "Currency", Id = 1, Percentage = 0.25 },
			{ Type = "Weapon", Id = 1, Percentage = 0.50 },
			{ Type = "Weapon", Id = 2, Percentage = 1.00 }
		},
		ThumbnailId = 9298723308,
		MobCount = 4,
		SpawnPositions = {
			Vector3.new(-1189.486, 3723.619, 8829.688),
			Vector3.new(-1189.486, 3728.107, 8981.316),
			Vector3.new(-1189.486, 3735.538, 9127.494),
			Vector3.new(-1189.486, 3745.051, 9238.502)
		},
		MobSpawnChance = {
			{ Type = "Mob", Id = 1, Percentage = 0.30},
			{ Type = "Mob", Id = 2, Percentage = 1.00}
		},
		StartPosition = Vector3.new(-1189.486, 3732.992, 8705.05)
	},
	[5] = {
		Name = "Volcano",
		LootTable = {
			{ Type = "Currency", Id = 1, Percentage = 0.25 },
			{ Type = "Weapon", Id = 1, Percentage = 0.50 },
			{ Type = "Weapon", Id = 2, Percentage = 1.00 }
		},
		SpawnPositions = {
			Vector3.new(-7731.232, 96.714, 474.448),
			Vector3.new(-7761.808, 118.545, 246.304),
			Vector3.new(-7662.461, 107.965, 362.779),
		},
		MobSpawnChance = {
			{ Type = "Mob", Id = 1, Percentage = 0.05},
			{ Type = "Mob", Id = 2, Percentage = 1.00}
		},
		ThumbnailId = 9298723308,
		MobCount = 3,
		StartPosition = Vector3.new(-7832.153, 108.79, 462.657)
	},
}

return Config

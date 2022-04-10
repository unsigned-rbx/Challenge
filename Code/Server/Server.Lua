-- services
local serverScriptStorage = game:GetService("ServerScriptService")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- folder
local modules = serverScriptStorage.Modules
local sharedModule = replicatedStorage.Modules.Shared

local scheduler = require(sharedModule.Scheduler)
local playersManager = require(modules.PlayersManager)
local dataHandler = require(modules.DataHandler)

-- modules
local serverEvent = require(modules.ServerEvent)

function Initialize()
	serverEvent.Initialize()
end

Initialize()

-- triggering the attack
scheduler.Connect("AttackSequence", function()
	for _, playerObj in pairs(playersManager.Players) do
		local stage = playerObj.Stage
		if not stage then continue end
	
		for _, mob in pairs(stage.Mobs) do
			if mob.CurrentlyAttacking then continue end
			mob:GenerateAttackSequence(playerObj.Object)
		end
	end
end, 0.5)

scheduler.Connect("AutoSave", function()
	for _, playerObj in pairs(playersManager.Players) do
		dataHandler.SetData(playerObj.Object, playerObj)		
	end
end, 15)

scheduler.Start()

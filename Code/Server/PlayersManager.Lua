local serverScriptService = game:GetService("ServerScriptService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local players = game:GetService("Players")

-- folders
local modules = serverScriptService.Modules
local objects = modules.Objects

-- objects
local playerObj = require(objects.Player)
local dataModule = require(modules.DataHandler)

local PlayersManager = {}
PlayersManager.Players = {}

function PlayersManager.SetupPlayer(player: Player)
	local data = dataModule.GetData(player)
	
	PlayersManager.Players[player.UserId] = playerObj.new(player, data)	
	return PlayersManager.Players[player.UserId]
end

return PlayersManager

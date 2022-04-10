local starterPlayer = game:GetService("StarterPlayer")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local players = game:GetService("Players")

local remote = replicatedStorage.Remote
local modules = replicatedStorage.Modules
local sharedModules = modules.Shared

local guiModule = require(modules.GUI)
local localPlayer = players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

guiModule.ShowLoadingScreen("Game")
guiModule.UpdateLoadingScreenTask("Importing Modules")

local event = require(modules.ClientEvent)
event.Initialize()

local drops = require(modules.Animations.Drops)
local funcLib = require(sharedModules.FunctionLibrary)
local preLoading = require(modules.PreLoading)
local playerObj = require(modules.Player)
local scheduler = require(sharedModules.Scheduler)

local function Initialize()
	guiModule.UpdateLoadingScreenTask("Setting up Events")
	preLoading.InitializeAssets()
end
Initialize()

scheduler.Connect("collect", function()
	if localPlayer.Character then
		drops.Collect(localPlayer.Character)	
	end
end, 0.1)

scheduler.Start()
guiModule.HideLoadingScreen()


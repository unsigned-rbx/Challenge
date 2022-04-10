local rs = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

-- player
local player = players.LocalPlayer
local character = player.Character

-- folders
local modules = rs.Modules
local sharedModules = modules.Shared
local dispose = workspace.Dispose
local assets = rs.Assets
local remote = rs.Remote

-- modules
local config = require(sharedModules.Configuration)
local mobsAnimation = require(modules.Animations.Mobs)
local drops = require(modules.Animations.Drops)
local funcLib = require(sharedModules.FunctionLibrary)

local userInterface = require(modules.GUI)

local StageHandler = {}
StageHandler.CurrentPlayingSoundTrack = nil
StageHandler.CurrentIndex = nil

function StageHandler.HidePlayers()
	for _, player in pairs(players:GetPlayers()) do
		if player == players.LocalPlayer then continue end
		
		local character = player.Character or player.CharacterAdded:Wait()
		funcLib.StoreModelState(character)
		funcLib.TweenModel(character, "Transparency", 1, 0, false, false)
	end
end

function StageHandler.ShowPlayers()
	for _, player in pairs(players:GetPlayers()) do
		local character = player.Character or player.CharacterAdded:Wait()
		funcLib.LoadModelState(character)
	end
end

function StageHandler.RequestStart(stageObject)
	userInterface.ShowLoadingScreen(stageObject.Index)
	userInterface.UpdateLoadingScreenTask("Setting up Map")
	assets.Audio.LoadingScreen:Play()
	
	local button: GuiButton = userInterface.GetButton("StartButton")
	button.Visible = false
	
	local nextStage: GuiButton = userInterface.GetButton("NextStage")
	nextStage.Visible = false
	
	-- configuration
	local mapConfig = config.Maps[stageObject.Index]
	local mapAssets = assets.Maps[mapConfig.Name]
	local backgroundMusic = assets.Audio.StageBackgroundMusic
	
	-- Set up Map
	local map = mapAssets:Clone()
	map.Name = string.format("StageMap")
	map.Parent = workspace.Dispose
	
	-- set up skybox
	local skybox = map:FindFirstChild("Skybox")
	if skybox then
		local oldSkybox = game.Lighting:FindFirstChild("Skybox") 
		if oldSkybox then oldSkybox:Destroy() end
		skybox.Parent = game.Lighting
	end
	
	StageHandler.CurrentIndex = stageObject.Index
	
	task.wait(1)
	
	-- teleport player to start
	character:PivotTo(CFrame.new(map.Start.Position))	
	
	StageHandler.HidePlayers()
	
	-- set up panel
	userInterface.SetupRunDetails(stageObject.Index)
	
	-- set up mob objects
	for _, mobData in pairs(stageObject.Mobs) do
		mobsAnimation.Spawn(mobData)		
	end	
	
	task.wait(6) -- dramatic pause, so the music can finish
	userInterface.HideLoadingScreen()
	StageHandler.CurrentPlayingSoundTrack = backgroundMusic[stageObject.Index]
	StageHandler.CurrentPlayingSoundTrack:Play()
end

function StageHandler.Dispose(quit)
	character:PivotTo(CFrame.new(15,15,15))
	local previousMap = workspace.Dispose:FindFirstChild("StageMap")
	
	if StageHandler.CurrentPlayingSoundTrack then
		StageHandler.CurrentPlayingSoundTrack:Stop()
	end
	
	if quit then userInterface.Reset() end
	
	if previousMap then
		mobsAnimation.DisposeAll()
		drops.DisposeAll()
		previousMap:Destroy()
	end
	
	local oldSkybox = game.Lighting:FindFirstChild("Skybox") 
	if oldSkybox then oldSkybox:Destroy() end
end

return StageHandler

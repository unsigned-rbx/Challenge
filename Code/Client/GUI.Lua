local replicatedStorage = game:GetService("ReplicatedStorage")
local starterGui = game:GetService("StarterGui")
local players = game:GetService("Players")

local remote = replicatedStorage.Remote
local screenGui = starterGui:WaitForChild("ScreenGui")

local config = require(replicatedStorage.Modules.Shared.Configuration)
local scheduler = require(replicatedStorage.Modules.Shared.Scheduler)

local player = players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
screenGui = playerGui:WaitForChild("ScreenGui")

local loadingScreen = screenGui.Full.LoadingScreen
local runDetails = screenGui.Right.RunDetails

local runDetailsInfo = {
	GoldGathered = 0,
	MobsLeft = 0,
	secondsElapsed = {
		Started = nil,
		CurrentTime = nil
	}
}

local GUI = {}

GUI.Buttons = {
	[screenGui.Top.Start] = function()
		remote.Stage.Server.RequestStart:FireServer()
	end,
	[screenGui.Right.RunDetails.NextStage] = function()
		remote.Stage.Server.RequestNext:FireServer()
	end,
	[screenGui.Right.RunDetails.QuitButton] = function()
		remote.Stage.Server.RequestQuit:FireServer()
	end,
}


function GUI.ShowLoadingScreen(input)
	local value 
	if input == "Game" then
		value = input
	else
		local mapConfig = config.Maps[input]
		value = mapConfig.Name
	end
	
	loadingScreen.Visible = true
	loadingScreen.DetailLabel.Text = string.format("Into %s", value)
	loadingScreen.BackgroundImage.Image = string.format("rbxgameasset://Images/%s", input)  
end

function GUI.UpdateLoadingScreenTask(message)
	loadingScreen.MessageLabel.Text = message
end

function GUI.HideLoadingScreen()
	loadingScreen.Visible = false
end

function GUI.InitializeButtons()
	screenGui.Top.Start.Visible = true
	
	for button: GuiButton, call in pairs(GUI.Buttons) do
		button.MouseButton1Down:Connect(call)
	end
end

function GUI.SetupRunDetails(zoneIndex)
	local mapConfig = config.Maps[zoneIndex]
	runDetails.Visible = true
	runDetails.Thumbnail.ImageLabel.Image = string.format("rbxassetid://%s", tostring(mapConfig.ThumbnailId))
	
	local stageFrame = runDetails.StageFrame
	local totalStatsFrame = runDetails.TotalStats
	
	if runDetailsInfo.GoldGathered == 0 then
		totalStatsFrame.TotalGold.Value.Text = "0g"
	end
	
	stageFrame.MobsLeft.Value.Text = mapConfig.MobCount
	stageFrame.CurrentStage.Value.Text = mapConfig.Name
	
	if not runDetailsInfo.secondsElapsed.Started then
		runDetailsInfo.secondsElapsed.Started = os.clock()
		
		scheduler.Connect("UpdateElapsedTime", function()
			if not totalStatsFrame:FindFirstChild("ElapsedTime") then return end
			local secondsElapsed = runDetailsInfo.secondsElapsed
			totalStatsFrame.ElapsedTime.Value.Text = string.format("%ss", tostring(math.floor(os.clock() - secondsElapsed.Started)))
		end, 1)		
	end
end

function GUI.UpdateRunDetails(statType, value)
	local stageFrame = runDetails.StageFrame
	local totalStatsFrame = runDetails.TotalStats
	
	if statType == "Gold" then
		runDetailsInfo.GoldGathered += value	
		totalStatsFrame.TotalGold.Value.Text = tostring(runDetailsInfo.GoldGathered .. "g")
	elseif statType == "MobsLeft" then
		stageFrame.MobsLeft.Value.Text = value
		
		if value == 0 then
			screenGui.Right.RunDetails.NextStage.Visible = true
		end
	end
end

function GUI.SetupNameplate(nameplate, name, maxHealth)
	if not nameplate then
		nameplate = screenGui.Bottom.PlayerHealthBar
	end
	
	nameplate.NameLabel.Text = name
	nameplate.Background.AmountText.Text = string.format("%d / %d", maxHealth, maxHealth)
	
	local healthFrame: Frame = nameplate.Background.Health
	healthFrame:TweenSize(UDim2.new(maxHealth / maxHealth, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad)
end

function GUI.UpdateNameplate(nameplate, currentHealth, maxHealth)
	if not screenGui:FindFirstChild("Bottom") then return end
	if currentHealth < 0 then currentHealth = 0 end
	
	
	if not nameplate then
		nameplate = screenGui.Bottom.PlayerHealthBar
	end
	
	nameplate.Background.AmountText.Text = string.format("%d / %d", currentHealth, maxHealth)
	local healthFrame: Frame = nameplate.Background.Health
	healthFrame.Size = UDim2.new(currentHealth / maxHealth, 0, 1, 0)
end

function GUI.GetButton(name)
	local returnVariable = nil
	if name == "NextStage" then
		returnVariable = screenGui.Right.RunDetails.NextStage
	elseif name == "StartButton" then
		returnVariable = screenGui.Top.Start
	end
	
	return returnVariable
end

function GUI.Reset()
	scheduler.Disconnect("UpdateElapsedTime")
	
	screenGui.Right.RunDetails.Visible = false
	screenGui.Right.RunDetails.Thumbnail.ImageLabel.Image = ""
	runDetailsInfo = {
		GoldGathered = 0,
		MobsLeft = 0,
		secondsElapsed = {
			Started = nil,
			CurrentTime = nil
		}
	}
	
	screenGui.Right.RunDetails.NextStage.Visible = false
	screenGui.Top.Start.Visible = true
end

function GUI.AddNotification(fromPlayer, message, messageType)
	--guiModule.AddNotification(true, string.format("[Target] -%s HP", damage), "Damage")
	coroutine.wrap(function()
		local color = Color3.new(1, 1, 1)

		if messageType == "Damage" then
			color = Color3.new(1, 0.227451, 0.239216)
		elseif messageType == "Loot" then
			color = Color3.new(0, 0.882353, 0)
		elseif messageType == "Equipped" then
			color = Color3.new(0.737255, 0.643137, 0.627451)
		end
		
		local messageLbl = script.Label:Clone()
		messageLbl.Parent = screenGui.Full
		local startPos = UDim2.new(0.201, 0, 0.897, 0)
		
		
		if fromPlayer then
			startPos = UDim2.new(0.648, 0,0.897, 0)
			messageLbl.TextXAlignment = Enum.TextXAlignment.Right
		end
		
		messageLbl.Position = startPos
		messageLbl.Text = string.format("[%s]: %s", messageType, message)
		messageLbl.TextColor3 = color
		
		messageLbl:TweenPosition(
			UDim2.new(startPos.Width, 0, 0.1, 0),
			Enum.EasingDirection.In,
			Enum.EasingStyle.Quad,
			3)
		task.wait(3)
		
		messageLbl:Destroy()
	end)()
end

return GUI

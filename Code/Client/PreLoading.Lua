local replicatedStorage = game:GetService("ReplicatedStorage")
local collisionService = game:GetService("CollectionService")

local sharedModules = replicatedStorage.Modules.Shared
local funcLib = require(sharedModules.FunctionLibrary)
local guiModule = require(replicatedStorage.Modules.GUI)

-- folders
local assets = replicatedStorage.Assets

local distancedPosition = Vector3.new(1e35, 1e35, 1e35)
local PreLoading = {}

PreLoading.Assets = {
	Mobs = {},
	Drops = {},
	Weapons = {}
}

function PreLoading.PrepareNameplate(mobModel: Model)
	local primaryPart = mobModel.PrimaryPart

	if primaryPart then
		local nameplate = script.Nameplate:Clone()
		local offset = primaryPart:GetAttribute("Offset") or Vector3.new(0,0,0)
		nameplate.StudsOffset += offset
		nameplate.Parent = primaryPart
	end	
end

function PreLoading.InitializeAnimation(animationName, priority, clone, animationObject)
	local animationController = clone.Humanoid
	local animator = animationController.Animator
		
	local animation: AnimationTrack = animator:LoadAnimation(animationObject)
	animation.Priority = priority
	return animation
end

function PreLoading.InitializeAnimations(clone, folder)
	--if not folder:FindFirstChild("Animations") then return end
	local initializedAnimations = {}
	
	local animationType = folder:GetAttribute("AnimationType")
	if not animationType then return end 
	local path = assets.Animations:FindFirstChild(animationType)
	if not path then return end 
	
	for _, animation: Animation in pairs(path:GetChildren()) do
		local priority = animation:GetAttribute("Priority")
		
		if priority and Enum.AnimationPriority[priority] then
			initializedAnimations[animation.Name] = PreLoading.InitializeAnimation(animation.Name, Enum.AnimationPriority[priority], clone, animation)
		else
			warn(string.format("Priorty not found for %s, animation not initialized", animation.Name))
		end
	end
	
	return initializedAnimations
end

function PreLoading.InitializeType(dataType, maxClones)
	if not assets[dataType] or not PreLoading.Assets[dataType] then return end		
	local cachedAsset = funcLib.GetFolder(workspace.Cache, dataType)
	local assetData = PreLoading.Assets[dataType]
	local loadAnimations = assets[dataType]:GetAttribute("LoadAnimations")
	
	for _, folder in pairs(assets[dataType]:GetChildren()) do
		assetData[folder.Name] = {}
		local category = funcLib.GetFolder(cachedAsset, folder.Name)
		local model: Model = folder.Model
		
		if dataType == "Mobs" then
			--funcLib.SetCollisionGroup(model, dataType)
			funcLib.StoreModelState(model)
		end
		
		for count = 1, maxClones do
			guiModule.UpdateLoadingScreenTask(string.format("Preloading Assets [%s->%s:%d]", dataType, folder.Name, count))
			local clone = model:Clone()
			clone:SetAttribute("Type", dataType)
			clone:SetAttribute("Category", folder.Name)
			
			clone:PivotTo(CFrame.new(distancedPosition))
			clone.Name = "_"			
			clone.Parent = category	
			
			assetData[folder.Name][clone] = {}			
			if loadAnimations then
				PreLoading.PrepareNameplate(clone)
				assetData[folder.Name][clone]["Animations"] = PreLoading.InitializeAnimations(clone, folder)
			end
			
			-- prevent throttling
			if (count % 3 == 0) then
				task.wait(0)
			end
		end	
	end
end

function PreLoading.Unload(model)
	local modelType = model:GetAttribute("Type")
	local modelCategory = model:GetAttribute("Category")
	local modelInformation = PreLoading.Assets[modelType][modelCategory][model]
	model.PrimaryPart.Anchored = true 
	
	-- animations
	if modelInformation["Animations"] then
		for _, animation in pairs(modelInformation["Animations"]) do
			if animation:IsA("AnimationTrack") then
				animation:Stop()
				
				if animation.Name == "Death" then
					animation:AdjustSpeed(1)
				end
			end
		end
		
		model.Humanoid:MoveTo(model:GetPivot().Position)
	end
	
	model.Parent = workspace.Cache[modelType][modelCategory]
	model:PivotTo(CFrame.new(distancedPosition))
	
	coroutine.wrap(function()
		task.wait(10)
		model.Name = "_"
	end)()
	return true
end

function PreLoading.FindCandidate(dataType, name)
	local asset = PreLoading.Assets[dataType][name]
	if not asset then return end
	for clone: Model, values in pairs(asset) do
		if clone.Name ~= "_" then continue end
		clone.Name = "__"
		return clone, values.Animations
	end	
end

function PreLoading.InitializeAssets()	
	PreLoading.InitializeType("Mobs", 10)
	PreLoading.InitializeType("Drops", 300)	
end

return PreLoading

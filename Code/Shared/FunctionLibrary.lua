local physicsService = game:GetService("PhysicsService")
local tweenService = game:GetService("TweenService")
local rand = Random.new()

local rotation = {}
local connections = {}
local cache = { OriginalColorList = {} }

local FunctionLibrary = {}

-- get a random ID from a chance table
function FunctionLibrary.GetRandomId(chanceTable)
	if not chanceTable then return end
	
	local randomNumber = rand:NextNumber(0, 1)
	local previousValue

	for i, entry in ipairs(chanceTable) do
		if i == 1 then previousValue = 0
		else
			previousValue = chanceTable[i-1].Percentage
		end 

		if randomNumber >= previousValue and randomNumber <= entry.Percentage then
			return entry.Id, entry.Type
		end
	end	
end

-- sets the collisiongroup of a model to a group
function FunctionLibrary.SetCollisionGroup(character, group)
	for _, child in pairs(character:GetDescendants()) do
		if child:IsA("BasePart") or child:IsA("MeshPart") then
			physicsService:SetPartCollisionGroup(child, group)
		end
	end
end

-- get folder, if not found; then create
function FunctionLibrary.GetFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	
	if folder then
		return folder
	else
		local newFolder = Instance.new("Folder")
		newFolder.Name = name
		newFolder.Parent = parent
		return newFolder
	end
end

-- animate all baseparts in a module based on input
function FunctionLibrary.TweenModel(model, property, value, timeInSeconds, inOut, shouldDestroy)
	local originalColorList = cache.OriginalColorList
	for _, part in pairs(model:GetDescendants()) do
		if connections[part] and originalColorList[part] then		
			part.Color = originalColorList[part]
			connections[part]:Disconnect()
		end

		if (part:IsA("BasePart") or part:IsA("MeshPart")) then			
			local tweenInfo = TweenInfo.new(timeInSeconds, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, inOut, 0)
			if not originalColorList[part] then originalColorList[part] = part.Color end

			local tween = tweenService:Create(part, tweenInfo, {[property] = value })
			connections[part] = tween.Completed:Connect(function()
				if shouldDestroy then 
					task.wait(0.2)
					model:Destroy() 
				end

				connections[part]:Disconnect()
			end)

			tween:Play()
		end
	end
end

-- save color state
function FunctionLibrary.StoreModelState(model)
	for _, part: BasePart in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part:SetAttribute("Color", part.Color)
			part:SetAttribute("Transparency", part.Transparency)
		end
	end
end

-- load original color
function FunctionLibrary.LoadModelState(model)
	for _, part: BasePart in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local color = part:GetAttribute("Color")
			local transparency = part:GetAttribute("Transparency")
			if color then 
				part.Color = color	
			end
			
			if transparency then
				part.Transparency = transparency
			end
		end
	end
end


return FunctionLibrary

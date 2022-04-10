local runService = game:GetService("RunService")
local rs = game:GetService("ReplicatedStorage")

--- gets the current script environment
-- @return: script environment
local function GetScriptType()
	if runService:IsServer() then
		return "Server"
	else
		return "Client"
	end
end

--- sets up all of the remote events / functions
-- @param category: all valid categories
-- @param folderRemotes: collection of remote event/function objects
local function SetupEvents(category, folderRemotes, scriptType)
	for _, event: RemoteEvent|RemoteFunction in pairs(folderRemotes) do
		local remote = category[event.Name]		
		if not remote then 
			warn(string.format("%s event has not yet been defined in code.", event.Name))
			continue 
		end

		if event:IsA("RemoteEvent") then 
			if scriptType == "Server" then 
				event.OnServerEvent:Connect(remote)
			else
				event.OnClientEvent:Connect(remote)
			end
		elseif event:IsA("RemoteFunction") then 
			if scriptType == "Server" then 
				event.OnServerInvoke = remote
			else
				event.OnClientInvoke = remote
			end
		else
			event.Event:Connect(remote)
		end
	end
end

--- iterates and verifies the category folders / keys
-- @param categories: collection of category folders
-- @param scriptType: current script environment
local function SetupCategories(categories, scriptType, remote)
	for _, remoteCategory: Folder in pairs(categories) do
		local remoteFolder = remoteCategory:FindFirstChild(scriptType)
		local eventCategory = remote[remoteCategory.Name]

		if not remoteFolder or not eventCategory then 
			warn(string.format("Category %s not yet implemented for %s.", remoteCategory.Name, string.lower(scriptType)))
			continue 
		else
			SetupEvents(eventCategory, remoteFolder:GetChildren(), scriptType)
		end		
	end
end

local InitRemotes = {}

function InitRemotes.Initialize(remote)
	local scriptType = GetScriptType()
	local categoryFolders = rs.Remote:GetChildren()

	SetupCategories(categoryFolders, scriptType, remote)
end

return InitRemotes

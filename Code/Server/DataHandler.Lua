local dsService = game:GetService("DataStoreService")
local httpService = game:GetService("HttpService")

local extra = require(script.Extra)
local parser = require(script.Parser)

local DATASTORE_NAME = "Main"
local DATASTORE_NAME_TEST = "Test"
local MAX_RETRIES = 3
local playerStore = dsService:GetDataStore(DATASTORE_NAME_TEST)
local attempts = {}

local DataHandler = {}
DataHandler.PlayerDebounce = {}

DataHandler.Template = extra.Template
DataHandler.TestData = extra.TestData

function DataHandler.DeepCheck(v, data)
	if type(v) == "table" then
		for key, value in pairs(v) do
			if data[key] == nil then
				data[key] = value
				continue
			else
				DataHandler.DeepCheck(v[key], data[key])
			end
		end
	else
		data = v
	end
end

function DataHandler.GetData(player: Player)
	local success, playerData = pcall(function()
		return playerStore:GetAsync(player.UserId)
	end)

	if not playerData then
		playerData = DataHandler.Template			
		table.insert(playerData.Inventory.Weapons, {
			Id = httpService:GenerateGUID(false), 
			ModelId = 1, 
			BaseDamage = 1, 
			Equipped = true
		})			
	else	
		DataHandler.DeepCheck(DataHandler.Template, playerData)
	end

	return playerData	
end

function DataHandler.SetData(player: Player, playerData)
	local userDebounce = DataHandler.PlayerDebounce[player.UserId] 
	if userDebounce and os.clock() < (userDebounce + 5) then return end
	DataHandler.PlayerDebounce[player.UserId] = os.clock()
	
	if typeof(playerData) ~= "table" then return end
	playerData = parser.Pack(playerData)

	DataHandler.DeepCheck(DataHandler.Template, playerData)

	local success, playerData = pcall(function()
		return playerStore:UpdateAsync(tostring(player.UserId), function()
			return playerData
		end)
	end)

	if success then
		warn(string.format("[DataStorage]: Successfully saved %s's data.", player.Name))
	else
		warn(string.format("[DataStorage]: Couldn't save %s's data.", player.Name))
	end
end

return DataHandler

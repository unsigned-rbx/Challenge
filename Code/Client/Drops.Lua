local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")

local preLoading = require(replicatedStorage.Modules.PreLoading)
local gui = require(replicatedStorage.Modules.GUI)

local remote = replicatedStorage.Remote

-- folders
local drops = replicatedStorage.Assets.Drops
local audio = replicatedStorage.Assets.Audio

-- variables
local rand = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.CollisionGroup = "Floor"

local Drops = {}
Drops.Collection = {}

local positional = Instance.new("Part")
positional.Transparency = 1
positional.Anchored = true
positional.CanCollide = false
positional.Size = Vector3.new(1,1,1)


local attachment = Instance.new("Attachment")
attachment.Parent = positional

function Drops.FindPosition(initialPosition)
	while task.wait() do
		local position = initialPosition + Vector3.new(
			rand:NextInteger(-12, 12), 25,
			rand:NextInteger(-12, 12)
		)
		
		local result = workspace:Raycast(position, Vector3.new(0, -40, 0), raycastParams)
		if result then
			return result.Position + Vector3.new(0, 1, 0)
		end
	end
end

function Drops.GetPositions(initialPosition, count)
	for i = 1, count do
		local position = Drops.FindPosition(initialPosition)
		
		local temp = Instance.new("Part")
		temp.Transparency = 1
		temp.Anchored = true
		temp.CanCollide = false
		temp.Parent = workspace.Dispose
		temp.Position = position
		
		local coin = drops.Coin.Model:Clone()
		coin:PivotTo(CFrame.new(initialPosition))
		coin.Parent = workspace.Loot
		coin.PrimaryPart.AlignPosition.Attachment1 = attachment
		audio.CoinPickup:Play()
	end
end

-- spawns the loot
function Drops.Spawn(initialPosition, data)
	for _, drop in pairs(data) do
	
		local coin = preLoading.FindCandidate("Drops", drop.DisplayName)
		coin.Parent = workspace.Loot
		Drops.Collection[drop.Identifier] = coin
		coin:SetAttribute("Created", os.clock())
	
		coin:PivotTo(CFrame.new(initialPosition))
		coin.PrimaryPart.Anchored = false
		coin.Name = drop.Identifier
		
		-- positional
		local positionalPart = positional:clone()
		positionalPart.Position = Drops.FindPosition(initialPosition)
		positionalPart.Parent = workspace.Dispose
		
		local offset = coin:GetAttribute("Offset")
		
		local attachment:Attachment = coin.PrimaryPart.AlignPosition.Attachment1
		
		if offset then
			positionalPart.Position += Vector3.new(0, offset, 0)
		end
		
		coin.PrimaryPart.AlignPosition.Attachment1 = positionalPart.Attachment
	end
end

-- resets the state before storing the model again
function Drops.ResetState(model, alignPosition)
	model.Parent = workspace.Cache
	Drops.Collection[model.Name] = nil
	model.Main.Anchored = true
	alignPosition.Attachment1 = nil
	alignPosition.MaxForce = 1e4
	alignPosition.Responsiveness = 10
end

-- unloads all of the loot
function Drops.DisposeAll()
	for _, coin: Model in pairs(Drops.Collection) do
		local main = coin:FindFirstChild("Main")
		local alignPosition: AlignPosition = main:FindFirstChild("AlignPosition")
		
		Drops.ResetState(coin, alignPosition)
		
		if preLoading.Unload(coin) then
			Drops.Collection[coin.Name] = nil
		end
	end
end

-- claim loot (confirmed with payload to server)
function Drops.Claim(model, alignPosition)
	local data = Drops.Collection[model.Name]
	if not data then end
	
	Drops.ResetState(model, alignPosition)
	
	local result = remote.Loot.Server.ClaimLoot:InvokeServer(model.Name)
	
	if result then 
		if  result.LootType == "Currency" then
			gui.UpdateRunDetails("Gold", result.Quantity)
			replicatedStorage.Assets.Audio.CoinPickup:Play()
			
			gui.AddNotification(
				false, 
				string.format("+%s Gold", tostring(result.Quantity)), 
				"Loot"
			)
		else
			gui.AddNotification(
				false, 
				string.format("+%s (%s)", result.DisplayName, tostring(result.Object.BaseDamage)), 
				"Loot"
			)
		end
	end
	
	if preLoading.Unload(model) then
		Drops.Collection[model.Name] = nil
	end
end


function Drops.Collect(character: Model)
	for _, coin: Model in pairs(Drops.Collection) do
		local createdAttribute = coin:GetAttribute("Created")
		
		if not createdAttribute or os.clock() < createdAttribute+1.5  then
			continue
		end
		
		local distance = (coin:GetPivot().Position - character:GetPivot().Position).Magnitude
		local main = coin:FindFirstChild("Main")
		local alignPosition: AlignPosition = main:FindFirstChild("AlignPosition")
		local upperTorso = character:FindFirstChild("UpperTorso")
		
		if distance < 5 then
			Drops.Claim(coin, alignPosition)
		elseif distance < 25 then
			
			alignPosition.MaxForce = 3e4
			alignPosition.Responsiveness = 40
			alignPosition.Attachment1 = upperTorso:FindFirstChild("NeckAttachment")
		end 
	end
end

return Drops

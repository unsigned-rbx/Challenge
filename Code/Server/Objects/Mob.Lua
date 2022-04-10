local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")

local sharedModules = replicatedStorage.Modules.Shared
local remote = replicatedStorage.Remote

local scheduler = require(sharedModules.Scheduler)
local config = require(sharedModules.Configuration)
local rand = Random.new()
local mobClientRemote = remote.Animation.Client.Mob
local raycast = RaycastParams.new()

local Mob = {}
Mob.__index = Mob

function Mob:GetMaxHealth(stageIndex)
	local random = rand:NextNumber(1, 3)
	return config.Mobs[self.ModelId].BaseHealth * (stageIndex + random)
end

function Mob.new(mobId, position, stageIndex)
	local self = setmetatable({}, Mob)
	
	self.BasePosition = position
	self.CurrentPosition = self.BasePosition
	
	-- setup
	self.Id = httpService:GenerateGUID(false)		
	self.ModelId = mobId
	
	-- stats
	self.IsDead = false
	self.CurrentlyAttacking = false
	self.MaxHealth = self:GetMaxHealth(stageIndex)
	self.CurrentHealth = self.MaxHealth
	self.PreviousFinishedAttackTime = os.clock()
	return self
end

function Mob:GetLoot()
	return self.Stage.PlayerObject:GenerateLoot(20)
end

function Mob:Damage(damage) 	
	local previousHealth = self.CurrentHealth
	self.CurrentHealth -= damage
	
	if self.CurrentHealth <= 0 then
		self.IsDead = true	
	end
	
	return { Object = self, PreviousHealth = previousHealth, Damage = damage}
end

function Mob:GetAttackType()
	local defaultAttack = "WingBeat"
	
	if rand:NextNumber(0, 1) >= 0.5 then
		defaultAttack = "FireBreath"
	end

	return defaultAttack
end

function Mob:DamagePlayer(attackType, character: Model, newPosition: Vector3, direction, oldCharacterPosition, player)
	if attackType == "FireBreath" then			
		scheduler.Connect("DragonPlayerAttack", function() 
			local result = workspace:Raycast(newPosition, -direction * 15, raycast)
			if result then
				remote.Player.Server.UpdateHealth:Fire(player, 10)
			end
		end, 0.3)	
	elseif attackType == "WingBeat" then
		if (character:GetPivot().Position - oldCharacterPosition).Magnitude < 10 then
			task.wait(0.6) remote.Player.Server.UpdateHealth:Fire(player, 10)
		end
	end
	
	task.wait(1.5)
end

function Mob:UpdatePosition(original, frequency, distanceBetween, targetPosition, direction)
	local splitUpdate = original / frequency
	local currentDistance = targetPosition / frequency
	for i = 1, frequency do
		self.CurrentPosition = targetPosition + (direction * (frequency-i))
		task.wait(splitUpdate)
	end
end

function Mob:GenerateAttackSequence(player: Player)
	local character = player.Character
	if not character or os.clock() < (self.PreviousFinishedAttackTime + 0.5) then return end
	
	local characterPosition = character:GetPivot().Position
	local mobPlayerDistance = player:DistanceFromCharacter(self.CurrentPosition)
	local basePlayerDistance = player:DistanceFromCharacter(self.BasePosition)
	local maxDistance = 50
	local walkingSpeed = 16
	
	if (mobPlayerDistance < maxDistance) and (basePlayerDistance < maxDistance) then	
		self.CurrentlyAttacking = true		
		
		local distance = 10 -- studs away from destination
		local direction = (self.CurrentPosition - characterPosition).Unit
		local newPosition = characterPosition + (direction * distance)
		local attackType = self:GetAttackType()
	
		mobClientRemote:FireClient(player, {
			Id = self.Id,
			Position = newPosition,
			AttackType = attackType
		}, "Move")
		
		coroutine.wrap(function()
			self:UpdatePosition(mobPlayerDistance / walkingSpeed, 50, mobPlayerDistance, newPosition, direction)
			self:DamagePlayer(attackType, character, newPosition, direction, characterPosition, player)
			scheduler.Disconnect("DragonPlayerAttack")
		
			self.CurrentlyAttacking = false
			self.PreviousFinishedAttackTime = os.clock()
		end)()
	elseif (self.BasePosition - self.CurrentPosition).Magnitude > 15 then
		mobClientRemote:FireClient(player, {
			Id = self.Id,
			Position = self.BasePosition
		}, "Move")
		
		self.CurrentPosition = self.BasePosition
	end
end
return Mob
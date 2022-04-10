local replicatedStorage = game:GetService("ReplicatedStorage")
local physicsService = game:GetService("PhysicsService")
local pathfindingService = game:GetService("PathfindingService")

local modules = replicatedStorage.Modules
local sharedModules = modules.Shared
-- modules
local config = require(sharedModules.Configuration)
local funcLib = require(sharedModules.FunctionLibrary)
local guiModule = require(replicatedStorage.Modules.GUI)
local remote = replicatedStorage.Remote

local preLoading = require(replicatedStorage.Modules.PreLoading)

local mobsAsset = replicatedStorage.Assets.Mobs
local drops = require(script.Parent.Drops)
local dragonEffects = replicatedStorage.Assets.Audio.DragonEffects

-- workspace
local cache = workspace.Cache

-- replicatedStorage
local mobsFolder = replicatedStorage.Assets.Mobs

local Mobs = {}
Mobs.Collection = {}

function Mobs.Spawn(data)
	local mobData = Mobs.Collection[data.Id]
	if mobData then return end
	
	-- fetch object
	local mobInfo = config.Mobs[data.ModelId]
	local mob, animations = preLoading.FindCandidate("Mobs", mobInfo.Name)
	
	funcLib.LoadModelState(mob)
	
	-- nameplates
	guiModule.SetupNameplate(mob.PrimaryPart.Nameplate, mobInfo.Name, data.MaxHealth)
	
	-- position
	mob:PivotTo(CFrame.new(data.BasePosition + Vector3.new(0, 3, 0)))
	mob.Name = data.Id	
	mob.Parent = workspace.Mobs
	mob.PrimaryPart.Anchored = false
	
	-- identifiy
	Mobs.Collection[data.Id] = {
		Object = mob,
		Animations = animations
	}

	-- setupAnimation
	local animation = animations.Idle
	animation.Looped = true
	animation:Play()
end

function Mobs.Damage(mobObject, previousHealth, damage)
	local mobData = Mobs.Collection[mobObject.Id]
	if not mobData or not mobData.Object or not mobData.Animations then return end 

	local mobModel = mobData.Object
	local animations = mobData.Animations
	local mobPrimary = mobModel.PrimaryPart
	guiModule.AddNotification(
		true, 
		string.format("Hit target: %s HP", tostring(damage)), 
			"Damage"
		)
	funcLib.TweenModel(mobModel, "Color", Color3.new(1, 0.435294, 0.443137), 0.15, true, false)
	guiModule.UpdateNameplate(mobPrimary.Nameplate, previousHealth-damage, mobObject.MaxHealth)
end

function Mobs.MoveTo(data)
	local mobData = Mobs.Collection[data.Id]
	if not mobData or not mobData.Object or not mobData.Animations then return end 
	local mobModel = mobData.Object
	local animations = mobData.Animations
	
	local walkAnimation: AnimationTrack = animations.Walk
	
	local walkAnimation = animations.Walk
	walkAnimation.Looped = true
	
	local distance = (mobModel:GetPivot().Position - data.Position).Magnitude
	local secondsTravel = distance / 16 
	
	coroutine.wrap(function()	
		walkAnimation:Play()
		mobModel.Humanoid:MoveTo(data.Position)
		task.wait(secondsTravel)
		walkAnimation:Stop()
		
		mobModel:SetPrimaryPartCFrame(CFrame.lookAt(
			mobModel.PrimaryPart.Position,
			data.Position * Vector3.new(1, 0, 1)
				+ mobModel.PrimaryPart.Position * Vector3.new(0, 1, 0)
		))
		
		local rand = Random.new()
		if mobData["IsDead"] then return end
		
		if data.AttackType == "FireBreath" then
			local fireBreathAnimation:AnimationTrack = animations.FireBreath
			fireBreathAnimation.Looped = false
			fireBreathAnimation:Play()
			dragonEffects.Roar:Play()
			
			local mouth = mobModel.Mouth
			coroutine.wrap(function()
				task.wait(0.3)				
				for i = 1, 2 do
					mouth.Light.Enabled = not mouth.Light.Enabled
					mouth.Flame.Enabled = not mouth.Flame.Enabled
					mouth.Smoke.Enabled = not mouth.Smoke.Enabled
					task.wait(0.7)
				end
			end)()
			
		elseif data.AttackType == "WingBeat" then
			local wingBeatAnimation: AnimationTrack = animations.WingBeat
			wingBeatAnimation.Looped = false
			wingBeatAnimation:Play()
			
			coroutine.wrap(function()
				task.wait(1)
				dragonEffects.Bite:Play()
			end)()
		end
	end)()	
end

function Mobs.GetMobData(identifier)
	local mob = Mobs.Collection[identifier]
	return mob
end

--Identifier = self.Identifier,
-- Loot = self:GetLoot()
function Mobs.Kill(id, loot)
	local mobData = Mobs.Collection[id]
	if not mobData or not mobData.Object or not mobData.Animations then return end 
	
	local mobModel = mobData.Object
	local animations = mobData.Animations
	local mobPosition = mobModel:GetPivot().Position
	
	-- stop any movement
	mobModel.Humanoid:MoveTo(mobPosition)
	mobData["IsDead"] = true
	dragonEffects.Dying:Play()
	mobData.Animations.Death:Play() task.wait(1.4)
	
	-- dispose
	animations.Death:AdjustSpeed(0)
	mobModel.PrimaryPart.Anchored = true
	
	-- tween
	funcLib.TweenModel(mobModel, "Transparency", 1, 2, false, false)
	drops.Spawn(mobPosition, loot) task.wait(2)
	
	if preLoading.Unload(mobModel) then
		Mobs.Collection[id] = nil
	end
end

function Mobs.DisposeAll()
	for id, mob in pairs(Mobs.Collection) do
		mob.Object.PrimaryPart.Anchored = true
		if preLoading.Unload(mob.Object) then
			print("Unloaded:", id)
			Mobs.Collection[id] = nil
		end
	end
end


return Mobs

local collisionGroup = game:GetService("PhysicsService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local modules = replicatedStorage.Modules
local sharedModules = modules.Shared


local plr = players.LocalPlayer
local config = require(sharedModules.Configuration)
local guiModule = require(modules.GUI)
local Player = {}
Player.Holding = false

Player.Data = {
	MaxHealth = 100,
	CurrentHealth = 100
}

function Player.Attack()
	if not Player.Holding then return end
	replicatedStorage.Remote.Combat.Server.RequestAttack:FireServer()
end

function Player.UnequipWeapon(character)
	local equippedSword = character:FindFirstChild("EquippedSword")
	if equippedSword then
		equippedSword:Destroy()
	end
end

function Player.EquipWeapon(swordObject)
	local character = plr.Character or plr.CharacterAdded:Wait()
	Player.UnequipWeapon(character)

	-- data
	local swordData = config.Weapon[swordObject.ModelId]
	local drops = replicatedStorage.Assets.Drops
	local weaponFolder = drops[swordData.Name]

	-- set up sword
	local sword: Model = weaponFolder.Model:Clone()
	sword.Parent = character
	sword.Name = "EquippedSword"
	sword:SetPrimaryPartCFrame(character:WaitForChild("RightHand").CFrame * CFrame.new(0, 0, -2) 
		* CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0)))

	local primaryPart = sword.PrimaryPart
	
	primaryPart.AlignOrientation.Enabled = false
	primaryPart.AlignPosition.Enabled = false
	primaryPart.AngularVelocity.Enabled = false
	
	--funcLib.SetCollisionGroup(character, "Players")
	local handWeld = Instance.new("ManualWeld")
	handWeld.Part0 = primaryPart
	handWeld.part1 = character:WaitForChild("RightHand")

	handWeld.C0 = handWeld.Part0.CFrame:ToObjectSpace(handWeld.part1.CFrame)
	handWeld.Parent = handWeld.Part0
	primaryPart.Anchored = false
	
	guiModule.AddNotification(
		false, 
		string.format("%s (%s)", swordData.Name, tostring(swordObject.BaseDamage)), 
		"Equipped"
	)
end

return Player
